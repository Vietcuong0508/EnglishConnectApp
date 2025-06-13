import 'package:flutter/material.dart';

class GlobalKeys {
  static final appRootNavigatorKey = GlobalKey<NavigatorState>();
  static final homeRootNavigatorKey = GlobalKey<NavigatorState>(
    debugLabel: "homeRootNavigatorKey",
  );
  static final gameRootNavigatorKey = GlobalKey<NavigatorState>(
    debugLabel: "gameRootNavigatorKey",
  );
  static final settingsRootNavigatorKey = GlobalKey<NavigatorState>(
    debugLabel: "settingsRootNavigatorKey",
  );
}
