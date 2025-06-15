import 'package:english_connect/main.dart';
import 'package:english_connect/ui/ui.dart';

enum DependencyInstance { nwUsecaseProvider }

class ServiceLocator {
  static final instance = ServiceLocator._internal();

  ServiceLocator._internal();

  void registerDependencies() {
    _registerViewModel();
  }

  void _registerViewModel() {
    locator.registerFactory<AppTabbarViewModel>(() => AppTabbarViewModel());
    locator.registerFactory<HomeViewModel>(() => HomeViewModel());
    locator.registerFactory<GameViewModel>(() => GameViewModel());
    locator.registerFactory<SettingsViewModel>(() => SettingsViewModel());
    locator.registerFactory<ProfileViewModel>(() => ProfileViewModel());
    locator.registerFactory<TopicViewModel>(() => TopicViewModel());
  }
}
