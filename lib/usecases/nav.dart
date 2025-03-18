import 'package:flutter/material.dart';

class Nav {
  static void push(BuildContext context, Widget screen) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => screen,
            settings: RouteSettings(name: screen.runtimeType.toString())));
  }

  static void pushAndPop(BuildContext context, Widget screen) {
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
            builder: (context) => screen,
            settings: RouteSettings(name: screen.runtimeType.toString())),
        (route) => false);
  }

  static void pop(BuildContext context) {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }

  static void popUntil(BuildContext context, Widget screen,
      {bool pushIfNotFound = false}) {
    if (!Navigator.canPop(context)) {
      push(context, screen);
      return;
    }

    bool foundRoute = false;
    Navigator.popUntil(
      context,
      (route) {
        if (route.settings.name == screen.runtimeType.toString()) {
          foundRoute = true;
          return true;
        }
        return false;
      },
    );

    if (!foundRoute && pushIfNotFound) {
      push(context, screen);
    }
  }
}
