class StudentModel {
  String id;
  String languagePreference;
  String learningPace; // 'slow', 'medium', 'fast'
  Map<String, int> subjectStrengths;
  Map<String, int> commonMistakes;

  StudentModel({
    required this.id,
    this.languagePreference = 'kn',
    this.learningPace = 'medium',
    this.subjectStrengths = const {},
    this.commonMistakes = const {},
  });
}
