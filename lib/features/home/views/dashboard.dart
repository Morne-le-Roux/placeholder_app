import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:placeholder_app/core/widgets/loaders/main_loader.dart';
import 'package:placeholder_app/features/home/widgets/user_list.dart';
import 'package:placeholder_app/core/usecases/snack.dart';

import '../../../core/usecases/is_portrait.dart';
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
        title: Text("Today"),
        actions: [Text("User: ${authCubit.state.phUser?.name}  ")],
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
