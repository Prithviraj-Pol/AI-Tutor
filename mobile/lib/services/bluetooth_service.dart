import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BluetoothService extends ChangeNotifier {
  static final BluetoothService _instance = BluetoothService._internal();
  factory BluetoothService() => _instance;
  BluetoothService._internal();

  BluetoothDevice? _serverDevice;
  BluetoothCharacteristic? _inputChar;
  BluetoothCharacteristic? _outputChar;

  bool isConnected = false;
  String responseText = "Connect to AI Tutor to start...";
  final String serverName = 'AI_Tutor_Kannada';

  Future<void> scanAndConnect() async {
    responseText = "Scanning for IVT Server...";
    notifyListeners();

    try {
      await FlutterBluePlus.startScan(timeout: const Duration(seconds: 4));
      
      FlutterBluePlus.scanResults.listen((results) async {
        for (ScanResult r in results) {
          if (r.device.platformName == serverName || r.device.advName == serverName) {
            await FlutterBluePlus.stopScan();
            _serverDevice = r.device;
            await _connectToServer();
            break;
          }
        }
      });
    } catch (e) {
      responseText = "Error scanning: $e";
      notifyListeners();
    }
  }

  Future<void> _connectToServer() async {
    if (_serverDevice == null) return;
    try {
      responseText = "Connecting to server...";
      notifyListeners();
      
      await _serverDevice!.connect();
      isConnected = true;
      responseText = "Connected! Ask a question.";
      notifyListeners();
      
      await _discoverServices();
    } catch (e) {
      responseText = "Connection failed: $e";
      notifyListeners();
    }
  }

  Future<void> _discoverServices() async {
    if (_serverDevice == null) return;
    
    // ignore: deprecated_member_use
    List<BluetoothService> services = await _serverDevice!.discoverServices();
    for (var service in services) {
      if (service.uuid.toString().contains('440000')) {
        for (var c in service.characteristics) {
          if (c.uuid.toString().contains('440001')) {
            _inputChar = c;
          }
          if (c.uuid.toString().contains('440002')) {
            _outputChar = c;
            await _outputChar!.setNotifyValue(true);
            _outputChar!.lastValueStream.listen((value) {
              final chunk = utf8.decode(value);
              if (responseText == "Connected! Ask a question." || responseText.startsWith("Asking:")) {
                responseText = chunk;
              } else {
                responseText += chunk;
              }
              notifyListeners();
            });
          }
        }
      }
    }
  }

  Future<void> sendDoubt(String question) async {
    if (!isConnected || _inputChar == null) {
      throw Exception('Not connected to server');
    }

    responseText = "Asking: $question\n\nWaiting for response...";
    notifyListeners();

    Map<String, dynamic> payload = {
      'question': question,
      'subject': 'Mathematics',
      'language': 'kn',
    };

    await _inputChar!.write(utf8.encode(jsonEncode(payload)), withoutResponse: true);
  }
}
