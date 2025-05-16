import 'dart:math';

import 'package:flutter/material.dart';

List<Color> getRandomColors() {
  final r = Random().nextInt(256);
  final g = Random().nextInt(256);
  final b = Random().nextInt(256);
  final firstColor = Color.fromARGB(255, r, g, b);
  // Make the second color even darker by reducing each channel by 40%, but not below 0
  darken(int value) => (value * 0.6).clamp(0, 255).toInt();
  final secondColor = Color.fromARGB(255, darken(r), darken(g), darken(b));
  return [firstColor, secondColor];
}
