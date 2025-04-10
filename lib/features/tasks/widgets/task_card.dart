import 'package:flutter/material.dart';
import 'package:placeholder_app/core/constants/constants.dart';
import 'package:placeholder_app/features/tasks/models/task.dart';

class TaskCard extends StatelessWidget {
  const TaskCard({super.key, required this.task});

  final Task task;

  @override
  Widget build(BuildContext context) {
    return Container(
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
        ],
      ),
    );
  }
}
