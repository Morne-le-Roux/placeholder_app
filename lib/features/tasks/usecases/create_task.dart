import 'package:flutter/material.dart';
import 'package:placeholder/features/tasks/models/task.dart';

import '../../auth/models/p_h_user.dart';
import '../widgets/create_task_bottom_sheet.dart';

Future<Task?> createTask(
  BuildContext context, {
  required PHUser phUser,
  Task? task,
  String? parentIdIfNew,
  bool? recurringIfChild,
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
            recurringIfChild: recurringIfChild,
            phUser: phUser,
            task: task,
            parentTaskIdIfNew: parentIdIfNew,
            onTaskCreated: (newTask) {
              returnedTask = newTask;
            },
          ),
        ),
  );

  return returnedTask;
}
