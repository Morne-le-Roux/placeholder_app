import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:placeholder_app/core/widgets/avatar.dart';
import 'package:placeholder_app/features/auth/models/p_h_user.dart';

class UserList extends StatelessWidget {
  const UserList({super.key, required this.user});

  final PHUser user;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(minWidth: 100),
      padding: EdgeInsets.only(top: 20, right: 10, left: 10),
      decoration: BoxDecoration(
          border: Border(right: BorderSide(width: 0.5, color: Colors.grey))),
      child: Column(
        children: [
          Row(
            children: [
              Avatar(url: user.avatarURL),
              Gap(10),
              Text(user.name),
            ],
          )
        ],
      ),
    );
  }
}
