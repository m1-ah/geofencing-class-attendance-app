import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dashboard_screen.dart';

class ProfilePage extends StatefulWidget {
  final User user;

  const ProfilePage({super.key, required this.user});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _regNoController = TextEditingController();
  final TextEditingController _imageUrlController = TextEditingController();
  String? _selectedInstitution;
  String? _selectedCourse;
  String? _selectedYear;
  bool isLoading = false;

  final List<String> institutions = [
    "KCA Main Campus", "KCA Town Campus", "KCA Kisumu Campus", "KCA Kitengela Campus"
  ];
  final List<String> courses = ["BBIT", "BSC", "BIT", "DIT"];
  final List<String> years = ["1st", "2nd", "3rd", "4th"];

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('students').doc(widget.user.uid).get();

    setState(() {
      _fullNameController.text = userDoc['fullName'] ?? '';
      _regNoController.text = userDoc['registrationNumber'] ?? '';
      // _imageUrlController.text = userDoc['profileImageUrl'] ?? '';
      _selectedInstitution = userDoc['institution'] ?? institutions.first;
      _selectedCourse = userDoc['course'] ?? courses.first;
      _selectedYear = userDoc['yearOfStudy'] ?? years.first;
    });
  }

  Future<void> updateUserData() async {
    setState(() => isLoading = true);

    String regNo = _regNoController.text.trim();

    // Check if the registration number is already taken by another user
    QuerySnapshot existingUsers = await FirebaseFirestore.instance
        .collection('students')
        .where('registrationNumber', isEqualTo: regNo)
        .get();

    // If a document with the same regNo exists and it's not the current user, show error
    if (existingUsers.docs.isNotEmpty &&
        existingUsers.docs.first.id != widget.user.uid) {
      setState(() => isLoading = false);
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Error"),
          content: const Text("This registration number is already in use by another user."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            ),
          ],
        ),
      );
      return;
    }

    // If not taken, update the user data
    await FirebaseFirestore.instance.collection('students').doc(widget.user.uid).set({
      'fullName': _fullNameController.text.trim(),
      'registrationNumber': regNo,
      // 'profileImageUrl': _imageUrlController.text.trim(),
      'institution': _selectedInstitution,
      'course': _selectedCourse,
      'yearOfStudy': _selectedYear,
    }, SetOptions(merge: true));

    setState(() => isLoading = false);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Success"),
        content: const Text("Profile updated successfully!"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => DashboardScreen(user: widget.user)),
            ),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }


  Future<void> resetUserData() async {
    bool confirmReset = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Warning"),
        content: const Text("This will erase all your profile data. Do you want to continue?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false), // Cancel
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true), // Confirm
            child: const Text("Yes, Reset"),
          ),
        ],
      ),
    );

    if (confirmReset) {
      setState(() => isLoading = true);

      await FirebaseFirestore.instance.collection('students').doc(widget.user.uid).delete();

      _fullNameController.clear();
      _regNoController.clear();
      _imageUrlController.clear();
      _selectedInstitution = null;
      _selectedCourse = null;
      _selectedYear = null;

      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFDF00),
      appBar: AppBar(
        title: const Text("Profile", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF0A0A23),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Center(
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(20),
            width: MediaQuery.of(context).size.width * 0.9,
            decoration: BoxDecoration(
              color: const Color(0xFF0A0A23),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTextField("Full Name", _fullNameController),
                _buildTextField("Registration Number", _regNoController),
                // _buildTextField("Google Drive Image Link", _imageUrlController),
                _buildDropdown("Institution", institutions, _selectedInstitution, (value) => setState(() => _selectedInstitution = value)),
                _buildDropdown("Course", courses, _selectedCourse, (value) => setState(() => _selectedCourse = value)),
                _buildDropdown("Year of Study", years, _selectedYear, (value) => setState(() => _selectedYear = value)),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: updateUserData,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.yellow,
                    foregroundColor: Colors.black,
                  ),
                  child: const Text("Save Changes"),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: resetUserData,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text("Reset Profile"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: controller,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.yellow),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          filled: true,
          fillColor: Colors.white10,
        ),
      ),
    );
  }

  Widget _buildDropdown(String label, List<String> items, String? selectedValue, ValueChanged<String?> onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: DropdownButtonFormField<String>(
        value: selectedValue,
        isExpanded: true, // 👈 Important: Allows full width for long items
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.yellow),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          filled: true,
          fillColor: Colors.white,
        ),
        items: items.map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(
              value,
              overflow: TextOverflow.ellipsis, // 👈 Optional: Adds ellipsis if it's still too long
              maxLines: 1,
              style: const TextStyle(fontSize: 14),
            ),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }
}