import 'package:flutter/foundation.dart';

@immutable
class ChatReaderInfo {
  final String userId;
  final String name;
  final String role;
  final DateTime? readAt;

  const ChatReaderInfo({
    required this.userId,
    required this.name,
    this.role = 'student',
    this.readAt,
  });

  factory ChatReaderInfo.fromJson(Map<String, dynamic> json) {
    return ChatReaderInfo(
      userId: json['user_id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'عضو',
      role: json['role']?.toString() ?? 'student',
      readAt: json['read_at'] != null ? DateTime.tryParse(json['read_at'].toString()) : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'user_id': userId,
        'name': name,
        'role': role,
        if (readAt != null) 'read_at': readAt!.toIso8601String(),
      };
}

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

  // Social-style delivery & read receipts
  final String deliveryStatus; // 'sent' | 'delivered' | 'read'
  final int deliveredCount;
  final int readCount;
  final int totalRecipients;
  final List<ChatReaderInfo> readBy;
  final List<ChatReaderInfo> unreadBy;

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
    this.deliveryStatus = 'sent',
    this.deliveredCount = 0,
    this.readCount = 0,
    this.totalRecipients = 0,
    this.readBy = const [],
    this.unreadBy = const [],
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
    String? deliveryStatus,
    int? deliveredCount,
    int? readCount,
    int? totalRecipients,
    List<ChatReaderInfo>? readBy,
    List<ChatReaderInfo>? unreadBy,
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
      deliveryStatus: deliveryStatus ?? this.deliveryStatus,
      deliveredCount: deliveredCount ?? this.deliveredCount,
      readCount: readCount ?? this.readCount,
      totalRecipients: totalRecipients ?? this.totalRecipients,
      readBy: readBy ?? this.readBy,
      unreadBy: unreadBy ?? this.unreadBy,
    );
  }

  factory CohortChatMessage.fromJson(Map<String, dynamic> json, {String? currentUserId, String? currentUserName}) {
    final sName = json['sender_name']?.toString() ?? 'مشارك';
    final sId = json['sender_id']?.toString() ?? '';
    final isMe = (currentUserId != null && currentUserId.isNotEmpty && sId == currentUserId) ||
        (currentUserName != null && currentUserName.isNotEmpty && sName == currentUserName) ||
        (json['is_mine'] == true);

    final parsedReadBy = (json['read_by'] as List<dynamic>? ?? [])
        .whereType<Map>()
        .map((e) => ChatReaderInfo.fromJson(Map<String, dynamic>.from(e)))
        .toList();

    final parsedUnreadBy = (json['unread_by'] as List<dynamic>? ?? [])
        .whereType<Map>()
        .map((e) => ChatReaderInfo.fromJson(Map<String, dynamic>.from(e)))
        .toList();

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
          ? DateTime.tryParse(json['timestamp'] as String)?.toLocal() ?? DateTime.now()
          : DateTime.now(),
      reactions: (json['reactions'] as List<dynamic>? ?? []).map((e) => e.toString()).toList(),
      isMine: isMe,
      deliveryStatus: json['delivery_status']?.toString() ?? 'sent',
      deliveredCount: json['delivered_count'] is num ? (json['delivered_count'] as num).toInt() : 0,
      readCount: json['read_count'] is num ? (json['read_count'] as num).toInt() : parsedReadBy.length,
      totalRecipients: json['total_recipients'] is num ? (json['total_recipients'] as num).toInt() : 0,
      readBy: parsedReadBy,
      unreadBy: parsedUnreadBy,
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
      'delivery_status': deliveryStatus,
      'delivered_count': deliveredCount,
      'read_count': readCount,
      'total_recipients': totalRecipients,
      'read_by': readBy.map((e) => e.toJson()).toList(),
      'unread_by': unreadBy.map((e) => e.toJson()).toList(),
    };
  }
}
