from transformers import pipeline

class IVTEngine:
    def __init__(self, model_name="distilbert-base-cased-distilled-squad"):
        """Initialize the lightweight QA pipeline"""
        self.qa_pipeline = pipeline("question-answering", model=model_name)

    def generate_step_by_step_answer(self, question, context, language='kn'):
        """Generate structured answer based on retrieved context"""
        
        # In a real scenario with a generative LLM (like Mistral), we would use prompt engineering.
        # Since we are using an extractive QA model (DistilBERT) for low bandwidth, 
        # it extracts the best span from the context.
        
        # We wrap the output to match our structured format.
        try:
            response = self.qa_pipeline(question=question, context=context)
            extracted_answer = response.get('answer', 'Sorry, I could not find an answer in the context.')
            
            # Format output (simulating the generation of a structured response)
            formatted_response = f"""CONCEPT:
Based on the curriculum...

STEP-BY-STEP SOLUTION:
Step 1: Understand the context.
Step 2: Apply the logic.

✓ FINAL ANSWER:
{extracted_answer}

KEY TAKEAWAY:
Keep practicing!"""
            
            return formatted_response
            
        except Exception as e:
            return f"Error generating answer: {str(e)}"
            
    def chunk_response(self, response_text, chunk_size=240):
        """Break down response into chunks for BLE MTU limits"""
        # Ensure we send as bytes or split into valid sized chunks
        encoded = response_text.encode('utf-8')
        chunks = []
        
        for i in range(0, len(encoded), chunk_size):
            chunk = encoded[i:i + chunk_size].decode('utf-8', errors='ignore')
            chunks.append(chunk)
            
        # Add an EOF marker chunk so client knows transmission is complete
        chunks.append("[END]")
        return chunks

# Basic test
if __name__ == "__main__":
    engine = IVTEngine()
    q = "What is the powerhouse of the cell?"
    ctx = "The mitochondria is the powerhouse of the cell."
    ans = engine.generate_step_by_step_answer(q, ctx)
    print(ans)
    print("Chunks:", engine.chunk_response(ans))
