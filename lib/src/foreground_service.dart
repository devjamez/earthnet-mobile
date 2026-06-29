import 'dart:io';

import 'package:flutter/services.dart';

/// Controls the Android foreground service that keeps the relay socket alive
/// with the screen off. No-op on non-Android platforms.
class ForegroundService {
  static const MethodChannel _channel = MethodChannel('earthnet/foreground');

  static Future<void> start() async {
    if (!Platform.isAndroid) return;
    try {
      await _channel.invokeMethod<bool>('start');
    } on PlatformException {
      // Service start is best-effort; the app still works in the foreground.
    }
  }

  static Future<void> stop() async {
    if (!Platform.isAndroid) return;
    try {
      await _channel.invokeMethod<bool>('stop');
    } on PlatformException {
      // ignore
    }
  }
}
