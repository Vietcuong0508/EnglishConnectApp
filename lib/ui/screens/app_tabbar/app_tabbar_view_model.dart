import 'package:english_connect/core/core.dart';
import 'package:english_connect/ui/ui.dart';

class AppTabbarViewModel extends BaseViewModel {
  AppTabBar get tabbarSelected => _tabbarSelected;
  AppTabBar _tabbarSelected = AppTabBar.home;

  void setTabbarSelected(AppTabBar tabbar, {bool isNeedNotify = true}) {
    _tabbarSelected = tabbar;
    if (isNeedNotify) {
      notifyListeners();
    }
  }
}
