import 'package:easy_localization/easy_localization.dart';
import 'package:english_connect/core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';

import 'app_route.dart';

GetIt locator = GetIt.instance;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await EasyLocalization.ensureInitialized();
  ServiceLocator.instance.registerDependencies();
  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('vi')],
      path: 'assets/locales',
      fallbackLocale: const Locale('en'),
      child: const EnglishConnectApp(),
    ),
  );
}

class EnglishConnectApp extends StatelessWidget {
  const EnglishConnectApp({super.key});

  @override
  Widget build(BuildContext context) {
    // print("Current locale: ${context.locale}");
    // print("Supported locales: ${context.supportedLocales}");
    // print("Testing translation: ${'app_name'.tr()}");
    // print("Strings.appName: ${Strings.appName}");
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => DataShared.instance),
      ],
      child: MaterialApp(
        title: Strings.appName,
        debugShowCheckedModeBanner: false,
        localizationsDelegates: context.localizationDelegates,
        locale: context.locale,
        supportedLocales: context.supportedLocales,
        theme: ThemeData(primaryColor: AppColors.primaryColor),
        navigatorKey: GlobalKeys.appRootNavigatorKey,
        initialRoute: RouteNames.homeView,
        onGenerateRoute: AppRouter.onGenerateRoute,
      ),
    );
  }
}
