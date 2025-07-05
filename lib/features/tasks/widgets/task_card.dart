import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:gap/gap.dart';
import 'package:placeholder/core/constants/constants.dart';
import 'package:placeholder/features/tasks/models/task.dart';
import 'package:placeholder/features/tasks/usecases/get_user_name_from_id.dart';
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
  bool done = false;

  double height = 80;

  @override
  Widget build(BuildContext context) {
    List<Color> colors = [const Color.fromARGB(255, 25, 25, 25), Colors.black];
    Color borderColor = colors.first;
    final Color bgColor = colors.first;
    // Calculate luminance to decide text color
    final bool useWhiteText = bgColor.computeLuminance() < 0.5;
    final Color textColor = useWhiteText ? Colors.white : Colors.black;
    if (!wasTaskDoneYesterday(widget.task)) {
      borderColor = Colors.deepOrange.withAlpha(100);
      colors = [
        Colors.deepOrange.withAlpha(100),
        Colors.deepOrange.withAlpha(0),
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
        onPressed: (context) => _handleComplete(delete: false),
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
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 5, vertical: 3),
      child: GestureDetector(
        onTap:
            done
                ? () => setState(() => done = false)
                : () async {
                  bool? markAsDone = await showAdaptiveDialog(
                    context: context,
                    builder:
                        (context) => AlertDialog(
                          backgroundColor: const Color.fromARGB(
                            255,
                            24,
                            24,
                            24,
                          ),
                          title: Text(
                            "Mark as done?",
                            style: Constants.textStyles.title3.copyWith(
                              color: Colors.white,
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context, true);
                              },
                              child: Text("Yes"),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context, false);
                              },
                              child: Text("No"),
                            ),
                          ],
                        ),
                  );
                  if (markAsDone == true) {
                    widget.onDone();
                  }
                },

        child: Slidable(
          key: Key(widget.task.id),
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
              done
                  ? AnimatedContainer(
                    duration: Duration(milliseconds: 500),
                    alignment: Alignment.center,
                    width: double.infinity,
                    height: height,
                    curve: Curves.ease,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient:
                          done
                              ? LinearGradient(
                                colors: [
                                  const Color.fromARGB(100, 255, 86, 34),
                                  const Color.fromARGB(0, 255, 86, 34),
                                ],
                              )
                              : null,
                    ),
                    child: Text("Undo?", style: Constants.textStyles.title3),
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
                          widget.task.title,
                          style: Constants.textStyles.title3.copyWith(
                            color: textColor,
                          ),
                        ),
                        if (widget.task.content != null &&
                            widget.task.content!.isNotEmpty)
                          Text(
                            widget.task.content!,
                            style: Constants.textStyles.description.copyWith(
                              color: textColor,
                            ),
                          ),
                        Gap(10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "By: ${userNameFromID(context, userId: widget.task.authorId)}",
                              style: Constants.textStyles.data.copyWith(
                                color: textColor.withOpacity(0.7),
                              ),
                            ),
                            if (widget.task.recurring)
                              Text(
                                wasTaskDoneYesterday(widget.task)
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
    );
  }

  Future<void> _handleComplete({required bool delete}) async {
    setState(() => done = true);
    await Future.delayed(Duration(seconds: 3));
    setState(() => height = 0);
    await Future.delayed(Duration(seconds: 1));

    if (!done) return;
    if (delete) {
      widget.onDismissed();
    } else {
      widget.onDone();
    }
  }
}
