import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:material_symbols_icons/symbols.dart';
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
  const CreateUser({super.key, this.user, this.isDashboard = false});

  final PHUser? user;
  final bool isDashboard;

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
          isDashboard: widget.isDashboard,
          accountHolderID: sb.auth.currentUser?.id ?? "",
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
                labelText: phUser.isDashboard ? "Dashboard Name" : "User Name",
                labelStyle: Constants.textStyles.data.copyWith(
                  color: const Color.fromARGB(255, 207, 207, 207),
                ),
              ),
            ),
            Gap(20),
            Divider(thickness: 0.5),

            InkWell(
              onTap:
                  () => setState(
                    () =>
                        phUser = phUser.copyWith(
                          isDashboard: !phUser.isDashboard,
                        ),
                  ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Is this a Dashboard?",
                          style: Constants.textStyles.title3.copyWith(
                            color: const Color.fromARGB(255, 207, 207, 207),
                          ),
                        ),
                        Gap(5),
                        Text(
                          "Dashboards will be able to see all of the tasks and projects of all users. Best viewed on tablets.",
                          style: Constants.textStyles.data.copyWith(
                            color: const Color.fromARGB(255, 207, 207, 207),
                          ),
                        ),
                      ],
                    ),
                  ),
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
            ),

            Gap(10),
            Divider(thickness: 0.5),
            Gap(20),

            InkWell(
              onTap: () async {
                try {
                  File? file = await pickImage(context);
                  if (file != null) {
                    setState(() => loadingAvatar = true);
                    phUser = phUser.copyWith(
                      avatarURL: await uploadImage(file),
                    );
                    setState(() => loadingAvatar = false);
                  }
                } catch (e) {
                  setState(() => loadingAvatar = false);
                  snack(context, e.toString());
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
                    constraints: BoxConstraints(maxWidth: 150, maxHeight: 150),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color.fromARGB(255, 25, 25, 25),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(1000),
                      child: FittedBox(
                        fit: BoxFit.cover,
                        child:
                            loadingAvatar
                                ? MainLoader()
                                : phUser.avatarURL == null ||
                                    phUser.avatarURL == ""
                                ? Padding(
                                  padding: EdgeInsets.all(10),
                                  child: Icon(
                                    phUser.isDashboard
                                        ? Symbols.dashboard_2
                                        : Icons.person,
                                    color: const Color.fromARGB(
                                      255,
                                      45,
                                      45,
                                      45,
                                    ),
                                    size: 100,
                                  ),
                                )
                                : Image.network(getImageUrl(phUser.avatarURL!)),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Gap(40),

            LargeRoundedButton(
              text:
                  widget.user == null
                      ? "Create ${phUser.isDashboard ? "Dashboard" : "User"}"
                      : "Update ${phUser.isDashboard ? "Dashboard" : "User"}",
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
