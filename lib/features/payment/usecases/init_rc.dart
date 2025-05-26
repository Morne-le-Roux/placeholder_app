import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

Future<void> initRC(String email) async {
  await Purchases.setLogLevel(kDebugMode ? LogLevel.debug : LogLevel.error);

  PackageInfo packageInfo = await PackageInfo.fromPlatform();

  PurchasesConfiguration configuration;
  configuration = PurchasesConfiguration(dotenv.env['RC_GOOGLE_API_KEY'] ?? "")
    ..appUserID = "$email-${packageInfo.packageName}";

  await Purchases.configure(configuration);
}
