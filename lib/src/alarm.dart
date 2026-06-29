import 'package:flutter/services.dart';
import 'package:vibration/vibration.dart';

/// Multimodal alarm: vibration pattern + an audible system alert. Best-effort;
/// never throws. (A louder custom alarm tone is a later enhancement.)
class Alarm {
  /// Fire the alarm for an incoming (still-approaching) confirmed event.
  static Future<void> trigger() async {
    try {
      if (await Vibration.hasVibrator()) {
        // wait, buzz, gap, buzz, gap, long buzz
        await Vibration.vibrate(pattern: [0, 400, 200, 400, 200, 800]);
      }
    } catch (_) {
      // vibration unsupported — ignore
    }
    try {
      await SystemSound.play(SystemSoundType.alert);
    } catch (_) {
      // audio unavailable — ignore
    }
  }
}
