import 'package:flutter/material.dart';

class FAQScreen extends StatelessWidget {
  const FAQScreen({super.key});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Frequently Asked Questions (FAQs)',
          style: TextStyle(
            fontSize: screenWidth * 0.05,
            fontWeight: FontWeight.bold,
            fontFamily: 'Poppins-Bold',
            color: Color(0xFF0A0A23),
          ),
        ),
        backgroundColor: Color(0xFFFFDF00),
        centerTitle: true,
        iconTheme: IconThemeData(color: Color(0xFF0A0A23)),
      ),
      backgroundColor: Color(0xFFFFDF00),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.05,
          vertical: screenHeight * 0.02,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildQuestionAnswer(
              'What is BioAuth Attendance System?',
              'BioAuth is an advanced attendance system designed for students and their lecturers. It uses face recognition and geofencing technology to accurately track attendance in classrooms.',
              screenWidth,
              screenHeight,
            ),
            _buildQuestionAnswer(
              'How do I sign up?',
              'Tap on the "SIGN UP" button on the main screen. You will be asked to provide your personal details, matric number, and upload a passport photo with a white background.',
              screenWidth,
              screenHeight,
            ),
            _buildQuestionAnswer(
              'What is geofencing?',
              'Geofencing creates a virtual boundary around a specific location, like your classroom. You need to be within this boundary for your attendance to be marked.',
              screenWidth,
              screenHeight,
            ),
            _buildQuestionAnswer(
              'How does face recognition work?',
              'When you attend a class, the app will use your device\'s camera to capture your face. It then compares this image to your registered facial profile for verification.',
              screenWidth,
              screenHeight,
            ),
            _buildQuestionAnswer(
              'What if my face isn\'t recognized?',
              'Ensure you are in a well-lit area and your face is clearly visible to the camera. If the issue persists, contact your course instructor or technical support.',
              screenWidth,
              screenHeight,
            ),
            _buildQuestionAnswer(
              'Can I use the app on multiple devices?',
              'Currently, your account is linked to a single device. Using multiple devices might lead to attendance discrepancies.',
              screenWidth,
              screenHeight,
            ),
            _buildQuestionAnswer(
              'What if I forget my password?',
              'On the sign-in screen, tap on "Forgot Password" and follow the instructions to reset your password via your registered email.',
              screenWidth,
              screenHeight,
            ),
            _buildQuestionAnswer(
              'How do I check my attendance records?',
              'Navigate to the "Reports" or "Attendance History" section within the app to view your detailed attendance history.',
              screenWidth,
              screenHeight,
            ),
            _buildQuestionAnswer(
              'Is my attendance data secure?',
              'Yes, your attendance data is securely stored on our servers and only accessible to authorized personnel, such as your instructors and administrators.',
              screenWidth,
              screenHeight,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionAnswer(String question, String answer, double screenWidth, double screenHeight) {
    return Card(
      color: Color(0xFFFFDF00), // Matching background color
      elevation: 3,
      margin: EdgeInsets.only(bottom: screenHeight * 0.02),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Color(0xFF0A0A23), width: 1.5),
      ),
      child: ExpansionTile(
        tilePadding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.05,
          vertical: screenHeight * 0.015,
        ),
        title: Text(
          question,
          style: TextStyle(
            fontSize: screenWidth * 0.045,
            fontWeight: FontWeight.bold,
            fontFamily: 'Poppins-Medium',
            color: Color(0xFF0A0A23),
          ),
        ),
        iconColor: Color(0xFF0A0A23),
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(screenWidth * 0.05),
            child: Text(
              answer,
              style: TextStyle(
                fontSize: screenWidth * 0.04,
                fontFamily: 'Bitter',
                color: Color(0xFF0A0A23),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
