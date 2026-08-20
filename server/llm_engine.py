import yaml
import logging
from openai import OpenAI
import os

logger = logging.getLogger("IVTEngine")
logging.basicConfig(level=logging.INFO)

class IVTEngine:
    def __init__(self, config_path="config.yaml"):
        """Initialize the local LLM engine connecting to Llamafile"""
        self._load_config(config_path)
        
        # Connect to local Llamafile API (OpenAI compatible)
        self.client = OpenAI(
            base_url=self.base_url,
            api_key="sk-no-key-required"
        )
        
        # Conversation Memory: { "conversation_id": [ {"role": "...", "content": "..."} ] }
        self.memory = {}
        
    def _load_config(self, config_path):
        self.base_url = "http://127.0.0.1:8080/v1"
        self.temperature = 0.4
        self.max_tokens = 1024
        self.model_name = "qwen"
        
        if os.path.exists(config_path):
            with open(config_path, 'r') as f:
                config = yaml.safe_load(f)
                llm_config = config.get('llm', {})
                self.base_url = llm_config.get('base_url', self.base_url)
                self.temperature = llm_config.get('temperature', self.temperature)
                self.max_tokens = llm_config.get('max_tokens', self.max_tokens)
                self.model_name = llm_config.get('model_path', self.model_name)
                
    def _build_system_prompt(self, profile: dict) -> str:
        """Construct the personalized system prompt dynamically"""
        lang = profile.get('languagePreference', 'English')
        pace = profile.get('learningPace', 'Medium')
        style = profile.get('explanationStyle', 'Detailed Step-by-Step')
        weak_subjects = ", ".join(profile.get('weakSubjects', []))
        goals = ", ".join(profile.get('learningGoals', []))
        class_level = profile.get('classLevel', 'General')
        
        prompt = f"""You are IVT AI Tutor, an expert educational tutor.

The student's selected language is: {lang}.
CRITICAL RULE: You MUST answer entirely in {lang}. Do NOT answer in English, except for technical terms, programming code, or math formulas.

Student Profile:
- Pace: {pace}
- Style: {style}
- Class Level: {class_level}

RULES:
1. Speak naturally and fluently in {lang}. Do not use awkward machine translations.
2. Explain concepts simply and accurately, tailored to the student's level.
3. Keep technical terms (like 'computer', 'programming', 'AI'), code, and formulas in their original format.
4. Answer directly. You may show your reasoning steps.
"""
        return prompt

    def generate_stream(self, question: str, context: str, profile: dict, conversation_id: str):
        """Stream a response from the local LLM using requests"""
        import requests
        import json
        
        # 1. Initialize memory for this conversation if not exists
        if conversation_id not in self.memory:
            system_prompt = self._build_system_prompt(profile)
            self.memory[conversation_id] = [
                {"role": "system", "content": system_prompt}
            ]
            
        # 2. Add current context and question
        user_content = question
        if context and context.strip():
            user_content = f"Context from curriculum:\n{context}\n\nQuestion:\n{question}"
            
        self.memory[conversation_id].append({"role": "user", "content": user_content})
        
        # 3. Trim memory to prevent context overflow (keep system prompt + last 6 messages)
        if len(self.memory[conversation_id]) > 7:
            self.memory[conversation_id] = [self.memory[conversation_id][0]] + self.memory[conversation_id][-6:]

        # 4. Stream from Llamafile manually via requests
        try:
            payload = {
                "model": self.model_name,
                "messages": self.memory[conversation_id],
                "temperature": self.temperature,
                "max_tokens": self.max_tokens,
                "stream": True
            }
            
            response = requests.post(f"{self.base_url}/chat/completions", json=payload, stream=True)
            if response.status_code != 200:
                logger.error(f"Llamafile error response: {response.text}")
            response.raise_for_status()
            
            full_answer = ""
            reasoning_answer = ""
            for line in response.iter_lines():
                if line:
                    decoded_line = line.decode('utf-8')
                    if decoded_line.startswith('data: '):
                        data_str = decoded_line[6:]
                        if data_str.strip() == '[DONE]':
                            break
                        try:
                            data = json.loads(data_str)
                            if 'choices' in data and len(data['choices']) > 0:
                                delta = data['choices'][0].get('delta', {})
                                
                                # Handle reasoning content (e.g. from qwen3-thinking models)
                                if 'reasoning_content' in delta and delta['reasoning_content']:
                                    token = delta['reasoning_content']
                                    reasoning_answer += token
                                    # Yield the reasoning token so the user sees the thinking in real-time
                                    yield token
                                    
                                # Handle standard content
                                if 'content' in delta and delta['content']:
                                    token = delta['content']
                                    full_answer += token
                                    yield token
                        except json.JSONDecodeError:
                            continue
                    elif decoded_line.startswith('{'):
                        try:
                            err_data = json.loads(decoded_line)
                            if 'error' in err_data:
                                error_msg = err_data['error'].get('message', str(err_data['error']))
                                yield f"\n[Llamafile Error: {error_msg}]"
                        except:
                            continue
                            
            # 5. Append AI's response to memory
            self.memory[conversation_id].append({"role": "assistant", "content": full_answer})
            
        except Exception as e:
            logger.error(f"Error during LLM generation: {e}")
            yield f"\n[Error communicating with AI Brain: {str(e)}]"
