import 'dart:async';
import 'package:edujarkom/screens/splash/welcome_screen.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Timer untuk pindah halaman setelah 3 detik
    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const WelcomeScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    // Ini adalah mockup splash screen pertama (background putih)
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Image.asset(
          'assets/images/logo.png', // Logo EDUJARKOM
          width: 150,
        ),
      ),
    );
  }
}