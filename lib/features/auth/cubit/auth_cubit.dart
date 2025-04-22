import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:placeholder/main.dart';

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
      await pb.collection("users").create(
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
      final response = await pb.collection("ph_users").create(
            body: phUser.toMap(),
          );
      emit(state.copyWith(phUser: PHUser.fromMap(response.toJson())));
    } catch (e) {
      rethrow;
    }
  }
}
