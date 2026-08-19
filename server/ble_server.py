import asyncio
import json
import logging
# Note: Bleak is primarily for BLE Clients. For BLE Servers in Python, 
# you typically use a library like 'bless' (Bluetooth Low Energy Server Setup)
# or interact directly with BlueZ (Linux). This script serves as the structural 
# implementation of the BLE server logic described in the IVT architecture.
from kb_retrieval import KnowledgeBase
from llm_engine import IVTEngine

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger("BLE_SERVER")

# Define our GATT UUIDs
SERVICE_UUID = "550e8400-e29b-41d4-a716-446655440000"
CHAR_INPUT_UUID = "550e8400-e29b-41d4-a716-446655440001"
CHAR_OUTPUT_UUID = "550e8400-e29b-41d4-a716-446655440002"

class IVTBluetoothServer:
    def __init__(self):
        logger.info("Initializing Knowledge Base...")
        self.kb = KnowledgeBase()
        # Pre-seed with some data for the MVP
        self.kb.index_content([
            "9x² + 12x + 4 is a perfect square trinomial equal to (3x + 2)²",
            "Photosynthesis is the process used by plants to convert light energy into chemical energy.",
            "Water boils at 100 degrees Celsius at standard atmospheric pressure."
        ])
        
        logger.info("Initializing NLP Engine...")
        self.llm = IVTEngine()
        
        self.response_queue = asyncio.Queue()

    async def handle_incoming_request(self, data_bytes):
        """Callback for when student sends a doubt via Characteristic 1 (INPUT_HANDLER)"""
        try:
            payload = json.loads(data_bytes.decode('utf-8'))
            question = payload.get('question', '')
            subject = payload.get('subject', 'General')
            language = payload.get('language', 'kn')

            logger.info(f"Received question: {question} (Subject: {subject})")

            # 1. KB Retrieval
            relevant_docs = self.kb.retrieve_relevant(question, k=3)
            context = " ".join([doc['content'] for doc in relevant_docs])
            
            logger.info(f"Retrieved Context: {context}")

            # 2. LLM Generation
            response_text = self.llm.generate_step_by_step_answer(question, context, language)
            
            # 3. Chunking for BLE MTU
            chunks = self.llm.chunk_response(response_text)
            
            # Queue chunks to be sent via Output Characteristic
            for chunk in chunks:
                await self.response_queue.put(chunk)
                
        except Exception as e:
            logger.error(f"Error handling request: {e}")
            await self.response_queue.put(f"Error processing request.[END]")

    async def broadcast_responses(self):
        """Simulates sending queued chunks to the client over Characteristic 2"""
        while True:
            chunk = await self.response_queue.get()
            # In a real BLE server implementation (e.g. using bless), 
            # you would update the characteristic value and send a Notification here.
            logger.info(f"[BLE TX CHUNK] -> {chunk}")
            await asyncio.sleep(0.1) # Simulate transmission delay

async def main():
    server = IVTBluetoothServer()
    logger.info("IVT Bluetooth Server Initialized.")
    
    # Start the broadcast loop in the background
    asyncio.create_task(server.broadcast_responses())
    
    # Simulate a request coming in from a mobile client
    sample_request = json.dumps({
        "question": "How do you factorize 9x² + 12x + 4?",
        "subject": "Mathematics",
        "language": "en"
    }).encode('utf-8')
    
    logger.info("Simulating incoming BLE request from mobile client...")
    await server.handle_incoming_request(sample_request)
    
    # Keep running to process queue
    await asyncio.sleep(2)
    logger.info("Simulation complete.")

if __name__ == "__main__":
    asyncio.run(main())
