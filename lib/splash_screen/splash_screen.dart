import 'dart:async';

import 'package:flutter/material.dart';

import '../Home.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize the animation controller
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    // Define the rotation animation (from 0 to 360 degrees)
    _rotationAnimation = Tween<double>(begin: 0.0, end: 2 * 3.14159).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    // Start the animations
    _controller.forward();

    // Set the animation to repeat indefinitely
    // _controller.repeat();

    // Navigate to the main screen after the splash screen duration
    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Home()),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.amber, // Background color of splash screen
      body: Center(
        child: RotationTransition(
          turns: _rotationAnimation, // This applies the rotation animation
          child: Container(
            width: 100, // Set the width of the box
            height: 100, // Set the height of the box
            color: Colors.white, // Set the color of the box
            child: const Center(
              child: Text(
                'Notes', // Optional: Text inside the box
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.amber,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
