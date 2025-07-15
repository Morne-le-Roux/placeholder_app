import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:placeholder/core/constants/constants.dart';
import 'package:placeholder/core/usecases/contact_support.dart';
import 'package:placeholder/core/widgets/loaders/main_loader.dart';
import 'package:placeholder/features/auth/cubit/auth_cubit.dart';
import 'package:placeholder/features/auth/models/p_h_user.dart';
import 'package:placeholder/features/auth/usecases/can_create_user.dart';
import 'package:placeholder/features/auth/usecases/check_and_set_pro.dart';
import 'package:placeholder/features/auth/usecases/show_release_notes.dart';
import 'package:placeholder/features/auth/views/login.dart';
import 'package:placeholder/features/auth/widgets/user_selector.dart';
import 'package:placeholder/features/home/views/dashboard.dart';
import 'package:placeholder/core/usecases/nav.dart';
import 'package:placeholder/core/usecases/snack.dart';
import 'package:placeholder/features/release_notes/cubit/release_notes_cubit.dart';
import 'package:placeholder/main.dart';

import '../usecases/create_new_user.dart';

class ChooseUser extends StatefulWidget {
  const ChooseUser({super.key});

  @override
  State<ChooseUser> createState() => _ChooseUserState();
}

class _ChooseUserState extends State<ChooseUser> {
  AuthCubit get authCubit => context.read<AuthCubit>();
  ReleaseNotesCubit get releaseNotesCubit => context.read<ReleaseNotesCubit>();
  ScrollController scrollController = ScrollController();

  bool loadingUsers = false;
  List<PHUser> phUsers = [];
  bool showEdit = false;

  @override
  void initState() {
    init();
    checkReleaseNotes(context);
    super.initState();
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  init() async {
    try {
      setState(() => loadingUsers = true);
      await checkAndSetPro(context);
      phUsers = await authCubit.fetchUsers();
    } catch (e) {
      snack(context, e.toString());
      log(e.toString());
    } finally {
      setState(() => loadingUsers = false);
    }
  }

  List<PHUser> get dashboards =>
      phUsers.where((phu) => phu.isDashboard).toList();
  List<PHUser> get users => phUsers.where((phu) => !phu.isDashboard).toList();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Hero(
          tag: "shadow",
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black,
              gradient: RadialGradient(
                center: Alignment.topCenter,
                radius: 1.5,
                colors: [
                  Colors.deepOrange.withAlpha(50),
                  Colors.deepOrange.withAlpha(0),
                ],
              ),
            ),
          ),
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            title: Text("Choose a user", style: Constants.textStyles.title2),
            actions: [
              // if (kDebugMode)
              //   IconButton(
              //     onPressed: () => context.read<AuthCubit>().setPro(true),
              //     icon: Icon(Icons.lock),
              //   ),
              PopupMenuButton(
                color: const Color.fromARGB(255, 26, 26, 26),
                onSelected: (value) {
                  if (value == "contact") {
                    contactSupport("", isError: false);
                  } else if (value == "logOut") {
                    sb.auth.signOut();
                    Nav.pushAndPop(context, Login());
                  }
                },
                itemBuilder:
                    (context) => [
                      PopupMenuItem(
                        value: "contact",
                        child: Text(
                          "Contact Support",
                          style: Constants.textStyles.title3,
                        ),
                      ),
                      PopupMenuItem(
                        value: "logOut",
                        child: Text(
                          "Log Out",
                          style: Constants.textStyles.title3,
                        ),
                      ),
                    ],
              ),
            ],
          ),
          body: SafeArea(
            child:
                loadingUsers
                    ? MainLoader(height: 100)
                    : Padding(
                      padding: EdgeInsets.all(20),
                      child: Center(
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              Text(
                                "Dashboards",
                                style: Constants.textStyles.title,
                              ),
                              Gap(20),
                              Wrap(
                                crossAxisAlignment: WrapCrossAlignment.center,
                                spacing: 40,
                                alignment: WrapAlignment.center,
                                children: [
                                  ...dashboards.map(
                                    (phu) => UserSelector(
                                      key: Key(phu.id),
                                      user: phu,
                                      showEdit: showEdit,
                                      onTap: () => _handleTap(phu),
                                      onLongPress: () => _handleLongPress(),
                                      onDelete: () => _handleDelete(phu),
                                    ),
                                  ),
                                  UserSelector(
                                    isDashboard: true,
                                    onDelete: () {},
                                    onTap: () async {
                                      bool canCreateNewUser = canCreateUser(
                                        context,
                                        currentUserCount: phUsers.length,
                                      );
                                      if (canCreateNewUser) {
                                        await createNewUser(
                                          context,
                                          isDashboard: true,
                                        );
                                      }
                                      init();
                                    },
                                    onLongPress: () => _handleLongPress(),
                                  ),
                                ],
                              ),
                              Text("Users", style: Constants.textStyles.title),
                              Gap(20),
                              Wrap(
                                crossAxisAlignment: WrapCrossAlignment.center,
                                spacing: 40,
                                alignment: WrapAlignment.center,
                                children: [
                                  ...users.map(
                                    (phu) => UserSelector(
                                      key: Key(phu.id),
                                      user: phu,
                                      showEdit: showEdit,
                                      onTap: () => _handleTap(phu),
                                      onDelete: () => _handleDelete(phu),
                                      onLongPress: () => _handleLongPress(),
                                    ),
                                  ),
                                  UserSelector(
                                    onDelete: () {},
                                    onTap: () async {
                                      bool canCreateNewUser = canCreateUser(
                                        context,
                                        currentUserCount: phUsers.length,
                                      );
                                      if (canCreateNewUser) {
                                        await createNewUser(
                                          context,
                                          isDashboard: false,
                                        );
                                      }
                                      init();
                                    },
                                    onLongPress: () => _handleLongPress(),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
          ),
        ),
      ],
    );
  }

  void _handleLongPress() {
    setState(() => showEdit = !showEdit);
  }

  void _handleTap(PHUser phu) async {
    if (showEdit) {
      await createNewUser(context, user: phu);
      init();
      setState(() => showEdit = false);
      return;
    } else {
      authCubit.setPHUser(phu);
      if (authCubit.state.phUser != null) {
        Nav.push(context, Dashboard());
      }
    }
  }

  void _handleDelete(PHUser phu) {
    setState(() {
      phUsers.remove(phu);
      showEdit = false;
    });
  }
}
