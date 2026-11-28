import 'live_session_recorder_types.dart';

class LiveSessionRecorder {
  bool get isSupported => false;
  bool get isRecording => false;
  int get elapsedSeconds => 0;

  Future<void> start({bool preferScreenCapture = true, bool includeMicAudio = true}) async {
    throw UnsupportedError('التسجيل المباشر من المتصفح متاح عبر نسخة الويب (Web PWA). يمكنك رفع ملف فيديو جاهز من جهازك.');
  }

  Future<LiveRecordingResult?> stop({String sessionId = 'session'}) async => null;

  void triggerLocalDownload(LiveRecordingResult result) {}

  void dispose() {}
}
