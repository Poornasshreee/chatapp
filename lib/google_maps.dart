// location_helper.dart
import 'package:geolocator/geolocator.dart';

class LocationHelper {
  // Get current position with permission handling
  static Future<Position> currentPosition() async {
    bool serviceEnable;
    LocationPermission permission;

    // check if the location service are enabled or not
    serviceEnable = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnable) {
      return Future.error("Location services are disable");
    }

    // check the location permission status
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error("Location permission denied");
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error("Location denied permanently");
    }

    return await Geolocator.getCurrentPosition();
  }

  // Get location as Google Maps URL (for sending in chat)
  static Future<String> getLocationUrl() async {
    Position position = await currentPosition();
    return 'https://www.google.com/maps/search/?api=1&query=${position.latitude},${position.longitude}';
  }

  // Get location data as Map (for sending in chat)
  static Future<Map<String, dynamic>> getLocationData() async {
    Position position = await currentPosition();
    return {
      'latitude': position.latitude,
      'longitude': position.longitude,
      'url': 'https://www.google.com/maps/search/?api=1&query=${position.latitude},${position.longitude}',
    };
  }
}