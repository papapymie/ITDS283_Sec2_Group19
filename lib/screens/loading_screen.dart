import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Import all screens
import 'home_screen.dart';
import 'login_screen.dart';
import 'location_screen.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  @override
  void initState() {
    super.initState();
    _navigateAfterLoading();
  }

  Future<void> _navigateAfterLoading() async {
  await Future.delayed(const Duration(seconds: 3));
  if (!mounted) return;

  await FirebaseAuth.instance.authStateChanges().first;
  
  if (!mounted) return;

  final User? currentUser = FirebaseAuth.instance.currentUser;
  if (currentUser != null) {
    Navigator.pushReplacementNamed(context, '/home');
  } else {
    Navigator.pushReplacementNamed(context, '/login');
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEAF8F6),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/logoapp.png',
                width: 120,
                height: 120,
              ),

              const SizedBox(height: 30),

              LoadingAnimationWidget.waveDots(
                color: const Color(0xFF4A6360),
                size: 75,
              ),

              const SizedBox(height: 10),

              const Text(
                'LOADING...',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                  color: Color(0xFF4A6360),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}