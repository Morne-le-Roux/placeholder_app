import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:placeholder/core/constants/constants.dart';
import 'package:placeholder/features/auth/models/p_h_user.dart';

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
            padding: EdgeInsets.all(2),
            decoration: BoxDecoration(
                color: const Color.fromARGB(255, 39, 39, 39),
                shape: BoxShape.circle),
            child: Container(
              padding: EdgeInsets.all(2),
              decoration:
                  BoxDecoration(color: Colors.black, shape: BoxShape.circle),
              child: Container(
                padding: user?.avatarURL == null ? EdgeInsets.all(20) : null,
                decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 39, 39, 39),
                    shape: BoxShape.circle),
                height: 100,
                width: 100,
                child: FittedBox(
                    child: Icon(
                  user != null ? Icons.person_rounded : Icons.add_rounded,
                  color: const Color.fromARGB(255, 73, 73, 73),
                )),
              ),
            ),
          ),
          Gap(20),
          Text(
            user?.name ?? "Add A User",
            style: Constants.textStyles.title2
                .copyWith(color: const Color.fromARGB(255, 153, 153, 153)),
          ),
          Gap(20),
        ],
      ),
    );
  }
}
