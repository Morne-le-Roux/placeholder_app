import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:placeholder/features/auth/cubit/auth_cubit.dart';
import 'package:placeholder/features/auth/models/p_h_user.dart';

String userNameFromID(BuildContext context, {required String? userId}) {
  if (userId == null || userId == '') return "User Name Not Found";

  List<PHUser> users = context.read<AuthCubit>().state.phUsers;

  PHUser? user = users.firstWhereOrNull(
    (user) => user.id == userId,
  );
  return user?.name ?? "User Name Not Found";
}
