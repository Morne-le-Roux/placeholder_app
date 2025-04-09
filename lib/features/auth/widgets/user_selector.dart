import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:placeholder_app/core/constants/constants.dart';
import 'package:placeholder_app/features/auth/models/p_h_user.dart';

class UserSelector extends StatelessWidget {
  const UserSelector({super.key, this.user, required this.onTap});

  final PHUser? user;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: user?.avatarURL == null ? EdgeInsets.all(20) : null,
            decoration: BoxDecoration(
                color: Colors.grey.shade300, shape: BoxShape.circle),
            height: 200,
            width: 200,
            child: FittedBox(
                child: Icon(
              Icons.person_rounded,
              color: Colors.grey,
            )),
          ),
          Gap(20),
          Text(
            user?.name ?? "Add A User",
            style: Constants.textStyles.title,
          )
        ],
      ),
    );
  }
}
