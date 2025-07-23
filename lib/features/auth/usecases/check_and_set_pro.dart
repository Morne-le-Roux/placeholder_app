import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:placeholder/features/auth/cubit/auth_cubit.dart';
import 'package:placeholder/features/auth/models/user.dart';
import 'package:placeholder/services/purchase_service.dart';

Future<void> checkAndSetPro(BuildContext context) async {
  User? accountHolder =
      await context.read<AuthCubit>().getAccountHolderDetails();
  if (accountHolder == null) {
    return;
  }

  String? baseID = await PurchaseService().isUserPro(
    activeSubscription: accountHolder.activeSubscription,
    nextProCheck: accountHolder.nextProCheck,
  );

  if (baseID != null) {
    context.read<AuthCubit>().setLocalPro(true);
  } else {
    context.read<AuthCubit>().setLocalPro(false);
  }
}
