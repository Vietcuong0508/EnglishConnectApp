import 'package:flutter/material.dart';

abstract class ThemeColors {
  String get name;
  Color get primaryColor;
  Color get buttonColor;
  Color get borderColor;
  Color get iconColor;
  Color get textColor;
  Color get shadowColor;
  Color get cardColor;

  RadialGradient get backgroundGradient;
}

// 🌊 1. Blue Fresh Theme
class BlueFreshTheme extends ThemeColors {
  @override
  String get name => "Blue Fresh";
  @override
  Color get primaryColor => const Color(0xFF4FC3F7);
  @override
  Color get buttonColor => const Color(0xFF26C6DA);
  @override
  Color get borderColor => const Color(0xFF6C63FF);
  @override
  Color get iconColor => const Color(0xFF7C83FD);
  @override
  Color get textColor => const Color(0xFF37474F);
  @override
  Color get shadowColor => const Color(0x406C63FF);
  @override
  Color get cardColor => const Color(0xFFE0F7FA);

  @override
  RadialGradient get backgroundGradient => const RadialGradient(
    center: Alignment(0, 1.3),
    radius: 1.0,
    colors: [
      Color.fromARGB(255, 255, 253, 154), // yellow center
      Color.fromARGB(255, 128, 251, 232), // teal edge
    ],
    stops: [0.0, 1.0],
  );
}

// 🍋 2. Lemon Peach Theme
class LemonPeachTheme extends ThemeColors {
  @override
  String get name => "Lemon Peach";
  @override
  Color get primaryColor => const Color(0xFFFFF176); // Lemon
  @override
  Color get buttonColor => const Color(0xFFFFCC80); // Peach
  @override
  Color get borderColor => const Color(0xFFFFB74D);
  @override
  Color get iconColor => const Color(0xFFF57C00);
  @override
  Color get textColor => const Color(0xFF4E342E);
  @override
  Color get shadowColor => const Color(0x40F57C00);
  @override
  Color get cardColor => const Color(0xFFFFF8E1);

  @override
  RadialGradient get backgroundGradient => const RadialGradient(
    center: Alignment(0, 1.3),
    radius: 1.0,
    colors: [
      Color.fromARGB(255, 255, 253, 154), // yellow center
      Color.fromARGB(255, 128, 251, 232), // teal edge
    ],
    stops: [0.0, 1.0],
  );
}

// 🌺 3. Coral Breeze Theme
class CoralBreezeTheme extends ThemeColors {
  @override
  String get name => "Coral Breeze";
  @override
  Color get primaryColor => const Color(0xFFFF8A65); // Coral
  @override
  Color get buttonColor => const Color(0xFFFFAB91);
  @override
  Color get borderColor => const Color(0xFFEF5350);
  @override
  Color get iconColor => const Color(0xFFD84315);
  @override
  Color get textColor => const Color(0xFF3E2723);
  @override
  Color get shadowColor => const Color(0x40D84315);
  @override
  Color get cardColor => const Color(0xFFFFEBEE);

  @override
  RadialGradient get backgroundGradient => const RadialGradient(
    center: Alignment(0, 1.3),
    radius: 1.0,
    colors: [
      Color.fromARGB(255, 255, 253, 154), // yellow center
      Color.fromARGB(255, 128, 251, 232), // teal edge
    ],
    stops: [0.0, 1.0],
  );
}

// 🍬 4. Candy Soft Theme
class CandySoftTheme extends ThemeColors {
  @override
  String get name => "Candy Soft";
  @override
  Color get primaryColor => const Color(0xFFE1BEE7); // Light purple
  @override
  Color get buttonColor => const Color(0xFFF8BBD0); // Pink
  @override
  Color get borderColor => const Color(0xFFCE93D8);
  @override
  Color get iconColor => const Color(0xFFAB47BC);
  @override
  Color get textColor => const Color(0xFF4A148C);
  @override
  Color get shadowColor => const Color(0x404A148C);
  @override
  Color get cardColor => const Color(0xFFF3E5F5);

  @override
  RadialGradient get backgroundGradient => const RadialGradient(
    center: Alignment(0, 1.3),
    radius: 1.0,
    colors: [
      Color.fromARGB(255, 255, 253, 154), // yellow center
      Color.fromARGB(255, 128, 251, 232), // teal edge
    ],
    stops: [0.0, 1.0],
  );
}

// 🍃 5. Nature Calm Theme
class NatureCalmTheme extends ThemeColors {
  @override
  String get name => "Nature Calm";
  @override
  Color get primaryColor => const Color(0xFFA5D6A7); // Green
  @override
  Color get buttonColor => const Color(0xFF80CBC4); // Aqua
  @override
  Color get borderColor => const Color(0xFF4DB6AC);
  @override
  Color get iconColor => const Color(0xFF00796B);
  @override
  Color get textColor => const Color(0xFF263238);
  @override
  Color get shadowColor => const Color(0x4000796B);
  @override
  Color get cardColor => const Color(0xFFE8F5E9);

  @override
  RadialGradient get backgroundGradient => const RadialGradient(
    center: Alignment(0, 1.3),
    radius: 1.0,
    colors: [
      Color.fromARGB(255, 255, 253, 154), // yellow center
      Color.fromARGB(255, 128, 251, 232), // teal edge
    ],
    stops: [0.0, 1.0],
  );
}
