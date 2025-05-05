import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:placeholder/core/constants/constants.dart';
import 'package:placeholder/core/usecases/contact_support.dart';
import 'package:placeholder/core/usecases/nav.dart';

void snack(context, String message, {bool isError = true}) {
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
                    if (isError)
                    Text(
                      "Something went wrong",
                      style: Constants.textStyles.title2,
                    ),
                    if (isError)
                    Gap(10),
                    if (isError)
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
                      style: isError ? TextStyle(
                          color: Colors.white, fontStyle: FontStyle.italic) : TextStyle(
                          color: Colors.white, fontStyle: FontStyle.italic, fontSize: 18),
                      maxLines: 4,
                    ),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (isError)
                        TextButton(
                            style: ButtonStyle(
                                padding:
                                    WidgetStateProperty.all(EdgeInsets.zero)),
                            onPressed: () {
                              Nav.pop(context);
                              // ignore: deprecated_member_use
                              contactSupport(message);
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


