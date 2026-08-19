class KBModel {
  final String questionId;
  final String question;
  final String cachedAnswer;
  final DateTime timestamp;

  KBModel({
    required this.questionId,
    required this.question,
    required this.cachedAnswer,
    required this.timestamp,
  });
}
