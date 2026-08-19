import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/student_model.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  static const String _studentKey = 'student_profile';

  Future<void> saveStudentProfile(StudentModel student) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = jsonEncode(student.toJson());
    await prefs.setString(_studentKey, jsonStr);
  }

  Future<StudentModel> getStudentProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_studentKey);
    if (jsonStr != null) {
      try {
        final map = jsonDecode(jsonStr) as Map<String, dynamic>;
        return StudentModel.fromJson(map);
      } catch (e) {
        // Fallback
      }
    }
    return StudentModel(id: 'student_001');
  }
}
