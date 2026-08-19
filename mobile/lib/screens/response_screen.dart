import 'package:flutter/material.dart';
import '../services/bluetooth_service.dart';

class ResponseScreen extends StatefulWidget {
  const ResponseScreen({super.key});

  @override
  State<ResponseScreen> createState() => _ResponseScreenState();
}

class _ResponseScreenState extends State<ResponseScreen> {
  final BluetoothService _bleService = BluetoothService();

  @override
  void initState() {
    super.initState();
    _bleService.addListener(_updateState);
  }

  @override
  void dispose() {
    _bleService.removeListener(_updateState);
    super.dispose();
  }

  void _updateState() => setState(() {});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AI Explanation')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(12),
          ),
          child: SingleChildScrollView(
            child: Text(
              _bleService.responseText,
              style: const TextStyle(fontSize: 16, height: 1.5),
            ),
          ),
        ),
      ),
    );
  }
}
