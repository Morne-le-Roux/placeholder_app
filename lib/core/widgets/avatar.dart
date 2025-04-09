import 'package:flutter/material.dart';

class Avatar extends StatelessWidget {
  const Avatar({super.key, required this.url});

  final String? url;

  @override
  Widget build(BuildContext context) {
    return Container(
        height: 40,
        width: 40,
        decoration:
            BoxDecoration(color: Colors.grey.shade300, shape: BoxShape.circle),
        child: url == null
            ? Icon(
                Icons.person_rounded,
                color: Colors.grey.shade400,
              )
            : SizedBox());
  }
}
