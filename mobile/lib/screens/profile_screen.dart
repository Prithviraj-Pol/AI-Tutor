import 'package:flutter/material.dart';
import '../widgets/ivt_card.dart';
import '../widgets/ivt_button.dart';
import '../services/storage_service.dart';
import '../models/student_model.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final StorageService _storage = StorageService();
  StudentModel? _student;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final student = await _storage.getStudentProfile();
    setState(() {
      _student = student;
      _isLoading = false;
    });
  }

  Future<void> _saveProfile() async {
    if (_student != null) {
      await _storage.saveStudentProfile(_student!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated', style: TextStyle(color: Colors.white)), backgroundColor: Color(0xFF22A06B), duration: Duration(seconds: 2)),
        );
        setState(() {}); // Re-render
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _student == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Profile'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildProfileCard(),
            const SizedBox(height: 32),
            _buildLanguageSection(),
            const SizedBox(height: 16),
            _buildPaceSection(),
            const SizedBox(height: 16),
            _buildWeakSubjectsSection(),
            const SizedBox(height: 16),
            _buildGoalsSection(),
            const SizedBox(height: 16),
            _buildPreferencesSection(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCard() {
    return IvtCard(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 36,
            backgroundColor: Color(0xFFF7F9FC),
            child: Icon(Icons.person, size: 40, color: Color(0xFF243B6B)),
          ),
          const SizedBox(width: 24),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Student', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF243B6B))),
              const SizedBox(height: 4),
              Text('Class 10', style: TextStyle(fontSize: 14, color: Colors.grey[600])),
              Text('${_student!.languagePreference} Learner', style: TextStyle(fontSize: 14, color: Colors.grey[600])),
            ],
          )
        ],
      ),
    );
  }

  // --- LANGUAGE ---
  Widget _buildLanguageSection() {
    return _buildSection(
      'LANGUAGE PREFERENCE',
      Icons.language,
      _student!.languagePreference,
      _editLanguage,
    );
  }

  void _editLanguage() {
    String tempLang = _student!.languagePreference;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(builder: (context, setModalState) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Select Language', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                ],
              ),
              const SizedBox(height: 16),
              // ignore: deprecated_member_use
              RadioGroup<String>(
                groupValue: tempLang,
                onChanged: (val) => setModalState(() => tempLang = val!),
                child: Column(
                  children: ['ಕನ್ನಡ (Kannada)', 'English', 'हिन्दी (Hindi)'].map((lang) {
                    // ignore: deprecated_member_use
                    return RadioListTile<String>(
                      title: Text(lang),
                      value: lang.split(' ')[0],
                      groupValue: tempLang,
                      onChanged: (val) => setModalState(() => tempLang = val!),
                      activeColor: const Color(0xFFFF6B5A),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: IvtPrimaryButton(
                  label: 'Save',
                  onPressed: () {
                    _student!.languagePreference = tempLang;
                    _saveProfile();
                    Navigator.pop(context);
                  },
                ),
              )
            ],
          ),
        );
      }),
    );
  }

  // --- PACE ---
  Widget _buildPaceSection() {
    return _buildSection(
      'LEARNING PACE & STYLE',
      Icons.speed,
      '${_student!.learningPace}\n${_student!.explanationStyle}',
      _editPace,
    );
  }

  void _editPace() {
    String tempPace = _student!.learningPace;
    String tempStyle = _student!.explanationStyle;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(builder: (context, setModalState) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Pace & Style', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                ],
              ),
              const SizedBox(height: 16),
              const Text('Learning Pace', style: TextStyle(fontWeight: FontWeight.bold)),
              // ignore: deprecated_member_use
              RadioGroup<String>(
                groupValue: tempPace,
                onChanged: (val) => setModalState(() => tempPace = val!),
                child: Column(
                  children: ['Slow', 'Medium', 'Fast'].map((pace) {
                    // ignore: deprecated_member_use
                    return RadioListTile<String>(
                      title: Text(pace),
                      value: pace,
                      groupValue: tempPace,
                      onChanged: (val) => setModalState(() => tempPace = val!),
                      activeColor: const Color(0xFFFF6B5A),
                    );
                  }).toList(),
                ),
              ),
              const Divider(),
              const Text('Explanation Style', style: TextStyle(fontWeight: FontWeight.bold)),
              // ignore: deprecated_member_use
              RadioGroup<String>(
                groupValue: tempStyle,
                onChanged: (val) => setModalState(() => tempStyle = val!),
                child: Column(
                  children: ['Quick Answer', 'Balanced', 'Detailed Step-by-Step', 'Concept First'].map((style) {
                    // ignore: deprecated_member_use
                    return RadioListTile<String>(
                      title: Text(style),
                      value: style,
                      groupValue: tempStyle,
                      onChanged: (val) => setModalState(() => tempStyle = val!),
                      activeColor: const Color(0xFFFF6B5A),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: IvtPrimaryButton(
                  label: 'Save',
                  onPressed: () {
                    _student!.learningPace = tempPace;
                    _student!.explanationStyle = tempStyle;
                    _saveProfile();
                    Navigator.pop(context);
                  },
                ),
              )
            ],
          ),
        );
      }),
    );
  }

  // --- WEAK SUBJECTS ---
  Widget _buildWeakSubjectsSection() {
    return _buildSectionList(
      'WEAK SUBJECTS',
      Icons.bar_chart,
      _student!.weakSubjects.isEmpty ? ['None selected'] : _student!.weakSubjects,
      _editWeakSubjects,
    );
  }

  void _editWeakSubjects() {
    List<String> tempSubjects = List.from(_student!.weakSubjects);
    final options = ['Mathematics', 'Science', 'Social Science', 'English', 'Kannada', 'Algebra', 'Trigonometry', 'Geometry', 'Statistics'];
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(builder: (context, setModalState) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.6,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Weak Subjects', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                  ],
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView(
                    children: options.map((s) {
                      return CheckboxListTile(
                        title: Text(s),
                        value: tempSubjects.contains(s),
                        activeColor: const Color(0xFFFF6B5A),
                        onChanged: (val) {
                          setModalState(() {
                            if (val == true) {
                              tempSubjects.add(s);
                            } else {
                              tempSubjects.remove(s);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: IvtPrimaryButton(
                    label: 'Save',
                    onPressed: () {
                      _student!.weakSubjects = tempSubjects;
                      _saveProfile();
                      Navigator.pop(context);
                    },
                  ),
                )
              ],
            ),
          ),
        );
      }),
    );
  }

  // --- GOALS ---
  Widget _buildGoalsSection() {
    return _buildSectionList(
      'LEARNING GOALS',
      Icons.flag,
      _student!.learningGoals.isEmpty ? ['None selected'] : _student!.learningGoals,
      _editGoals,
    );
  }

  void _editGoals() {
    List<String> tempGoals = List.from(_student!.learningGoals);
    final options = ['Improve Mathematics', 'Improve Science', 'Board Exam Preparation', 'Daily Practice', 'Concept Understanding', 'Improve Problem Solving', 'Improve Kannada Learning'];
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(builder: (context, setModalState) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.6,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Learning Goals', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                  ],
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView(
                    children: options.map((s) {
                      return CheckboxListTile(
                        title: Text(s),
                        value: tempGoals.contains(s),
                        activeColor: const Color(0xFFFF6B5A),
                        onChanged: (val) {
                          setModalState(() {
                            if (val == true) {
                              tempGoals.add(s);
                            } else {
                              tempGoals.remove(s);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: IvtPrimaryButton(
                    label: 'Save',
                    onPressed: () {
                      _student!.learningGoals = tempGoals;
                      _saveProfile();
                      Navigator.pop(context);
                    },
                  ),
                )
              ],
            ),
          ),
        );
      }),
    );
  }

  // --- PREFERENCES ---
  Widget _buildPreferencesSection() {
    List<String> prefs = [];
    if (_student!.voiceAnswers) prefs.add('Voice Answers');
    if (_student!.stepByStep) prefs.add('Step-by-Step Explanations');
    if (_student!.showSources) prefs.add('Show AI Sources');
    if (_student!.autoPlayVoice) prefs.add('Auto Play Voice');
    if (_student!.useKannadaResponses) prefs.add('Use Kannada Responses');
    if (_student!.saveChatHistory) prefs.add('Save Chat History');

    return _buildSectionList(
      'PREFERENCES',
      Icons.settings,
      prefs.isEmpty ? ['None selected'] : prefs,
      _editPreferences,
    );
  }

  void _editPreferences() {
    bool tempVoice = _student!.voiceAnswers;
    bool tempStep = _student!.stepByStep;
    bool tempSources = _student!.showSources;
    bool tempAuto = _student!.autoPlayVoice;
    bool tempKannada = _student!.useKannadaResponses;
    bool tempHistory = _student!.saveChatHistory;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(builder: (context, setModalState) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.7,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Preferences', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                  ],
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView(
                    children: [
                      SwitchListTile(title: const Text('Voice Answers'), value: tempVoice, activeThumbColor: const Color(0xFFFF6B5A), onChanged: (v) => setModalState(() => tempVoice = v)),
                      SwitchListTile(title: const Text('Step-by-Step Explanations'), value: tempStep, activeThumbColor: const Color(0xFFFF6B5A), onChanged: (v) => setModalState(() => tempStep = v)),
                      SwitchListTile(title: const Text('Show AI Sources'), value: tempSources, activeThumbColor: const Color(0xFFFF6B5A), onChanged: (v) => setModalState(() => tempSources = v)),
                      SwitchListTile(title: const Text('Auto Play Voice'), value: tempAuto, activeThumbColor: const Color(0xFFFF6B5A), onChanged: (v) => setModalState(() => tempAuto = v)),
                      SwitchListTile(title: const Text('Use Kannada Responses'), value: tempKannada, activeThumbColor: const Color(0xFFFF6B5A), onChanged: (v) => setModalState(() => tempKannada = v)),
                      SwitchListTile(title: const Text('Save Chat History'), value: tempHistory, activeThumbColor: const Color(0xFFFF6B5A), onChanged: (v) => setModalState(() => tempHistory = v)),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: IvtPrimaryButton(
                    label: 'Save',
                    onPressed: () {
                      _student!.voiceAnswers = tempVoice;
                      _student!.stepByStep = tempStep;
                      _student!.showSources = tempSources;
                      _student!.autoPlayVoice = tempAuto;
                      _student!.useKannadaResponses = tempKannada;
                      _student!.saveChatHistory = tempHistory;
                      _saveProfile();
                      Navigator.pop(context);
                    },
                  ),
                )
              ],
            ),
          ),
        );
      }),
    );
  }

  // --- HELPERS ---
  Widget _buildSection(String title, IconData icon, String value, VoidCallback onTap) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
        const SizedBox(height: 8),
        IvtCard(
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: const Color(0xFFF7F9FC), borderRadius: BorderRadius.circular(8)),
              child: Icon(icon, color: const Color(0xFF243B6B)),
            ),
            title: Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
            trailing: const Icon(Icons.edit_outlined, color: Colors.grey),
            onTap: onTap,
          ),
        )
      ],
    );
  }

  Widget _buildSectionList(String title, IconData icon, List<String> items, VoidCallback onTap) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
        const SizedBox(height: 8),
        IvtCard(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            children: [
              ...items.map((item) => ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: const Color(0xFFF7F9FC), borderRadius: BorderRadius.circular(8)),
                  child: Icon(icon, color: const Color(0xFF243B6B)),
                ),
                title: Text(item, style: const TextStyle(fontWeight: FontWeight.w500)),
                trailing: const Icon(Icons.edit_outlined, color: Colors.grey),
                onTap: onTap,
              )),
              if (items.isEmpty)
                ListTile(
                  title: const Text('Tap to edit'),
                  trailing: const Icon(Icons.edit_outlined, color: Colors.grey),
                  onTap: onTap,
                )
            ],
          ),
        )
      ],
    );
  }
}
