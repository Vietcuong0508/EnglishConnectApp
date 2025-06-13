import 'package:flutter/material.dart';

class AppColors {
  static const Color gradientEdge = Color.fromARGB(255, 128, 251, 232);
  static const Color gradientCenter = Color.fromARGB(255, 255, 253, 154);

  static const RadialGradient backgroundGradient = RadialGradient(
    center: Alignment(0, 1.3),
    radius: 1.0,
    colors: [gradientCenter, gradientEdge],
    stops: [0.0, 1.0],
  );

  static const primaryColor = Color(0xFF6C63FF);
  static const buttonColor = Color(0xFFFFFFFF);
  static const borderColor = Color(0xFF6C63FF);
  static const iconColor = Color(0xFF7C83FD);
  static const textColor = Color(0xFF3C3C3C);
  static const shadowColor = Color(0x406C63FF);
  static const cardColor = Color(0xFFE8EAF6);
}
