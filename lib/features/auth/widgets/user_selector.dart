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
            height: 100,
            width: 100,
            child: FittedBox(
                child: Icon(
              user != null ? Icons.person_rounded : Icons.add_rounded,
              color: Colors.grey.shade400,
            )),
          ),
          Gap(20),
          Text(
            user?.name ?? "Add A User",
            style: Constants.textStyles.title2,
          )
        ],
      ),
    );
  }
}
