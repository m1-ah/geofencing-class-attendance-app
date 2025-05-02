import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'take_attendance.dart';

class MarkAttendance extends StatefulWidget {
  const MarkAttendance({super.key});

  @override
  _MarkAttendanceState createState() => _MarkAttendanceState();
}

class _MarkAttendanceState extends State<MarkAttendance> {
  GoogleMapController? mapController;
  LatLng? studentLocation;
  LatLng? venueLocation;
  double geofenceRadius = 100.0; // Default radius in meters
  bool isInsideGeofence = false;
  bool _isLoading = true;
  String? _startTime;
  String? _endTime;
  bool isClassOngoing = false;

  @override
  void initState() {
    super.initState();
    _initializeAttendance();
  }

  @override
  void dispose() {
    mapController?.dispose();
    super.dispose();
  }

  Future<void> _initializeAttendance() async {
    await _checkAndRequestLocationPermissions();
    await _getCurrentLocation();
    await _fetchVenueDetails();
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _checkAndRequestLocationPermissions() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.deniedForever) {
        _showErrorDialog("Location permission is required", true);
        return;
      }
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.best);
      setState(() {
        studentLocation = LatLng(position.latitude, position.longitude);
      });

      if (venueLocation != null) {
        _checkGeofence();
      }
    } catch (e) {
      print("Error fetching location: $e");
      _showErrorDialog("Failed to get location. Check GPS settings.", true);
    }
  }

  Future<void> _fetchVenueDetails() async {
    try {
      DocumentSnapshot venueDoc = await FirebaseFirestore.instance
          .collection('venues')
          .doc('current_venue')
          .get();

      if (!venueDoc.exists) {
        _showErrorDialog("No venue has been set by the lecturer.", true);
        return;
      }

      Map<String, dynamic> data = venueDoc.data() as Map<String, dynamic>;
      if (data.containsKey('latitude') && data.containsKey('longitude') &&
          data.containsKey('start_time') && data.containsKey('end_time')) {
        setState(() {
          venueLocation = LatLng(data['latitude'], data['longitude']);
          geofenceRadius = data['radius'] ?? 100.0;
          _startTime = data['start_time'];
          _endTime = data['end_time'];
        });

        if (studentLocation != null) {
          _checkGeofence();
          _checkClassTiming();
        }
      } else {
        _showErrorDialog("Venue data is incomplete.", true);
      }
    } catch (e) {
      print("Error fetching venue details: $e");
      _showErrorDialog("Failed to fetch venue details. Try again later.", true);
    }
  }

  void _checkGeofence() {
    if (studentLocation != null && venueLocation != null) {
      double distance = Geolocator.distanceBetween(
        studentLocation!.latitude,
        studentLocation!.longitude,
        venueLocation!.latitude,
        venueLocation!.longitude,
      );

      setState(() {
        isInsideGeofence = distance <= geofenceRadius;
      });
    }
  }

  void _checkClassTiming() {
    if (_startTime != null && _endTime != null) {
      TimeOfDay now = TimeOfDay.now();
      TimeOfDay start = _parseTime(_startTime!);
      TimeOfDay end = _parseTime(_endTime!);

      bool ongoing = _isTimeInRange(now, start, end);
      setState(() {
        isClassOngoing = ongoing;
      });
    }
  }

  TimeOfDay _parseTime(String timeString) {
    List<String> parts = timeString.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  bool _isTimeInRange(TimeOfDay now, TimeOfDay start, TimeOfDay end) {
    int nowMinutes = now.hour * 60 + now.minute;
    int startMinutes = start.hour * 60 + start.minute;
    int endMinutes = end.hour * 60 + end.minute;

    return nowMinutes >= startMinutes && nowMinutes <= endMinutes;
  }

  void _navigateToTakeAttendance() {
    if (venueLocation == null) {
      _showErrorDialog("No venue has been set", true);
      return;
    }
    if (!isInsideGeofence) {
      _showErrorDialog("You are outside the institution perimeter.", false);
      return;
    }
    if (!isClassOngoing) {
      _showErrorDialog("Class is not ongoing. You can only mark attendance during class time.", false);
      return;
    }

    // If all checks pass, navigate to TakeAttendance page
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TakeAttendance(),
      ),
    );
  }


  void _showErrorDialog(String message, bool redirectToDashboard) {
    if (!mounted) return; // Prevent calling setState when widget is disposed

    Future.microtask(() {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Error"),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                if (redirectToDashboard && mounted) {
                  Navigator.pop(context); // Return to dashboard
                }
              },
              child: const Text("OK"),
            ),
          ],
        ),
      );
    });
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Mark Attendance")),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Expanded(
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: studentLocation ?? const LatLng(0, 0),
                zoom: 16,
              ),
              onMapCreated: (controller) {
                setState(() {
                  mapController = controller;
                });
              },
              markers: {
                if (studentLocation != null)
                  Marker(
                    markerId: const MarkerId("student"),
                    position: studentLocation!,
                    icon: BitmapDescriptor.defaultMarkerWithHue(
                        BitmapDescriptor.hueBlue),
                  ),
                if (venueLocation != null)
                  Marker(
                    markerId: const MarkerId("venue"),
                    position: venueLocation!,
                    icon: BitmapDescriptor.defaultMarkerWithHue(
                        BitmapDescriptor.hueRed),
                  ),
              },
              circles: {
                if (venueLocation != null)
                  Circle(
                    circleId: const CircleId("geofence"),
                    center: venueLocation!,
                    radius: geofenceRadius,
                    fillColor: Colors.red.withOpacity(0.3),
                    strokeColor: Colors.red,
                    strokeWidth: 2,
                  ),
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () {
                if (venueLocation == null) {
                  _showErrorDialog("No venue has been set", true);
                } else if (!isInsideGeofence) {
                  _showErrorDialog("You are outside the institution perimeter.", false);
                } else if (!isClassOngoing) {
                  _showErrorDialog("Class is not ongoing. You can only mark attendance during class time.", false);
                } else {
                  _navigateToTakeAttendance();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: (isInsideGeofence && isClassOngoing) ? Colors.green : Colors.grey,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              ),
              child: const Text("Proceed to Take Attendance"),
            ),
          ),
        ],
      ),
    );
  }
}