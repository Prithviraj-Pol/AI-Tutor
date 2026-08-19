import os
from llm_engine import IVTEngine

def test_engine():
    engine = IVTEngine()
    
    profile = {
        "languagePreference": "Kannada",
        "learningPace": "Medium",
        "explanationStyle": "Detailed Step-by-Step",
        "weakSubjects": ["Mathematics"],
        "learningGoals": ["Understand basic concepts"]
    }
    
    question = "What is CaCO3?"
    context = "CaCO3 is Calcium Carbonate. It is found in chalk and limestone."
    
    print("Sending question:", question)
    print("Profile language:", profile["languagePreference"])
    print("-" * 50)
    print("Response Stream:")
    
    try:
        for token in engine.generate_stream(question, context, profile, "test_conv_1"):
            print(token, end="", flush=True)
        print("\n" + "-" * 50)
        print("Test complete.")
    except Exception as e:
        print(f"\nFailed to connect to Llamafile. Is it running on port 8080? Error: {e}")

if __name__ == "__main__":
    test_engine()
