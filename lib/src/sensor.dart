import 'dart:async';
import 'dart:math';

import 'package:sensors_plus/sensors_plus.dart';

import 'rust/api/detect.dart';

/// On-device P-wave detector: feeds the accelerometer magnitude into the SHARED
/// Rust STA/LTA core (via flutter_rust_bridge — same code the node runs) over a
/// rolling window. Deterministic, no ML (DESIGN guardrail).
class SensorDetector {
  SensorDetector({this.sampleRate = 50.0, this.windowSeconds = 12});

  final double sampleRate;
  final int windowSeconds;
  final List<double> _buf = [];
  StreamSubscription<AccelerometerEvent>? _accel;
  Timer? _timer;

  int get _maxSamples => (sampleRate * windowSeconds).round();

  /// Starts sampling; calls [onUpdate] ~2/s with the current STA/LTA ratio,
  /// whether a P-wave pick fired, and a crude peak ground acceleration (g).
  void start(void Function(double ratio, bool pick, double peakG) onUpdate) {
    _accel = accelerometerEventStream(
      samplingPeriod: SensorInterval.gameInterval,
    ).listen((e) {
      _buf.add(sqrt(e.x * e.x + e.y * e.y + e.z * e.z));
      if (_buf.length > _maxSamples) {
        _buf.removeRange(0, _buf.length - _maxSamples);
      }
    });
    _timer = Timer.periodic(const Duration(milliseconds: 500), (_) {
      if (_buf.length <= sampleRate * 10) return; // need > LTA seconds of data
      final pick = detectPick(
        samples: List<double>.from(_buf),
        samplingRate: sampleRate,
      );
      // peak deviation from gravity (~9.81 m/s^2) expressed in g
      var peak = 0.0;
      for (final v in _buf) {
        final dev = (v - 9.81).abs();
        if (dev > peak) peak = dev;
      }
      onUpdate(pick?.staLtaRatio ?? 0, pick != null, peak / 9.81);
    });
  }

  Future<void> stop() async {
    await _accel?.cancel();
    _timer?.cancel();
    _buf.clear();
  }
}
