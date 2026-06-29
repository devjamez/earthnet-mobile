import 'dart:math';

import 'package:earthnet_mobile/src/rust/api/detect.dart';
import 'package:earthnet_mobile/src/rust/frb_generated.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

// On-device test of the flutter_rust_bridge detection bridge: it exercises the
// SHARED Rust STA/LTA core compiled into the app. Run with:
//   flutter test integration_test  (needs a device/emulator)
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async => await RustLib.init());

  test('Rust STA/LTA detects a P-wave onset through the bridge', () {
    const rate = 50.0;
    final samples = <double>[];
    for (var i = 0; i < (rate * 20).toInt(); i++) {
      final baseline = 0.1 * sin(i * 0.3);
      final burst = (i / rate) >= 14 ? 3.0 * sin(i * 1.7) : 0.0;
      samples.add(baseline + burst);
    }
    final pick = detectPick(samples: samples, samplingRate: rate);
    expect(pick, isNotNull);
    expect(pick!.staLtaRatio, greaterThan(triggerOn()));
  });

  test('no pick on low-amplitude noise', () {
    const rate = 50.0;
    final samples = [for (var i = 0; i < 1100; i++) 0.1 * sin(i * 0.3)];
    expect(detectPick(samples: samples, samplingRate: rate), isNull);
  });
}
