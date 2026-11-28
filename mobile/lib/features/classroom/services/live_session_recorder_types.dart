import 'dart:typed_data';

class LiveRecordingResult {
  final Uint8List bytes;
  final String mimeType;
  final String filename;
  final int durationSeconds;

  const LiveRecordingResult({
    required this.bytes,
    required this.mimeType,
    required this.filename,
    required this.durationSeconds,
  });

  int get sizeBytes => bytes.length;
}
