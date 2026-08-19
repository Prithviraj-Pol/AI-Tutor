import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter/services.dart';
import '../models/chat_message.dart';
import '../services/bluetooth_service.dart';
import '../services/speech_service.dart';

class InputScreen extends StatefulWidget {
  final String? initialPrompt;
  const InputScreen({super.key, this.initialPrompt});

  @override
  State<InputScreen> createState() => _InputScreenState();
}

class _InputScreenState extends State<InputScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final BleService _bleService = BleService();
  final SpeechService _speechService = SpeechService();
  
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    _bleService.addListener(_onChatUpdated);
    if (widget.initialPrompt != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _sendMessage(widget.initialPrompt!);
      });
    }
  }

  @override
  void dispose() {
    _bleService.removeListener(_onChatUpdated);
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onChatUpdated() {
    setState(() {});
    _scrollToBottom();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 100,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _sendMessage(String text) async {
    if (text.trim().isEmpty) return;
    _controller.clear();
    
    try {
      await _bleService.sendDoubt(text);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  void _startVoiceInput() async {
    setState(() => _isListening = true);
    String voiceText = await _speechService.startListening();
    setState(() {
      _isListening = false;
      if (voiceText.isNotEmpty) {
        _controller.text = voiceText;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('AI Tutor', style: TextStyle(fontWeight: FontWeight.bold)),
            Text('Learn with IVT', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
          ],
        ),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Row(
                children: [
                  Icon(Icons.circle, size: 10, color: _bleService.isConnected ? const Color(0xFF22A06B) : const Color(0xFFD64545)),
                  const SizedBox(width: 6),
                  Text(_bleService.isConnected ? 'Connected' : 'Offline', style: TextStyle(color: Colors.grey[700], fontSize: 12)),
                ],
              ),
            ),
          )
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _bleService.chatHistory.isEmpty ? _buildEmptyState() : _buildChatList(),
          ),
          _buildComposer(),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircleAvatar(
                radius: 40,
                backgroundColor: Color(0xFFE0E7FF),
                child: Icon(Icons.auto_awesome, size: 40, color: Color(0xFF243B6B)),
              ),
              const SizedBox(height: 24),
              const Text('How can I help you learn today?', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF243B6B)), textAlign: TextAlign.center),
              const SizedBox(height: 32),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                children: [
                  _buildSuggestionChip('Explain photosynthesis'),
                  _buildSuggestionChip('Solve an algebra problem'),
                  _buildSuggestionChip('Explain in Kannada'),
                  _buildSuggestionChip('Give me a practice question'),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSuggestionChip(String label) {
    return ActionChip(
      label: Text(label),
      backgroundColor: Colors.white,
      side: const BorderSide(color: Color(0xFFE0E7FF)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      onPressed: () => _sendMessage(label),
    );
  }

  Widget _buildChatList() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: _bleService.chatHistory.length,
      itemBuilder: (context, index) {
        final message = _bleService.chatHistory[index];
        return _buildMessageBubble(message);
      },
    );
  }

  Widget _buildMessageBubble(ChatMessage msg) {
    bool isUser = msg.role == ChatRole.user;

    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              if (!isUser) ...[
                const CircleAvatar(
                  radius: 12,
                  backgroundColor: Color(0xFF243B6B),
                  child: Icon(Icons.auto_awesome, size: 14, color: Colors.white),
                ),
                const SizedBox(width: 8),
                const Text('IVT AI', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey)),
              ],
              if (isUser) ...[
                const Text('User', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey)),
                const SizedBox(width: 8),
                const CircleAvatar(
                  radius: 12,
                  backgroundColor: Color(0xFFE0E7FF),
                  child: Icon(Icons.person, size: 14, color: Color(0xFF243B6B)),
                ),
              ]
            ],
          ),
          const SizedBox(height: 8),
          Container(
            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.85),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isUser ? const Color(0xFF243B6B) : Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(20),
                topRight: const Radius.circular(20),
                bottomLeft: isUser ? const Radius.circular(20) : const Radius.circular(4),
                bottomRight: isUser ? const Radius.circular(4) : const Radius.circular(20),
              ),
              boxShadow: [
                if (!isUser)
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
              ],
            ),
            child: msg.isThinking
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFFF6B5A))),
                      const SizedBox(width: 12),
                      Text('Thinking...', style: TextStyle(color: Colors.grey[600])),
                    ],
                  )
                : (isUser
                    ? Text(msg.text, style: const TextStyle(color: Colors.white, fontSize: 16))
                    : MarkdownBody(
                        data: msg.text,
                        styleSheet: MarkdownStyleSheet(
                          p: const TextStyle(fontSize: 16, height: 1.5, color: Color(0xFF1E293B)),
                          h3: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF243B6B)),
                        ),
                      )),
          ),
          if (!isUser && !msg.isThinking)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildActionButton(Icons.volume_up_outlined, 'Listen', () {}),
                  const SizedBox(width: 16),
                  _buildActionButton(Icons.thumb_up_outlined, 'Helpful', () {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Thanks for your feedback!')));
                  }),
                  const SizedBox(width: 16),
                  _buildActionButton(Icons.thumb_down_outlined, 'Not Helpful', () {}),
                  const SizedBox(width: 16),
                  _buildActionButton(Icons.copy, 'Copy', () {
                    Clipboard.setData(ClipboardData(text: msg.text));
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Copied to clipboard')));
                  }),
                  const SizedBox(width: 16),
                  _buildActionButton(Icons.refresh, 'Regenerate', () {}),
                ],
              ),
            )
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String tooltip, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Tooltip(
        message: tooltip,
        child: Icon(icon, size: 18, color: Colors.grey[500]),
      ),
    );
  }

  Widget _buildComposer() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, -4),
            blurRadius: 10,
          )
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.add, color: Color(0xFF243B6B)),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Image questions are coming soon.')));
              },
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F9FC),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFFE0E7FF)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        minLines: 1,
                        maxLines: 4,
                        decoration: InputDecoration(
                          hintText: _isListening ? 'Listening...' : 'Type your question...',
                          border: InputBorder.none,
                          hintStyle: TextStyle(color: Colors.grey[400]),
                        ),
                        onSubmitted: _sendMessage,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.mic, color: _isListening ? const Color(0xFFFF6B5A) : Colors.grey[500]),
                      onPressed: _startVoiceInput,
                    )
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              decoration: const BoxDecoration(
                color: Color(0xFF243B6B),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.send, color: Colors.white),
                onPressed: () => _sendMessage(_controller.text),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
