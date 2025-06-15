import 'package:english_connect/core/core.dart';
import 'package:english_connect/ui/ui.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rive/rive.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.08,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // void _startRandomGame() {
  //   final randomTopic = (topics..shuffle()).first;
  //   Navigator.pushNamed(context, '/game', arguments: randomTopic);
  // }

  // void _showTopicList() {
  //   showModalBottomSheet(
  //     context: context,
  //     shape: const RoundedRectangleBorder(
  //       borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
  //     ),
  //     builder:
  //         (_) => Column(
  //           mainAxisSize: MainAxisSize.min,
  //           children: [
  //             const Padding(
  //               padding: EdgeInsets.all(16.0),
  //               child: Text(
  //                 'Chọn Chủ Đề',
  //                 style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
  //               ),
  //             ),
  //             ...topics.map(
  //               (topic) => ListTile(
  //                 title: Text(topic),
  //                 onTap: () {
  //                   Navigator.pop(context);
  //                   Navigator.pushNamed(context, '/game', arguments: topic);
  //                 },
  //               ),
  //             ),
  //           ],
  //         ),
  //   );
  // }

  Widget buildCircleButton({
    required IconData icon,
    required VoidCallback onTap,
    required ThemeColors theme,
    double size = 60,
    double iconSize = 30,
    String? label,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: theme.buttonColor,
              shape: BoxShape.circle,
              border: Border.all(color: theme.borderColor, width: 2),
              boxShadow: [
                BoxShadow(
                  color: theme.shadowColor,
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(icon, color: theme.iconColor, size: iconSize),
          ),
        ),
        if (label != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              label,
              style: TextStyle(color: theme.textColor, fontSize: 12),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeManager>().currentTheme;

    return BaseView<HomeViewModel>(
      onViewModelReady: (viewModel) async {
        await viewModel.loadRandomWords();
      },
      builder: (context, viewModel, _) {
        return Scaffold(
          body: Stack(
            children: [
              SizedBox.expand(
                child: RiveAnimation.asset(
                  'assets/animations/big_ben_english.riv',
                  fit: BoxFit.cover,
                ),
              ),
              // Nút PLAY ở giữa
              Align(
                alignment: Alignment.center,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        '/game',
                        arguments: {"randomWord": viewModel.selectedWords},
                      );
                    },
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: theme.buttonColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: theme.borderColor, width: 4),
                        boxShadow: [
                          BoxShadow(
                            color: theme.shadowColor,
                            blurRadius: 12,
                            spreadRadius: 2,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.play_arrow,
                              size: 40,
                              color: theme.iconColor,
                            ),
                            Text(
                              "PLAY",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: theme.textColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Nút Cài đặt
              Positioned(
                top: 40,
                right: 16,
                child: buildCircleButton(
                  theme: theme,
                  icon: Icons.settings,
                  size: 40,
                  iconSize: 20,
                  onTap: () {
                    Navigator.pushNamed(context, '/settings');
                  },
                  // label: "Cài đặt",
                ),
              ),

              // Nút chọn chủ đề (phải)
              Positioned(
                bottom: 40,
                right: 16,
                child: buildCircleButton(
                  theme: theme,
                  icon: Icons.menu_book_rounded,
                  size: 40,
                  iconSize: 20,
                  onTap: () {
                    Navigator.pushNamed(context, '/topic');
                  },
                  // label: "Chủ đề",
                ),
              ),

              // Nút chọn chủ đề (trái - có thể thay bằng nút khác)
              Positioned(
                bottom: 40,
                left: 16,
                child: buildCircleButton(
                  theme: theme,
                  icon: Icons.manage_accounts_rounded,
                  size: 40,
                  iconSize: 20,
                  onTap: () {
                    Navigator.pushNamed(context, '/profile');
                  },
                  // label: "Tài khoản",
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
