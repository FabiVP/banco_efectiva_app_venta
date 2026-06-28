import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class GeoService {
  static Future<(double lat, double lng)?> addressToCoordinates(String address) async {
    try {
      final locations = await locationFromAddress(address);
      if (locations.isNotEmpty) {
        final loc = locations.first;
        return (loc.latitude, loc.longitude);
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  static Future<Position?> getCurrentPosition() async {
    try {
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );
    } catch (_) {
      return null;
    }
  }
}
