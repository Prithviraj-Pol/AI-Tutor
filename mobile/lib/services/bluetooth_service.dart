import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/chat_message.dart';

import 'storage_service.dart';

class BleService extends ChangeNotifier {
  static final BleService _instance = BleService._internal();
  factory BleService() => _instance;
  BleService._internal();

  bool isConnected = false;
  
  List<ChatMessage> chatHistory = [];
  bool _isGenerating = false;
  final _uuid = const Uuid();

  void clearHistory() {
    chatHistory.clear();
    notifyListeners();
  }

  Future<void> scanAndConnect() async {
    // Simulate scanning and connecting delay
    await Future.delayed(const Duration(seconds: 1));
    isConnected = true;
    notifyListeners();
  }

  Future<void> sendDoubt(String question) async {
    if (!isConnected) {
      throw Exception('Not connected to server');
    }
    
    if (_isGenerating) return; // Prevent multiple clicks
    _isGenerating = true;

    // Add User message
    final userMsg = ChatMessage(
      id: _uuid.v4(),
      text: question,
      role: ChatRole.user,
      timestamp: DateTime.now(),
    );
    chatHistory.add(userMsg);
    notifyListeners();

    // Add AI "thinking" message
    final aiId = _uuid.v4();
    chatHistory.add(ChatMessage(
      id: aiId,
      text: '',
      role: ChatRole.ai,
      timestamp: DateTime.now(),
      isThinking: true,
    ));
    notifyListeners();

    // Simulate processing delay
    await Future.delayed(const Duration(seconds: 2));

    // Remove thinking state
    int aiIndex = chatHistory.indexWhere((m) => m.id == aiId);
    if (aiIndex != -1) {
      chatHistory[aiIndex] = chatHistory[aiIndex].copyWith(isThinking: false);
      notifyListeners();
    }

    // Prepare simulated response based on profile (fake logic)
    final profile = await StorageService().getStudentProfile();
    String simulatedResponse = "Sure! Let's solve this step by step.\n\n";
    if (profile.languagePreference.startsWith('Kannada')) {
      simulatedResponse += "**ಹಂತ 1: ಸೂತ್ರವನ್ನು ಅನ್ವಯಿಸಿ (Step 1: Apply formula)**\n";
      simulatedResponse += "CaCO₃ ಅನ್ನು ಕ್ಯಾಲ್ಸಿಯಂ ಕಾರ್ಬೋನೇಟ್ ಎಂದು ಕರೆಯಲಾಗುತ್ತದೆ...\n\n";
    } else {
      simulatedResponse += "**Step 1: Identify the formula**\n";
      simulatedResponse += "CaCO₃ is calcium carbonate...\n\n";
    }
    
    simulatedResponse += "**Answer:**\nIt is commonly found in Limestone, Marble, and Chalk.";

    // Stream the response
    String currentText = "";
    for (int i = 0; i < simulatedResponse.length; i += 3) {
      int end = i + 3;
      if (end > simulatedResponse.length) end = simulatedResponse.length;
      currentText += simulatedResponse.substring(i, end);
      
      aiIndex = chatHistory.indexWhere((m) => m.id == aiId);
      if (aiIndex != -1) {
        chatHistory[aiIndex] = chatHistory[aiIndex].copyWith(text: currentText);
        notifyListeners();
      }
      
      await Future.delayed(const Duration(milliseconds: 50));
    }
    
    _isGenerating = false;
  }
}
