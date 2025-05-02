import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'select_course_screen.dart'; // Import the next screen

class SelectVenueScreen extends StatefulWidget {
  const SelectVenueScreen({super.key});

  @override
  _SelectVenueScreenState createState() => _SelectVenueScreenState();
}

class _SelectVenueScreenState extends State<SelectVenueScreen> {
  final Map<String, LatLng> _institutions = {
    "KCA Main Campus": LatLng(-1.2532856047009595, 36.85943123690865),
    "KCA Town Campus": LatLng(-1.2808907802335652, 36.81834586574463),
    "KCA Kitengela Campus": LatLng(-1.4779816689852165, 36.95766175225298),
    "KCA Kisumu Campus": LatLng(-0.09862608114155379, 34.752400394579205),
  };

  String? _selectedInstitution;
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  LatLng _selectedLocation = LatLng(-1.286389, 36.817223); // Default Location

  TimeOfDay? _startTime;
  TimeOfDay? _endTime;

  void _onInstitutionSelected(String? institution) {
    if (institution == null) return;
    setState(() {
      _selectedInstitution = institution;
      _selectedLocation = _institutions[institution] ?? LatLng(0, 0);
      _markers = {
        Marker(
          markerId: MarkerId(institution),
          position: _selectedLocation,
          infoWindow: InfoWindow(title: institution),
        ),
      };

      if (_mapController != null) {
        _mapController!.animateCamera(
          CameraUpdate.newLatLngZoom(_selectedLocation, 15),
        );
      }
    });
  }

  Future<void> _selectTime(BuildContext context, bool isStartTime) async {
    TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isStartTime ? (_startTime ?? TimeOfDay.now()) : (_endTime ?? TimeOfDay.now()),
    );

    if (picked != null) {
      setState(() {
        if (isStartTime) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
    }
  }

  Future<void> _saveVenueSelection() async {
    if (_selectedInstitution == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please select an institution")),
      );
      return;
    }

    if (_startTime == null || _endTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please select class start and end times")),
      );
      return;
    }

    // Convert TimeOfDay to minutes for easy comparison
    int startMinutes = _startTime!.hour * 60 + _startTime!.minute;
    int endMinutes = _endTime!.hour * 60 + _endTime!.minute;

    if (endMinutes <= startMinutes) {
      _showErrorDialog("Invalid Time Selection", "End time must be after start time.");
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('venues').doc('current_venue').set({
        'institution': _selectedInstitution,
        'latitude': _selectedLocation.latitude,
        'longitude': _selectedLocation.longitude,
        'radius': 100.0, // Ensure geofence radius is stored
        'start_time': "${_startTime!.hour}:${_startTime!.minute}",
        'end_time': "${_endTime!.hour}:${_endTime!.minute}",
        'timestamp': FieldValue.serverTimestamp(),
      });

      _showSuccessDialog();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to save venue: $e")),
      );
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Success"),
        content: Text("Institution and class timing successfully saved!"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => SelectCourseScreen()),
              );
            },
            child: Text("OK"),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Select Institution"),
        backgroundColor: Color(0xFF0A0A23),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Select an Institution", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            DropdownButtonFormField<String>(
              value: _selectedInstitution,
              onChanged: _onInstitutionSelected,
              items: _institutions.keys.map((institution) {
                return DropdownMenuItem(
                  value: institution,
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.8, // or a fixed width like 300
                    child: Text(
                      institution,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                      softWrap: true,
                    ),
                  ),
                );
              }).toList(),
              decoration: InputDecoration(border: OutlineInputBorder()),
            ),
            SizedBox(height: 16),

            Text("Institution Location on Map", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Container(
              height: 250,
              decoration: BoxDecoration(border: Border.all(color: Colors.black)),
              child: GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: _selectedLocation,
                  zoom: 14,
                ),
                onMapCreated: (controller) {
                  setState(() {
                    _mapController = controller;
                  });
                },
                markers: _markers,
              ),
            ),
            SizedBox(height: 16),

            // Start Time Picker
            Text("Select Class Start Time", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Row(
              children: [
                ElevatedButton(
                  onPressed: () => _selectTime(context, true),
                  child: Text(_startTime == null ? "Pick Start Time" : "${_startTime!.hour}:${_startTime!.minute}"),
                ),
              ],
            ),
            SizedBox(height: 16),

            // End Time Picker
            Text("Select Class End Time", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Row(
              children: [
                ElevatedButton(
                  onPressed: () => _selectTime(context, false),
                  child: Text(_endTime == null ? "Pick End Time" : "${_endTime!.hour}:${_endTime!.minute}"),
                ),
              ],
            ),
            SizedBox(height: 20),

            Center(
              child: ElevatedButton(
                onPressed: _saveVenueSelection,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF0A0A23),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                ),
                child: Text("Save Venue & Time"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
