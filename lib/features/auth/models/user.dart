class User {
  final String id;
  final String email;
  final bool isPro;
  final String? activeSubscription;
  final String? nextProCheck;
  User({
    required this.id,
    required this.email,
    required this.isPro,
    this.activeSubscription,
    this.nextProCheck,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'email': email,
      'is_pro': isPro,
      'active_subscription': activeSubscription,
      'next_pro_check': nextProCheck,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] as String,
      email: map['email'] as String,
      isPro: map['is_pro'] as bool,
      activeSubscription:
          map['active_subscription'] != null
              ? map['active_subscription'] as String
              : null,
      nextProCheck:
          map['next_pro_check'] != null
              ? map['next_pro_check'] as String
              : null,
    );
  }

  User copyWith({
    String? id,
    String? email,
    bool? isPro,
    String? activeSubscription,
    String? nextProCheck,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      isPro: isPro ?? this.isPro,
      activeSubscription: activeSubscription ?? this.activeSubscription,
      nextProCheck: nextProCheck ?? this.nextProCheck,
    );
  }

  @override
  bool operator ==(covariant User other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.email == email &&
        other.isPro == isPro &&
        other.activeSubscription == activeSubscription &&
        other.nextProCheck == nextProCheck;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        email.hashCode ^
        isPro.hashCode ^
        activeSubscription.hashCode ^
        nextProCheck.hashCode;
  }
}
