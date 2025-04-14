import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:placeholder_app/core/constants/constants.dart';
import 'package:placeholder_app/features/tasks/models/task.dart';
import 'package:placeholder_app/features/tasks/usecases/get_user_name_from_id.dart';

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
    return Dismissible(
      key: Key(task.id),
      background: isLTR ? _DeleteIcon() : _CompleteIcon(),
      secondaryBackground: isLTR ? _CompleteIcon() : _DeleteIcon(),
      onDismissed: (direction) {
        direction == DismissDirection.startToEnd ? onDismissed() : onDone();
      },
      child: Container(
        margin: EdgeInsets.all(4),
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(20)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              task.title,
              style: Constants.textStyles.title3,
            ),
            if (task.content != null && task.content!.isNotEmpty)
              Text(
                task.content!,
                style: Constants.textStyles.description,
              ),
            Gap(20),
            Text(
              "By: ${userNameFromID(context, userId: task.authorId)}",
              style: Constants.textStyles.data,
            ),
          ],
        ),
      ),
    );
  }
}

class _DeleteIcon extends StatelessWidget {
  const _DeleteIcon({super.key});

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
    );
  }
}

class _CompleteIcon extends StatelessWidget {
  const _CompleteIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerRight,
      margin: EdgeInsets.all(4),
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20), color: Colors.blue),
      child: Icon(Icons.check),
    );
  }
}
