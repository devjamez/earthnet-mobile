import 'geo.dart';
import 'proto/earthnet.pb.dart';

/// Approximate crustal wave velocities (km/s). The warning window is the gap
/// between the (already-passed) P-wave detection and the destructive S-wave.
const double pWaveKmPerS = 6.0;
const double sWaveKmPerS = 3.5;

/// How many seconds until the S-wave reaches ([userLat], [userLon]).
///
/// Computed locally from the event's epicenter + origin time and the device's
/// own location — the client never sends its location upstream for this.
/// Negative means the S-wave has already arrived (no warning possible here).
double sWaveLeadSeconds(
  ConfirmedEvent event,
  double userLat,
  double userLon, {
  DateTime? now,
}) {
  final (epiLat, epiLon) = decodeGeohash(event.epicenter.geohash);
  final distKm = haversineKm(epiLat, epiLon, userLat, userLon);
  final originSec = event.originTimeNs.toInt() / 1e9;
  final sArrivalSec = originSec + distKm / sWaveKmPerS;
  final nowSec = (now ?? DateTime.now().toUtc()).microsecondsSinceEpoch / 1e6;
  return sArrivalSec - nowSec;
}
