import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class ViewRecords extends StatefulWidget {
  const ViewRecords({super.key});

  @override
  _ViewRecordsState createState() => _ViewRecordsState();
}

class _ViewRecordsState extends State<ViewRecords> {
  User? user = FirebaseAuth.instance.currentUser;
  String searchQuery = '';

  Future<Map<String, dynamic>> fetchStudentProfile() async {
    var studentDoc = await FirebaseFirestore.instance
        .collection('students')
        .doc(user?.uid)
        .get();
    return studentDoc.data() ?? {};
  }

  Future<int> fetchTotalClasses(Map<String, dynamic> studentData) async {
    var classSnapshot = await FirebaseFirestore.instance
        .collection('classes')
        .where('course', isEqualTo: studentData['course'])
        .where('institution', isEqualTo: studentData['institution'])
        .where('yearOfStudy', isEqualTo: studentData['yearOfStudy'])
        .get();
    return classSnapshot.docs.length;
  }

  Future<int> fetchMarkedClasses(String registrationNumber) async {
    var attendanceSnapshot = await FirebaseFirestore.instance
        .collection('attendance')
        .where('registrationNumber', isEqualTo: registrationNumber)
        .where('checkOutTime', isNotEqualTo: null)
        .get();
    return attendanceSnapshot.docs.length;
  }

  Stream<QuerySnapshot> fetchAttendanceRecords(String registrationNumber) {
    return FirebaseFirestore.instance
        .collection('attendance')
        .where('registrationNumber', isEqualTo: registrationNumber)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: fetchStudentProfile(),
      builder: (context, AsyncSnapshot<Map<String, dynamic>> snapshot) {
        if (!snapshot.hasData) {
          return Scaffold(
            backgroundColor: const Color(0xFFFFDF00),
            body: const Center(child: CircularProgressIndicator()),
          );
        }
        var studentData = snapshot.data!;
        return Scaffold(
          backgroundColor: const Color(0xFFFFDF00),
          appBar: AppBar(
            title: const Text(
              "Student Records",
              style: TextStyle(color: Colors.white), // Navbar Text Color
            ),
            backgroundColor: const Color(0xFF0A0A23),
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Student Profile Section
                Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 3,
                        blurRadius: 7,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        "Name: ${studentData['fullName']}",
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0A0A23),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Reg Number: ${studentData['registrationNumber']}",
                        style: const TextStyle(
                          fontSize: 18,
                          color: Color(0xFF0A0A23),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Total Classes and Marked Classes Section
                FutureBuilder(
                  future: Future.wait([
                    fetchTotalClasses(studentData),
                    fetchMarkedClasses(studentData['registrationNumber']),
                  ]),
                  builder: (context, AsyncSnapshot<List<int>> snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    var totalClasses = snapshot.data![0];
                    var markedClasses = snapshot.data![1];
                    return Column(
                      children: [
                        Text(
                          "Your Classes: $totalClasses",
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0A0A23),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Marked Classes: $markedClasses",
                          style: const TextStyle(
                            fontSize: 22,
                            color: Color(0xFF0A0A23),
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 16),
                // Search Bar
                TextField(
                  decoration: InputDecoration(
                    hintText: "Search",
                    prefixIcon: const Icon(Icons.search, color: Color(0xFF0A0A23)),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      searchQuery = value;
                    });
                  },
                ),
                const SizedBox(height: 16),
                // Attendance History Section
                Expanded(
                  child: StreamBuilder(
                    stream: fetchAttendanceRecords(studentData['registrationNumber']),
                    builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      var attendanceDocs = snapshot.data!.docs.where((doc) {
                        var unit = doc['unit'].toString().toLowerCase();
                        var adminName = doc['adminName'].toString().toLowerCase();
                        return unit.contains(searchQuery.toLowerCase()) ||
                            adminName.contains(searchQuery.toLowerCase());
                      }).toList();

                      if (attendanceDocs.isEmpty) {
                        return const Center(child: Text("No Records Found"));
                      }

                      return ListView.builder(
                        itemCount: attendanceDocs.length,
                        itemBuilder: (context, index) {
                          var doc = attendanceDocs[index];
                          var startTime = DateFormat("dd/MM/yy HH:mm").format(doc['startTime'].toDate());
                          return ExpansionTile(
                            title: Text(
                              "$startTime - ${doc['course']}: ${doc['unit']} - ${doc['adminName']}",
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            children: [
                              SizedBox(
                                width: double.infinity,
                                child: Container(
                                  padding: const EdgeInsets.all(16.0),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF0A0A23), // Background Color
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 8),
                                      Text(
                                        "Admin UID: ${doc['adminUID']}",
                                        style: const TextStyle(color: Colors.white), // Text Color
                                      ),
                                      Text(
                                        "Institution: ${doc['institution']}",
                                        style: const TextStyle(color: Colors.white), // Text Color
                                      ),
                                      Text(
                                        "Duration Spent: ${(doc['checkOutTime'].toDate().difference(doc['startTime'].toDate()).inMinutes)} minutes",
                                        style: const TextStyle(color: Colors.white), // Text Color
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}