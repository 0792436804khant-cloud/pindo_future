class SessionRecordingEntity {
  final int id;
  final String recordingCode;
  final String title;
  final String? description;
  final int durationSeconds;
  final int viewsCount;
  final String createdAt;
  final bool isAccessible;

  const SessionRecordingEntity({
    required this.id,
    required this.recordingCode,
    required this.title,
    this.description,
    required this.durationSeconds,
    required this.viewsCount,
    required this.createdAt,
    required this.isAccessible,
  });

  String get formattedDuration {
    final minutes = durationSeconds ~/ 60;
    final seconds = durationSeconds % 60;
    if (minutes >= 60) {
      final hours = minutes ~/ 60;
      final remMinutes = minutes % 60;
      return '${hours}h ${remMinutes}m';
    }
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}
