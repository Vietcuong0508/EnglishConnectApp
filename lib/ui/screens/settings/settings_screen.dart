import 'package:english_connect/core/core.dart';
import 'package:english_connect/ui/ui.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currentTheme = context.watch<ThemeManager>().currentTheme;

    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(gradient: currentTheme.backgroundGradient),
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            title: const Text('Cài đặt'),
          ),
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: CustomButton(
              title: 'Chọn Giao Diện',
              onPressed: () => _showThemeSelection(context),
              icon: Icons.color_lens,
              // padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            ),
          ),
        ),
      ],
    );
  }

  void _showThemeSelection(BuildContext context) {
    final themes = [
      BlueFreshTheme(),
      LemonPeachTheme(),
      CoralBreezeTheme(),
      CandySoftTheme(),
      NatureCalmTheme(),
    ];
    final themeManager = context.read<ThemeManager>();
    final current = themeManager.currentTheme;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Chọn Giao Diện',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children:
                      themes.map((theme) {
                        final isSelected =
                            theme.runtimeType == current.runtimeType;
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: GestureDetector(
                            onTap: () {
                              themeManager.setTheme(theme);
                              Navigator.pop(context);
                            },
                            child: Column(
                              children: [
                                CircleAvatar(
                                  radius: isSelected ? 28 : 24,
                                  backgroundColor: theme.primaryColor,
                                  child:
                                      isSelected
                                          ? const Icon(
                                            Icons.check,
                                            color: Colors.white,
                                          )
                                          : null,
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  theme.name,
                                  style: TextStyle(
                                    fontSize: 10,
                                    color:
                                        isSelected
                                            ? theme.primaryColor
                                            : Colors.black87,
                                    fontWeight:
                                        isSelected
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  // Widget _buildThemeOption(BuildContext context, ThemeColors theme) {
  //   final themeManager = context.read<ThemeManager>();
  //   final isSelected =
  //       theme.runtimeType == themeManager.currentTheme.runtimeType;

  //   return ListTile(
  //     leading: Icon(Icons.circle, color: theme.primaryColor),
  //     title: Text(theme.name),
  //     trailing:
  //         isSelected ? const Icon(Icons.check, color: Colors.green) : null,
  //     onTap: () {
  //       themeManager.setTheme(theme);
  //       Navigator.pop(context);
  //     },
  //   );
  // }
}
