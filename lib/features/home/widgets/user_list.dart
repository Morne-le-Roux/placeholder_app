import 'dart:developer';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:placeholder/core/widgets/avatar.dart';
import 'package:placeholder/features/auth/cubit/auth_cubit.dart';
import 'package:placeholder/features/auth/models/p_h_user.dart';
import 'package:placeholder/features/tasks/usecases/can_add_tasks.dart';
import 'package:placeholder/features/tasks/usecases/is_task_done_today.dart';
import 'package:placeholder/features/tasks/widgets/task_card.dart';

import '../../../core/constants/constants.dart';
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
  List<PHUser> phUsers = [];
  bool isScrolled = false;
  final scrollController = ScrollController();
  Future<void> init({bool showLoader = false}) async {
    try {
      setState(() => isLoading = showLoader);
      tasks = await taskCubit.fetchTasks(user.id);
      tasks.removeWhere((task) => isTaskDoneToday(task));
      phUsers.addAll(authCubit.state.phUsers);
      phUsers.removeWhere((u) => u.isDashboard);
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
    scrollController.addListener(() {
      setState(() => isScrolled = scrollController.position.pixels > 10);
    });
    if (isDashboard) {
      _refreshTimer = Timer.periodic(const Duration(minutes: 5), (timer) {
        init(showLoader: false);
      });
    }
    super.initState();
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          RefreshIndicator(
            onRefresh: () async {
              await init(showLoader: false);
            },
            child: Container(
              height: MediaQuery.of(context).size.height,
              constraints: BoxConstraints(minWidth: 100),
              padding: EdgeInsets.only(right: 5, left: 5),

              child: SingleChildScrollView(
                controller: scrollController,
                physics: AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    Gap(10),
                    InkWell(
                      splashColor: Colors.deepOrange.withAlpha(100),
                      borderRadius: BorderRadius.circular(20),
                      onTap:
                          !isDashboard
                              ? () {
                                int currentIndex = phUsers.indexWhere(
                                  (u) => u.id == user.id,
                                );
                                int nextIndex =
                                    (currentIndex + 1) >= phUsers.length
                                        ? 0
                                        : currentIndex + 1;
                                user = phUsers[nextIndex];
                                setState(() {
                                  init(showLoader: true);
                                });
                              }
                              : null,
                      child: Container(
                        margin: EdgeInsets.all(4),
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: const Color.fromARGB(255, 36, 36, 36),
                            width: 3,
                          ),
                          gradient: LinearGradient(
                            colors: [
                              const Color.fromARGB(255, 41, 41, 41),
                              const Color.fromARGB(255, 0, 0, 0),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          color: const Color.fromARGB(255, 39, 39, 39),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            Avatar(url: user.avatarURL),
                            Gap(10),
                            Text(
                              user.name,
                              style: Constants.textStyles.title3.copyWith(
                                color: const Color.fromARGB(255, 207, 207, 207),
                              ),
                            ),
                            Gap(10),

                            Expanded(child: SizedBox()),

                            if (!isDashboard)
                              Text(
                                "Next User >>",
                                style: Constants.textStyles.description
                                    .copyWith(fontStyle: FontStyle.italic),
                              ),
                          ],
                        ),
                      ),
                    ),
                    Gap(10),
                    ...tasks.map(
                      (task) => Animate(
                        effects: [
                          FadeEffect(
                            duration: Duration(
                              milliseconds: 200 + (tasks.indexOf(task) * 100),
                            ),
                          ),
                        ],
                        child: TaskCard(
                          key: Key(task.id),
                          task: task,
                          onDone: () {
                            log("onDone ${task.id}");
                            setState(
                              () => tasks.removeWhere((t) => t.id == task.id),
                            );
                            if (task.recurring) {
                              taskCubit.updateTask(
                                task.copyWith(
                                  lastDone: DateTime.now().toString(),
                                ),
                              );
                            } else {
                              taskCubit.deleteTask(task);
                            }
                          },
                          onDismissed: () {
                            log("onDismissed ${task.id}");
                            setState(
                              () => tasks.removeWhere((t) => t.id == task.id),
                            );
                            taskCubit.deleteTask(task);
                          },
                        ),
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
              backgroundColor: const Color.fromARGB(255, 39, 39, 39),
              foregroundColor: const Color.fromARGB(255, 207, 207, 207),
              heroTag: "add_user_${user.id}",
              elevation: 2,
              child: Icon(Icons.add_rounded),
              onPressed: () async {
                bool canTask = canAddTask(
                  context,
                  currentTaskCount: tasks.length,
                );
                if (canTask) {
                  await createTask(context, user);
                }
                await init(showLoader: tasks.isEmpty);
              },
            ),
          ),
          if (isLoading) Center(child: MainLoader()),

          AnimatedContainer(
            duration: Duration(milliseconds: 200),
            curve: Curves.ease,
            height: 50,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              gradient:
                  isScrolled
                      ? LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withAlpha(100),
                          Colors.black.withAlpha(0),
                        ],
                      )
                      : null,
            ),
          ),
        ],
      ),
    );
  }
}
