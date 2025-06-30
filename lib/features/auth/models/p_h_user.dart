import 'dart:convert';

// ignore_for_file: public_member_api_docs, sort_constructors_first

class PHUser {
  PHUser({
    required this.id,
    required this.name,
    required this.avatarURL,
    required this.isDashboard,
    required this.accountHolderID,
  });
  final String id;
  final String name;
  final String? avatarURL;
  final bool isDashboard;
  final String accountHolderID;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'avatar_url': avatarURL,
      'is_dashboard': isDashboard,
      'account_holder': accountHolderID,
    };
  }

  factory PHUser.fromMap(Map<String, dynamic> map) {
    return PHUser(
      id: map['id'] as String,
      name: map['name'] as String,
      avatarURL: map['avatar_url'] != null ? map['avatar_url'] as String : null,
      isDashboard: map['is_dashboard'] as bool,
      accountHolderID: map['account_holder'] as String,
    );
  }

  PHUser copyWith({
    String? id,
    String? name,
    String? avatarURL,
    bool? isDashboard,
    String? accountHolderId,
  }) {
    return PHUser(
      id: id ?? this.id,
      name: name ?? this.name,
      avatarURL: avatarURL ?? this.avatarURL,
      isDashboard: isDashboard ?? this.isDashboard,
      accountHolderID: accountHolderId ?? accountHolderID,
    );
  }

  String toJson() => json.encode(toMap());

  factory PHUser.fromJson(String source) =>
      PHUser.fromMap(json.decode(source) as Map<String, dynamic>);
}
