import 'package:flutter/material.dart';
import 'package:placeholder/features/auth/models/p_h_user.dart';

import '../widgets/create_user.dart';

Future<void> createNewUser(
  BuildContext context, {
  PHUser? user,
  bool isDashboard = false,
}) async {
  await showModalBottomSheet(
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    context: context,
    builder:
        (context) => Padding(
          padding: MediaQuery.of(context).viewInsets,
          child: CreateUser(user: user, isDashboard: isDashboard),
        ),
  );
}
