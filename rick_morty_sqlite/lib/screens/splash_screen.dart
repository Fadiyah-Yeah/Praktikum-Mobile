import 'dart:async';
import 'package:flutter/material.dart';
import '../core/app_colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 2), () {
      if (mounted) Navigator.pushReplacementNamed(context, '/login');
    });
  }

  @override
  Widget build(BuildContext context) => const Scaffold(
    backgroundColor: AppColors.sage,
    body: Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.travel_explore_rounded, size: 58, color: Colors.white),
        SizedBox(height: 15),
        Text('Rick & Morty', style: TextStyle(
          color: Colors.white, fontSize: 25, fontWeight: FontWeight.w700,
        )),
        SizedBox(height: 5),
        Text('Character Explorer', style: TextStyle(color: Colors.white70)),
      ]),
    ),
  );
}
