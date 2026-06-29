import 'package:geolocator/geolocator.dart';

/// Device location with a graceful fallback so the app always has coordinates
/// to compute the S-wave countdown against.
class DeviceLocation {
  /// Fallback when location is unavailable or denied (Santiago, Chile).
  static const ({double lat, double lon}) fallback = (lat: -33.45, lon: -70.66);

  /// Best-effort current location; never throws. `gps` is true when a real
  /// device fix was obtained, false when it fell back to [fallback].
  static Future<({double lat, double lon, bool gps})> current() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        return (lat: fallback.lat, lon: fallback.lon, gps: false);
      }
      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.denied ||
          perm == LocationPermission.deniedForever) {
        return (lat: fallback.lat, lon: fallback.lon, gps: false);
      }
      final p = await Geolocator.getCurrentPosition();
      return (lat: p.latitude, lon: p.longitude, gps: true);
    } catch (_) {
      return (lat: fallback.lat, lon: fallback.lon, gps: false);
    }
  }
}
