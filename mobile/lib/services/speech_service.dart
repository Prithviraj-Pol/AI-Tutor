class SpeechService {
  static final SpeechService _instance = SpeechService._internal();
  factory SpeechService() => _instance;
  SpeechService._internal();

  bool isListening = false;

  Future<String> startListening() async {
    // Mock implementation for MVP
    isListening = true;
    await Future.delayed(const Duration(seconds: 2));
    isListening = false;
    return "How do I factorize a perfect square trinomial?";
  }
}
