import 'package:english_connect/core/core.dart';
import 'package:english_connect/ui/ui.dart';
import 'package:flutter/material.dart';
import 'package:motion_tab_bar/MotionTabBar.dart';
import 'package:motion_tab_bar/MotionTabBarController.dart';
import 'package:provider/provider.dart';

class AppTabbarScreen extends StatefulWidget {
  const AppTabbarScreen({super.key});

  @override
  State<AppTabbarScreen> createState() => _AppTabbarScreenState();
}

class _AppTabbarScreenState extends State<AppTabbarScreen>
    with TickerProviderStateMixin {
  late MotionTabBarController _motionTabBarController;

  @override
  void initState() {
    super.initState();
    _motionTabBarController = MotionTabBarController(
      initialIndex: 0,
      length: 3,
      vsync: this,
    );
  }

  @override
  void dispose() {
    _motionTabBarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeManager>().currentTheme;

    return BaseView<AppTabbarViewModel>(
      onViewModelReady: (viewModel) {
        if (mounted &&
            _motionTabBarController.index != viewModel.tabbarSelected.index) {
          _motionTabBarController.index = viewModel.tabbarSelected.index;
        }
        _motionTabBarController.animation!.addListener(() {
          final newIndex = _motionTabBarController.index;
          final newTab = AppTabbarExt.getAppTabbar(newIndex);
          if (viewModel.tabbarSelected != newTab) {
            viewModel.setTabbarSelected(newTab, isNeedNotify: false);
          }
        });
      },
      builder: (context, viewModel, _) {
        if (_motionTabBarController.index != viewModel.tabbarSelected.index) {
          _motionTabBarController.index = viewModel.tabbarSelected.index;
        }

        return Scaffold(
          bottomNavigationBar: MotionTabBar(
            controller: _motionTabBarController,
            initialSelectedTab: Strings.homeTab,
            labels: [Strings.homeTab, Strings.gameTab, Strings.settingsTab],
            icons: const [Icons.home, Icons.videogame_asset, Icons.settings],
            tabSize: 50,
            tabBarHeight: 55,
            textStyle: TextStyle(
              color: theme.textColor,
              fontWeight: FontWeight.bold,
            ),
            tabIconColor: theme.iconColor,
            tabIconSelectedColor: theme.primaryColor,
            tabSelectedColor: Colors.white,
            tabBarColor: theme.primaryColor,
            onTabItemSelected: (index) {
              final selected = AppTabbarExt.getAppTabbar(index);
              viewModel.setTabbarSelected(selected);
            },
          ),
          body: IndexedStack(
            index: viewModel.tabbarSelected.index,
            children: const [
              HomeScreen(),
              GameScreen(topicName: ""),
              SettingsScreen(),
            ],
          ),
        );
      },
    );
  }
}
