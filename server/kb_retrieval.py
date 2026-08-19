import faiss
import numpy as np
from sentence_transformers import SentenceTransformer

class KnowledgeBase:
    def __init__(self, embedding_model='all-MiniLM-L6-v2', embedding_dim=384):
        # Lightweight embedding model (33M params)
        self.embedder = SentenceTransformer(embedding_model)

        # FAISS index for fast retrieval
        self.index = faiss.IndexFlatL2(embedding_dim) # 384-dim embeddings by default
        self.metadata = [] # Store original content
        
    def index_content(self, documents):
        """Embed and index curriculum documents"""
        if not documents:
            return
        
        # Convert to numpy array for FAISS
        embeddings = self.embedder.encode(documents, convert_to_numpy=True)
        self.index.add(embeddings)
        self.metadata.extend(documents)

    def retrieve_relevant(self, query, k=5):
        """Retrieve top-k similar content"""
        if self.index.ntotal == 0:
            return []
            
        # Ensure k is not larger than total documents
        k = min(k, self.index.ntotal)
        
        query_embedding = self.embedder.encode(query, convert_to_numpy=True)
        # Reshape to 2D array as required by FAISS
        query_embedding = np.array([query_embedding])
        
        distances, indices = self.index.search(query_embedding, k=k)

        results = []
        for i, idx in enumerate(indices[0]):
            if idx < len(self.metadata):
                results.append({
                    'content': self.metadata[idx],
                    'relevance_score': float(1 - distances[0][i]) # Convert distance to score
                })

        return results

# Basic test if run directly
if __name__ == "__main__":
    kb = KnowledgeBase()
    docs = [
        "A perfect square trinomial of form a²x² + 2abx + b² can be factorized as (ax + b)²",
        "Newton's second law of motion states F = ma",
        "The mitochondria is the powerhouse of the cell"
    ]
    kb.index_content(docs)
    print(kb.retrieve_relevant("How to factorize a polynomial?", k=1))
