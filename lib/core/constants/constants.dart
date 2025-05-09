// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class Constants {
  static const _Colors colors = _Colors();
  static const _TextStyles textStyles = _TextStyles();
  static const _Limits limits = _Limits();
}

class _Colors {
  const _Colors();

  final Color primary = Colors.deepOrange;
  final Color secondary = const Color(0xFF03DAC6);
  final Color error = const Color(0xFFF44336);
  final Color tasksColor = const Color.fromARGB(255, 252, 241, 210);
  final Color tasksColorSec = const Color.fromARGB(255, 250, 245, 233);

  final Color headerColor = const Color.fromARGB(255, 241, 241, 241);
}

class _TextStyles {
  const _TextStyles();

  final TextStyle title = const TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );
  final TextStyle title2 = const TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );
  final TextStyle title3 = const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );
  final TextStyle description = const TextStyle(
    fontSize: 14,
    color: Colors.grey,
  );

  final TextStyle data = const TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w300,
    fontStyle: FontStyle.italic,
  );
}

class _Limits {
  const _Limits();

  final int taskCountLimitPerUser = kDebugMode ? 99 : 3;
  final int userCountLimit = kDebugMode ? 99 : 2;
  // final bool canViewDashboardOnFree = false;
}
