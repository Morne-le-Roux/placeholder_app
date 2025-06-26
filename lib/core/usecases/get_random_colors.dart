import 'dart:math';

import 'package:flutter/material.dart';

List<Color> getRandomColors() {
  final firstColor = _randomColors[Random().nextInt(_randomColors.length)];
  // Make the second color even darker by reducing each channel by 40%, but not below 0
  darken(double value) => (value * 0.6).clamp(0, 255).toInt();
  final secondColor = Color.fromARGB(
    255,
    darken(firstColor.r),
    darken(firstColor.g),
    darken(firstColor.b),
  );
  return [firstColor, secondColor];
}

List<Color> _randomColors = [
  Colors.deepPurple.withAlpha(100),
  Colors.deepPurpleAccent.withAlpha(100),
];
