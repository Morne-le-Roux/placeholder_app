import 'package:flutter/material.dart';

import '../widgets/create_user.dart';

Future<void> createNewUser(BuildContext context) async {
  await showModalBottomSheet(
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    context: context,
    builder: (context) => Padding(
        padding: MediaQuery.of(context).viewInsets, child: CreateUser()),
  );
}
