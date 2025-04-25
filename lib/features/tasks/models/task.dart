class Task {
  Task({
    required this.id,
    required this.userId,
    required this.accountHolderId,
    required this.title,
    required this.content,
    required this.recurring,
    required this.createdAt,
    required this.authorId,
    this.lastDone,
    this.deleted,
  });
  final String id;
  final String userId;
  final String accountHolderId;
  final String title;
  final String? content;
  final bool recurring;
  final String createdAt;
  final String? lastDone;
  final String? authorId;
  final bool? deleted;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'account_holder_id': accountHolderId,
      'title': title,
      'content': content,
      'recurring': recurring,
      'created_at': createdAt,
      'last_done': lastDone,
      'author_id': authorId,
      'deleted': deleted,
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      accountHolderId: map['account_holder_id'] as String,
      title: map['title'] as String,
      content: map['content'] as String,
      recurring: map['recurring'] == null ? false : map['recurring'] as bool,
      createdAt: map['created'] as String,
      lastDone: map['last_done'] as String?,
      authorId: map["author_id"] as String?,
      deleted: map["deleted"] == null ? false : map["deleted"] as bool?,
    );
  }

  Task copyWith({
    String? id,
    String? userId,
    String? accountHolderId,
    String? title,
    String? content,
    bool? recurring,
    String? createdAt,
    String? lastDone,
    String? authorId,
    bool? deleted,
  }) {
    return Task(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      accountHolderId: accountHolderId ?? this.accountHolderId,
      title: title ?? this.title,
      content: content ?? this.content,
      recurring: recurring ?? this.recurring,
      createdAt: createdAt ?? this.createdAt,
      lastDone: lastDone ?? this.lastDone,
      authorId: authorId ?? this.authorId,
      deleted: deleted ?? this.deleted,
    );
  }
}
