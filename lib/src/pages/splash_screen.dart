import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:animated_splash_screen/animated_splash_screen.dart';

//import 'dart:async';
import 'auth_screen.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedSplashScreen(
      splash: Center(child: Lottie.asset('assets/animations/vFjyV5D2vT.json')),
      nextScreen: AuthScreen(),
      duration: 3500,
      backgroundColor: Color(0xFF0A0A23),
      splashIconSize: 400,
    );
  }
}