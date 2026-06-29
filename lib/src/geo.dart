import 'dart:math';

const _base32 = '0123456789bcdefghjkmnpqrstuvwxyz';

/// Decodes a geohash to its approximate center `(lat, lon)` in degrees.
(double, double) decodeGeohash(String geohash) {
  var latLo = -90.0, latHi = 90.0;
  var lonLo = -180.0, lonHi = 180.0;
  var even = true;
  for (final c in geohash.codeUnits) {
    final idx = _base32.indexOf(String.fromCharCode(c));
    if (idx < 0) continue;
    for (var bit = 4; bit >= 0; bit--) {
      final set = (idx >> bit) & 1 == 1;
      if (even) {
        final mid = (lonLo + lonHi) / 2;
        if (set) {
          lonLo = mid;
        } else {
          lonHi = mid;
        }
      } else {
        final mid = (latLo + latHi) / 2;
        if (set) {
          latLo = mid;
        } else {
          latHi = mid;
        }
      }
      even = !even;
    }
  }
  return ((latLo + latHi) / 2, (lonLo + lonHi) / 2);
}

/// Great-circle distance between two points in kilometers.
double haversineKm(double lat1, double lon1, double lat2, double lon2) {
  const r = 6371.0;
  double rad(double d) => d * pi / 180.0;
  final dLat = rad(lat2 - lat1);
  final dLon = rad(lon2 - lon1);
  final h = pow(sin(dLat / 2), 2) +
      cos(rad(lat1)) * cos(rad(lat2)) * pow(sin(dLon / 2), 2);
  return 2 * r * asin(sqrt(h));
}
