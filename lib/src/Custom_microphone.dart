import 'dart:async';
import 'package:flutter/services.dart';

class Microphone {
  static const MethodChannel _channel = MethodChannel('microphone');
  static StreamController<List<int>>? _controller;

  static Future<bool> get hasPermissions async {
    final bool hasPermissions =
        await _channel.invokeMethod('hasPermissions') ?? false;
    return hasPermissions;
  }

  static Future<void> requestPermissions() async {
    await _channel.invokeMethod('requestPermissions');
  }

  static Stream<List<int>> listen() {
    _controller = StreamController<List<int>>(
      onListen: () => _startListening(),
      onCancel: () => _stopListening(),
    );
    return _controller!.stream;
  }

  static void _startListening() {
    _channel.invokeMethod('startListening');
    _channel.setMethodCallHandler((call) {
      if (call.method == 'onData') {
        List<int> data = List<int>.from(call.arguments);
        _controller!.add(data);
      }
      return Future<void>.value();
    });
  }


  static void _stopListening() {
    _channel.invokeMethod('stopListening');
    _controller!.close();
    _controller = null;
  }
}
