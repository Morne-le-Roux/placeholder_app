import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

Future<void> initRC() async {
  await Purchases.setLogLevel(kDebugMode ? LogLevel.debug : LogLevel.error);

  PurchasesConfiguration configuration;
  configuration = PurchasesConfiguration(dotenv.env['RC_GOOGLE_API_KEY'] ?? "");

  await Purchases.configure(configuration);
}
