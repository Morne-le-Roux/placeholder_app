import 'dart:math';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:placeholder/main.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../models/p_h_user.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(AuthState());

  Future<void> login(String email, String password) async {
    try {
      await pb.collection("users").authWithPassword(email, password);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> createLoginEvent() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    try {
      await pb
          .collection("login_events")
          .create(
            body: {
              "user": pb.authStore.record!.id,
              "app_version": packageInfo.version,
              "string_array_test": [
                "login",
                "logout",
                "create_task",
                "create_dashboard",
                "create_user",
              ],
            },
          );

      final response = await pb
          .collection("login_events")
          .getList(filter: "user = '${pb.authStore.record!.id}'");
      List<String> stringArrayTest = [];
      for (var item in response.items) {
        if (item.data["string_array_test"] != null) {
          final dynamicList = item.data["string_array_test"] as List<dynamic>;
          stringArrayTest.addAll(
            dynamicList.map((item) => item.toString()).toList(),
          );
        }
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> register(String email, String password) async {
    try {
      await pb
          .collection("users")
          .create(
            body: {
              "email": email,
              "password": password,
              "passwordConfirm": password,
            },
          );
    } catch (e) {
      rethrow;
    }
  }

  Future<List<PHUser>> fetchUsers() async {
    try {
      List<PHUser> phUsers = [];
      final response = await pb.collection("ph_users").getList();

      for (var phuRecord in response.items) {
        phUsers.add(PHUser.fromMap(phuRecord.toJson()));
      }
      emit(state.copyWith(phUsers: phUsers));
      return phUsers;
    } catch (e) {
      rethrow;
    }
  }

  void setPHUser(PHUser phUser) {
    emit(state.copyWith(phUser: phUser));
  }

  Future<void> createUser(PHUser phUser) async {
    try {
      final response = await pb
          .collection("ph_users")
          .create(body: phUser.toMap());
      emit(state.copyWith(phUser: PHUser.fromMap(response.toJson())));
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateUser(PHUser phUser) async {
    try {
      final response = await pb
          .collection("ph_users")
          .update(phUser.id, body: phUser.toMap());
      emit(state.copyWith(phUser: PHUser.fromMap(response.toJson())));
    } catch (e) {
      rethrow;
    }
  }

  Future<void> checkSub() async {
    // if manual pro untill date override is set, check if it's before now, if it is, set pro to true
    // if it's not set, check if the user has an active subscription
    String? manualProUntillDateOverride =
        pb.authStore.record?.data["manual_pro_untill_date_override"];

    if (manualProUntillDateOverride != null) {
      DateTime? manualProUntillDateOverrideDate = DateTime.tryParse(
        manualProUntillDateOverride,
      );
      if (manualProUntillDateOverrideDate != null &&
          manualProUntillDateOverrideDate.isBefore(DateTime.now())) {
        setPro(true);
        return;
      } else {
        // if the manual pro untill date override is not before now, set it to null
        pb
            .collection("users")
            .update(
              pb.authStore.record!.id,
              body: {"manual_pro_untill_date_override": null},
            );
      }
    }

    final CustomerInfo customerInfo = await Purchases.getCustomerInfo();

    final bool isPro = customerInfo.activeSubscriptions.isNotEmpty;

    setPro(isPro);
  }

  void setPro(bool isPro) {
    pb
        .collection("users")
        .update(pb.authStore.record!.id, body: {"is_pro": isPro});
    emit(state.copyWith(isPro: isPro));
  }

  Future<void> getSubscriptions() async {
    final Offerings offerings = await Purchases.getOfferings();
    final List<Package> subscriptions =
        offerings.current?.availablePackages ?? [];
    emit(state.copyWith(availableSubscriptions: subscriptions));
  }

  Future<void> deleteUser(String userId) async {
    await pb.collection("ph_users").delete(userId);
  }
}
