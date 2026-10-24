import '../../domain/entities/room_connection_details.dart';

class RoomConnectionDetailsModel extends RoomConnectionDetails {
  const RoomConnectionDetailsModel({
    required super.serverUrl,
    required super.token,
    required super.sessionId,
    required super.role,
    required super.identity,
    required super.canPublish,
    required super.canSubscribe,
    required super.expiresIn,
    super.watermarkText,
  });

  factory RoomConnectionDetailsModel.fromJson(Map<String, dynamic> json) {
    final session = json['session'] as Map<String, dynamic>? ?? {};
    final participant = json['participant'] as Map<String, dynamic>? ?? {};

    return RoomConnectionDetailsModel(
      serverUrl: json['server_url'] as String? ?? 'wss://livekit.pindofuture.com',
      token: json['token'] as String? ?? '',
      sessionId: session['session_id'] as String? ?? '',
      role: participant['role'] as String? ?? 'attendee',
      identity: participant['identity'] as String? ?? '',
      canPublish: participant['can_publish'] as bool? ?? false,
      canSubscribe: participant['can_subscribe'] as bool? ?? true,
      expiresIn: participant['expires_in'] as int? ?? 21600,
      watermarkText: participant['watermark_text'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'server_url': serverUrl,
      'token': token,
      'session': {
        'session_id': sessionId,
      },
      'participant': {
        'role': role,
        'identity': identity,
        'can_publish': canPublish,
        'can_subscribe': canSubscribe,
        'expires_in': expiresIn,
      },
    };
  }
}
