import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:placeholder/core/usecases/nav.dart';
import 'package:placeholder/core/widgets/loaders/main_loader.dart';
import 'package:placeholder/features/home/widgets/user_list.dart';
import 'package:placeholder/core/usecases/snack.dart';

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
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Today",
            style: Constants.textStyles.title2.copyWith(color: Colors.white)),
        actions: [
          GestureDetector(
            onTap: () => Nav.pop(context),
            child: Text(
              "User: ${authCubit.state.phUser?.name}    ",
              style: Constants.textStyles.data.copyWith(color: Colors.white),
            ),
          )
        ],
        automaticallyImplyLeading: false,
      ),
      body: isLoading
          ? Center(child: MainLoader())
          : Container(
              alignment: Alignment.center,
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                child: isDashboard
                    ? Row(
                        children: users
                            .map(
                                (user) => Expanded(child: UserList(user: user)))
                            .toList())
                    : UserList(user: authCubit.state.phUser!),
              ),
            ),
    );
  }
}
