part of 'auth_cubit.dart';

class AuthState extends Equatable {
  const AuthState({this.phUser, this.phUsers = const []});

  final PHUser? phUser;
  final List<PHUser> phUsers;

  AuthState copyWith({
    PHUser? phUser,
    List<PHUser>? phUsers,
  }) {
    return AuthState(
        phUser: phUser ?? this.phUser, phUsers: phUsers ?? this.phUsers);
  }

  @override
  List<Object?> get props => [phUser, phUser];
}
