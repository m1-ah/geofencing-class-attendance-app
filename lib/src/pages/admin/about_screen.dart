import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Geofence App",
          style: TextStyle(color: Color(0xFFFFDF00)), // Title color changed to yellow
        ),
        backgroundColor: Color(0xFF0A0A23), // Background color set to dark
        foregroundColor: Color(0xFFFFDF00), // Back button color changed to yellow
      ),
      body: Container(
        color: Color(0xFF0A0A23), // Background color set to dark for the screen
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // App Logo
            Center(
              child: Image.asset(
                'assets/logo/logo.jpeg',
                height: 100,
              ),
            ),
            SizedBox(height: 20),

            // App Title
            Text(
              "Attendance System",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFFFFDF00),
              ),
            ),
            SizedBox(height: 10),

            // App Description
            Text(
              "Geofencing Attendance App is a smart attendance tracking system that uses geofencing and facial recognition to ensure students are present in class. "
                  "Admins can set venues, schedule classes, and monitor attendance records in real-time.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Color(0xFFFFDF00)), // Text color set to yellow
            ),
            SizedBox(height: 20),

            // Features List
            _buildFeatureItem(Icons.location_on, "Geofencing for accurate attendance"),
            _buildFeatureItem(Icons.fingerprint, "Secure biometric authentication"),
            _buildFeatureItem(Icons.schedule, "Easy class scheduling"),
            _buildFeatureItem(Icons.analytics, "Real-time attendance tracking"),
            _buildFeatureItem(Icons.notifications, "Instant student notifications"),

            Spacer(),

            // Footer
            Text(
              "Developed with ❤️ by Dev Maina",
              style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  // Feature Item Widget
  Widget _buildFeatureItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Color(0xFFFFDF00)), // Icon color set to yellow
          SizedBox(width: 10),
          Text(text, style: TextStyle(fontSize: 16, color: Color(0xFFFFDF00))), // Text color set to yellow
        ],
      ),
    );
  }
}
