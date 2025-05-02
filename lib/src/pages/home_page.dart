import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  User? user = FirebaseAuth.instance.currentUser;
  String userName = "Student";

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    if (user != null) {
      DocumentSnapshot studentDoc = await FirebaseFirestore.instance
          .collection("studentsNames")
          .doc(user!.uid)
          .get();

      if (studentDoc.exists) {
        setState(() {
          userName = studentDoc["fullName"] ?? "Student";
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacementNamed(context, '/dashboard');
        return false;
      },
      child: Scaffold(
        backgroundColor: Color(0xFFFFDF00),
        appBar: AppBar(
          backgroundColor: Color(0xFFFFDF00),
          elevation: 0,
          iconTheme: IconThemeData(color: Color(0xFF0A0A23)),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Center(
                      child: Image.asset('assets/logo/logo.png', height: 100),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        "Your Smart Attendance Companion 📍",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0A0A23),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(height: 20),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        "Welcome, $userName 👋",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0A0A23),
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      "Here's an overview of your activities:",
                      style: TextStyle(fontSize: 16, color: Color(0xFF0A0A23)),
                    ),
                    SizedBox(height: 20),
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      childAspectRatio: 1.3,
                      physics: NeverScrollableScrollPhysics(),
                      children: [
                        _buildQuickAction(
                          icon: Icons.person,
                          label: "Profile",
                          onTap: () => Navigator.pushNamed(context, "/profile"),
                        ),
                        _buildQuickAction(
                          icon: Icons.location_on,
                          label: "Mark Attendance",
                          onTap: () => Navigator.pushNamed(context, "/mark_attendance"),
                        ),
                        _buildQuickAction(
                          icon: Icons.check_circle,
                          label: "Take Attendance",
                          onTap: () => Navigator.pushNamed(context, "/take_attendance"),
                        ),
                        _buildQuickAction(
                          icon: Icons.history,
                          label: "View Records",
                          onTap: () => Navigator.pushNamed(context, "/view_records"),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                  ],
                ),
              ),
            ),

            // Footer
            Container(
              padding: EdgeInsets.all(16),
              color: Color(0xFF0A0A23),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildClickableIcon(Icons.email, "mailto:devmaina01@gmail.com"),
                      _buildClickableIcon(Icons.phone, "tel:+254794047040"),
                      _buildClickableIcon(FontAwesomeIcons.whatsapp, "https://wa.me/254794047040"),
                      _buildClickableIcon(FontAwesomeIcons.github, "https://github.com/m1-ah"),
                    ],
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Developed with ❤️ by Dev Maina",
                    style: TextStyle(color: Colors.white, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Quick Action Widget
  Widget _buildQuickAction({required IconData icon, required String label, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: Color(0xFF0A0A23),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Colors.white),
            SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  // Clickable Contact Icons
  Widget _buildClickableIcon(IconData icon, String url) {
    return IconButton(
      icon: Icon(icon, color: Colors.white, size: 30),
      onPressed: () async {
        if (await canLaunch(url)) {
          await launch(url);
        } else {
          print("Could not open $url");
        }
      },
    );
  }
}
