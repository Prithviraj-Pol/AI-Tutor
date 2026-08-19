class StudentModel {
  String id;
  String languagePreference;
  String learningPace;
  String explanationStyle;
  List<String> weakSubjects;
  List<String> learningGoals;
  
  bool voiceAnswers;
  bool stepByStep;
  bool showSources;
  bool autoPlayVoice;
  bool useKannadaResponses;
  bool saveChatHistory;

  StudentModel({
    required this.id,
    this.languagePreference = 'Kannada',
    this.learningPace = 'Medium',
    this.explanationStyle = 'Detailed Step-by-Step',
    this.weakSubjects = const [],
    this.learningGoals = const [],
    this.voiceAnswers = true,
    this.stepByStep = true,
    this.showSources = false,
    this.autoPlayVoice = false,
    this.useKannadaResponses = true,
    this.saveChatHistory = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'languagePreference': languagePreference,
      'learningPace': learningPace,
      'explanationStyle': explanationStyle,
      'weakSubjects': weakSubjects,
      'learningGoals': learningGoals,
      'voiceAnswers': voiceAnswers,
      'stepByStep': stepByStep,
      'showSources': showSources,
      'autoPlayVoice': autoPlayVoice,
      'useKannadaResponses': useKannadaResponses,
      'saveChatHistory': saveChatHistory,
    };
  }

  factory StudentModel.fromJson(Map<String, dynamic> json) {
    return StudentModel(
      id: json['id'] as String? ?? 'student_001',
      languagePreference: json['languagePreference'] as String? ?? 'Kannada',
      learningPace: json['learningPace'] as String? ?? 'Medium',
      explanationStyle: json['explanationStyle'] as String? ?? 'Detailed Step-by-Step',
      weakSubjects: (json['weakSubjects'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
      learningGoals: (json['learningGoals'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
      voiceAnswers: json['voiceAnswers'] as bool? ?? true,
      stepByStep: json['stepByStep'] as bool? ?? true,
      showSources: json['showSources'] as bool? ?? false,
      autoPlayVoice: json['autoPlayVoice'] as bool? ?? false,
      useKannadaResponses: json['useKannadaResponses'] as bool? ?? true,
      saveChatHistory: json['saveChatHistory'] as bool? ?? true,
    );
  }
}
