import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:placeholder/core/usecases/pick_image.dart';
import 'package:placeholder/core/usecases/upload_image.dart';
import 'package:placeholder/core/widgets/buttons/large_rounded_button.dart';
import 'package:placeholder/core/widgets/loaders/main_loader.dart';
import 'package:placeholder/features/auth/models/p_h_user.dart';
import 'package:placeholder/main.dart';
import 'package:placeholder/core/usecases/nav.dart';
import 'package:placeholder/core/usecases/snack.dart';
import 'package:uuid/uuid.dart';

import '../../../core/constants/constants.dart';
import '../cubit/auth_cubit.dart';

class CreateUser extends StatefulWidget {
  const CreateUser({super.key, this.user});

  final PHUser? user;

  @override
  State<CreateUser> createState() => _CreateUserState();
}

class _CreateUserState extends State<CreateUser> {
  late PHUser phUser;
  bool loading = false;
  bool loadingAvatar = false;

  AuthCubit get authCubit => context.read<AuthCubit>();

  @override
  void initState() {
    phUser =
        widget.user ??
        PHUser(
          id: Uuid().v4().replaceAll("-", ""),
          name: "",
          avatarURL: null,
          isDashboard: false,
          accountHolderID: pb.authStore.record?.id ?? "",
        );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 19, 19, 19),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              initialValue: phUser.name,
              style: Constants.textStyles.description.copyWith(
                color: const Color.fromARGB(255, 207, 207, 207),
              ),
              onChanged:
                  (value) =>
                      setState(() => phUser = phUser.copyWith(name: value)),
              decoration: InputDecoration(
                labelText: "User Name",
                labelStyle: Constants.textStyles.data.copyWith(
                  color: const Color.fromARGB(255, 207, 207, 207),
                ),
              ),
            ),
            Gap(20),
            Row(
              children: [
                Text(
                  "Dashboard",
                  style: Constants.textStyles.description.copyWith(
                    color: const Color.fromARGB(255, 207, 207, 207),
                  ),
                ),
                Expanded(child: SizedBox()),
                Switch(
                  inactiveTrackColor: Colors.black38,

                  value: phUser.isDashboard,
                  onChanged:
                      (value) => setState(
                        () => phUser = phUser.copyWith(isDashboard: value),
                      ),
                ),
              ],
            ),
            InkWell(
              onTap: () async {
                File? file = await pickImage(context);
                if (file != null) {
                  setState(() => loadingAvatar = true);
                  phUser = phUser.copyWith(avatarURL: await uploadImage(file));
                  setState(() => loadingAvatar = false);
                }
              },
              child: Container(
                padding: EdgeInsets.all(2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.deepOrange.withAlpha(100),
                ),
                child: Container(
                  padding: EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color.fromARGB(255, 0, 0, 0),
                  ),
                  child: Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color.fromARGB(255, 25, 25, 25),
                    ),
                    child: FittedBox(
                      child:
                          loadingAvatar
                              ? MainLoader()
                              : phUser.avatarURL == null
                              ? Icon(
                                Icons.person,
                                color: const Color.fromARGB(255, 45, 45, 45),
                              )
                              : Image.network(phUser.avatarURL!),
                    ),
                  ),
                ),
              ),
            ),
            Gap(40),

            LargeRoundedButton(
              text: widget.user == null ? "Create User" : "Update User",
              onPressed: () async {
                try {
                  FocusScope.of(context).unfocus();
                  setState(() => loading = true);
                  if (widget.user == null) {
                    await authCubit.createUser(phUser);
                  } else {
                    await authCubit.updateUser(phUser);
                  }
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
      ),
    );
  }
}
