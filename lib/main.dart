import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'src/services/geofence_status_provider.dart';
import 'src/pages/splash_screen.dart';
import 'src/pages/home_page.dart';
import 'src/pages/profile_page.dart';
import 'src/pages/mark_attendance.dart';
import 'src/pages/take_attendance.dart';
import 'src/pages/view_records.dart';
import 'src/pages/face_recognition.dart';
import 'src/pages/dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    ChangeNotifierProvider(
      create: (context) => GeofenceStatusProvider(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Debug banner removed
      title: 'BioAuth Attendance System',
      theme: ThemeData(
        primaryColor: Color(0xFFFFDF00),
        scaffoldBackgroundColor: Color(0xFFFFDF00),
        textTheme: TextTheme(
          bodyLarge: TextStyle(
            color: Color(0xFF0A0A23),
            fontFamily: 'Poppins-Bold',
            fontSize: 20,
          ),
          bodyMedium: TextStyle(
            color: Color(0xFF0A0A23),
            fontFamily: 'Poppins-Medium',
            fontSize: 16,
          ),
          titleLarge: TextStyle(
            color: Color(0xFF0A0A23),
            fontFamily: 'Sansation-Bold',
            fontSize: 24,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF0A0A23),
            foregroundColor: Color(0xFFFFDF00),
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            textStyle: TextStyle(
              fontFamily: 'Poppins-Medium',
              fontSize: 18,
            ),
          ),
        ),
      ),
      initialRoute: "/",
      onGenerateRoute: (settings) {
        final User? user = FirebaseAuth.instance.currentUser;

        switch (settings.name) {
          case "/":
            return MaterialPageRoute(builder: (_) => SplashScreen());
          case "/home":
            return MaterialPageRoute(builder: (_) => HomePage());
          case "/profile":
            if (user != null) {
              return MaterialPageRoute(builder: (_) => ProfilePage(user: user));
            }
            return _redirectToHome();
          case "/mark_attendance":
            return MaterialPageRoute(builder: (_) => MarkAttendance());
          case "/take_attendance":
             return MaterialPageRoute(builder: (_) => TakeAttendance());
          case "/view_records":
            return MaterialPageRoute(builder: (_) => ViewRecords());
          case "/face_recognition":
            return MaterialPageRoute(builder: (_) => FaceRecognition());
          case "/dashboard":
            if (user != null) {
              return MaterialPageRoute(builder: (_) => DashboardScreen(user: user));
            }
            return _redirectToHome();
          default:
            return _redirectToHome();
        }
      },
    );
  }

  // Redirect to HomePage if user is not authenticated
  MaterialPageRoute _redirectToHome() {
    return MaterialPageRoute(builder: (_) => HomePage());
  }
}