import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:gap/gap.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:placeholder/core/constants/constants.dart';
import 'package:placeholder/core/usecases/snack.dart';
import 'package:placeholder/features/auth/cubit/auth_cubit.dart';
import 'package:placeholder/features/auth/models/p_h_user.dart';
import 'package:placeholder/features/tasks/cubit/task_cubit.dart';
import 'package:placeholder/features/tasks/models/task.dart';
import 'package:placeholder/features/tasks/usecases/create_task.dart';
import 'package:placeholder/features/tasks/usecases/get_user_name_from_id.dart';
import 'package:placeholder/features/tasks/usecases/is_task_done_today.dart';
import 'package:placeholder/features/tasks/usecases/was_done_yesterday.dart';

class TaskCard extends StatefulWidget {
  const TaskCard({
    super.key,
    required this.task,
    required this.onDismissed,
    required this.onDone,
  });

  final Task task;
  final VoidCallback onDismissed;
  final VoidCallback onDone;

  @override
  State<TaskCard> createState() => _TaskCardState();
}

class _TaskCardState extends State<TaskCard> {
  bool markedForDelete = false;

  double height = 80;

  AuthCubit get authCubit => context.read<AuthCubit>();
  bool get isSubtask => task.parentTask != null;

  late Task task;
  List<Task> subTasks = [];

  TaskCubit get taskCubit => context.read<TaskCubit>();

  @override
  void initState() {
    task = widget.task;
    subTasks.addAll(widget.task.subTasks);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<Color> colors = [const Color.fromARGB(255, 25, 25, 25), Colors.black];
    Color borderColor = colors.first;
    final Color bgColor = colors.first;
    // Calculate luminance to decide text color
    final bool useWhiteText = bgColor.computeLuminance() < 0.5;
    final Color textColor = useWhiteText ? Colors.white : Colors.black;

    if (!wasTaskDoneYesterday(task)) {
      borderColor = Colors.deepOrange.withAlpha(100);
      colors = [
        Colors.deepOrange.withAlpha(100),
        Colors.deepOrange.withAlpha(0),
      ];
    }

    if (isSubtask &&
        (task.recurring ? isTaskDoneToday(task) : task.lastDone != null)) {
      borderColor = const Color.fromARGB(255, 0, 198, 23).withAlpha(100);
      colors = [
        const Color.fromARGB(255, 6, 183, 0).withAlpha(100),
        const Color.fromARGB(255, 22, 103, 0).withAlpha(0),
      ];
    }

    final List<Widget> actions = [
      CustomSlidableAction(
        onPressed: (context) => _handleComplete(delete: true),
        borderRadius: BorderRadius.circular(16),
        padding: EdgeInsets.zero,
        foregroundColor: Colors.white,
        backgroundColor: Colors.transparent,
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 5),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.deepOrange, width: 2),
            color: Colors.deepOrange.withAlpha(100),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.delete, color: Colors.white),
              Gap(5),
              Text(
                "Delete",
                style: Constants.textStyles.description.copyWith(
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
      CustomSlidableAction(
        padding: EdgeInsets.zero,
        onPressed: (context) async {
          await _handleComplete(delete: false);
          if (isSubtask) {
            setState(() {
              task = task.copyWith(lastDone: DateTime.now().toString());
            });
          }
        },
        foregroundColor: Colors.white,
        backgroundColor: Colors.transparent,
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 5),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.blue, width: 2),
            borderRadius: BorderRadius.circular(16),
            color: Colors.blue.withAlpha(100),
          ),

          alignment: Alignment.center,
          padding: EdgeInsets.all(10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check, color: Colors.white),
              Gap(5),
              Text(
                "Done",
                style: Constants.textStyles.description.copyWith(
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    ];
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 5,
            vertical: height != 0 ? 3 : 0,
          ),
          child: GestureDetector(
            onTap:
                markedForDelete
                    ? () => setState(() => markedForDelete = false)
                    : () async {
                      PHUser? user = authCubit.state.phUsers.firstWhereOrNull(
                        (u) => u.id == task.userId,
                      );
                      if (user == null) {
                        snack(
                          context,
                          "The owner of this task is not available.",
                        );
                        return;
                      }
                      Task? returnedTask = await createTask(
                        context,
                        task: task,
                        phUser: user,
                      );
                      if (returnedTask != null) {
                        setState(() {
                          task = returnedTask;
                          subTasks = returnedTask.subTasks;
                        });
                      }
                    },

            child: Slidable(
              key: Key(task.id),
              endActionPane: ActionPane(
                extentRatio: 0.4,

                motion: DrawerMotion(),
                children: actions.reversed.toList(),
              ),

              startActionPane: ActionPane(
                extentRatio: 0.4,
                motion: DrawerMotion(),
                children: actions,
              ),
              child:
                  markedForDelete
                      ? AnimatedContainer(
                        duration: Duration(milliseconds: 500),
                        alignment: Alignment.center,
                        width: double.infinity,
                        height: height,
                        curve: Curves.ease,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          gradient:
                              markedForDelete
                                  ? LinearGradient(
                                    colors: [
                                      const Color.fromARGB(100, 255, 86, 34),
                                      const Color.fromARGB(0, 255, 86, 34),
                                    ],
                                  )
                                  : null,
                        ),
                        child: Text(
                          "Undo?",
                          style: Constants.textStyles.title3,
                        ),
                      )
                      : AnimatedContainer(
                        duration: Duration(milliseconds: 1000),
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          border: Border.all(color: borderColor, width: 3),
                          gradient: LinearGradient(colors: colors),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              task.title,
                              style: Constants.textStyles.title3.copyWith(
                                color: textColor,
                              ),
                            ),
                            if (task.content != null &&
                                task.content!.isNotEmpty)
                              Text(
                                task.content!,
                                style: Constants.textStyles.description
                                    .copyWith(color: textColor),
                              ),
                            Gap(10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "By: ${userNameFromID(context, userId: task.authorId)}",
                                  style: Constants.textStyles.data.copyWith(
                                    color: textColor.withOpacity(0.7),
                                  ),
                                ),
                                if (task.recurring)
                                  Text(
                                    wasTaskDoneYesterday(task)
                                        ? "Daily"
                                        : "Task not done yesterday",
                                    style: Constants.textStyles.data.copyWith(
                                      color: textColor.withOpacity(0.7),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
            ),
          ),
        ),
        for (Task subTask in subTasks)
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,

            children: [
              if (height != 0)
                Icon(
                  Symbols.subdirectory_arrow_right_rounded,
                  color: const Color.fromARGB(
                    255,
                    255,
                    255,
                    255,
                  ).withAlpha(100),
                ),
              Expanded(
                child: TaskCard(
                  key: Key(subTask.id),
                  task: subTask,
                  onDismissed: () async {
                    try {
                      await taskCubit.deleteTask(subTask);
                      setState(() {
                        subTasks.removeWhere((t) => t.id == subTask.id);
                      });
                    } catch (e) {
                      snack(context, e.toString());
                    }
                  },
                  onDone: () async {
                    await taskCubit.updateTask(
                      subTask.copyWith(lastDone: DateTime.now().toString()),
                    );
                    subTask = subTask.copyWith(
                      lastDone: DateTime.now().toString(),
                    );
                  },
                ),
              ),
            ],
          ),
      ],
    );
  }

  Future<void> _handleComplete({required bool delete}) async {
    if (!isSubtask || delete) {
      setState(() => markedForDelete = true);
      await Future.delayed(Duration(seconds: 3));
      setState(() => height = 0);
      await Future.delayed(Duration(milliseconds: 100));

      if (!markedForDelete) return;
      if (delete) {
        widget.onDismissed();
      } else {
        widget.onDone();
      }
    } else {
      if (delete) {
        widget.onDismissed();
      } else {
        widget.onDone();
      }
    }
  }
}
