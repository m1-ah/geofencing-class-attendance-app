import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _resetPassword() async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: _emailController.text.trim(),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Password reset email sent!',
            style: TextStyle(color: Colors.white, fontFamily: 'Poppins-Medium'),
          ),
          backgroundColor: Color(0xFF0A0A23),
        ),
      );
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Failed to send reset email';
      if (e.code == 'user-not-found') {
        errorMessage = 'No user found for that email.';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            errorMessage,
            style: TextStyle(color: Colors.white, fontFamily: 'Poppins-Medium'),
          ),
          backgroundColor: Color(0xFF0A0A23),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Forgot Password',
          style: TextStyle(
            fontSize: screenWidth * 0.05,
            fontWeight: FontWeight.bold,
            fontFamily: 'Poppins-Bold',
            color: Color(0xFF0A0A23),
          ),
        ),
        backgroundColor: Color(0xFFFFDF00),
        elevation: 0,
        iconTheme: IconThemeData(color: Color(0xFF0A0A23)),
        centerTitle: true,
      ),
      backgroundColor: Color(0xFFFFDF00),
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.07,
          vertical: screenHeight * 0.02,
        ),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                SizedBox(height: screenHeight * 0.1),
                Image.asset(
                  'assets/logo/logo.png', // Optional Logo
                  height: screenHeight * 0.15,
                ),
                SizedBox(height: screenHeight * 0.03),
                Text(
                  'Reset Your Password',
                  style: TextStyle(
                    fontSize: screenWidth * 0.06,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins-Bold',
                    color: Color(0xFF0A0A23),
                  ),
                ),
                SizedBox(height: screenHeight * 0.04),
                TextFormField(
                  controller: _emailController,
                  style: TextStyle(
                    color: Color(0xFF0A0A23),
                    fontFamily: 'Poppins-Medium',
                  ),
                  decoration: InputDecoration(
                    labelText: 'Email',
                    labelStyle: TextStyle(
                      color: Color(0xFF0A0A23),
                      fontFamily: 'Poppins-Medium',
                    ),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF0A0A23)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF0A0A23), width: 2),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    return null;
                  },
                ),
                SizedBox(height: screenHeight * 0.04),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF0A0A23),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.2,
                      vertical: screenHeight * 0.025,
                    ),
                    textStyle: TextStyle(
                      fontSize: screenWidth * 0.045,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Poppins-Bold',
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _resetPassword();
                    }
                  },
                  child: Text('RESET PASSWORD'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
