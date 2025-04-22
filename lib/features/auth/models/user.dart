// ignore_for_file: public_member_api_docs, sort_constructors_first
class User {
  final String id;
  final String email;
  final bool verified;
  final String name;
  final String? avatar;
  final String created;
  User({
    required this.id,
    required this.email,
    required this.verified,
    required this.name,
    this.avatar,
    required this.created,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'email': email,
      'verified': verified,
      'name': name,
      'avatar': avatar,
      'created': created,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] as String,
      email: map['email'] as String,
      verified: map['verified'] as bool,
      name: map['name'] as String,
      avatar: map['avatar'] != null ? map['avatar'] as String : null,
      created: map['created'] as String,
    );
  }
}
