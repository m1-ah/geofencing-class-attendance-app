import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class ViewRecordsScreen extends StatefulWidget {
  const ViewRecordsScreen({super.key});

  @override
  _ViewRecordsScreenState createState() => _ViewRecordsScreenState();
}

class _ViewRecordsScreenState extends State<ViewRecordsScreen> {
  User? user = FirebaseAuth.instance.currentUser;
  String adminName = "";
  String adminUID = "";
  int totalClassesCreated = 0;
  TextEditingController searchController = TextEditingController();
  String searchQuery = "";

  @override
  void initState() {
    super.initState();
    fetchAdminData();
    fetchClassesCreated();
  }

  Future<void> fetchAdminData() async {
    var adminDoc =
        await FirebaseFirestore.instance
            .collection('admins')
            .doc(user?.uid)
            .get();
    if (adminDoc.exists) {
      setState(() {
        adminName = adminDoc["name"];
        adminUID = adminDoc["adminUID"];
      });
    }
  }

  Future<void> fetchClassesCreated() async {
    var classQuery =
        await FirebaseFirestore.instance
            .collection('classes')
            .where("adminUID", isEqualTo: user?.uid)
            .get();
    setState(() {
      totalClassesCreated = classQuery.docs.length;
    });
  }

  Stream<QuerySnapshot> fetchAttendanceHistory() {
    return FirebaseFirestore.instance
        .collection('attendance')
        .where("adminUID", isEqualTo: adminUID)
        .snapshots();
  }

  Color getStatusColor(String status) {
    switch (status) {
      case "present":
        return Colors.green;
      case "partially present":
        return Colors.orange;
      case "absent":
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String getStatus(int durationMinutes, int classMinutes) {
    if (durationMinutes >= (classMinutes / 2)) {
      return "present";
    } else if (durationMinutes > 0) {
      return "partially present";
    } else {
      return "absent";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0A0A23),
      appBar: AppBar(
        title: Text(
          "Attendance Records",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color(0xFF0A0A23),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Card(
              color: Colors.yellow,
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      adminName,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0A0A23),
                      ),
                    ),
                    Text(
                      adminUID,
                      style: TextStyle(fontSize: 18, color: Color(0xFF0A0A23)),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "Classes Created: $totalClassesCreated",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0A0A23),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),
            Expanded(
              child: StreamBuilder(
                stream: fetchAttendanceHistory(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (!snapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                  }

                  var records = snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: records.length,
                    itemBuilder: (context, index) {
                      var doc = records[index];
                      return Card(
                        color: Colors.white,
                        margin: EdgeInsets.symmetric(vertical: 8.0),
                        child: ExpansionTile(
                          title: Text(
                            "${DateFormat("dd/MM/yy HH:mm").format((doc['startTime'] as Timestamp).toDate())} - ${doc['course']}: ${doc['unit']}",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Institution: ${doc['institution']}",
                                style: TextStyle(fontSize: 14),
                              ),
                              Text(
                                "Year: ${doc['yearOfStudy']}",
                                style: TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                          children: [
                            Padding(
                              padding: EdgeInsets.all(10.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  TextField(
                                    controller: searchController,
                                    decoration: InputDecoration(
                                      labelText:
                                          "Search by Status or Registration Number",
                                      prefixIcon: Icon(Icons.search),
                                      border: OutlineInputBorder(),
                                    ),
                                    onChanged: (value) {
                                      setState(() {
                                        searchQuery = value.toLowerCase();
                                      });
                                    },
                                  ),
                                  SizedBox(height: 10),
                                  StreamBuilder(
                                    stream:
                                        FirebaseFirestore.instance
                                            .collection('students')
                                            .where(
                                              "course",
                                              isEqualTo: doc["course"],
                                            )
                                            .where(
                                              "institution",
                                              isEqualTo: doc["institution"],
                                            )
                                            .where(
                                              "yearOfStudy",
                                              isEqualTo: doc["yearOfStudy"],
                                            )
                                            .snapshots(),
                                    builder: (
                                      context,
                                      AsyncSnapshot<QuerySnapshot>
                                      studentSnapshot,
                                    ) {
                                      if (!studentSnapshot.hasData) {
                                        return Center(
                                          child: CircularProgressIndicator(),
                                        );
                                      }

                                      var students = studentSnapshot.data!.docs;

                                      return Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Total Students: ${students.length}",
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          SizedBox(height: 10),
                                          ...students.map((student) {
                                            var studentReg =
                                                student['registrationNumber'];
                                            QueryDocumentSnapshot<Object?>?
                                            attendanceDoc;
                                            try {
                                              attendanceDoc = records.firstWhere(
                                                (rec) =>
                                                    rec["registrationNumber"] ==
                                                    studentReg,
                                              );
                                            } catch (e) {
                                              attendanceDoc = null;
                                            }

                                            DateTime? startTime =
                                                attendanceDoc != null
                                                    ? (attendanceDoc['startTime']
                                                            as Timestamp)
                                                        .toDate()
                                                    : null;
                                            DateTime? checkOutTime =
                                                attendanceDoc != null &&
                                                        attendanceDoc['checkOutTime'] !=
                                                            null
                                                    ? (attendanceDoc['checkOutTime']
                                                            as Timestamp)
                                                        .toDate()
                                                    : null;

                                            int durationMinutes =
                                                (startTime != null &&
                                                        checkOutTime != null)
                                                    ? checkOutTime
                                                        .difference(startTime)
                                                        .inMinutes
                                                    : 0;

                                            DateTime? classStartTime =
                                                (doc['startTime'] as Timestamp?)
                                                    ?.toDate();
                                            DateTime? classEndTime =
                                                (doc['endTime'] as Timestamp?)
                                                    ?.toDate();

                                            // Calculate class duration in minutes
                                            int classMinutes =
                                                (classStartTime != null &&
                                                        classEndTime != null)
                                                    ? classEndTime
                                                        .difference(
                                                          classStartTime,
                                                        )
                                                        .inMinutes
                                                    : 0; // Default to 0 if startTime or endTime is missing

                                            String status =
                                                (attendanceDoc != null &&
                                                        startTime != null &&
                                                        checkOutTime != null)
                                                    ? getStatus(
                                                      durationMinutes,
                                                      classMinutes,
                                                    )
                                                    : "absent";

                                            Color statusColor = getStatusColor(
                                              status,
                                            );

                                            if (searchQuery.isNotEmpty &&
                                                !studentReg
                                                    .toLowerCase()
                                                    .contains(searchQuery) &&
                                                status.toLowerCase() !=
                                                    searchQuery) {
                                              return SizedBox();
                                            }

                                            return Card(
                                              color: Colors.grey[200],
                                              margin: EdgeInsets.symmetric(
                                                vertical: 5,
                                              ),
                                              child: ListTile(
                                                title: Text(
                                                  "Reg: ${studentReg} - ${student['fullName']}",
                                                ),
                                                subtitle: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      "Start Time: ${startTime != null ? DateFormat("HH:mm").format(startTime) : 'N/A'}",
                                                    ),
                                                    Text(
                                                      "Check-Out: ${checkOutTime != null ? DateFormat("HH:mm").format(checkOutTime) : 'N/A'}",
                                                    ),
                                                    Text(
                                                      "Duration: $durationMinutes mins",
                                                    ),
                                                  ],
                                                ),
                                                trailing: Container(
                                                  padding: EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 4,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: statusColor,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          8,
                                                        ),
                                                  ),
                                                  child: Text(
                                                    status,
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            );
                                          }).toList(),
                                        ],
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
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
  }
}
