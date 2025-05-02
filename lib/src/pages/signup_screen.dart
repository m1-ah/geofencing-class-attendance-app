import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dashboard_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  bool _isLoading = false;

  Widget _buildTextField(String label, TextEditingController controller, {bool isPassword = false}) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Please enter $label";
        }
        if (label == "Confirm Password" && value != _passwordController.text) {
          return "Passwords do not match";
        }
        return null;
      },
    );
  }

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      // Create user with Firebase Authentication
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      User? user = userCredential.user;

      // Save student details in Firestore
      if (user != null) {
        await FirebaseFirestore.instance.collection('studentsNames').doc(user.uid).set({
          'fullName': _fullNameController.text.trim(),
          'email': user.email,
          'StudentId': user.uid,
          'createdAt': FieldValue.serverTimestamp(), // Store timestamp for reference
        });

        // Navigate to dashboard
        _showBiometricPrompt(user);
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage = "Sign-up failed. Please try again.";
      if (e.code == 'email-already-in-use') {
        errorMessage = "This email is already registered. Try logging in instead.";
      } else if (e.code == 'weak-password') {
        errorMessage = "Your password is too weak. Try a stronger password.";
      }
      _showErrorDialog("Sign-Up Failed", errorMessage);
    } catch (e) {
      _showErrorDialog("Error", "An unexpected error occurred: $e");
    }

    setState(() => _isLoading = false);
  }

  void _showBiometricPrompt(User user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Enable Biometric Authentication?"),
        content: const Text("Would you like to enable fingerprint login for easier access?"),
        actions: [
          TextButton(
            onPressed: () => _navigateToDashboard(user, enableBiometric: false),
            child: const Text("No, Thanks"),
          ),
          TextButton(
            onPressed: () {
              _saveBiometricPreference(true, user);
              _navigateToDashboard(user, enableBiometric: true);
            },
            child: const Text("Enable"),
          ),
        ],
      ),
    );
  }

  Future<void> _saveBiometricPreference(bool enable, User user) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool("useFingerprint", enable);
    await prefs.setString("userEmail", user.email!);
  }

  void _navigateToDashboard(User user, {required bool enableBiometric}) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => DashboardScreen(user: user)),
    );
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.red.shade700,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
        title: Column(
          children: [
            const Icon(Icons.error_outline, color: Colors.white, size: 40),
            const SizedBox(height: 10),
            Text(title, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text(message, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white)),
        actions: [
          Center(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.red.shade700),
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("OK"),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFDF00),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0A0A23)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Lottie.asset('assets/animations/W1ypnS40wH.json', height: 120),
                ),
                const SizedBox(height: 20),
                _buildTextField("Full Name", _fullNameController),
                const SizedBox(height: 10),
                _buildTextField("School Email", _emailController),
                const SizedBox(height: 10),
                _buildTextField("Password", _passwordController, isPassword: true),
                const SizedBox(height: 10),
                _buildTextField("Confirm Password", _confirmPasswordController, isPassword: true),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _signUp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0A0A23),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text("Sign Up", style: TextStyle(fontSize: 18)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}