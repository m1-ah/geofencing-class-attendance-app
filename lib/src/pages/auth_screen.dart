import 'package:bioauth_attendance_app/src/pages/signup_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'signin_screen.dart';
import 'faq_screen.dart';
import 'admin/admin_auth_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final ButtonStyle elevatedButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: Color(0xFF0A0A23),
    foregroundColor: Colors.white,
    padding: EdgeInsets.symmetric(horizontal: 60, vertical: 20),
    textStyle: TextStyle(fontSize: 20, fontFamily: 'Poppins-Bold'),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        SystemNavigator.pop(); // Exits the app
        return false; // Prevents navigating back
      },
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.deepPurple,
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: elevatedButtonStyle,
          ),
        ),
        home: Scaffold(
          backgroundColor: Color(0xFFFFDF00),
          body: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Lottie.asset('assets/animations/i1ilhLbywu.json', height: 200),
                  SizedBox(height: 20),
                  Text(
                    'Hi, Welcome!',
                    style: TextStyle(
                      fontSize: 30,
                      fontFamily: 'Poppins-Bold',
                      color: Color(0xFF0A0A23),
                    ),
                  ),
                  SizedBox(height: 50),
                  MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => SignUpScreen()),
                        );
                      },
                      child: Text('SIGN UP'),
                    ),
                  ),
                  SizedBox(height: 20),
                  MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => SignInScreen()),
                        );
                      },
                      child: Text('SIGN IN'),
                    ),
                  ),
                  SizedBox(height: 50),
                  MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => FAQScreen()),
                        );
                      },
                      child: Text(
                        'Frequently Asked Questions (FAQs)',
                        style: TextStyle(
                          fontFamily: 'Sansation-Bold',
                          color: Color(0xFF0A0A23),
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 60),
                  MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: SizedBox(
                      width: 300,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => AdminAuthScreen()),
                          );
                        },
                        icon: Icon(Icons.admin_panel_settings, color: Colors.white),
                        label: Text(
                          'USE BioAuth AS AN ADMINISTRATOR',
                          style: TextStyle(
                            fontFamily: 'Bitter-Bold',
                            color: Colors.white,
                            fontSize: 18,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF0A0A23),
                          padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}