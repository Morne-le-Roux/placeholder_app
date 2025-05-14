import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:placeholder/core/usecases/is_portrait.dart';
import 'package:placeholder/core/usecases/nav.dart';
import 'package:placeholder/core/widgets/loaders/main_loader.dart';
import 'package:placeholder/features/auth/usecases/refresh_auth.dart';
import 'package:placeholder/features/home/widgets/user_list.dart';
import 'package:placeholder/core/usecases/snack.dart';
import 'package:placeholder/main.dart';

import '../../../core/constants/constants.dart';
import '../../auth/cubit/auth_cubit.dart';
import '../../auth/models/p_h_user.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  AuthCubit get authCubit => context.read<AuthCubit>();
  bool get isDashboard => authCubit.state.phUser?.isDashboard ?? false;
  List<PHUser> users = [];
  bool isLoading = false;
  Timer? _authRefreshTimer;

  init() async {
    try {
      setState(() => isLoading = true);
      users = await authCubit.fetchUsers();
      users.removeWhere((e) => e.isDashboard);
      setState(() => isLoading = false);
    } catch (e) {
      setState(() => isLoading = false);
      snack(context, e.toString());
    }
  }

  @override
  void initState() {
    init();
    _authRefreshTimer = Timer.periodic(const Duration(days: 1), (timer) {
      refreshAuth();
    });
    super.initState();
  }

  @override
  void dispose() {
    _authRefreshTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "Today",
          style: Constants.textStyles.title2.copyWith(color: Colors.white),
        ),
        actions: [
          GestureDetector(
            onTap: () => Nav.pop(context),
            child: Text(
              "User: ${authCubit.state.phUser?.name}    ",
              style: Constants.textStyles.data.copyWith(color: Colors.white),
            ),
          ),
        ],
        automaticallyImplyLeading: false,
      ),
      body:
          isLoading
              ? Center(child: MainLoader())
              : Builder(
                builder: (context) {
                  bool isOnlyDashboard = users.isEmpty && isDashboard;

                  if (isPortrait(context) && isDashboard) {
                    Future.delayed(Duration(seconds: 1), () {
                      snack(
                        context,
                        "This user is a Dashboard user, which is best viewed in landscape mode, on larger displays.",
                        isError: false,
                      );
                    });
                  }

                  if (isOnlyDashboard) {
                    return Container(
                      alignment: Alignment.center,
                      height: MediaQuery.of(context).size.height,
                      width: MediaQuery.of(context).size.width,
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: Text(
                          "No users found, create some to get started.",
                          style: Constants.textStyles.title2,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  }
                  return Container(
                    alignment: Alignment.center,
                    height: MediaQuery.of(context).size.height,
                    width: MediaQuery.of(context).size.width,
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width,
                      child:
                          isDashboard
                              ? Row(
                                children:
                                    users
                                        .map(
                                          (user) => Expanded(
                                            child: UserList(user: user),
                                          ),
                                        )
                                        .toList(),
                              )
                              : UserList(user: authCubit.state.phUser!),
                    ),
                  );
                },
              ),
    );
  }
}
