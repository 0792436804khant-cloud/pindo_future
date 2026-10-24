class RoomConnectionDetails {
  final String serverUrl;
  final String token;
  final String sessionId;
  final String role;
  final String identity;
  final bool canPublish;
  final bool canSubscribe;
  final int expiresIn;
  final String? watermarkText;

  const RoomConnectionDetails({
    required this.serverUrl,
    required this.token,
    required this.sessionId,
    required this.role,
    required this.identity,
    required this.canPublish,
    required this.canSubscribe,
    required this.expiresIn,
    this.watermarkText,
  });

  bool get isPublisher => canPublish;
  bool get isSubscriberOnly => !canPublish;
  bool get isTeacher => role == 'teacher';
}
