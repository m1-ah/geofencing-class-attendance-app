import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'admin_signup_screen.dart';
import 'admin_signin_screen.dart';

class AdminAuthScreen extends StatelessWidget {
  const AdminAuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A23), // Dark background
      appBar: AppBar(
        backgroundColor: Colors.transparent, // Makes AppBar blend with background
        elevation: 0, // Removes shadow
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20), // Adds padding around the screen
          child: Column(
            mainAxisSize: MainAxisSize.min, // Prevents excess spacing
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Animation at the top
              Lottie.asset(
                'assets/animations/avQgOpX2S4.json',
                height: 180,
              ),
              const SizedBox(height: 20),

              // Form Container
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFDF00), // Yellow background
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min, // Prevents unnecessary stretching
                  children: [
                    const Text(
                      'Admin Portal',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0A0A23), // Dark text color
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Admin Sign Up Button
                    SizedBox(
                      width: 250, // Controls button width
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => AdminSignUpScreen()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0A0A23),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text('ADMIN SIGN UP'),
                      ),
                    ),
                    const SizedBox(height: 15),

                    // Admin Sign In Button
                    SizedBox(
                      width: 250,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => AdminSignInScreen()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0A0A23),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text('ADMIN SIGN IN'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
