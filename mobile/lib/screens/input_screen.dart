import 'package:flutter/material.dart';
import '../services/bluetooth_service.dart';
import '../services/speech_service.dart';
import 'response_screen.dart';

class InputScreen extends StatefulWidget {
  const InputScreen({super.key});

  @override
  State<InputScreen> createState() => _InputScreenState();
}

class _InputScreenState extends State<InputScreen> {
  final TextEditingController _controller = TextEditingController();
  final BluetoothService _bleService = BluetoothService();
  final SpeechService _speechService = SpeechService();

  void _submitDoubt(String text) async {
    if (text.trim().isEmpty) return;
    
    try {
      await _bleService.sendDoubt(text);
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const ResponseScreen()),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  void _startVoiceInput() async {
    String voiceText = await _speechService.startListening();
    setState(() {
      _controller.text = voiceText;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ask a Doubt')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                maxLines: null,
                expands: true,
                decoration: const InputDecoration(
                  hintText: 'Type your question or tap the mic...',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                FloatingActionButton(
                  heroTag: 'voiceBtn',
                  onPressed: _startVoiceInput,
                  child: const Icon(Icons.mic),
                ),
                ElevatedButton.icon(
                  onPressed: () => _submitDoubt(_controller.text),
                  icon: const Icon(Icons.send),
                  label: const Text('Send to IVT'),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
