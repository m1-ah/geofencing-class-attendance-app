import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

class GeofenceStatusProvider with ChangeNotifier {
  bool _isInsideGeofence = false;
  Position? _currentPosition;

  bool get isInsideGeofence => _isInsideGeofence;
  Position? get currentPosition => _currentPosition;

  Future<void> updateGeofenceStatus(double lat, double lon, double radius) async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    _currentPosition = position;

    double distance = Geolocator.distanceBetween(
      lat, lon, position.latitude, position.longitude);

    _isInsideGeofence = distance <= radius;
    notifyListeners();
  }
}
