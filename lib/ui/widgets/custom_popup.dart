import 'package:english_connect/core/core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CustomPopup extends StatelessWidget {
  final IconData? icon;
  final Color? iconColor;
  final String titleText;
  final Color? titleColor;
  final String contentText;
  final IconData? contentIcon;
  final String? descriptionText;
  final String result;
  final String? textBtnleft;
  final String? textBtnRight;
  final int currentLevel;
  final int totalLevels;
  final VoidCallback? onBtnLeft;
  final VoidCallback onBtnRight;
  final VoidCallback? onContentIcon;

  const CustomPopup({
    super.key,
    this.icon,
    this.iconColor,
    required this.titleText,
    this.titleColor,
    required this.contentText,
    this.contentIcon,
    this.descriptionText,
    required this.result,
    this.textBtnleft,
    this.textBtnRight,
    required this.currentLevel,
    required this.totalLevels,
    this.onBtnLeft,
    required this.onBtnRight,
    this.onContentIcon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeManager>().currentTheme;

    return AlertDialog(
      backgroundColor: theme.cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null)
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Icon(icon, color: iconColor, size: 30),
            ),
          Text(
            titleText,
            style: TextStyle(
              color: titleColor ?? theme.textColor,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(contentText, textAlign: TextAlign.center),
              if (contentIcon != null)
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: InkWell(
                    onTap: onContentIcon,
                    borderRadius: BorderRadius.circular(20),
                    splashColor: theme.primaryColor,
                    child: Container(
                      margin: const EdgeInsets.all(8.0),
                      child: Icon(
                        contentIcon,
                        color: theme.iconColor,
                        size: 24,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          if (descriptionText != null)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                descriptionText ?? '',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
        ],
      ),
      actions: [
        if (currentLevel < totalLevels - 1 && textBtnleft != null)
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.buttonColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            onPressed: () {
              Navigator.pop(context);
              onBtnLeft!();
            },
            child: Text(textBtnleft ?? ''),
          ),
        OutlinedButton(
          style: OutlinedButton.styleFrom(
            foregroundColor: theme.buttonColor,
            side: BorderSide(color: theme.buttonColor, width: 2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
          onPressed: () {
            Navigator.pop(context);
            onBtnRight();
          },
          child: Text(textBtnRight ?? ''),
        ),
      ],
    );
  }
}
