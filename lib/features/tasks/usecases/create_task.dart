import 'package:flutter/material.dart';
import 'package:placeholder/features/tasks/models/task.dart';

import '../../auth/models/p_h_user.dart';
import '../widgets/create_task_bottom_sheet.dart';

Future<Task?> createTask(
  BuildContext context, {
  required PHUser phUser,
  Task? task,
}) async {
  Task? returnedTask;

  await showModalBottomSheet(
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    context: context,
    builder:
        (context) => Padding(
          padding: MediaQuery.of(context).viewInsets,
          child: CreateTaskBottomSheet(
            phUser: phUser,
            task: task,
            onTaskCreated: (newTask) {
              returnedTask = newTask;
            },
          ),
        ),
  );

  return returnedTask;
}
