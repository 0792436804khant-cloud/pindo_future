class ClassroomChatMessage {
  final String id;
  final String sessionId;
  final String senderName;
  final String senderRole;
  final String message;
  final bool isPinned;
  final DateTime timestamp;
  final bool isMine;

  const ClassroomChatMessage({
    required this.id,
    required this.sessionId,
    required this.senderName,
    required this.senderRole,
    required this.message,
    this.isPinned = false,
    required this.timestamp,
    this.isMine = false,
  });

  bool get isTeacher => senderRole.toLowerCase() == 'teacher';
  bool get isStudent => senderRole.toLowerCase() == 'student';

  factory ClassroomChatMessage.fromJson(Map<String, dynamic> json, {String? currentUserId, String? currentUserName}) {
    final sender = json['sender_name'] as String? ?? 'Participant';
    final isMe = (currentUserName != null && sender == currentUserName) ||
        (json['is_mine'] as bool? ?? false);

    return ClassroomChatMessage(
      id: json['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
      sessionId: json['session_id'] as String? ?? '',
      senderName: sender,
      senderRole: json['sender_role'] as String? ?? 'student',
      message: json['message'] as String? ?? '',
      isPinned: json['is_pinned'] as bool? ?? false,
      timestamp: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String) ?? DateTime.now()
          : (json['timestamp'] != null
              ? DateTime.tryParse(json['timestamp'] as String) ?? DateTime.now()
              : DateTime.now()),
      isMine: isMe,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': 'chat_message',
      'id': id,
      'session_id': sessionId,
      'sender_name': senderName,
      'sender_role': senderRole,
      'message': message,
      'is_pinned': isPinned,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
