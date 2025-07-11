import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:placeholder/features/auth/cubit/auth_cubit.dart';

import '../../../core/constants/constants.dart';
import '../../../core/usecases/nav.dart';
import '../../payment/views/paywall.dart';

bool canCreateUser(BuildContext context, {required int currentUserCount}) {
  return true; // Temporarily returning true for development purposes
  // bool canCreateUser = context.read<AuthCubit>().state.isPro;
  // if (!canCreateUser) {
  //   bool aboveLimit = currentUserCount >= Constants.limits.userCountLimit;
  //   if (aboveLimit) {
  //     Nav.push(context, Paywall());
  //     return false;
  //   } else {
  //     return true;
  //   }
  // } else {
  //   return true;
  // }
}
