import 'package:geocoding/geocoding.dart' as geo;

class GeocodingService {
  /// Get address from coordinates
  static Future<String> getAddressFromCoordinates(
      double latitude,
      double longitude,
      ) async {
    try {
      final placemarks = await geo.placemarkFromCoordinates(latitude, longitude);

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        return '${place.street}, ${place.locality}, ${place.postalCode}';
      }
    } catch (e) {
      print('Error: $e');
    }
    return '$latitude, $longitude';
  }

  /// Get coordinates from address
  static Future<Map<String, double>?> getCoordinatesFromAddress(
      String address,
      ) async {
    try {
      final locations = await geo.locationFromAddress(address);

      if (locations.isNotEmpty) {
        return {
          'latitude': locations.first.latitude,
          'longitude': locations.first.longitude,
        };
      }
    } catch (e) {
      print('Error: $e');
    }
    return null;
  }
}