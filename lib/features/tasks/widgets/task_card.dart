import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:placeholder/core/constants/constants.dart';
import 'package:placeholder/features/tasks/models/task.dart';
import 'package:placeholder/features/tasks/usecases/get_user_name_from_id.dart';
import 'package:placeholder/features/tasks/widgets/clipped_dismissable.dart'
    as cd;

import '../../../core/usecases/is_dark_mode.dart';

class TaskCard extends StatelessWidget {
  const TaskCard(
      {super.key,
      required this.task,
      required this.onDismissed,
      required this.onDone});

  final Task task;
  final VoidCallback onDismissed;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    bool isLTR = Directionality.of(context) == TextDirection.ltr;
    return GestureDetector(
      onTap: () async {
        bool? markAsDone = await showAdaptiveDialog(
            context: context,
            builder: (context) => AlertDialog(
                  backgroundColor: isDarkMode(context)
                      ? const Color.fromARGB(255, 24, 24, 24)
                      : null,
                  title: Text(
                    "Mark as done?",
                    style: Constants.textStyles.title3.copyWith(
                        color:
                            isDarkMode(context) ? Colors.white : Colors.black),
                  ),
                  actions: [
                    TextButton(
                        onPressed: () {
                          Navigator.pop(context, true);
                        },
                        child: Text("Yes")),
                    TextButton(
                        onPressed: () {
                          Navigator.pop(context, false);
                        },
                        child: Text("No")),
                  ],
                ));
        if (markAsDone == true) {
          onDone();
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: cd.ClippedDismissible(
            key: Key(task.id),
            background: isLTR ? _DeleteIcon() : _CompleteIcon(),
            secondaryBackground: isLTR ? _CompleteIcon() : _DeleteIcon(),
            onDismissed: (direction) {
              direction == cd.DismissDirection.startToEnd
                  ? onDismissed()
                  : onDone();
            },
            child: Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: isDarkMode(context)
                      ? const Color.fromARGB(255, 39, 39, 39)
                      : Constants.colors.tasksColor,
                  gradient: isDarkMode(context)
                      ? LinearGradient(colors: [
                          const Color.fromARGB(255, 41, 41, 41),
                          const Color.fromARGB(255, 0, 0, 0),
                        ], begin: Alignment.topLeft, end: Alignment.bottomRight)
                      : LinearGradient(
                          colors: [
                            Constants.colors.tasksColorSec,
                            Constants.colors.tasksColor,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                  borderRadius: BorderRadius.circular(20)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    task.title,
                    style: Constants.textStyles.title3.copyWith(
                        color: isDarkMode(context)
                            ? const Color.fromARGB(255, 238, 238, 238)
                            : Colors.black),
                  ),
                  if (task.content != null && task.content!.isNotEmpty)
                    Text(
                      task.content!,
                      style: Constants.textStyles.description,
                    ),
                  Gap(20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "By: ${userNameFromID(context, userId: task.authorId)}",
                        style: Constants.textStyles.data.copyWith(
                            color: isDarkMode(context)
                                ? const Color.fromARGB(255, 153, 153, 153)
                                : Colors.black),
                      ),
                      if (task.recurring)
                        Text(
                          "Daily",
                          style: Constants.textStyles.data.copyWith(
                            color: Colors.grey,
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
    );
  }
}

class _DeleteIcon extends StatelessWidget {
  const _DeleteIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerLeft,
      margin: EdgeInsets.all(4),
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.deepOrangeAccent,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Icon(
        Icons.delete,
        color: Colors.white,
      ),
    );
  }
}

class _CompleteIcon extends StatelessWidget {
  const _CompleteIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerRight,
      margin: EdgeInsets.all(4),
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20), color: Colors.blue),
      child: Icon(
        Icons.check,
        color: Colors.white,
      ),
    );
  }
}
