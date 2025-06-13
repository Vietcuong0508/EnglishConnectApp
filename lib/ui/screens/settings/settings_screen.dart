import 'package:english_connect/core/core.dart';
import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(gradient: AppColors.backgroundGradient),
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            foregroundColor: AppColors.primaryColor,
            title: Text(Strings.settingsTab),
          ),
          body: Center(
            child: Text(
              'Settings Screen',
              style: TextStyle(fontSize: 24, color: Colors.black54),
            ),
          ),
        ),
      ],
    );
  }
}
