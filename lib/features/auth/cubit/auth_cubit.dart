import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:placeholder_app/main.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(AuthInitial());

  Future<void> login(String email, String password) async {
    try {
      await supabaseClient.auth
          .signInWithPassword(email: email, password: password);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> register(String email, String password) async {
    try {
      await supabaseClient.auth.signUp(email: email, password: password);
      await login(email, password);
    } catch (e) {
      rethrow;
    }
  }
}
