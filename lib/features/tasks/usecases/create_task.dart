import 'package:flutter/material.dart';

import '../../auth/models/p_h_user.dart';
import '../widgets/create_task_bottom_sheet.dart';

Future<void> createTask(BuildContext context, PHUser phUser) async {
  await showModalBottomSheet(
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    context: context,
    builder: (context) => Padding(
        padding: MediaQuery.of(context).viewInsets,
        child: CreateTaskBottomSheet(phUser: phUser)),
  );
}
