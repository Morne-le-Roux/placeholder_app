import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:placeholder_app/core/widgets/buttons/large_rounded_button.dart';
import 'package:placeholder_app/features/auth/models/p_h_user.dart';
import 'package:placeholder_app/main.dart';
import 'package:placeholder_app/usecases/nav.dart';
import 'package:placeholder_app/usecases/snack.dart';
import 'package:uuid/uuid.dart';

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
        id: Uuid().v4(),
        name: "",
        avatarURL: null,
        isDashboard: false,
        accountHolderId: supabaseClient.auth.currentUser?.id ?? "");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      padding: EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            initialValue: phUser.name,
            onChanged: (value) =>
                setState(() => phUser = phUser.copyWith(name: value)),
            decoration: InputDecoration(label: Text("User Name")),
          ),
          Gap(20),
          Row(
            children: [
              Text("Dashboard"),
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
