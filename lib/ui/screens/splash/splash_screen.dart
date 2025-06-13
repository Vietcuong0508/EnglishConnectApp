import 'package:flutter/material.dart';
import '../../../core/constants/strings.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacementNamed(context, '/home');
    });

    return Scaffold(
      body: Center(
        child: Text(Strings.appName, style: TextStyle(fontSize: 24)),
      ),
    );
  }
}
