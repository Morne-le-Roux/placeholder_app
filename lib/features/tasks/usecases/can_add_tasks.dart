import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:placeholder/core/constants/constants.dart';
import 'package:placeholder/core/usecases/nav.dart';
import 'package:placeholder/features/auth/cubit/auth_cubit.dart';
import 'package:placeholder/features/payment/views/paywall.dart';

bool canAddTask(BuildContext context, {required int currentTaskCount}) {
  bool canAddTask = context.read<AuthCubit>().state.isPro;

  if (!canAddTask) {
    bool aboveLimit =
        currentTaskCount >= Constants.limits.taskCountLimitPerUser;
    if (aboveLimit) {
      Nav.push(context, Paywall());
      return false;
    } else {
      return true;
    }
  } else {
    return true;
  }
}
