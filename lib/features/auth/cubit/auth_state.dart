part of 'auth_cubit.dart';

class AuthState extends Equatable {
  const AuthState({
    this.phUser,
    this.phUsers = const [],
    // this.availableSubscriptions = const [],
    this.isPro = false,
  });

  final PHUser? phUser;
  final List<PHUser> phUsers;
  final bool isPro;

  AuthState copyWith({
    PHUser? phUser,
    List<PHUser>? phUsers,
    // List<Package>? availableSubscriptions,
    bool? isPro,
  }) {
    return AuthState(
      phUser: phUser ?? this.phUser,
      phUsers: phUsers ?? this.phUsers,
      // availableSubscriptions:
      //     availableSubscriptions ?? this.availableSubscriptions,
      isPro: isPro ?? this.isPro,
    );
  }

  @override
  List<Object?> get props => [phUser, phUsers, isPro];
}
