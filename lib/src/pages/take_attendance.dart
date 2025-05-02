import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lottie/lottie.dart';

class TakeAttendance extends StatefulWidget {
  const TakeAttendance({super.key});

  @override
  _TakeAttendanceState createState() => _TakeAttendanceState();
}

class _TakeAttendanceState extends State<TakeAttendance> {
  User? user = FirebaseAuth.instance.currentUser;
  String studentName = "Loading...";
  String registrationNumber = "";
  String message = "Checking attendance...";
  Map<String, dynamic>? ongoingClass;
  bool canCheckIn = false;
  bool isLate = false;
  bool isCheckedIn = false;
  String animationPath = "assets/animations/checkattendance.json";

  @override
  void initState() {
    super.initState();
    _fetchStudentDetails();
  }

  Future<void> _fetchStudentDetails() async {
    if (user == null) return;
    DocumentSnapshot studentSnapshot = await FirebaseFirestore.instance
        .collection('students')
        .doc(user!.uid)
        .get();

    if (studentSnapshot.exists) {
      var studentData = studentSnapshot.data() as Map<String, dynamic>;
      setState(() {
        studentName = studentData['fullName'] ?? "Unknown";
        registrationNumber = studentData['registrationNumber'] ?? "N/A";
      });
      _fetchOngoingClass(studentData);
    }
  }

  Future<void> _fetchOngoingClass(Map<String, dynamic> studentData) async {
    QuerySnapshot classSnapshot = await FirebaseFirestore.instance
        .collection('UpcomingClasses')
        .where('course', isEqualTo: studentData['course'])
        .where('institution', isEqualTo: studentData['institution'])
        .where('yearOfStudy', isEqualTo: studentData['yearOfStudy'])
        .get();

    var now = DateTime.now();
    for (var doc in classSnapshot.docs) {
      var classData = doc.data() as Map<String, dynamic>;
      DateTime startTime = classData['startTime'].toDate();
      DateTime endTime = classData['endTime'].toDate();

      if (startTime.isBefore(now) && endTime.isAfter(now)) {
        setState(() {
          ongoingClass = classData;
          canCheckIn = now.isBefore(startTime.add(Duration(minutes: 5)));
          isLate = !canCheckIn;
        });
        return;
      }
    }
    setState(() {
      ongoingClass = null;
    });
  }

  Future<void> _checkOut() async {
    if (!isCheckedIn || ongoingClass == null) {
      setState(() {
        message = "You need to check in first!";
      });
      return;
    }

    setState(() {
      message = "Checking out...";
      animationPath = "assets/animations/checkout.json";
    });

    await FirebaseFirestore.instance.collection("attendance").add({
      "registrationNumber": registrationNumber,
      "studentName": studentName,
      "course": ongoingClass!["course"],
      "unit": ongoingClass!["unit"],
      "institution": ongoingClass!["institution"],
      "yearOfStudy": ongoingClass!["yearOfStudy"],
      "adminName": ongoingClass!["adminName"],
      "adminUID": ongoingClass!["adminUID"],
      "startTime": ongoingClass!["startTime"],
      "endTime": ongoingClass!["endTime"],
      "checkOutTime": FieldValue.serverTimestamp(),
      "status": "Checked Out",
      "email": user!.email, // Ensure email is stored
    });

    setState(() {
      message = "Checked out successfully!";
      animationPath = "assets/animations/checkout.json";
      isCheckedIn = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFDF00),
      appBar: AppBar(
        title: const Text("Take Attendance"),
        backgroundColor: const Color(0xFF0A0A23),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/dashboard'); // Ensure '/dashboard' is properly defined in routes
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, color: Color(0xFF0A0A23), size: 30),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(studentName,
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black)),
                    Text("Reg No: $registrationNumber",
                        style: const TextStyle(fontSize: 16, color: Colors.black)),
                  ],
                )
              ],
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.login, color: Color(0xFF0A0A23)),
                    title: const Text("Check In", style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(isLate ? "You are late!" : "Tap to mark attendance"),
                    trailing: ElevatedButton(
                      onPressed: canCheckIn && !isCheckedIn
                          ? () => setState(() => isCheckedIn = true)
                          : null,
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0A0A23)),
                      child: const Text("Check In", style: TextStyle(color: Colors.white)),
                    ),
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.logout, color: Color(0xFF0A0A23)),
                    title: const Text("Check Out", style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: const Text("Tap to sign out of class"),
                    trailing: ElevatedButton(
                      onPressed: isCheckedIn ? _checkOut : null,
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0A0A23)),
                      child: const Text("Check Out", style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: Column(
                children: [
                  Text(
                    message,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                  const SizedBox(height: 10),
                  Lottie.asset(animationPath, height: 150),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}