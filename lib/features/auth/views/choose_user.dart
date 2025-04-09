import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:placeholder_app/core/widgets/loaders/main_loader.dart';
import 'package:placeholder_app/features/auth/cubit/auth_cubit.dart';
import 'package:placeholder_app/features/auth/models/p_h_user.dart';
import 'package:placeholder_app/features/auth/widgets/user_selector.dart';
import 'package:placeholder_app/usecases/snack.dart';

class ChooseUser extends StatefulWidget {
  const ChooseUser({super.key});

  @override
  State<ChooseUser> createState() => _ChooseUserState();
}

class _ChooseUserState extends State<ChooseUser> {
  AuthCubit get authCubit => context.read<AuthCubit>();

  bool loadingUsers = false;
  List<PHUser> phUsers = [];

  @override
  void initState() {
    init();
    super.initState();
  }

  init() async {
    try {
      setState(() => loadingUsers = true);
      phUsers = await authCubit.fetchUsers();
    } catch (e) {
      snack(context, e.toString());
    } finally {
      setState(() => loadingUsers = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Choose a user"),
        actions: [
          IconButton(
              onPressed: () {
                init();
              },
              icon: Icon(Icons.refresh))
        ],
      ),
      body: Center(
        child: loadingUsers
            ? MainLoader()
            : Wrap(
                spacing: 40,
                alignment: WrapAlignment.center,
                children: [
                  ...phUsers.map(
                    (phu) => UserSelector(
                      user: phu,
                      onTap: () {
                        authCubit.setPHUser(phu);
                      },
                    ),
                  ),
                  UserSelector(
                    onTap: () {},
                  ),
                ],
              ),
      ),
    );
  }
}
