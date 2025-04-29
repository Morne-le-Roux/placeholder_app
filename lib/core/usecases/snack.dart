import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:placeholder/core/constants/constants.dart';
import 'package:placeholder/core/usecases/nav.dart';
import 'package:url_launcher/url_launcher.dart';

void snack(context, String message) {
  showDialog(
      barrierColor: Colors.black.withOpacity(0.5),
      barrierDismissible: true,
      context: context,
      builder: (context) => Material(
            color: Colors.transparent,
            child: Center(
              child: Container(
                margin: EdgeInsets.all(20),
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 30, 30, 30),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: Colors.white,
                    width: 2,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Something went wrong",
                      style: Constants.textStyles.title2,
                    ),
                    Gap(10),
                    Text(
                        """We've logged this error and the let the developers know.
                        
If this is not the first time you are getting this error, please contact support.""",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                        )),
                    Gap(10),
                    Text(
                      message,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.white, fontStyle: FontStyle.italic),
                      maxLines: 4,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                            style: ButtonStyle(
                                padding:
                                    WidgetStateProperty.all(EdgeInsets.zero)),
                            onPressed: () {
                              Nav.pop(context);
                              // ignore: deprecated_member_use
                              launchUrl(Uri.parse(
                                  "mailto:placeholder-support@disnetdev.co.za?subject=Support Request&body=Hi!\nI am getting this following error: \n\n\n $message"));
                            },
                            child: Text("Contact Support")),
                        TextButton(
                            onPressed: () {
                              Nav.pop(context);
                            },
                            child: Text("Close")),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ));
}
