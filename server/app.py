from flask import Flask, request, Response, jsonify
import json
import uuid
import logging
from llm_engine import IVTEngine
from kb_retrieval import KnowledgeBase

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger("IVT_Server")

app = Flask(__name__)

# Initialize components
logger.info("Initializing LLM Engine...")
llm = IVTEngine()

logger.info("Initializing Knowledge Base...")
kb = KnowledgeBase()
kb.index_content([
    "9x² + 12x + 4 is a perfect square trinomial equal to (3x + 2)²",
    "Photosynthesis is the process used by plants to convert light energy into chemical energy.",
    "Water boils at 100 degrees Celsius at standard atmospheric pressure.",
    "CaCO₃ is Calcium Carbonate. It is a chemical compound commonly found in rocks as the minerals calcite and aragonite."
])

@app.route('/chat/stream', methods=['POST'])
def chat_stream():
    """Streaming chat endpoint for Flutter client"""
    data = request.json
    if not data:
        return jsonify({"error": "No JSON payload provided"}), 400
        
    question = data.get('question', '')
    student_profile = data.get('student_profile', {})
    conversation_id = data.get('conversation_id', 'default_conv')
    message_id = str(uuid.uuid4())
    
    logger.info(f"Received question from {student_profile.get('languagePreference', 'Unknown')}: {question}")

    # 1. Retrieve Knowledge Base context
    relevant_docs = kb.retrieve_relevant(question, k=2)
    context = " ".join([doc['content'] for doc in relevant_docs])
    logger.info(f"Retrieved Context: {context}")
    
    # 2. Generator for streaming JSON
    def generate():
        try:
            # Stream tokens
            for token in llm.generate_stream(question, context, student_profile, conversation_id):
                chunk = {
                    "type": "chat_stream",
                    "message_id": message_id,
                    "token": token
                }
                yield f"{json.dumps(chunk)}\n"
                
            # Signal completion
            complete_msg = {
                "type": "chat_complete",
                "message_id": message_id
            }
            yield f"{json.dumps(complete_msg)}\n"
            
        except Exception as e:
            logger.error(f"Streaming error: {e}")
            error_msg = {
                "type": "chat_stream",
                "message_id": message_id,
                "token": f"\n[Error: {str(e)}]"
            }
            yield f"{json.dumps(error_msg)}\n"
            complete_msg = {
                "type": "chat_complete",
                "message_id": message_id
            }
            yield f"{json.dumps(complete_msg)}\n"

    # Return as server-sent streaming response (application/x-ndjson or text/event-stream)
    return Response(generate(), mimetype='application/x-ndjson')

@app.route('/health', methods=['GET'])
def health():
    return jsonify({"status": "AI Server Online"})

if __name__ == '__main__':
    logger.info("Starting IVT AI Server on port 5000...")
    app.run(host='0.0.0.0', port=5000, threaded=True)
