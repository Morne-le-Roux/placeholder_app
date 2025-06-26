import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:placeholder/core/constants/constants.dart';
import 'package:placeholder/core/widgets/loaders/main_loader.dart';
import 'package:placeholder/features/auth/cubit/auth_cubit.dart';
import 'package:placeholder/features/auth/models/p_h_user.dart';
import 'package:simple_shadow/simple_shadow.dart';

class UserSelector extends StatelessWidget {
  const UserSelector({
    super.key,
    this.user,
    required this.onTap,
    required this.onDelete,
    this.showEdit = false,
    this.loading = false,
    this.isDashboard = false,
    required this.onLongPress,
  });

  final PHUser? user;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final bool showEdit;
  final bool loading;
  final bool isDashboard;
  final VoidCallback onLongPress;

  String _wrapText(String text, {int maxChars = 10}) {
    if (text.length <= maxChars) return text;

    final words = text.split(' ');
    String result = '';
    String currentLine = '';

    for (int i = 0; i < words.length; i++) {
      final word = words[i];
      if (currentLine.isEmpty) {
        // First word of a line
        currentLine = word;
        if (currentLine.length > maxChars) {
          result += currentLine;
          currentLine = '';
          if (i < words.length - 1) {
            result += '\n';
          }
        } else {
          currentLine += ' ';
        }
      } else if ((currentLine + word).length > maxChars) {
        result += '${currentLine.trim()}\n';
        currentLine = '$word ';
      } else {
        currentLine += '$word ';
      }
    }

    return result + currentLine.trim();
  }

  @override
  Widget build(BuildContext context) {
    bool hasAvatar = user?.avatarURL != null && user?.avatarURL != "";

    return Stack(
      alignment: Alignment.topRight,
      children: [
        GestureDetector(
          onTap: onTap,
          onLongPress: onLongPress,
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color:
                      user != null
                          ? Constants.colors.primary.withAlpha(100)
                          : const Color.fromARGB(255, 25, 25, 25),
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
                    decoration: BoxDecoration(
                      color:
                          user != null
                              ? Color.fromARGB(255, 30, 30, 30)
                              : const Color.fromARGB(255, 15, 15, 15),
                      shape: BoxShape.circle,
                    ),
                    height: 100,
                    width: 100,
                    child: Builder(
                      builder: (context) {
                        if (user != null) {
                          return AnimatedSwitcher(
                            duration: Duration(milliseconds: 200),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Builder(
                                  builder: (context) {
                                    if (user?.avatarURL == null ||
                                        user?.avatarURL == "") {
                                      if (showEdit) {
                                        return SizedBox();
                                      }
                                      return Icon(
                                        isDashboard
                                            ? Symbols.dashboard_2
                                            : Icons.person_rounded,
                                        color: const Color.fromARGB(
                                          255,
                                          73,
                                          73,
                                          73,
                                        ),
                                        size: 80,
                                      );
                                    }

                                    return ClipRRect(
                                      borderRadius: BorderRadius.circular(1000),
                                      child: Image.network(
                                        user!.avatarURL!,
                                        width: 100,
                                        height: 100,
                                        fit: BoxFit.cover,
                                      ),
                                    );
                                  },
                                ),
                                if (showEdit)
                                  Padding(
                                    padding: EdgeInsets.all(5),
                                    child: SimpleShadow(
                                      child: Icon(
                                        Icons.edit,
                                        size: 60,
                                        color:
                                            hasAvatar
                                                ? const Color.fromARGB(
                                                  145,
                                                  255,
                                                  255,
                                                  255,
                                                )
                                                : Color.fromARGB(
                                                  255,
                                                  73,
                                                  73,
                                                  73,
                                                ),
                                      ),
                                    ),
                                  ),
                              ],
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
              Gap(20),
              if (user != null)
                Text(
                  _wrapText(user?.name ?? ""),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: Constants.textStyles.title2.copyWith(
                    color: const Color.fromARGB(255, 153, 153, 153),
                  ),
                )
              else
                Gap(20),
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
