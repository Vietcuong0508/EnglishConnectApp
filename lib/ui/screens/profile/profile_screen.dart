import 'package:english_connect/core/constants/colors.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(gradient: AppColors.backgroundGradient),
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            foregroundColor: AppColors.primaryColor,
            title: Text('Profile'),
          ),
          body: Center(child: Text('Profile Screen')),
        ),
      ],
    );
  }
}
