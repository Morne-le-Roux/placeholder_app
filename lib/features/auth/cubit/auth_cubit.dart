import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:placeholder/main.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:uuid/uuid.dart';

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
    await Purchases.logIn(pb.authStore.record?.id ?? Uuid().v4());
    final CustomerInfo customerInfo = await Purchases.getCustomerInfo();

    final bool isPro = customerInfo.activeSubscriptions.isNotEmpty;

    if (isPro) {
      emit(state.copyWith(isPro: isPro));
    } else {
      emit(state.copyWith(isPro: false));
    }
  }

  void setPro() {
    emit(state.copyWith(isPro: true));
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
