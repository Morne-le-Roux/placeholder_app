import 'dart:developer';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:placeholder/core/usecases/is_portrait.dart';
import 'package:placeholder/core/widgets/avatar.dart';
import 'package:placeholder/features/auth/cubit/auth_cubit.dart';
import 'package:placeholder/features/auth/models/p_h_user.dart';
import 'package:placeholder/features/tasks/usecases/is_task_done_today.dart';
import 'package:placeholder/features/tasks/widgets/task_card.dart';

import '../../../core/constants/constants.dart';
import '../../../core/usecases/is_dark_mode.dart';
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
  AuthCubit get authCubit => context.read<AuthCubit>();
  bool get isDashboard => authCubit.state.phUser?.isDashboard ?? false;

  bool isLoading = false;
  Timer? _refreshTimer;
  List<Task> tasks = [];
  late PHUser user;

  Future<void> init({bool showLoader = false}) async {
    try {
      setState(() => isLoading = showLoader);
      tasks = await taskCubit.fetchTasks(user.id);
      tasks.removeWhere((task) => isTaskDoneToday(task));
      setState(() => isLoading = false);
    } catch (e) {
      setState(() => isLoading = false);
      snack(context, e.toString());
    }
  }

  @override
  void initState() {
    user = widget.user;
    init(showLoader: true);
    if (isDashboard) {
      _refreshTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
        init(showLoader: false);
      });
    }
    super.initState();
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        RefreshIndicator(
          onRefresh: () async {
            await init(showLoader: false);
          },
          child: Container(
            height: MediaQuery.of(context).size.height,
            constraints: BoxConstraints(minWidth: 100),
            padding: EdgeInsets.only(top: 10, right: 5, left: 5),
            decoration: BoxDecoration(
                border: Border(
                    right: BorderSide(
                        width: 0.5,
                        color: isDarkMode(context)
                            ? const Color.fromARGB(255, 36, 36, 36)
                            : Colors.grey.shade300))),
            child: SingleChildScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  InkWell(
                    onTap: !isDashboard
                        ? () {
                            setState(() {
                              int currentIndex = authCubit.state.phUsers
                                  .indexWhere((u) => u.id == user.id);
                              int nextIndex = (currentIndex + 1) >=
                                      authCubit.state.phUsers.length
                                  ? 0
                                  : currentIndex + 1;
                              user = authCubit.state.phUsers[nextIndex];
                              init(showLoader: true);
                            });
                          }
                        : null,
                    child: Container(
                      margin: EdgeInsets.all(4),
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isDarkMode(context)
                            ? const Color.fromARGB(255, 39, 39, 39)
                            : Constants.colors.headerColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Avatar(url: user.avatarURL),
                          Gap(10),
                          Text(user.name,
                              style: Constants.textStyles.title3.copyWith(
                                  color: isDarkMode(context)
                                      ? const Color.fromARGB(255, 207, 207, 207)
                                      : Colors.black)),
                          Gap(10),
                          if (!isDashboard)
                            Icon(Icons.keyboard_arrow_right_rounded,
                                color: isDarkMode(context)
                                    ? const Color.fromARGB(255, 207, 207, 207)
                                    : Colors.black),
                        ],
                      ),
                    ),
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
            backgroundColor: isDarkMode(context)
                ? const Color.fromARGB(255, 39, 39, 39)
                : Constants.colors.headerColor,
            foregroundColor: isDarkMode(context)
                ? const Color.fromARGB(255, 207, 207, 207)
                : Colors.black,
            heroTag: "add_user_${user.id}",
            elevation: 2,
            child: Icon(Icons.add_rounded),
            onPressed: () async {
              await createTask(context, user);
              await init(showLoader: tasks.isEmpty);
            },
          ),
        ),
        if (isLoading) Center(child: MainLoader()),
      ],
    );
  }
}
