import 'dart:developer';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:placeholder/core/usecases/extract_date.dart';
import 'package:placeholder/core/usecases/nav.dart';
import 'package:placeholder/features/auth/models/p_h_user.dart';
import 'package:placeholder/features/tasks/usecases/can_add_tasks.dart';
import 'package:placeholder/features/tasks/usecases/create_task.dart';
import 'package:placeholder/features/tasks/widgets/task_card.dart';
import 'package:uuid/uuid.dart';

import '../../../core/constants/constants.dart';
import '../../../core/usecases/snack.dart';
import '../../../core/widgets/buttons/large_rounded_button.dart';
import '../../../main.dart';
import '../../auth/cubit/auth_cubit.dart';
import '../cubit/task_cubit.dart';
import '../models/task.dart';

class CreateTaskBottomSheet extends StatefulWidget {
  const CreateTaskBottomSheet({
    super.key,
    required this.phUser,
    this.task,
    this.onTaskCreated,
    this.parentTaskIdIfNew,
    this.recurringIfChild,
  });
  final PHUser phUser;
  final Task? task;
  final Function(Task)? onTaskCreated;
  final String? parentTaskIdIfNew;
  final bool? recurringIfChild;

  @override
  State<CreateTaskBottomSheet> createState() => _CreateTaskBottomSheetState();
}

class _CreateTaskBottomSheetState extends State<CreateTaskBottomSheet> {
  late Task task;
  bool get isSubtask => task.parentTask != null;
  AuthCubit get authCubit => context.read<AuthCubit>();
  TaskCubit get taskCubit => context.read<TaskCubit>();

  bool isLoading = false;

  bool get isEditing => widget.task != null;

  @override
  void initState() {
    task =
        widget.task ??
        Task(
          id: Uuid().v4(),
          userId: widget.phUser.id,
          authorId: authCubit.state.phUser?.id ?? "",
          accountHolderId: sb.auth.currentUser?.id ?? "",
          title: "",
          content: "",
          recurring: widget.recurringIfChild ?? false,
          createdAt: DateTime.now().toString(),
          parentTask: widget.parentTaskIdIfNew,
        );

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 19, 19, 19),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        padding: EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                "${isEditing ? "Update" : "Create"} ${isSubtask ? "Subtask" : "Task"} for ${widget.phUser.name}",
                textAlign: TextAlign.center,
                style: Constants.textStyles.title3.copyWith(
                  color: const Color.fromARGB(255, 207, 207, 207),
                ),
              ),
              Gap(20),
              TextFormField(
                textCapitalization: TextCapitalization.sentences,
                style: Constants.textStyles.description.copyWith(
                  color: const Color.fromARGB(255, 207, 207, 207),
                ),
                validator:
                    (value) => value!.isEmpty ? "Title is required" : null,
                decoration: InputDecoration(
                  labelText: "Title",
                  labelStyle: Constants.textStyles.data.copyWith(
                    color: const Color.fromARGB(255, 207, 207, 207),
                  ),
                ),
                initialValue: task.title,
                onChanged:
                    (value) =>
                        setState(() => task = task.copyWith(title: value)),
              ),
              Gap(20),
              TextFormField(
                textCapitalization: TextCapitalization.sentences,
                style: Constants.textStyles.description.copyWith(
                  color: const Color.fromARGB(255, 207, 207, 207),
                ),
                decoration: InputDecoration(
                  labelText: "Description",
                  alignLabelWithHint: true,
                  labelStyle: Constants.textStyles.data.copyWith(
                    color: const Color.fromARGB(255, 207, 207, 207),
                  ),
                ),
                initialValue: task.content,
                maxLines: 5,
                onChanged:
                    (value) =>
                        setState(() => task = task.copyWith(content: value)),
              ),
              Gap(20),
              if (!isSubtask)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Recurring (Daily)",
                      style: Constants.textStyles.description.copyWith(
                        color: const Color.fromARGB(255, 207, 207, 207),
                      ),
                    ),
                    Switch(
                      value: task.recurring,
                      inactiveTrackColor: Colors.black38,
                      onChanged:
                          (value) => setState(
                            () => task = task.copyWith(recurring: value),
                          ),
                    ),
                  ],
                ),
              Gap(10),
              Divider(thickness: 0.3),
              Gap(10),
              InkWell(
                onTap: () async {
                  DateTime? dueDate;
                  DateTime now = DateTime.now();
                  dueDate = await showDatePicker(
                    initialDate: DateTime.tryParse(task.dueDate ?? ""),
                    context: context,
                    firstDate: now,
                    lastDate: now.copyWith(year: now.year + 20),
                  );
                  setState(() {
                    if (dueDate != null) {
                      task = task.copyWith(dueDate: dueDate.toIso8601String());
                    }
                  });
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      task.dueDate == null || (task.dueDate?.isEmpty ?? false)
                          ? "Set Due Date"
                          : "Due by: ${formatFriendlyDate(task.dueDate ?? "")}",
                      style: Constants.textStyles.description.copyWith(
                        color: Colors.white,
                      ),
                    ),
                    Icon(Symbols.date_range, color: Colors.white),
                  ],
                ),
              ),
              Gap(10),
              Divider(thickness: 0.3),
              Gap(20),

              if (isEditing && !isSubtask)
                for (Task subtask in task.subTasks)
                  TaskCard(
                    task: subtask,
                    onDismissed: () async {
                      try {
                        await taskCubit.deleteTask(subtask);
                      } catch (e) {
                        snack(context, e.toString());
                      }
                      task.subTasks.removeWhere((t) => t.id == subtask.id);
                    },
                    onDone: () async {
                      taskCubit.updateTask(
                        subtask.copyWith(lastDone: DateTime.now().toString()),
                      );
                      setState(() {
                        subtask = subtask.copyWith(
                          lastDone: DateTime.now().toString(),
                        );
                      });
                    },
                  ),
              Gap(20),

              if (isEditing && !isSubtask)
                InkWell(
                  onTap: () async {
                    PHUser? phUser = authCubit.state.phUsers.firstWhereOrNull(
                      (test) => test.id == task.userId,
                    );
                    if (phUser != null) {
                      Task? subtask = await createTask(
                        context,
                        phUser: phUser,
                        parentIdIfNew: task.id,
                        recurringIfChild: task.recurring,
                      );
                      if (subtask != null) {
                        setState(() => task.subTasks.add(subtask));
                      }
                    } else {
                      snack(context, "Something went wrong, no user found.");
                      return;
                    }
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50),
                      border: Border.all(color: Colors.white, width: 0.5),
                    ),
                    child: Text(
                      "Add a subtask",
                      textAlign: TextAlign.center,
                      style: Constants.textStyles.description.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              Gap(20),

              LargeRoundedButton(
                text: isEditing ? "Update Task" : "Create Task",
                isLoading: isLoading,
                isValid: task.title.isNotEmpty,
                onPressed: () async {
                  try {
                    setState(() => isLoading = true);
                    if (isEditing) {
                      await taskCubit.updateTask(task);
                    } else {
                      await taskCubit.createTask(task);
                    }
                    widget.onTaskCreated?.call(task);
                    setState(() => isLoading = false);
                    Nav.pop(context);
                  } catch (e) {
                    setState(() => isLoading = false);
                    snack(context, e.toString());
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
