import 'package:flutter/material.dart';
import 'package:placeholder/core/usecases/is_dark_mode.dart';

class Avatar extends StatelessWidget {
  const Avatar({super.key, required this.url});

  final String? url;

  @override
  Widget build(BuildContext context) {
    return Container(
        height: 40,
        width: 40,
        decoration: BoxDecoration(
            color: isDarkMode(context)
                ? const Color.fromARGB(255, 39, 39, 39)
                : Colors.grey.shade300,
            shape: BoxShape.circle),
        child: url == null
            ? Icon(
                Icons.person_rounded,
                color: isDarkMode(context)
                    ? const Color.fromARGB(255, 153, 153, 153)
                    : Colors.grey.shade400,
              )
            : SizedBox());
  }
}
