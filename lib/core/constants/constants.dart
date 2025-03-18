// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';

class Constants {
  static const _Colors colors = _Colors();
  static const _TextStyles textStyles = _TextStyles();
}

class _Colors {
  const _Colors();

  final Color primary = const Color(0xFF2196F3);
  final Color secondary = const Color(0xFF03DAC6);
  final Color error = const Color(0xFFF44336);
}

class _TextStyles {
  const _TextStyles();

  final TextStyle title =
      const TextStyle(fontSize: 24, fontWeight: FontWeight.bold);
}
