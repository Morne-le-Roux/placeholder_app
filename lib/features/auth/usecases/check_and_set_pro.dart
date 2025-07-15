import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:placeholder/features/auth/cubit/auth_cubit.dart';
import 'package:placeholder/main.dart';
import 'package:placeholder/services/purchase_service.dart';

Future<void> checkAndSetPro(BuildContext context) async {
  String? userId = sb.auth.currentUser?.id;
  bool isPro = await PurchaseService().isUserPro();
  if (userId == null) throw "User is null, cannot update";
  await sb
      .from("profiles")
      .update({'is_pro': isPro})
      .eq("id", sb.auth.currentUser?.id ?? "");
  context.read<AuthCubit>().setLocalPro(false);
}
