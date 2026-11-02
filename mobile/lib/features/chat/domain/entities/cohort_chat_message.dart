import 'package:flutter/foundation.dart';

@immutable
class CohortChatMessage {
  final String id;
  final String cohortId;
  final String cohortName;
  final String senderId;
  final String senderName;
  final String senderRole; // 'teacher', 'student', 'admin'
  final String? senderAvatarUrl;
  final Uint8List? senderAvatarBytes;
  final String text;
  final String messageType; // 'text', 'image', 'link', 'file'
  final String? imageUrl;
  final Uint8List? imageBytes;
  final String? linkUrl;
  final String? linkTitle;
  final String? fileName;
  final int? fileSizeBytes;
  final bool isPinned;
  final DateTime timestamp;
  final List<String> reactions;
  final bool isMine;

  const CohortChatMessage({
    required this.id,
    required this.cohortId,
    required this.cohortName,
    required this.senderId,
    required this.senderName,
    required this.senderRole,
    this.senderAvatarUrl,
    this.senderAvatarBytes,
    required this.text,
    this.messageType = 'text',
    this.imageUrl,
    this.imageBytes,
    this.linkUrl,
    this.linkTitle,
    this.fileName,
    this.fileSizeBytes,
    this.isPinned = false,
    required this.timestamp,
    this.reactions = const [],
    this.isMine = false,
  });

  bool get isTeacher => senderRole.toLowerCase() == 'teacher';
  bool get isStudent => senderRole.toLowerCase() == 'student';
  bool get hasImage => imageBytes != null || (imageUrl != null && imageUrl!.isNotEmpty);
  bool get hasLink => linkUrl != null && linkUrl!.isNotEmpty;
  bool get hasFile => fileName != null && fileName!.isNotEmpty;

  CohortChatMessage copyWith({
    String? id,
    String? cohortId,
    String? cohortName,
    String? senderId,
    String? senderName,
    String? senderRole,
    String? senderAvatarUrl,
    Uint8List? senderAvatarBytes,
    String? text,
    String? messageType,
    String? imageUrl,
    Uint8List? imageBytes,
    String? linkUrl,
    String? linkTitle,
    String? fileName,
    int? fileSizeBytes,
    bool? isPinned,
    DateTime? timestamp,
    List<String>? reactions,
    bool? isMine,
  }) {
    return CohortChatMessage(
      id: id ?? this.id,
      cohortId: cohortId ?? this.cohortId,
      cohortName: cohortName ?? this.cohortName,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      senderRole: senderRole ?? this.senderRole,
      senderAvatarUrl: senderAvatarUrl ?? this.senderAvatarUrl,
      senderAvatarBytes: senderAvatarBytes ?? this.senderAvatarBytes,
      text: text ?? this.text,
      messageType: messageType ?? this.messageType,
      imageUrl: imageUrl ?? this.imageUrl,
      imageBytes: imageBytes ?? this.imageBytes,
      linkUrl: linkUrl ?? this.linkUrl,
      linkTitle: linkTitle ?? this.linkTitle,
      fileName: fileName ?? this.fileName,
      fileSizeBytes: fileSizeBytes ?? this.fileSizeBytes,
      isPinned: isPinned ?? this.isPinned,
      timestamp: timestamp ?? this.timestamp,
      reactions: reactions ?? this.reactions,
      isMine: isMine ?? this.isMine,
    );
  }

  factory CohortChatMessage.fromJson(Map<String, dynamic> json, {String? currentUserId, String? currentUserName}) {
    final sName = json['sender_name']?.toString() ?? 'مشارك';
    final sId = json['sender_id']?.toString() ?? '';
    final isMe = (currentUserId != null && sId == currentUserId) ||
        (currentUserName != null && sName == currentUserName) ||
        (json['is_mine'] == true);

    return CohortChatMessage(
      id: json['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
      cohortId: json['cohort_id']?.toString() ?? '',
      cohortName: json['cohort_name']?.toString() ?? '',
      senderId: sId,
      senderName: sName,
      senderRole: json['sender_role']?.toString() ?? 'student',
      senderAvatarUrl: json['sender_avatar_url']?.toString(),
      text: json['text']?.toString() ?? json['message']?.toString() ?? '',
      messageType: json['message_type']?.toString() ?? 'text',
      imageUrl: json['image_url']?.toString(),
      linkUrl: json['link_url']?.toString(),
      linkTitle: json['link_title']?.toString(),
      fileName: json['file_name']?.toString(),
      fileSizeBytes: json['file_size_bytes'] is num ? (json['file_size_bytes'] as num).toInt() : null,
      isPinned: json['is_pinned'] == true,
      timestamp: json['timestamp'] != null
          ? DateTime.tryParse(json['timestamp'] as String) ?? DateTime.now()
          : DateTime.now(),
      reactions: (json['reactions'] as List<dynamic>? ?? []).map((e) => e.toString()).toList(),
      isMine: isMe,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cohort_id': cohortId,
      'cohort_name': cohortName,
      'sender_id': senderId,
      'sender_name': senderName,
      'sender_role': senderRole,
      'sender_avatar_url': senderAvatarUrl,
      'text': text,
      'message_type': messageType,
      'image_url': imageUrl,
      'link_url': linkUrl,
      'link_title': linkTitle,
      'file_name': fileName,
      'file_size_bytes': fileSizeBytes,
      'is_pinned': isPinned,
      'timestamp': timestamp.toIso8601String(),
      'reactions': reactions,
    };
  }
}
