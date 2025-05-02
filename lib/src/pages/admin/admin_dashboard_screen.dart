import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart'; // For Lottie animation
import 'select_venue_screen.dart';
import 'select_course_screen.dart';
import 'view_records_screen.dart';
import 'about_screen.dart';
import '../auth_screen.dart';

class AdminDashboard extends StatelessWidget {
  final String adminName;

  const AdminDashboard({Key? key, required this.adminName}) : super(key: key);


  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirm Logout"),
          content: const Text("Are you sure you want to log out?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const AuthScreen()), // Redirect to AuthScreen
                );
              },
              child: const Text("Logout", style: TextStyle(color: Colors.red)),
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
        title: const Text(
          "(Admin Panel)",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFFFFDF00), // Updated text color to yellow
          ),
        ),
        backgroundColor: const Color(0xFF0A0A23), // Updated background color to dark
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFFFFDF00)), // Updated icon color to yellow
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: const BoxDecoration(color: Color(0xFFFFDF00)),
              child: const Text(
                'Admin Menu',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0A0A23), // Updated text color to dark
                ),
              ),
            ),
            _buildDrawerItem(context, Icons.location_on, 'Select Venue', const SelectVenueScreen()),
            _buildDrawerItem(context, Icons.book, 'Select Course', const SelectCourseScreen()),
            _buildDrawerItem(context, Icons.list, 'View Records', const ViewRecordsScreen()),
            _buildDrawerItem(context, Icons.info, 'About', const AboutScreen()),
            const Divider(), // Adds a separator
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text(
                "Logout",
                style: TextStyle(color: Colors.red),
              ),
              onTap: () {
                _showLogoutDialog(context);
              },
            ),
          ],
        ),
      ),
      backgroundColor: const Color(0xFF0A0A23), // Set background color to dark
      body: Padding(
        padding: const EdgeInsets.all(16.0), // Padding to prevent overflow
        child: SingleChildScrollView(
          child: Center( // Centers the content
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center, // Centers vertically
              crossAxisAlignment: CrossAxisAlignment.center, // Centers horizontally
              children: [
                // Lottie animation at the top
                Lottie.asset('assets/animations/avQgOpX2S4.json', height: 200),
                const SizedBox(height: 20),

                // Welcome Text
                Text(
                  "Welcome, $adminName!",
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFFFDF00), // Updated text color to yellow
                  ),
                ),
                const SizedBox(height: 20),

                // Dashboard Buttons
                _buildDashboardButton(context, Icons.location_on, "Select Venue", const SelectVenueScreen()),
                _buildDashboardButton(context, Icons.book, "Select Course", const SelectCourseScreen()),
                _buildDashboardButton(context, Icons.list, "View Records", const ViewRecordsScreen()),
                _buildDashboardButton(context, Icons.info, "About", const AboutScreen()),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Button Builder
  Widget _buildDashboardButton(BuildContext context, IconData icon, String label, Widget page) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ElevatedButton.icon(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => page));
        },
        icon: Icon(icon, color: const Color(0xFF0A0A23)), // Icon color dark
        label: Text(
          label,
          style: const TextStyle(color: Color(0xFF0A0A23)), // Text color dark
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFFDF00), // Button background color yellow
          foregroundColor: Colors.white,
          minimumSize: const Size(220, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
    );
  }

  // Drawer Item Builder
  Widget _buildDrawerItem(BuildContext context, IconData icon, String title, Widget page) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF0A0A23)), // Icon color dark
      title: Text(
        title,
        style: const TextStyle(color: Color(0xFF0A0A23)), // Text color dark
      ),
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => page));
      },
    );
  }
}
