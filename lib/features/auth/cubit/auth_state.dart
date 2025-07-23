part of 'auth_cubit.dart';

class AuthState extends Equatable {
  const AuthState({
    this.phUser,
    this.accountHolder,
    this.phUsers = const [],
    this.isPro = false,
  });

  final PHUser? phUser;
  final User? accountHolder;
  final List<PHUser> phUsers;
  final bool isPro;

  AuthState copyWith({
    PHUser? phUser,
    List<PHUser>? phUsers,
    bool? isPro,
    User? accountHolder,
  }) {
    return AuthState(
      phUser: phUser ?? this.phUser,
      phUsers: phUsers ?? this.phUsers,
      isPro: isPro ?? this.isPro,
      accountHolder: this.accountHolder,
    );
  }

  @override
  List<Object?> get props => [phUser, phUsers, isPro, accountHolder];
}
