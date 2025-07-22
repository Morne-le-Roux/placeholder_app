import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:placeholder/features/auth/cubit/auth_cubit.dart';
import 'package:placeholder/services/purchase_service.dart';

Future<void> checkAndSetPro(BuildContext context) async {
  String? baseID = await PurchaseService().isUserPro();

  if (baseID != null) {
    context.read<AuthCubit>().setLocalPro(false);
  }
}
