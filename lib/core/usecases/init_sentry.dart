import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

Future<void> initSentry({required Widget mainApp}) async {
  await SentryFlutter.init(
    (options) {
      options.dsn =
          // kDebugMode ? "false-yet" :
          dotenv.env['SENTRY_DSN'] ?? "false-yet";

      options.sendDefaultPii = true;
    },
    appRunner: () => runApp(
      SentryWidget(
        child: mainApp,
      ),
    ),
  );
}
