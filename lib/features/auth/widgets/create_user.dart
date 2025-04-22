import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:placeholder/core/widgets/buttons/large_rounded_button.dart';
import 'package:placeholder/features/auth/models/p_h_user.dart';
import 'package:placeholder/main.dart';
import 'package:placeholder/core/usecases/nav.dart';
import 'package:placeholder/core/usecases/snack.dart';
import 'package:uuid/uuid.dart';

import '../../../core/constants/constants.dart';
import '../../../core/usecases/is_dark_mode.dart';
import '../cubit/auth_cubit.dart';

class CreateUser extends StatefulWidget {
  const CreateUser({super.key});

  @override
  State<CreateUser> createState() => _CreateUserState();
}

class _CreateUserState extends State<CreateUser> {
  late PHUser phUser;
  bool loading = false;

  AuthCubit get authCubit => context.read<AuthCubit>();

  @override
  void initState() {
    phUser = PHUser(
        id: Uuid().v4().replaceAll("-", ""),
        name: "",
        avatarURL: null,
        isDashboard: false,
        accountHolderID: pb.authStore.record?.id ?? "");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: isDarkMode(context)
              ? const Color.fromARGB(255, 19, 19, 19)
              : Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      padding: EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            initialValue: phUser.name,
            style: Constants.textStyles.description.copyWith(
                color: isDarkMode(context)
                    ? const Color.fromARGB(255, 207, 207, 207)
                    : Colors.black),
            onChanged: (value) =>
                setState(() => phUser = phUser.copyWith(name: value)),
            decoration: InputDecoration(
                labelText: "User Name",
                labelStyle: Constants.textStyles.data.copyWith(
                    color: isDarkMode(context)
                        ? const Color.fromARGB(255, 207, 207, 207)
                        : Colors.black)),
          ),
          Gap(20),
          Row(
            children: [
              Text("Dashboard",
                  style: Constants.textStyles.description.copyWith(
                      color: isDarkMode(context)
                          ? const Color.fromARGB(255, 207, 207, 207)
                          : Colors.black)),
              Expanded(child: SizedBox()),
              Switch(
                  value: phUser.isDashboard,
                  onChanged: (value) => setState(
                        () => phUser = phUser.copyWith(isDashboard: value),
                      ))
            ],
          ),
          Gap(20),
          LargeRoundedButton(
            text: "Create User",
            onPressed: () async {
              try {
                FocusScope.of(context).unfocus();
                setState(() => loading = true);
                await authCubit.createUser(phUser);
                setState(() => loading = false);
                Nav.pop(context);
              } catch (e) {
                setState(() => loading = false);
                snack(context, e.toString());
              }
            },
            isLoading: loading,
            isValid: phUser.name.isNotEmpty,
          ),
          Gap(20),
        ],
      ),
    );
  }
}
