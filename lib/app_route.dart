import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'ui/ui.dart';

class RouteNames {
  static const tabbarView = "/tabbar";
  static const homeView = "/home";
  static const gameView = "/game";
  static const settingsView = "/settings";
  static const profileView = "/profile";
  static const topicView = "/topic";
}

class AppRouter {
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    dynamic arguments = settings.arguments;
    switch (settings.name) {
      case RouteNames.tabbarView:
        return CupertinoPageRoute(builder: (_) => const AppTabbarScreen());
      case RouteNames.homeView:
        return CupertinoPageRoute(builder: (_) => const HomeScreen());
      case RouteNames.gameView:
        return CupertinoPageRoute(builder: (_) => const GameScreen());
      case RouteNames.settingsView:
        return CupertinoPageRoute(builder: (_) => const SettingsScreen());
      case RouteNames.profileView:
        return CupertinoPageRoute(builder: (_) => const ProfileScreen());
      case RouteNames.topicView:
        if (arguments is String) {
          return CupertinoPageRoute(builder: (_) => TopicScreen());
        } else {
          return CupertinoPageRoute(builder: (_) => TopicScreen());
        }
      default:
        return CupertinoPageRoute(
          builder:
              (_) => Scaffold(
                body: Center(
                  child: Text('No route defined for ${settings.name}.'),
                ),
              ),
        );
    }
  }
}
