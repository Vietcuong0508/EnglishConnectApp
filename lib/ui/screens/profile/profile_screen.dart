import 'package:english_connect/core/core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeManager>().currentTheme;

    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(gradient: theme.backgroundGradient),
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            title: Text(Strings.profile),
          ),
          body: Center(child: Text('Profile Screen')),
        ),
      ],
    );
  }
}
