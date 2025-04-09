part of 'auth_cubit.dart';

class AuthState extends Equatable {
  const AuthState({this.phUser});

  final PHUser? phUser;

  AuthState copyWith({
    PHUser? phUser,
  }) {
    return AuthState(phUser: phUser ?? this.phUser);
  }

  @override
  List<Object?> get props => [phUser];
}
