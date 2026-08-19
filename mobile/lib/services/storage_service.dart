import '../models/student_model.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  StudentModel? _cachedStudent;

  Future<void> saveStudentProfile(StudentModel student) async {
    // Mock saving to shared_preferences
    _cachedStudent = student;
  }

  Future<StudentModel> getStudentProfile() async {
    // Mock retrieval
    return _cachedStudent ?? StudentModel(id: 'student_001');
  }
}
