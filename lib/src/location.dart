import 'package:geolocator/geolocator.dart';

/// Device location with a graceful fallback so the app always has coordinates
/// to compute the S-wave countdown against.
class DeviceLocation {
  /// Fallback when location is unavailable or denied (Santiago, Chile).
  static const ({double lat, double lon}) fallback = (lat: -33.45, lon: -70.66);

  /// Best-effort current location; never throws.
  static Future<({double lat, double lon})> current() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) return fallback;
      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.denied ||
          perm == LocationPermission.deniedForever) {
        return fallback;
      }
      final p = await Geolocator.getCurrentPosition();
      return (lat: p.latitude, lon: p.longitude);
    } catch (_) {
      return fallback;
    }
  }
}
