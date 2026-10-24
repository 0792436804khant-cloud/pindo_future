class ChildAttendanceRecordEntity {
  final int id;
  final String sessionId;
  final String sessionTitle;
  final String? joinedAt;
  final String? leftAt;
  final int durationSeconds;
  final double durationMinutes;
  final String sessionStatus;

  const ChildAttendanceRecordEntity({
    required this.id,
    required this.sessionId,
    required this.sessionTitle,
    this.joinedAt,
    this.leftAt,
    required this.durationSeconds,
    required this.durationMinutes,
    required this.sessionStatus,
  });

  factory ChildAttendanceRecordEntity.fromJson(Map<String, dynamic> json) {
    return ChildAttendanceRecordEntity(
      id: json['id'] as int? ?? 0,
      sessionId: json['session_id'] as String? ?? '',
      sessionTitle: json['session_title'] as String? ?? 'Classroom Session',
      joinedAt: json['joined_at'] as String?,
      leftAt: json['left_at'] as String?,
      durationSeconds: json['duration_seconds'] as int? ?? 0,
      durationMinutes: (json['duration_minutes'] as num?)?.toDouble() ?? 0.0,
      sessionStatus: json['session_status'] as String? ?? 'ended',
    );
  }
}
