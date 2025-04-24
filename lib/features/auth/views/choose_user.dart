import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:placeholder/core/constants/constants.dart';
import 'package:placeholder/core/widgets/loaders/main_loader.dart';
import 'package:placeholder/features/auth/cubit/auth_cubit.dart';
import 'package:placeholder/features/auth/models/p_h_user.dart';
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
            : Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  children: [
                    Expanded(child: SizedBox()),
                    Wrap(
                      spacing: 40,
                      alignment: WrapAlignment.center,
                      children: [
                        ...phUsers.map(
                          (phu) => UserSelector(
                            user: phu,
                            onTap: () {
                              authCubit.setPHUser(phu);
                              if (authCubit.state.phUser != null) {
                                Nav.push(context, Dashboard());
                              }
                            },
                          ),
                        ),
                        UserSelector(
                          onTap: () async {
                            await createNewUser(context);
                            init();
                          },
                        ),
                      ],
                    ),
                    Expanded(child: SizedBox()),
                    InkWell(
                      onTap: () {
                        Nav.push(context, Paywall());
                      },
                      child: Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.grey,
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          authCubit.state.isPro ? "Sub Active" : "Go Pro",
                          style: Constants.textStyles.title2.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
      ),
    );
  }
}
