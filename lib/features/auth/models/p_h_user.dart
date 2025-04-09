// ignore_for_file: public_member_api_docs, sort_constructors_first

class PHUser {
  PHUser({
    required this.id,
    required this.name,
    required this.avatarURL,
    required this.isDashboard,
    required this.accountHolderId,
  });
  final String id;
  final String name;
  final String? avatarURL;
  final bool isDashboard;
  final String accountHolderId;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'avatar_url': avatarURL,
      'is_dashboard': isDashboard,
      'account_holder_id': accountHolderId,
    };
  }

  factory PHUser.fromMap(Map<String, dynamic> map) {
    return PHUser(
        id: map['id'] as String,
        name: map['name'] as String,
        avatarURL: map['avatar_url'] as String?,
        isDashboard: map['is_dashboard'] as bool,
        accountHolderId: map['account_holder_id']);
  }
}
