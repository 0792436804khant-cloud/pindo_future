import 'dart:async';
import 'dart:js_interop';
import 'dart:typed_data';
import 'package:web/web.dart' as web;
import 'live_session_recorder_types.dart';

class LiveSessionRecorder {
  web.MediaRecorder? _recorder;
  final List<web.MediaStream> _ownedStreams = [];
  final List<web.Blob> _chunks = [];
  DateTime? _startedAt;
  Completer<LiveRecordingResult?>? _stopCompleter;
  String _activeMimeType = 'video/webm';
  String _pendingSessionId = 'session';

  bool get isSupported => true;
  bool get isRecording => _recorder != null && _recorder!.state == 'recording';

  int get elapsedSeconds =>
      _startedAt == null ? 0 : DateTime.now().difference(_startedAt!).inSeconds;

  String _pickBestMimeType() {
    const candidates = [
      'video/webm;codecs=vp9,opus',
      'video/webm;codecs=vp8,opus',
      'video/webm',
      'video/mp4',
    ];
    for (final candidate in candidates) {
      try {
        if (web.MediaRecorder.isTypeSupported(candidate)) {
          return candidate;
        }
      } catch (_) {}
    }
    return 'video/webm';
  }

  Future<void> start({bool preferScreenCapture = true, bool includeMicAudio = true}) async {
    if (isRecording) return;
    _cleanupStreams();
    _chunks.clear();

    final mediaDevices = web.window.navigator.mediaDevices;
    final web.MediaStream combinedStream = web.MediaStream();

    if (preferScreenCapture) {
      final videoConstraints = <String, Object>{
        'width': {'ideal': 1920},
        'height': {'ideal': 1080},
        'frameRate': {'ideal': 60, 'max': 60},
      }.jsify();

      final displayOptions = web.DisplayMediaStreamOptions(
        video: videoConstraints ?? true.toJS,
        audio: true.toJS,
      );
      final screenStream = await mediaDevices.getDisplayMedia(displayOptions).toDart;
      _ownedStreams.add(screenStream);
      for (final track in screenStream.getTracks().toDart) {
        combinedStream.addTrack(track);
      }
    } else {
      final camConstraints = <String, Object>{
        'width': {'ideal': 1920},
        'height': {'ideal': 1080},
        'frameRate': {'ideal': 60},
      }.jsify();
      final camStream = await mediaDevices
          .getUserMedia(web.MediaStreamConstraints(video: camConstraints ?? true.toJS))
          .toDart;
      _ownedStreams.add(camStream);
      for (final track in camStream.getVideoTracks().toDart) {
        combinedStream.addTrack(track);
      }
    }

    if (includeMicAudio) {
      try {
        final micStream = await mediaDevices
            .getUserMedia(web.MediaStreamConstraints(audio: true.toJS))
            .toDart;
        _ownedStreams.add(micStream);
        for (final track in micStream.getAudioTracks().toDart) {
          combinedStream.addTrack(track);
        }
      } catch (_) {
        // Proceed even if mic capture was unavailable or muted
      }
    }

    _activeMimeType = _pickBestMimeType();
    final recorder = web.MediaRecorder(
      combinedStream,
      web.MediaRecorderOptions(
        mimeType: _activeMimeType,
        videoBitsPerSecond: 6000000,
        audioBitsPerSecond: 192000,
      ),
    );

    recorder.addEventListener(
      'dataavailable',
      ((web.BlobEvent event) {
        if (event.data.size > 0) {
          _chunks.add(event.data);
        }
      }).toJS,
    );

    recorder.addEventListener(
      'stop',
      ((web.Event _) {
        _finalizeStop();
      }).toJS,
    );

    _recorder = recorder;
    _startedAt = DateTime.now();
    recorder.start(1000); // Emit 1-second media chunks reliably
  }

  Future<void> _finalizeStop() async {
    try {
      if (_chunks.isEmpty) {
        _stopCompleter?.complete(null);
      } else {
        final baseMime = _activeMimeType.split(';').first;
        final blob = web.Blob(
          _chunks.toJS,
          web.BlobPropertyBag(type: baseMime),
        );
        final buffer = await blob.arrayBuffer().toDart;
        final Uint8List bytes = buffer.toDart.asUint8List();
        final ext = baseMime.contains('mp4') ? 'mp4' : 'webm';
        final stamp = DateTime.now().millisecondsSinceEpoch;
        _stopCompleter?.complete(
          LiveRecordingResult(
            bytes: bytes,
            mimeType: baseMime,
            filename: '${_pendingSessionId}_$stamp.$ext',
            durationSeconds: elapsedSeconds,
          ),
        );
      }
    } catch (e) {
      _stopCompleter?.completeError(e);
    } finally {
      _cleanupStreams();
      _recorder = null;
      _startedAt = null;
    }
  }

  Future<LiveRecordingResult?> stop({String sessionId = 'session'}) async {
    final recorder = _recorder;
    if (recorder == null || recorder.state == 'inactive') {
      _cleanupStreams();
      return null;
    }

    _pendingSessionId = sessionId;
    _stopCompleter = Completer<LiveRecordingResult?>();
    recorder.stop();
    return _stopCompleter!.future;
  }

  void triggerLocalDownload(LiveRecordingResult result) {
    final blob = web.Blob(
      [result.bytes.toJS].toJS,
      web.BlobPropertyBag(type: result.mimeType),
    );
    final url = web.URL.createObjectURL(blob);
    final anchor = web.document.createElement('a') as web.HTMLAnchorElement;
    anchor.href = url;
    anchor.download = result.filename;
    anchor.style.display = 'none';
    web.document.body?.append(anchor);
    anchor.click();
    anchor.remove();
    web.URL.revokeObjectURL(url);
  }

  void _cleanupStreams() {
    for (final stream in _ownedStreams) {
      for (final track in stream.getTracks().toDart) {
        track.stop();
      }
    }
    _ownedStreams.clear();
  }

  void dispose() {
    if (_recorder != null && _recorder!.state == 'recording') {
      try {
        _recorder!.stop();
      } catch (_) {}
    }
    _cleanupStreams();
  }
}
