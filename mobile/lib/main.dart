import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

void main() {
  runApp(const TutorApp());
}

class TutorApp extends StatelessWidget {
  const TutorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI Tutor - Kannada',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const TutorHomePage(),
    );
  }
}

class TutorHomePage extends StatefulWidget {
  const TutorHomePage({super.key});

  @override
  State<TutorHomePage> createState() => _TutorHomePageState();
}

class _TutorHomePageState extends State<TutorHomePage> {
  BluetoothDevice? _serverDevice;
  BluetoothCharacteristic? _inputChar;
  BluetoothCharacteristic? _outputChar;
  
  String _responseText = "Connect to AI Tutor to start...";
  bool _isConnected = false;
  
  final String serverName = 'AI_Tutor_Kannada';

  @override
  void initState() {
    super.initState();
    _scanAndConnect();
  }

  Future<void> _scanAndConnect() async {
    setState(() {
      _responseText = "Scanning for IVT Server...";
    });

    try {
      await FlutterBluePlus.startScan(timeout: const Duration(seconds: 4));
      
      FlutterBluePlus.scanResults.listen((results) async {
        for (ScanResult r in results) {
          if (r.device.platformName == serverName || r.device.advName == serverName) {
            await FlutterBluePlus.stopScan();
            setState(() {
              _serverDevice = r.device;
            });
            await _connectToServer();
            break;
          }
        }
      });
    } catch (e) {
      setState(() {
        _responseText = "Error scanning: $e";
      });
    }
  }

  Future<void> _connectToServer() async {
    if (_serverDevice == null) return;
    
    try {
      setState(() => _responseText = "Connecting to server...");
      await _serverDevice!.connect();
      
      setState(() {
        _isConnected = true;
        _responseText = "Connected! Ask a question.";
      });
      
      await _discoverServices();
    } catch (e) {
      setState(() => _responseText = "Connection failed: $e");
    }
  }

  Future<void> _discoverServices() async {
    if (_serverDevice == null) return;
    
    List<BluetoothService> services = await _serverDevice!.discoverServices();
    for (BluetoothService service in services) {
      if (service.uuid.toString().contains('440000')) {
        for (BluetoothCharacteristic c in service.characteristics) {
          if (c.uuid.toString().contains('440001')) {
            _inputChar = c;
          }
          if (c.uuid.toString().contains('440002')) {
            _outputChar = c;
            await _outputChar!.setNotifyValue(true);
            _outputChar!.lastValueStream.listen((value) {
              final chunk = utf8.decode(value);
              setState(() {
                if (_responseText == "Connected! Ask a question." || _responseText.startsWith("Asking:")) {
                  _responseText = chunk;
                } else {
                  _responseText += chunk;
                }
              });
            });
          }
        }
      }
    }
  }

  Future<void> _sendDoubt(String question) async {
    if (!_isConnected || _inputChar == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Not connected to server')),
      );
      return;
    }

    setState(() {
      _responseText = "Asking: $question\n\nWaiting for response...";
    });

    Map<String, dynamic> payload = {
      'question': question,
      'subject': 'Mathematics',
      'language': 'kn',
    };

    try {
      await _inputChar!.write(utf8.encode(jsonEncode(payload)), withoutResponse: true);
    } catch (e) {
      setState(() {
        _responseText = "Failed to send doubt: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Tutor - Kannada'),
        actions: [
          IconButton(
            icon: Icon(_isConnected ? Icons.bluetooth_connected : Icons.bluetooth_disabled),
            onPressed: _isConnected ? null : _scanAndConnect,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    _responseText,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _sendDoubt("How to factorize 9x² + 12x + 4?"),
                  icon: const Icon(Icons.send),
                  label: const Text('Test Math'),
                ),
                FloatingActionButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Voice input not implemented in MVP UI')),
                    );
                  },
                  child: const Icon(Icons.mic),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
