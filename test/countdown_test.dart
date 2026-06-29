import 'package:earthnet_mobile/src/countdown.dart';
import 'package:earthnet_mobile/src/geo.dart';
import 'package:earthnet_mobile/src/proto/earthnet.pb.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flutter_test/flutter_test.dart';

ConfirmedEvent _event(String geohash, int originSec) => ConfirmedEvent(
  epicenter: Location(geohash: geohash),
  originTimeNs: Int64(originSec) * Int64(1000000000),
);

void main() {
  const originSec = 1700000000;
  final originUtc = DateTime.fromMillisecondsSinceEpoch(
    originSec * 1000,
    isUtc: true,
  );

  test('warning lead is positive while the S-wave is still travelling', () {
    final ev = _event('66jd2', originSec); // epicenter ~ northern Chile
    final lead = sWaveLeadSeconds(
      ev,
      -33.45,
      -70.66,
      now: originUtc,
    ); // Santiago
    expect(lead, greaterThan(0));
  });

  test('S-wave arrives later the farther you are', () {
    final ev = _event('66jd2', originSec);
    final (epiLat, epiLon) = decodeGeohash('66jd2');
    final near = sWaveLeadSeconds(ev, epiLat + 0.2, epiLon, now: originUtc);
    final far = sWaveLeadSeconds(ev, epiLat + 5.0, epiLon, now: originUtc);
    expect(far, greaterThan(near));
  });

  test('non-positive lead once the S-wave has passed', () {
    final ev = _event('66jd2', originSec);
    final late = originUtc.add(const Duration(seconds: 1000));
    expect(sWaveLeadSeconds(ev, -21.0, -69.0, now: late), lessThanOrEqualTo(0));
  });
}
