import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lottie/lottie.dart';
import 'auth_screen.dart';
import 'home_page.dart';
import 'profile_page.dart';
import 'mark_attendance.dart';
import 'take_attendance.dart';
import 'view_records.dart';
import 'face_recognition.dart';
import 'package:bioauth_attendance_app/src/widgets/profile_card.dart';
import 'dart:async';

class DashboardScreen extends StatefulWidget {
  final User user;

  const DashboardScreen({super.key, required this.user});

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Map<String, dynamic>? studentData;
  Stream<QuerySnapshot>? upcomingClassesStream;
  Timer? _statusUpdateTimer;

  @override
  void initState() {
    super.initState();
    fetchStudentData();
    _statusUpdateTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      fetchUpcomingClasses();
    });
  }

  @override
  void dispose() {
    _statusUpdateTimer?.cancel();
    super.dispose();
  }

  Future<void> fetchStudentData() async {
    try {
      DocumentSnapshot studentDoc = await FirebaseFirestore.instance
          .collection('students')
          .doc(widget.user.uid)
          .get();

      if (studentDoc.exists && studentDoc.data() != null) {
        setState(() {
          studentData = studentDoc.data() as Map<String, dynamic>;
          fetchUpcomingClasses();
        });
      } else {
        setState(() {
          studentData = {};
        });
      }
    } catch (e) {
      debugPrint("Error fetching student data: $e");
      setState(() {
        studentData = {};
      });
    }
  }

  void fetchUpcomingClasses() async {
    if (studentData == null || studentData!.isEmpty) return;

    DateTime now = DateTime.now();

    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('UpcomingClasses')
        .where("course", isEqualTo: studentData?["course"] ?? "")
        .where("institution", isEqualTo: studentData?["institution"] ?? "")
        .where("yearOfStudy", isEqualTo: studentData?["yearOfStudy"] ?? "")
        .get();

    for (var doc in snapshot.docs) {
      Timestamp? endTimestamp = doc["endTime"];
      if (endTimestamp != null) {
        DateTime endTime = endTimestamp.toDate();

        if (endTime.isBefore(now)) {
          // Move only if the class has ended
          await moveClassToCompleted(doc);
        }
      }
    }

    // Update stream to show only upcoming and ongoing classes
    setState(() {
      upcomingClassesStream = FirebaseFirestore.instance
          .collection('UpcomingClasses')
          .where("course", isEqualTo: studentData?["course"] ?? "")
          .where("institution", isEqualTo: studentData?["institution"] ?? "")
          .where("yearOfStudy", isEqualTo: studentData?["yearOfStudy"] ?? "")
          .snapshots();
    });
  }


  Future<void> moveClassToCompleted(QueryDocumentSnapshot doc) async {
    try {
      DocumentReference classRef = FirebaseFirestore.instance
          .collection("classes")
          .doc(doc.id); // Use the class ID as the document reference

      // Check if the class already exists in "classes"
      DocumentSnapshot existingRecord = await classRef.get();
      if (existingRecord.exists) {
        debugPrint("Class already moved to classes.");
        return;
      }

      // Move class details to "classes"
      await classRef.set(doc.data(), SetOptions(merge: true));

      // Delete the class from "UpcomingClasses" after moving it
      await FirebaseFirestore.instance.collection("UpcomingClasses").doc(doc.id).delete();

      debugPrint("Class successfully moved to classes.");
    } catch (e) {
      debugPrint("Error moving class to classes: $e");
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Student Dashboard")),
      drawer: _buildDrawer(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ProfileCard(),
            const SizedBox(height: 20),
            const Text(
              "Upcoming Classes",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0A0A23)),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.5,
              child: studentData == null || studentData!.isEmpty
                  ? _buildNoClassesWidget()
                  : StreamBuilder<QuerySnapshot>(
                stream: upcomingClassesStream,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return _buildNoClassesWidget();
                  }
                  return _buildClassesList(snapshot.data!.docs);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(studentData?["name"] ?? "Student"),
            accountEmail: Text(widget.user.email ?? "No email"),
            currentAccountPicture: const CircleAvatar(
              backgroundImage: AssetImage("assets/logo/profile.jpg"),
            ),
            decoration: const BoxDecoration(color: Color(0xFFFFDF00)),
          ),
          _buildDrawerItem(Icons.home, "Home", () => _navigateToPage(const HomePage())),
          _buildDrawerItem(Icons.person, "Profile", () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ProfilePage(user: widget.user)),
            );
            if (result == true) fetchStudentData();
          }),
          _buildDrawerItem(Icons.location_on, "Mark Attendance", () => _navigateToPage(const MarkAttendance())),
          _buildDrawerItem(Icons.location_on, "Take Attendance", () => _navigateToPage(const TakeAttendance())),
          _buildDrawerItem(Icons.history, "View Records", () => _navigateToPage(const ViewRecords())),
          _buildDrawerItem(Icons.face, "Face Recognition", () => _navigateToPage(const FaceRecognition())),
          const Divider(),
          _buildDrawerItem(Icons.logout, "Logout", _confirmLogout, color: Colors.red),
        ],
      ),
    );
  }

  Widget _buildNoClassesWidget() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Lottie.asset("assets/animations/kicoTqO06J.json", width: 220, height: 220),
        const SizedBox(height: 12),
        const Text(
          "No classes to show yet!",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0A0A23)),
        ),
      ],
    );
  }

  Widget _buildClassesList(List<QueryDocumentSnapshot> docs) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: docs.length,
      itemBuilder: (context, index) {
        var doc = docs[index];

        dynamic startRaw = doc['startTime'];
        dynamic endRaw = doc['endTime'];

        Timestamp? startTimestamp;
        Timestamp? endTimestamp;

        if (startRaw is Timestamp) {
          startTimestamp = startRaw;
        } else if (startRaw is String) {
          try {
            startTimestamp = Timestamp.fromDate(DateTime.parse(startRaw));
          } catch (e) {
            debugPrint("Error parsing startTime: $e");
          }
        }

        if (endRaw is Timestamp) {
          endTimestamp = endRaw;
        } else if (endRaw is String) {
          try {
            endTimestamp = Timestamp.fromDate(DateTime.parse(endRaw));
          } catch (e) {
            debugPrint("Error parsing endTime: $e");
          }
        }

        DateTime now = DateTime.now();
        DateTime startTime = startTimestamp?.toDate() ?? now;
        DateTime endTime = endTimestamp?.toDate() ?? now;

        // ✅ Determine class status
        String status = "Unknown";

        if (now.isBefore(startTime)) {
          status = "Upcoming";
        } else if (now.isAfter(startTime) && now.isBefore(endTime)) {
          status = "Ongoing";
        } else if (now.isAfter(endTime)) {
          status = "Completed";
          return const SizedBox(); // Hide completed classes
        }

        return FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance.collection("admins").doc(doc["adminUID"]).get(),
          builder: (context, adminSnapshot) {
            String lecturerName = "Unknown Lecturer";

            if (adminSnapshot.hasData && adminSnapshot.data!.exists) {
              lecturerName = adminSnapshot.data!["name"] ?? "Unknown Lecturer";
            }

            String formattedStartTime = "${startTime.hour}:${startTime.minute.toString().padLeft(2, '0')}";
            String formattedEndTime = "${endTime.hour}:${endTime.minute.toString().padLeft(2, '0')}";

            return Card(
              color: Colors.white,
              child: ListTile(
                title: Text("${doc['unit']} - ${doc['course']}",
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Lecturer: $lecturerName", style: const TextStyle(color: Colors.black87)),
                    Text("Time: $formattedStartTime - $formattedEndTime", style: const TextStyle(color: Colors.black87)),
                    Text("Status: $status",
                        style: TextStyle(color: status == "Upcoming" ? Colors.blue : (status == "Ongoing" ? Colors.green : Colors.red))),
                  ],
                ),
                onTap: () {
                  if (status == "Upcoming") {
                    // 🚫 Show error dialog if class is upcoming
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text("Wait!"),
                        content: const Text("The class is not ongoing 🚫"),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text("OK"),
                          ),
                        ],
                      ),
                    );
                  } else if (status == "Ongoing") {
                    // ✅ Navigate to Mark Attendance screen if class is ongoing
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const MarkAttendance()),
                    );
                  }
                },
              ),
            );
          },
        );
      },
    );
  }



  Widget _buildDrawerItem(IconData icon, String title, VoidCallback onTap, {Color color = Colors.black}) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(title, style: TextStyle(color: color)),
      onTap: onTap,
    );
  }

  void _navigateToPage(Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => page));
  }

  Future<void> _confirmLogout() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirm Logout"),
        content: const Text("Are you sure you want to log out?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          TextButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const AuthScreen()));
            },
            child: const Text("Logout", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}