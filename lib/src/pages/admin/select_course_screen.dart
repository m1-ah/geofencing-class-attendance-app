import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'admin_dashboard_screen.dart';

class SelectCourseScreen extends StatefulWidget {
  const SelectCourseScreen({super.key});

  @override
  _SelectCourseScreenState createState() => _SelectCourseScreenState();
}

class _SelectCourseScreenState extends State<SelectCourseScreen> {
  final List<String> _courses = ["BBIT", "BSC", "BIT", "DIT"];
  final List<String> _institutions = ["KCA Main Campus", "KCA Town Campus", "KCA Kisumu Campus", "KCA Kitengela Campus"];
  final List<String> _years = ["1st", "2nd", "3rd", "4th"];
  final Map<String, List<String>> _units = {
    "BBIT": ["Database Systems", "Software Engineering", "Cyber Security"],
    "BSC": ["Machine Learning", "Cloud Computing", "AI & Data Science"],
    "BIT": ["Web Development", "Mobile App Dev", "Network Security"],
    "DIT": ["Programming Basics", "Computer Hardware", "Networking"],
  };

  String? _selectedCourse;
  String? _selectedUnit;
  String? _selectedInstitution;
  String? _selectedYear;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;

  void _saveCourseSelection() async {
    if (_selectedCourse == null || _selectedUnit == null || _selectedInstitution == null || _selectedYear == null || _startTime == null || _endTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please complete all fields")),
      );
      return;
    }

    DateTime now = DateTime.now();
    DateTime startDateTime = DateTime(
        now.year, now.month, now.day, _startTime!.hour, _startTime!.minute);
    DateTime endDateTime = DateTime(
        now.year, now.month, now.day, _endTime!.hour, _endTime!.minute);

    if (endDateTime.isBefore(startDateTime)) {
      _showErrorDialog("End Time cannot be before Start Time.");
      return;
    }

    try {
      String? adminUID = FirebaseAuth.instance.currentUser?.uid;
      if (adminUID == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Error: Admin not signed in")),
        );
        return;
      }

      DocumentSnapshot adminDoc = await FirebaseFirestore.instance.collection("admins").doc(adminUID).get();
      if (!adminDoc.exists) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Error: Admin details not found")),
        );
        return;
      }

      String adminName = adminDoc["name"] ?? "Unknown Admin";


      // Convert TimeOfDay to Timestamp
      DateTime now = DateTime.now();
      DateTime startDateTime = DateTime(now.year, now.month, now.day, _startTime!.hour, _startTime!.minute);
      DateTime endDateTime = DateTime(now.year, now.month, now.day, _endTime!.hour, _endTime!.minute);

      Map<String, dynamic> courseData = {
        "course": _selectedCourse,
        "unit": _selectedUnit,
        "institution": _selectedInstitution,
        "yearOfStudy": _selectedYear,  // Ensure consistent key
        "adminName": adminName,
        "startTime": Timestamp.fromDate(startDateTime), // Store as Timestamp
        "endTime": Timestamp.fromDate(endDateTime), // Store as Timestamp
        "timestamp": FieldValue.serverTimestamp(),
        "adminUID": adminUID,  // Store admin's UID for filtering later
      };

      await FirebaseFirestore.instance.collection("UpcomingClasses").add(courseData);

      _showSuccessDialog(courseData);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error saving course: $e")),
      );
    }
  }



  Future<void> _pickStartTime() async {
    TimeOfDay? picked = await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (picked != null) setState(() => _startTime = picked);
  }

  Future<void> _pickEndTime() async {
    TimeOfDay? picked = await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (picked != null) setState(() => _endTime = picked);
  }

  void _showSuccessDialog(Map<String, dynamic> courseData) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Course Added Successfully"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("✅ Lecturer: ${courseData["adminName"]}"),
              Text("✅ Course: ${courseData["course"]}"),
              Text("✅ Unit: ${courseData["unit"]}"),
              Text("✅ Institution: ${courseData["institution"]}"),
              Text("✅ Year: ${courseData["yearOfStudy"]}"),
              Text("✅ Time: ${DateFormat.jm().format((courseData["startTime"] as Timestamp).toDate())}")
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => AdminDashboard(adminName: courseData["adminName"]
                  )),
                );
              },
              child: Text("OK"),
            ),
          ],
        );
      },
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Invalid Time Selection"),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("OK"),
            ),
          ],
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Select Course"),
        backgroundColor: Color(0xFF0A0A23),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDropdown("Select Course", _selectedCourse, _courses, (value) {
              setState(() {
                _selectedCourse = value;
                _selectedUnit = null;
              });
            }),
            SizedBox(height: 16),
            _buildDropdown("Select Unit", _selectedUnit, _selectedCourse != null ? (_units[_selectedCourse] ?? []) : [], (value) {
              setState(() => _selectedUnit = value);
            }),
            SizedBox(height: 16),
            TextField(
              readOnly: true,
              onTap: _pickStartTime,
              decoration: InputDecoration(labelText: "Select Start Time", suffixIcon: Icon(Icons.access_time)),
              controller: TextEditingController(text: _startTime != null ? _startTime!.format(context) : ""),
            ),
            SizedBox(height: 16),
            TextField(
              readOnly: true,
              onTap: _pickEndTime,
              decoration: InputDecoration(labelText: "Select End Time", suffixIcon: Icon(Icons.access_time)),
              controller: TextEditingController(text: _endTime != null ? _endTime!.format(context) : ""),
            ),
            SizedBox(height: 16),
            _buildDropdown("Select Institution", _selectedInstitution, _institutions, (value) => setState(() => _selectedInstitution = value)),
            SizedBox(height: 16),
            _buildDropdown("Select Year of Study", _selectedYear, _years, (value) => setState(() => _selectedYear = value)),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: _saveCourseSelection,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF0A0A23),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                ),
                child: Text("Save Course Details"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown(String label, String? selectedValue, List<String> items, ValueChanged<String?> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        DropdownButtonFormField<String>(
          value: selectedValue,
          onChanged: onChanged,
          isExpanded: true, // ✅ Makes the dropdown take full width
          items: items.map((item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(
                item,
                overflow: TextOverflow.ellipsis, // ✅ Prevents text from overflowing
                maxLines: 1,
              ),
            );
          }).toList(),
          decoration: InputDecoration(border: OutlineInputBorder()),
        ),
      ],
    );
  }
}
