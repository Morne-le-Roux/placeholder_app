import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:placeholder/core/constants/constants.dart';
import 'package:placeholder/main.dart';
import 'package:simple_shadow/simple_shadow.dart';
import 'package:toastification/toastification.dart';

void snack(BuildContext context, String message) {
  log(message);

  String messageToShow = message;

  if (message.contains("message:")) {
    messageToShow = toBeginningOfSentenceCase(
      message.split("message: ")[1].split(", ")[0],
    );
  }

  if (messageToShow == "{}") {
    messageToShow = "An error occurred:";
  }

  if (message.contains("error:")) {
    messageToShow = toBeginningOfSentenceCase(
      message.split("error: ")[1].split(", ")[0],
    );
  }

  if (message.contains("details:")) {
    messageToShow =
        "$messageToShow ${toBeginningOfSentenceCase(message.split("details: ")[1].split(", ")[0])}";
  }

  //Log snacks
  sb.from("snacks").insert({"snack": messageToShow});

  toastification.showCustom(
    alignment: Alignment.bottomCenter,
    autoCloseDuration: const Duration(seconds: 7),
    builder:
        (BuildContext context, ToastificationItem holder) =>
            _ToastWidget(message: messageToShow),
  );
}

class _ToastWidget extends StatelessWidget {
  const _ToastWidget({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return SimpleShadow(
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Constants.colors.error, width: 2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              spacing: 10,
              children: [
                Icon(Icons.error, color: Constants.colors.error),
                Text("An Error Occured", style: Constants.textStyles.title3),
              ],
            ),
            Divider(color: Colors.white.withAlpha(100)),
            Text(message, style: Constants.textStyles.description),
          ],
        ),
      ),
    );
  }
}
