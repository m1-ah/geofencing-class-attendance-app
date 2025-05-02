import 'package:geolocator/geolocator.dart';

// Define the allowed geofence coordinates
const double allowedLatitude = 37.7749;
const double allowedLongitude = -122.4194;
const double allowedRadius = 100.0; // in meters

Future<bool> checkGeofencing(double latitude, double longitude) async {
  bool serviceEnabled;
  LocationPermission permission;

  // Checking if location services are enabled
  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    return false;
  }

  // Requesting location permissions
  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      return false;
    }
  }

  if (permission == LocationPermission.deniedForever) {
    return false;
  }

  // Getting current location
  Position position = await Geolocator.getCurrentPosition();
  double distance = Geolocator.distanceBetween(
    allowedLatitude,
    allowedLongitude,
    position.latitude,
    position.longitude,
  );

  return distance <= allowedRadius;
}

