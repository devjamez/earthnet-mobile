import 'package:earthnet_mobile/src/intensity.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('intensity is highest near the epicenter and falls with distance', () {
    expect(expectedMmi(6.0, 10), greaterThan(expectedMmi(6.0, 100)));
    expect(expectedMmi(6.0, 100), greaterThan(expectedMmi(6.0, 2000)));
  });

  test('bigger magnitude => stronger shaking at the same distance', () {
    expect(expectedMmi(7.0, 100), greaterThan(expectedMmi(5.0, 100)));
  });

  test('far large quake is not felt (would be filtered)', () {
    // M6.0 at 2264 km — the Pica demo — is imperceptible at Mar del Plata.
    expect(expectedMmi(6.0, 2264), lessThan(kFeltMmi));
  });

  test('moderate-distance quake is felt (passes the filter)', () {
    // M6.4 at ~313 km.
    expect(expectedMmi(6.4, 313), greaterThanOrEqualTo(kFeltMmi));
  });

  test('intensityText gives a roman numeral and a label', () {
    expect(intensityText(5.0), contains('V'));
    expect(intensityText(1.0), contains('No se siente'));
  });
}
