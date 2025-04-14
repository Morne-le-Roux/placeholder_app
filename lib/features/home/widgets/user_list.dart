import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:placeholder_app/core/widgets/avatar.dart';
import 'package:placeholder_app/features/auth/models/p_h_user.dart';
import 'package:placeholder_app/features/tasks/usecases/is_task_done_today.dart';
import 'package:placeholder_app/features/tasks/widgets/task_card.dart';

import '../../../core/usecases/snack.dart';
import '../../../core/widgets/loaders/main_loader.dart';
import '../../tasks/cubit/task_cubit.dart';
import '../../tasks/models/task.dart';
import '../../tasks/usecases/create_task.dart';

class UserList extends StatefulWidget {
  const UserList({super.key, required this.user});

  final PHUser user;

  @override
  State<UserList> createState() => _UserListState();
}

class _UserListState extends State<UserList> {
  TaskCubit get taskCubit => context.read<TaskCubit>();
  bool isLoading = false;

  List<Task> tasks = [];

  Future<void> init({bool showLoader = false}) async {
    try {
      setState(() => isLoading = showLoader);
      tasks = await taskCubit.fetchTasks(widget.user.id);
      tasks.removeWhere((task) => isTaskDoneToday(task));
      setState(() => isLoading = false);
    } catch (e) {
      setState(() => isLoading = false);
      snack(context, e.toString());
    }
  }

  @override
  void initState() {
    init(showLoader: true);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          height: MediaQuery.of(context).size.height,
          constraints: BoxConstraints(minWidth: 100),
          padding: EdgeInsets.only(top: 10, right: 10, left: 10),
          decoration: BoxDecoration(
              border:
                  Border(right: BorderSide(width: 0.5, color: Colors.grey))),
          child: RefreshIndicator(
            onRefresh: () async {
              await init(showLoader: tasks.isEmpty);
            },
            child: SingleChildScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  Row(
                    children: [
                      Avatar(url: widget.user.avatarURL),
                      Gap(10),
                      Text(widget.user.name),
                    ],
                  ),
                  Gap(10),
                  ...tasks.map(
                    (task) => TaskCard(
                      task: task,
                      onDone: () {
                        log("onDone ${task.id}");
                        setState(
                            () => tasks.removeWhere((t) => t.id == task.id));
                        if (task.recurring) {
                          taskCubit.updateTask(task.copyWith(
                              lastDone: DateTime.now().toString()));
                        } else {
                          taskCubit.deleteTask(task);
                        }
                      },
                      onDismissed: () {
                        log("onDismissed ${task.id}");
                        setState(
                            () => tasks.removeWhere((t) => t.id == task.id));
                        taskCubit.deleteTask(task);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 20,
          right: 10,
          child: FloatingActionButton.small(
            heroTag: "add_user_${widget.user.id}",
            elevation: 2,
            child: Icon(Icons.add_rounded),
            onPressed: () async {
              await createTask(context, widget.user);
              await init(showLoader: tasks.isEmpty);
            },
          ),
        ),
        if (isLoading) Center(child: MainLoader()),
      ],
    );
  }
}
