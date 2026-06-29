import 'package:earthnet_mobile/src/backoff.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('doubles and caps', () {
    expect(nextBackoff(1), 2);
    expect(nextBackoff(2), 4);
    expect(nextBackoff(16), 30); // capped
    expect(nextBackoff(30), 30);
  });

  test('floors to min', () {
    expect(nextBackoff(0), 1);
  });
}
