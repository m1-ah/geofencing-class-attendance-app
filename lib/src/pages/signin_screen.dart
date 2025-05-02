import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lottie/lottie.dart';
import 'dashboard_screen.dart';
import 'forgotpassword_screen.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isSubmitEnabled = false;
  bool _isLoading = false;
  final LocalAuthentication _localAuth = LocalAuthentication();

  Future<void> _submitSignInForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      var connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        _showErrorDialog("No Internet Connection", "Please check your network.", Icons.wifi_off);
        setState(() => _isLoading = false);
        return;
      }

      try {
        UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        String userUID = userCredential.user!.uid;

        // 🔹 Fetch the student document
        DocumentSnapshot studentDoc = await FirebaseFirestore.instance
            .collection('studentsNames')
            .doc(userUID)
            .get();

        if (!studentDoc.exists) {
          await FirebaseAuth.instance.signOut(); // Sign out unauthorized user
          throw FirebaseAuthException(code: 'user-not-student', message: 'This account is not a student.');
        }

        // 🔹 Save credentials locally
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('email', _emailController.text.trim());
        prefs.setString('password', _passwordController.text.trim());

        // 🔹 Navigate to the dashboard
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => DashboardScreen(user: userCredential.user!)),
        );

      } on FirebaseAuthException catch (e) {
        String errorMessage = "Invalid Credentials!";
        if (e.code == 'user-not-found' || e.code == 'wrong-password') {
          errorMessage = "Invalid email or password.";
        } else if (e.code == 'user-not-student') {
          errorMessage = "This account is not a student.";
        }
        _showErrorDialog("Login Failed", errorMessage, Icons.error);
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }


  void _showErrorDialog(String title, String message, IconData icon) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(icon, color: Colors.red),
            SizedBox(width: 10),
            Text(title),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("OK"),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, {bool isPassword = false}) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
      ),
      validator: (value) => value!.isEmpty ? "$label cannot be empty" : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Color(0xFFFFDF00),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Color(0xFF0A0A23)),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Lottie.asset('assets/animations/W1ypnS40wH.json', height: 120),
                    SizedBox(height: 20),
                    Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, spreadRadius: 2),
                        ],
                      ),
                      child: Form(
                        key: _formKey,
                        onChanged: () => setState(() => _isSubmitEnabled = _formKey.currentState!.validate()),
                        child: Column(
                          children: [
                            Text("Student Sign In", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black)),
                            SizedBox(height: 15),
                            _buildTextField(_emailController, "School Email"),
                            SizedBox(height: 10),
                            _buildTextField(_passwordController, "Password", isPassword: true),
                            SizedBox(height: 10),
                            TextButton(
                              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ForgotPasswordScreen())),
                              child: Text("Forgot Password?", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                            ),
                            SizedBox(height: 10),
                            ElevatedButton(
                              onPressed: _isSubmitEnabled && !_isLoading ? _submitSignInForm : null,
                              child: _isLoading ? CircularProgressIndicator() : Text("Sign In"),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}