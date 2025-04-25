import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:gap/gap.dart';
import 'package:placeholder/core/constants/constants.dart';
import 'package:placeholder/features/tasks/models/task.dart';
import 'package:placeholder/features/tasks/usecases/get_user_name_from_id.dart';

class TaskCard extends StatefulWidget {
  const TaskCard(
      {super.key,
      required this.task,
      required this.onDismissed,
      required this.onDone});

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
    final List<Widget> actions = [
      SlidableAction(
        onPressed: (context) => _handleComplete(delete: true),
        borderRadius: BorderRadius.circular(16),
        padding: EdgeInsets.zero,
        icon: Icons.delete,
        label: "Delete",
        foregroundColor: Colors.white,
        backgroundColor: const Color.fromARGB(100, 255, 86, 34),
      ),
      SlidableAction(
        padding: EdgeInsets.zero,
        borderRadius: BorderRadius.circular(16),
        onPressed: (context) => _handleComplete(delete: false),
        icon: Icons.check,
        label: "Done",
        foregroundColor: Colors.white,
        backgroundColor: const Color.fromARGB(100, 64, 195, 255),
      ),
    ];
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 5, vertical: 3),
      child: GestureDetector(
        onTap: done
            ? () => setState(() => done = false)
            : () async {
                bool? markAsDone = await showAdaptiveDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                          backgroundColor:
                              const Color.fromARGB(255, 24, 24, 24),
                          title: Text(
                            "Mark as done?",
                            style: Constants.textStyles.title3
                                .copyWith(color: Colors.white),
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
                  widget.onDone();
                }
              },
        child: Slidable(
          key: Key(widget.task.id),
          endActionPane: ActionPane(
            extentRatio: 0.4,
            motion: DrawerMotion(),
            children: actions,
          ),
          startActionPane: ActionPane(
            extentRatio: 0.4,
            motion: DrawerMotion(),
            children: actions,
          ),
          child: done
              ? AnimatedContainer(
                  duration: Duration(milliseconds: 500),
                  alignment: Alignment.center,
                  width: double.infinity,
                  height: height,
                  curve: Curves.ease,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: done
                          ? LinearGradient(colors: [
                              const Color.fromARGB(100, 255, 86, 34),
                              const Color.fromARGB(0, 255, 86, 34),
                            ])
                          : null),
                  child: Text(
                    "Undo?",
                    style: Constants.textStyles.title3,
                  ),
                )
              : Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 39, 39, 39),
                      gradient: LinearGradient(colors: [
                        const Color.fromARGB(255, 41, 41, 41),
                        const Color.fromARGB(255, 0, 0, 0),
                      ], begin: Alignment.topLeft, end: Alignment.bottomRight),
                      borderRadius: BorderRadius.circular(20)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        widget.task.title,
                        style: Constants.textStyles.title3.copyWith(
                            color: const Color.fromARGB(255, 238, 238, 238)),
                      ),
                      if (widget.task.content != null &&
                          widget.task.content!.isNotEmpty)
                        Text(
                          widget.task.content!,
                          style: Constants.textStyles.description,
                        ),
                      Gap(10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "By: ${userNameFromID(context, userId: widget.task.authorId)}",
                            style: Constants.textStyles.data.copyWith(
                                color:
                                    const Color.fromARGB(255, 153, 153, 153)),
                          ),
                          if (widget.task.recurring)
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
