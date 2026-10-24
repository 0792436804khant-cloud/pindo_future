class GuardianNoteEntity {
  final int id;
  final String title;
  final String content;
  final String type;
  final bool isAcknowledged;
  final String createdAt;
  final String authorName;
  final String authorRole;

  const GuardianNoteEntity({
    required this.id,
    required this.title,
    required this.content,
    required this.type,
    required this.isAcknowledged,
    required this.createdAt,
    required this.authorName,
    required this.authorRole,
  });

  factory GuardianNoteEntity.fromJson(Map<String, dynamic> json) {
    final author = json['author'] as Map<String, dynamic>? ?? {};

    return GuardianNoteEntity(
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ?? 'Notice',
      content: json['content'] as String? ?? '',
      type: json['type'] as String? ?? 'general',
      isAcknowledged: json['is_acknowledged'] as bool? ?? false,
      createdAt: json['created_at'] as String? ?? '',
      authorName: author['name'] as String? ?? 'System',
      authorRole: author['role'] as String? ?? 'staff',
    );
  }
}
