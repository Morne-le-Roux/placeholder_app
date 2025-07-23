import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:placeholder/features/auth/models/user.dart';
import 'package:placeholder/main.dart';

import '../models/p_h_user.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(AuthState());

  Future<void> login(String email, String password) async {
    try {
      await sb.auth.signInWithPassword(email: email, password: password);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> register(String email, String password) async {
    try {
      await sb.auth.signUp(email: email, password: password);
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> isEmailAvailable(String email) async {
    try {
      bool doesExist = await sb.rpc(
        "does_email_exist",
        params: {"check_email": email},
      );
      return doesExist;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<PHUser>> fetchUsers() async {
    try {
      List<PHUser> phUsers = [];
      final response = await sb.from("ph_users").select();

      for (Map<String, dynamic> phuRecord in response) {
        phUsers.add(PHUser.fromMap(phuRecord));
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
      await sb.from("ph_users").insert(phUser.toMap());
      emit(state.copyWith(phUser: phUser));
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateUser(PHUser phUser) async {
    try {
      await sb.from("ph_users").update(phUser.toMap()).eq("id", phUser.id);
      emit(state.copyWith(phUser: phUser));
    } catch (e) {
      rethrow;
    }
  }

  void setLocalPro(bool pro) {
    emit(state.copyWith(isPro: pro));
  }

  Future<void> deleteUser(String userId) async {
    await sb.from("ph_users").delete().eq("id", userId);
  }

  Future<User?> getAccountHolderDetails() async {
    try {
      if (sb.auth.currentUser?.id != null) {
        final response = await sb
            .from('profiles')
            .select()
            .eq('id', sb.auth.currentUser!.id);
        if (response.isNotEmpty) {
          final profile = response.first;
          final accountHolder = User.fromMap(profile);

          emit(state.copyWith(accountHolder: accountHolder));
          return accountHolder;
        }
      } else {
        throw "No user logged in";
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }
}
