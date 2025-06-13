enum AppTabBar { home, game, settings }

extension AppTabbarExt on AppTabBar {
  static AppTabBar getAppTabbar(int index) {
    switch (index) {
      case 0:
        return AppTabBar.home;
      case 1:
        return AppTabBar.game;
      case 2:
        return AppTabBar.settings;
      default:
        return AppTabBar.home;
    }
  }
}
