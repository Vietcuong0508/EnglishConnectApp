// theme_helper.dart
import 'package:english_connect/core/core.dart';
import 'package:flutter/material.dart';

ThemeData createThemeFrom(ThemeColors theme) {
  return ThemeData(
    primaryColor: theme.primaryColor,
    // scaffoldBackgroundColor: theme.backgroundGradient.colors.first,
    cardColor: theme.cardColor,
    iconTheme: IconThemeData(color: theme.iconColor),
    textTheme: TextTheme(bodyMedium: TextStyle(color: theme.textColor)),
    appBarTheme: AppBarTheme(
      backgroundColor: theme.primaryColor,
      foregroundColor: theme.buttonColor,
      elevation: 0,
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: theme.primaryColor,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: theme.primaryColor,
        foregroundColor: theme.buttonColor,
      ),
    ),
    colorScheme: ColorScheme.fromSwatch().copyWith(
      primary: theme.primaryColor,
      secondary: theme.buttonColor,
    ),
  );
}
