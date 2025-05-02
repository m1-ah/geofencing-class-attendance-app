import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileCard extends StatefulWidget {
  const ProfileCard({super.key});

  @override
  _ProfileCardState createState() => _ProfileCardState();
}

class _ProfileCardState extends State<ProfileCard> {
  User? currentUser;

  @override
  void initState() {
    super.initState();
    currentUser = FirebaseAuth.instance.currentUser;
  }

  @override
  Widget build(BuildContext context) {
    if (currentUser == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('students').doc(currentUser!.uid).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return const Center(child: Text("Error loading profile"));
        }

        // Extract student data or use default values
        final studentData = snapshot.data?.data() as Map<String, dynamic>? ?? {};
        String firstName = studentData['firstName']?.toString() ?? "Student";
        String registrationNumber = studentData['registrationNumber']?.toString() ?? "Unknown";
        String course = studentData['course']?.toString() ?? "N/A";
        String institution = studentData['institution']?.toString() ?? "N/A";
        String yearOfStudy = studentData['yearOfStudy']?.toString() ?? "N/A";
        String profileImageUrl = studentData['profileImage'] ?? "assets/logo/profile.jpg"; // Default image

        return Container(
          color: const Color(0xFFFFDF00),
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          child: Center(
            child: Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundImage: profileImageUrl.startsWith('http')
                              ? NetworkImage(profileImageUrl) as ImageProvider
                              : AssetImage("assets/logo/profile.jpg"),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                firstName,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                "Email: ${currentUser?.email ?? 'No email'}",
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text("Reg: $registrationNumber"),
                              Text("Course: $course"),
                              Text("Institution: $institution"),
                              Text("Year: $yearOfStudy"),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
