import 'package:flutter/material.dart';

bool isDarkMode(BuildContext context) {
  final brightness = MediaQuery.platformBrightnessOf(context);
  return brightness == Brightness.dark;
}
