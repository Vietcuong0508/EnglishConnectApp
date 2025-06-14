import 'package:english_connect/core/core.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeManager extends ChangeNotifier {
  static const _themeKey = 'selected_theme';

  ThemeColors _currentTheme = BlueFreshTheme(); // Mặc định

  ThemeColors get currentTheme => _currentTheme;

  // Đặt theme mới và lưu vào local
  Future<void> setTheme(ThemeColors theme) async {
    _currentTheme = theme;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, theme.runtimeType.toString());
  }

  // Load theme từ local khi app khởi động
  Future<void> loadThemeFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final savedThemeName = prefs.getString(_themeKey);

    _currentTheme = _getThemeByName(savedThemeName) ?? BlueFreshTheme();
    notifyListeners();
  }

  // Xoay vòng themes
  void switchTheme() {
    if (_currentTheme is BlueFreshTheme) {
      setTheme(LemonPeachTheme());
    } else if (_currentTheme is LemonPeachTheme) {
      setTheme(CoralBreezeTheme());
    } else if (_currentTheme is CoralBreezeTheme) {
      setTheme(CandySoftTheme());
    } else if (_currentTheme is CandySoftTheme) {
      setTheme(NatureCalmTheme());
    } else {
      setTheme(BlueFreshTheme());
    }
  }

  // Trả về instance tương ứng từ tên class (chuỗi)
  ThemeColors? _getThemeByName(String? name) {
    switch (name) {
      case 'BlueFreshTheme':
        return BlueFreshTheme();
      case 'LemonPeachTheme':
        return LemonPeachTheme();
      case 'CoralBreezeTheme':
        return CoralBreezeTheme();
      case 'CandySoftTheme':
        return CandySoftTheme();
      case 'NatureCalmTheme':
        return NatureCalmTheme();
      default:
        return null;
    }
  }
}
