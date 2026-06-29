import 'package:geocoding/geocoding.dart';

/// Reverse-geocodes the EPICENTER (public data) to a human place name via the
/// device's native geocoder. The user's own location is never geocoded.
class ReverseGeocode {
  /// Returns a short "City, Region" string, or null if unavailable.
  static Future<String?> placeName(double lat, double lon) async {
    try {
      final placemarks = await placemarkFromCoordinates(lat, lon);
      if (placemarks.isEmpty) return null;
      final p = placemarks.first;
      final parts = <String?>[
        p.locality,
        p.subAdministrativeArea,
        p.administrativeArea,
        p.country,
      ].where((s) => s != null && s.isNotEmpty).cast<String>().toList();
      if (parts.isEmpty) return null;
      return parts.take(2).join(', ');
    } catch (_) {
      return null; // geocoder unavailable / offline
    }
  }
}
