import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:placeholder/core/constants/constants.dart';
import 'package:placeholder/core/widgets/loaders/main_loader.dart';
import 'package:placeholder/features/auth/cubit/auth_cubit.dart';
import 'package:placeholder/features/auth/models/p_h_user.dart';

class UserSelector extends StatelessWidget {
  const UserSelector({
    super.key,
    this.user,
    required this.onTap,
    required this.onDelete,
    this.showEdit = false,
    this.loading = false,
  });

  final PHUser? user;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final bool showEdit;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topRight,
      children: [
        GestureDetector(
          onTap: onTap,
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: Constants.colors.primary.withAlpha(100),
                  shape: BoxShape.circle,
                ),
                child: Container(
                  padding: EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    shape: BoxShape.circle,
                  ),
                  child: Container(
                    clipBehavior: Clip.hardEdge,
                    padding:
                        user?.avatarURL == null ? EdgeInsets.all(20) : null,
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 39, 39, 39),
                      shape: BoxShape.circle,
                    ),
                    height: 100,
                    width: 100,
                    child: FittedBox(
                      fit: BoxFit.cover,
                      child: Builder(
                        builder: (context) {
                          if (user != null) {
                            return AnimatedSwitcher(
                              duration: Duration(milliseconds: 200),
                              child:
                                  showEdit
                                      ? Padding(
                                        padding: EdgeInsets.all(5),
                                        child: Icon(
                                          Icons.edit,
                                          color: const Color.fromARGB(
                                            255,
                                            73,
                                            73,
                                            73,
                                          ),
                                        ),
                                      )
                                      : user?.avatarURL == null ||
                                          user?.avatarURL == ""
                                      ? Icon(
                                        Icons.person_rounded,
                                        color: const Color.fromARGB(
                                          255,
                                          73,
                                          73,
                                          73,
                                        ),
                                      )
                                      : ClipRRect(
                                        borderRadius: BorderRadius.circular(
                                          1000,
                                        ),
                                        child: Image.network(user!.avatarURL!),
                                      ),
                            );
                          }
                          return Icon(
                            Icons.add_rounded,
                            color: const Color.fromARGB(255, 73, 73, 73),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
              Gap(20),
              Text(
                user?.name ?? "Add A User",
                style: Constants.textStyles.title2.copyWith(
                  color: const Color.fromARGB(255, 153, 153, 153),
                ),
              ),
              Gap(20),
            ],
          ),
        ),
        AnimatedContainer(
          height: showEdit && user != null ? 30 : 0,
          duration: Duration(milliseconds: 100),
          curve: Curves.easeInOut,
          child: FittedBox(
            child:
                loading
                    ? MainLoader()
                    : GestureDetector(
                      onTap: () async {
                        bool delete = await showDialog(
                          context: context,
                          builder:
                              (context) => AlertDialog(
                                backgroundColor: const Color.fromARGB(
                                  255,
                                  22,
                                  22,
                                  22,
                                ),
                                title: Text(
                                  "Delete User?",
                                  style: Constants.textStyles.title2,
                                ),
                                content: Text(
                                  "All of the tasks linked to this user will also be removed. This cannot be undone.",
                                  style: Constants.textStyles.description,
                                ),
                                actions: [
                                  TextButton(
                                    onPressed:
                                        () => Navigator.of(context).pop(false),
                                    child: Text(
                                      "No",
                                      style: TextStyle(
                                        color: Colors.deepOrange,
                                      ),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed:
                                        () => Navigator.of(context).pop(true),
                                    child: Text(
                                      "Yes",
                                      style: TextStyle(
                                        color: Colors.deepOrange,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                        );
                        if (delete) {
                          await context.read<AuthCubit>().deleteUser(
                            user?.id ?? "",
                          );
                          onDelete.call();
                        }
                      },
                      child: Icon(
                        fill: 1,
                        Symbols.cancel,
                        color: Colors.deepOrange.shade900,
                      ),
                    ),
          ),
        ),
      ],
    );
  }
}
