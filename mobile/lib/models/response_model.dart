class ResponseModel {
  final String rawText;
  final String concept;
  final List<String> steps;
  final String finalAnswer;
  final String keyTakeaway;

  ResponseModel({
    required this.rawText,
    this.concept = '',
    this.steps = const [],
    this.finalAnswer = '',
    this.keyTakeaway = '',
  });

  factory ResponseModel.fromRawText(String text) {
    return ResponseModel(
      rawText: text,
      concept: _extractSection(text, 'CONCEPT:', 'STEP-BY-STEP SOLUTION:'),
      finalAnswer: _extractSection(text, '✓ FINAL ANSWER:', 'KEY TAKEAWAY:'),
      keyTakeaway: _extractSection(text, 'KEY TAKEAWAY:', '[END]'),
    );
  }

  static String _extractSection(String text, String start, String end) {
    int startIndex = text.indexOf(start);
    if (startIndex == -1) return '';
    startIndex += start.length;
    
    int endIndex = text.indexOf(end, startIndex);
    if (endIndex == -1) endIndex = text.length;
    
    return text.substring(startIndex, endIndex).trim();
  }
}
