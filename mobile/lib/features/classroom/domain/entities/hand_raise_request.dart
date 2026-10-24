class HandRaiseRequest {
  final String participantIdentity;
  final String participantName;
  final DateTime timestamp;

  const HandRaiseRequest({
    required this.participantIdentity,
    required this.participantName,
    required this.timestamp,
  });

  factory HandRaiseRequest.fromJson(Map<String, dynamic> json) {
    return HandRaiseRequest(
      participantIdentity: json['participant_identity'] as String? ?? '',
      participantName: json['participant_name'] as String? ?? 'Student',
      timestamp: json['timestamp'] != null
          ? DateTime.tryParse(json['timestamp'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': 'hand_raise',
      'participant_identity': participantIdentity,
      'participant_name': participantName,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
