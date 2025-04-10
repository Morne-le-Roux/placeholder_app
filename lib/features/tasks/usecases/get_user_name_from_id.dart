import 'package:flutter/material.dart';
import 'package:placeholder_app/features/auth/cubit/auth_cubit.dart';

String getUserNameFromId(BuildContext context, {required String? userId}) {
  if (userId == null) return "User Name Not Found";

  return "User";
}
