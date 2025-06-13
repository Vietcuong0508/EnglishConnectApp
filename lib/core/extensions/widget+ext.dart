import 'package:english_connect/core/core.dart';
import 'package:flutter/cupertino.dart';

extension WidgetExt on Widget {
  void showDialog(BuildContext context, DialogContent dialogContent) {
    showCupertinoDialog(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          title: Text(dialogContent.title),
          content: Text(dialogContent.content),
          actions: getCupertinoActions(
            context,
            dialogContent.buttons,
            dialogContent.buttonActions,
          ),
        );
      },
    );
  }

  List<CupertinoDialogAction> getCupertinoActions(
    BuildContext dialogContext,
    List<String> buttons,
    List<Function> buttonActions,
  ) {
    List<CupertinoDialogAction> actions = [];
    int numberOfActions = buttons.length;
    for (int i = 0; i < numberOfActions; i++) {
      CupertinoDialogAction action = CupertinoDialogAction(
        child: Text(buttons[i]),
        onPressed: () {
          if (i < buttonActions.length) {
            Function callBack = buttonActions[i];
            callBack();
          }
          Navigator.of(dialogContext).pop();
        },
      );
      actions.add(action);
    }
    if (numberOfActions == 0) {
      CupertinoDialogAction action = CupertinoDialogAction(
        child: Text(Strings.ok),
        onPressed: () {
          Navigator.of(dialogContext).pop();
        },
      );
      actions.add(action);
    }
    return actions;
  }
}
