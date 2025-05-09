import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:placeholder/core/constants/constants.dart';
import 'package:placeholder/core/usecases/contact_support.dart';
import 'package:placeholder/core/widgets/loaders/main_loader.dart';
import 'package:placeholder/features/auth/cubit/auth_cubit.dart';
import 'package:placeholder/features/auth/models/p_h_user.dart';
import 'package:placeholder/features/auth/usecases/can_create_user.dart';
import 'package:placeholder/features/auth/views/login.dart';
import 'package:placeholder/features/auth/widgets/user_selector.dart';
import 'package:placeholder/features/home/views/dashboard.dart';
import 'package:placeholder/core/usecases/nav.dart';
import 'package:placeholder/core/usecases/snack.dart';
import 'package:placeholder/features/payment/views/paywall.dart';

import '../usecases/create_new_user.dart';

class ChooseUser extends StatefulWidget {
  const ChooseUser({super.key});

  @override
  State<ChooseUser> createState() => _ChooseUserState();
}

class _ChooseUserState extends State<ChooseUser> {
  AuthCubit get authCubit => context.read<AuthCubit>();
  ScrollController scrollController = ScrollController();

  bool loadingUsers = false;
  List<PHUser> phUsers = [];
  bool showEdit = false;

  @override
  void initState() {
    init();
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
      phUsers = await authCubit.fetchUsers();
      await authCubit.checkSub();
      phUsers = await authCubit.fetchUsers();
    } catch (e) {
      snack(context, e.toString());
      log(e.toString());
    } finally {
      setState(() => loadingUsers = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Choose a user", style: Constants.textStyles.title2),
        actions: [
          PopupMenuButton(
            color: const Color.fromARGB(255, 26, 26, 26),
            onSelected: (value) {
              if (value == "contact") {
                contactSupport("");
              } else if (value == "logOut") {
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
                    child: Text("Log Out", style: Constants.textStyles.title3),
                  ),
                ],
          ),
        ],
      ),
      body: SafeArea(
        child:
            loadingUsers
                ? MainLoader()
                : Stack(
                  children: [
                    Padding(
                      padding: EdgeInsets.all(20),
                      child: Center(
                        child: SingleChildScrollView(
                          child: Wrap(
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: 40,
                            alignment: WrapAlignment.center,
                            children: [
                              ...phUsers.map(
                                (phu) => UserSelector(
                                  key: Key(phu.id),
                                  user: phu,
                                  showEdit: showEdit,
                                  onTap: () async {
                                    if (showEdit) {
                                      await createNewUser(context, user: phu);
                                      init();
                                      return;
                                    } else {
                                      authCubit.setPHUser(phu);
                                      if (authCubit.state.phUser != null) {
                                        Nav.push(context, Dashboard());
                                      }
                                    }
                                  },
                                  onDelete:
                                      () => setState(() => phUsers.remove(phu)),
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
                                    await createNewUser(context);
                                  }
                                  init();
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      right: 20,
                      top: 20,
                      child: IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () => setState(() => showEdit = !showEdit),
                      ),
                    ),
                  ],
                ),
      ),
    );
  }
}
