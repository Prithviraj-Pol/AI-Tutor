import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;
import '../models/chat_message.dart';

import 'storage_service.dart';

enum ServerStatus {
  offline,
  online,
  error,
}

class BleService extends ChangeNotifier {
  static final BleService _instance = BleService._internal();
  factory BleService() => _instance;
  BleService._internal();

  ServerStatus status = ServerStatus.offline;
  bool get isConnected => status == ServerStatus.online;
  
  List<ChatMessage> chatHistory = [];
  bool _isGenerating = false;
  final _uuid = const Uuid();
  String _conversationId = const Uuid().v4();

  // Try localhost first (Windows), then emulator host
  final List<String> _possibleUrls = [
    'http://127.0.0.1:5000',
    'http://10.0.2.2:5000'
  ];
  String? _activeUrl;

  void clearHistory() {
    chatHistory.clear();
    _conversationId = const Uuid().v4(); // Reset memory context
    notifyListeners();
  }

  Future<void> scanAndConnect() async {
    status = ServerStatus.offline;
    notifyListeners();

    for (String url in _possibleUrls) {
      try {
        final response = await http.get(Uri.parse('$url/health')).timeout(const Duration(seconds: 2));
        if (response.statusCode == 200) {
          _activeUrl = url;
          status = ServerStatus.online;
          notifyListeners();
          return;
        }
      } catch (e) {
        // Continue to next URL
      }
    }
    
    // If all fail
    status = ServerStatus.error;
    notifyListeners();
  }

  Future<void> sendDoubt(String question) async {
    if (!isConnected || _activeUrl == null) {
      // Try to reconnect once if disconnected
      await scanAndConnect();
      if (!isConnected) {
        throw Exception('AI Tutor Server disconnected. Ensure local server is running.');
      }
    }
    
    if (_isGenerating) return; 
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

    try {
      final profile = await StorageService().getStudentProfile();
      
      final request = http.Request('POST', Uri.parse('$_activeUrl/chat/stream'));
      request.headers['Content-Type'] = 'application/json';
      request.body = jsonEncode({
        "question": question,
        "student_profile": profile.toJson(),
        "conversation_id": _conversationId
      });

      final response = await http.Client().send(request);

      if (response.statusCode != 200) {
        throw Exception('Server returned ${response.statusCode}');
      }

      // We will remove thinking state only when the first real token arrives
      int aiIndex = chatHistory.indexWhere((m) => m.id == aiId);
      bool isFirstToken = true;

      String currentText = "";
      
      await for (var bytes in response.stream) {
        final chunkString = utf8.decode(bytes);
        final lines = chunkString.split('\n');
        
        for (String line in lines) {
          if (line.trim().isEmpty) continue;
          try {
            final data = jsonDecode(line);
            if (data['type'] == 'chat_stream') {
              if (isFirstToken) {
                isFirstToken = false;
                if (aiIndex != -1) {
                  chatHistory[aiIndex] = chatHistory[aiIndex].copyWith(isThinking: false);
                }
              }
              
              currentText += data['token'];
              
              if (aiIndex != -1) {
                chatHistory[aiIndex] = chatHistory[aiIndex].copyWith(text: currentText);
                notifyListeners();
              }
            } else if (data['type'] == 'chat_complete') {
              // Done
            }
          } catch (e) {
            // Ignore malformed JSON chunks from stream boundaries
          }
        }
      }
      
    } catch (e) {
      int aiIndex = chatHistory.indexWhere((m) => m.id == aiId);
      if (aiIndex != -1) {
        chatHistory[aiIndex] = chatHistory[aiIndex].copyWith(
          isThinking: false, 
          text: 'Error connecting to IVT Brain: $e'
        );
        notifyListeners();
      }
      status = ServerStatus.error;
      notifyListeners();
    } finally {
      _isGenerating = false;
    }
  }
}
