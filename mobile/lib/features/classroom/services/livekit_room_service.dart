import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:livekit_client/livekit_client.dart';
import 'package:permission_handler/permission_handler.dart';
import '../domain/entities/classroom_chat_message.dart';
import '../domain/entities/classroom_stage_mode.dart';
import '../domain/entities/hand_raise_request.dart';
import '../domain/entities/room_connection_details.dart';
import '../domain/entities/whiteboard_stroke_entity.dart';

enum ClassroomConnectionStatus {
  disconnected,
  connecting,
  connected,
  reconnecting,
  error,
}

enum LiveStreamQualityPreset {
  ultraMax,
  highHd,
  dataSaver;

  String get arabicLabel => switch (this) {
        LiveStreamQualityPreset.ultraMax => 'أقصى جودة (1080p • 60 FPS)',
        LiveStreamQualityPreset.highHd => 'جودة عالية (720p • 60 FPS)',
        LiveStreamQualityPreset.dataSaver => 'توفير البيانات (540p • 30 FPS)',
      };

  String get shortBadge => switch (this) {
        LiveStreamQualityPreset.ultraMax => 'MAX 1080p • 60fps',
        LiveStreamQualityPreset.highHd => 'HD 720p • 60fps',
        LiveStreamQualityPreset.dataSaver => 'ECO 540p • 30fps',
      };

  VideoParameters get cameraParameters => switch (this) {
        LiveStreamQualityPreset.ultraMax => const VideoParameters(
            dimensions: VideoDimensionsPresets.h1080_169,
            encoding: VideoEncoding(maxBitrate: 4500 * 1000, maxFramerate: 60),
          ),
        LiveStreamQualityPreset.highHd => const VideoParameters(
            dimensions: VideoDimensionsPresets.h720_169,
            encoding: VideoEncoding(maxBitrate: 2500 * 1000, maxFramerate: 60),
          ),
        LiveStreamQualityPreset.dataSaver => VideoParametersPresets.h540_169,
      };

  VideoParameters get screenShareParameters => switch (this) {
        LiveStreamQualityPreset.ultraMax => const VideoParameters(
            dimensions: VideoDimensionsPresets.h1080_169,
            encoding: VideoEncoding(maxBitrate: 6500 * 1000, maxFramerate: 60),
          ),
        LiveStreamQualityPreset.highHd => const VideoParameters(
            dimensions: VideoDimensionsPresets.h1080_169,
            encoding: VideoEncoding(maxBitrate: 3800 * 1000, maxFramerate: 30),
          ),
        LiveStreamQualityPreset.dataSaver => VideoParametersPresets.screenShareH720FPS15,
      };
}

class LiveKitRoomService extends ChangeNotifier {
  Room? _room;
  EventsListener<RoomEvent>? _listener;

  ClassroomConnectionStatus _status = ClassroomConnectionStatus.disconnected;
  RoomConnectionDetails? _connectionDetails;
  String? _errorMessage;

  bool _isCameraEnabled = false;
  bool _isMicrophoneEnabled = false;
  bool _isScreenShareEnabled = false;
  bool _isScreenAnnotationEnabled = false;
  LiveStreamQualityPreset _qualityPreset = LiveStreamQualityPreset.ultraMax;

  ClassroomStageMode _currentStageMode = ClassroomStageMode.camera;
  final List<WhiteboardStrokeEntity> _whiteboardStrokes = [];

  ClassroomConnectionStatus get status => _status;
  Room? get room => _room;
  RoomConnectionDetails? get connectionDetails => _connectionDetails;
  String? get errorMessage => _errorMessage;

  bool get isConnected => _status == ClassroomConnectionStatus.connected && _room != null;
  bool get isCameraEnabled => _isCameraEnabled;
  bool get isMicrophoneEnabled => _isMicrophoneEnabled;
  bool get isScreenShareEnabled => _isScreenShareEnabled;
  bool get isScreenAnnotationEnabled => _isScreenAnnotationEnabled;
  LiveStreamQualityPreset get qualityPreset => _qualityPreset;
  bool get canPublish => _connectionDetails?.canPublish ?? false;

  ClassroomStageMode get currentStageMode => _currentStageMode;
  List<WhiteboardStrokeEntity> get whiteboardStrokes => List.unmodifiable(_whiteboardStrokes);

  LocalParticipant? get localParticipant => _room?.localParticipant;
  List<RemoteParticipant> get remoteParticipants =>
      _room?.remoteParticipants.values.toList() ?? [];

  final List<ClassroomChatMessage> _messages = [];
  final List<HandRaiseRequest> _raisedHands = [];
  bool _isHandRaised = false;

  List<ClassroomChatMessage> get messages => List.unmodifiable(_messages);
  List<HandRaiseRequest> get raisedHands => List.unmodifiable(_raisedHands);
  bool get isHandRaised => _isHandRaised;
  int get raisedHandsCount => _raisedHands.length;

  /// Returns active screen share publication if anyone is presenting their screen
  TrackPublication? get activeScreenSharePublication {
    final local = _room?.localParticipant?.videoTrackPublications
        .where((p) => p.source == TrackSource.screenShareVideo)
        .firstOrNull;
    if (local != null) return local;

    for (final remote in remoteParticipants) {
      final pub = remote.videoTrackPublications
          .where((p) => p.source == TrackSource.screenShareVideo)
          .firstOrNull;
      if (pub != null) return pub;
    }
    return null;
  }

  VideoTrack? cameraTrackFor(Participant? participant) {
    if (participant == null) return null;
    final camPub = participant.videoTrackPublications
        .where((p) => p.source == TrackSource.camera)
        .firstOrNull;
    return camPub?.track as VideoTrack?;
  }

  VideoTrack? screenShareTrackFor(Participant? participant) {
    if (participant == null) return null;
    final sharePub = participant.videoTrackPublications
        .where((p) => p.source == TrackSource.screenShareVideo)
        .firstOrNull;
    return sharePub?.track as VideoTrack?;
  }

  CameraCaptureOptions _buildCameraOptions([LiveStreamQualityPreset? preset]) {
    final p = preset ?? _qualityPreset;
    return CameraCaptureOptions(
      params: p.cameraParameters,
      maxFrameRate: (p.cameraParameters.encoding?.maxFramerate ?? 60).toDouble(),
    );
  }

  ScreenShareCaptureOptions _buildScreenShareOptions([LiveStreamQualityPreset? preset]) {
    final p = preset ?? _qualityPreset;
    return ScreenShareCaptureOptions(
      useiOSBroadcastExtension: true,
      captureScreenAudio: true,
      preferCurrentTab: false,
      selfBrowserSurface: 'exclude',
      maxFrameRate: (p.screenShareParameters.encoding?.maxFramerate ?? 60).toDouble(),
      params: p.screenShareParameters,
    );
  }

  /// Connect to the LiveKit SFU cluster using signed RoomConnectionDetails
  Future<bool> connect(RoomConnectionDetails details) async {
    _status = ClassroomConnectionStatus.connecting;
    _errorMessage = null;
    _connectionDetails = details;
    notifyListeners();

    try {
      // 1. Request Hardware Permissions if user has Publisher permissions
      if (details.canPublish && !kIsWeb) {
        await _requestMediaPermissions();
      }

      // 2. Configure Room optimized for Max FPS / Max Quality + Simulcast scaling
      final roomOptions = RoomOptions(
        adaptiveStream: true, // Match subscriber viewport resolution seamlessly
        dynacast: true,       // Pause unused encoding layers automatically
        defaultAudioCaptureOptions: const AudioCaptureOptions(
          echoCancellation: true,
          noiseSuppression: true,
          autoGainControl: true,
        ),
        defaultAudioPublishOptions: const AudioPublishOptions(
          dtx: true,
          red: true,
        ),
        defaultCameraCaptureOptions: _buildCameraOptions(),
        defaultScreenShareCaptureOptions: _buildScreenShareOptions(),
        defaultVideoPublishOptions: VideoPublishOptions(
          simulcast: true,
          videoCodec: 'VP9',
          backupVideoCodec: const BackupVideoCodec(
            enabled: true,
            codec: 'H264',
            simulcast: true,
          ),
          videoEncoding: _qualityPreset.cameraParameters.encoding,
          screenShareEncoding: _qualityPreset.screenShareParameters.encoding,
          videoSimulcastLayers: [
            VideoParametersPresets.h360_169,
            VideoParametersPresets.h720_169,
          ],
          screenShareSimulcastLayers: [
            VideoParametersPresets.h720_169,
          ],
        ),
      );

      _room = Room(roomOptions: roomOptions);
      _listener = _room!.createListener();
      _setupRoomEventListeners(_listener!);

      // 3. Connect to the External SFU WebRTC Gateway
      await _room!.connect(
        details.serverUrl,
        details.token,
        fastConnectOptions: FastConnectOptions(),
      );

      // 4. If publisher (teacher), initialize camera (with safe fallback) and microphone
      if (details.canPublish) {
        try {
          await _room!.localParticipant?.setCameraEnabled(
            true,
            cameraCaptureOptions: _buildCameraOptions(),
          );
          _isCameraEnabled = true;
        } catch (e) {
          debugPrint('Max-FPS camera init failed, retrying safe 720p fallback: $e');
          try {
            await _room!.localParticipant?.setCameraEnabled(
              true,
              cameraCaptureOptions: const CameraCaptureOptions(
                params: VideoParametersPresets.h720_169,
              ),
            );
            _isCameraEnabled = true;
          } catch (fallbackErr) {
            debugPrint('Warning: Camera could not be initialized automatically: $fallbackErr');
          }
        }

        try {
          await _room!.localParticipant?.setMicrophoneEnabled(true);
          _isMicrophoneEnabled = true;
        } catch (e) {
          debugPrint('Warning: Microphone could not be initialized automatically: $e');
        }
      }

      _status = ClassroomConnectionStatus.connected;
      notifyListeners();
      return true;
    } catch (e) {
      _status = ClassroomConnectionStatus.error;
      _errorMessage = 'Failed to connect to LiveKit classroom: $e';
      notifyListeners();
      await disconnect();
      return false;
    }
  }

  /// Request runtime camera & microphone permissions
  Future<void> _requestMediaPermissions() async {
    try {
      await [
        Permission.camera,
        Permission.microphone,
      ].request();
    } catch (e) {
      debugPrint('Permission request error: $e');
    }
  }

  /// Wire internal LiveKit Room events
  void _setupRoomEventListeners(EventsListener<RoomEvent> listener) {
    listener
      ..on<RoomDisconnectedEvent>((event) {
        _status = ClassroomConnectionStatus.disconnected;
        notifyListeners();
      })
      ..on<ParticipantConnectedEvent>((event) {
        // When new student joins, teacher auto-syncs whiteboard state and stage mode
        if (canPublish) {
          _broadcastCurrentStateToAttendee();
        }
        notifyListeners();
      })
      ..on<ParticipantDisconnectedEvent>((event) {
        notifyListeners();
      })
      ..on<LocalTrackPublishedEvent>((event) {
        if (event.publication.source == TrackSource.screenShareVideo) {
          _isScreenShareEnabled = true;
          _currentStageMode = ClassroomStageMode.screenShare;
        } else if (event.publication.source == TrackSource.camera) {
          _isCameraEnabled = true;
        } else if (event.publication.source == TrackSource.microphone) {
          _isMicrophoneEnabled = true;
        }
        notifyListeners();
      })
      ..on<LocalTrackUnpublishedEvent>((event) {
        if (event.publication.source == TrackSource.screenShareVideo) {
          _isScreenShareEnabled = false;
          if (_currentStageMode == ClassroomStageMode.screenShare) {
            _currentStageMode = ClassroomStageMode.camera;
          }
        } else if (event.publication.source == TrackSource.camera) {
          _isCameraEnabled = false;
        } else if (event.publication.source == TrackSource.microphone) {
          _isMicrophoneEnabled = false;
        }
        notifyListeners();
      })
      ..on<TrackSubscribedEvent>((event) {
        if (event.publication.source == TrackSource.screenShareVideo) {
          _currentStageMode = ClassroomStageMode.screenShare;
        }
        notifyListeners();
      })
      ..on<TrackUnsubscribedEvent>((event) {
        if (event.publication.source == TrackSource.screenShareVideo) {
          if (_currentStageMode == ClassroomStageMode.screenShare) {
            _currentStageMode = ClassroomStageMode.camera;
          }
        }
        notifyListeners();
      })
      ..on<ActiveSpeakersChangedEvent>((event) {
        notifyListeners();
      })
      ..on<DataReceivedEvent>((event) {
        try {
          final jsonString = utf8.decode(event.data);
          final data = jsonDecode(jsonString) as Map<String, dynamic>;
          final type = data['type'] as String?;

          if (type == 'chat_message') {
            final chatMsg = ClassroomChatMessage.fromJson(data);
            _messages.add(chatMsg);
            notifyListeners();
          } else if (type == 'hand_raise' || type == 'raise_hand') {
            final identity = data['participant_identity'] as String? ?? '';
            if (!_raisedHands.any((h) => h.participantIdentity == identity)) {
              _raisedHands.add(HandRaiseRequest.fromJson(data));
              notifyListeners();
            }
          } else if (type == 'lower_hand') {
            final identity = data['participant_identity'] as String? ?? '';
            _raisedHands.removeWhere((h) => h.participantIdentity == identity);
            if (identity == _room?.localParticipant?.identity) {
              _isHandRaised = false;
            }
            notifyListeners();
          } else if (type == 'stage_mode') {
            // Synchronize active classroom spotlight view mode
            final modeStr = data['mode'] as String?;
            _currentStageMode = ClassroomStageModeExtension.fromString(modeStr);
            notifyListeners();
          } else if (type == 'screen_annotation') {
            _isScreenAnnotationEnabled = data['enabled'] == true;
            notifyListeners();
          } else if (type == 'whiteboard_stroke') {
            // Receive real-time vector stroke from instructor
            final strokeMap = data['stroke'] as Map<String, dynamic>?;
            if (strokeMap != null) {
              final stroke = WhiteboardStrokeEntity.fromJson(strokeMap);
              if (!_whiteboardStrokes.any((s) => s.id == stroke.id)) {
                _whiteboardStrokes.add(stroke);
                notifyListeners();
              }
            }
          } else if (type == 'whiteboard_undo') {
            if (_whiteboardStrokes.isNotEmpty) {
              _whiteboardStrokes.removeLast();
              notifyListeners();
            }
          } else if (type == 'whiteboard_clear') {
            _whiteboardStrokes.clear();
            notifyListeners();
          } else if (type == 'whiteboard_sync') {
            final rawStrokes = data['strokes'] as List<dynamic>? ?? [];
            _whiteboardStrokes.clear();
            for (final s in rawStrokes) {
              if (s is Map<String, dynamic>) {
                _whiteboardStrokes.add(WhiteboardStrokeEntity.fromJson(s));
              }
            }
            notifyListeners();
          }
        } catch (e) {
          debugPrint('Error parsing WebRTC data payload: $e');
        }
      });
  }

  /// Toggle local camera track with active Max-FPS quality options
  Future<void> toggleCamera() async {
    if (_room == null || !canPublish) return;

    final nextState = !_isCameraEnabled;
    try {
      await _room!.localParticipant?.setCameraEnabled(
        nextState,
        cameraCaptureOptions: _buildCameraOptions(),
      );
      _isCameraEnabled = nextState;
      notifyListeners();
    } catch (e) {
      debugPrint('Error toggling camera: $e');
    }
  }

  /// Switch streaming quality preset live (Max FPS / HD / Data Saver)
  Future<void> setQualityPreset(LiveStreamQualityPreset preset) async {
    _qualityPreset = preset;
    notifyListeners();

    if (_room == null || !canPublish) return;
    try {
      if (_isCameraEnabled) {
        await _room!.localParticipant?.setCameraEnabled(false);
        await _room!.localParticipant?.setCameraEnabled(
          true,
          cameraCaptureOptions: _buildCameraOptions(preset),
        );
      }
    } catch (e) {
      debugPrint('Quality preset camera update warning: $e');
    }
  }

  /// Toggle local microphone track
  Future<void> toggleMicrophone() async {
    if (_room == null || !canPublish) return;

    final nextState = !_isMicrophoneEnabled;
    try {
      await _room!.localParticipant?.setMicrophoneEnabled(nextState);
      _isMicrophoneEnabled = nextState;
      notifyListeners();
    } catch (e) {
      debugPrint('Error toggling microphone: $e');
    }
  }

  /// Toggle Screen Sharing display media track with error reporting and self-surface exclusion
  Future<String?> toggleScreenShare() async {
    if (_room == null || !canPublish) {
      return 'غير مصرح لك بمشاركة الشاشة في هذه الغرفة.';
    }

    final targetEnabled = !_isScreenShareEnabled;
    try {
      final pub = await _room!.localParticipant?.setScreenShareEnabled(
        targetEnabled,
        captureScreenAudio: true,
        screenShareCaptureOptions: _buildScreenShareOptions(),
      );

      if (targetEnabled) {
        final hasShare = pub != null || activeScreenSharePublication != null;
        if (!hasShare) {
          _isScreenShareEnabled = false;
          notifyListeners();
          return 'لم يتم اختيار نافذة أو شاشة للمشاركة.';
        }
        _isScreenShareEnabled = true;
        await setStageMode(ClassroomStageMode.screenShare);
      } else {
        _isScreenShareEnabled = false;
        await setStageMode(ClassroomStageMode.camera);
      }
      notifyListeners();
      return null;
    } catch (e) {
      _isScreenShareEnabled = activeScreenSharePublication != null;
      notifyListeners();
      debugPrint('Error toggling screen share: $e');
      return 'تم إلغاء مشاركة الشاشة أو رفض الإذن من المتصفح/الجهاز.';
    }
  }

  /// Toggle transparent live annotation overlay on top of Camera / Screen Share
  Future<void> toggleScreenAnnotation({bool? enabled}) async {
    final nextState = enabled ?? !_isScreenAnnotationEnabled;
    _isScreenAnnotationEnabled = nextState;
    notifyListeners();

    if (canPublish && _room?.localParticipant != null) {
      try {
        final payload = {
          'type': 'screen_annotation',
          'enabled': nextState,
          'timestamp': DateTime.now().toIso8601String(),
        };
        await _room!.localParticipant!.publishData(
          utf8.encode(jsonEncode(payload)),
          reliable: true,
          topic: 'whiteboard',
        );
      } catch (e) {
        debugPrint('Error broadcasting screen annotation state: $e');
      }
    }
  }

  /// Change and broadcast active classroom stage mode (Camera | Whiteboard | ScreenShare)
  Future<void> setStageMode(ClassroomStageMode mode, {bool broadcast = true}) async {
    _currentStageMode = mode;
    notifyListeners();

    if (broadcast && canPublish && _room?.localParticipant != null) {
      try {
        final payload = {
          'type': 'stage_mode',
          'mode': mode.name,
          'timestamp': DateTime.now().toIso8601String(),
        };
        final bytes = utf8.encode(jsonEncode(payload));
        await _room!.localParticipant!.publishData(
          bytes,
          reliable: true,
          topic: 'stage_mode',
        );
      } catch (e) {
        debugPrint('Error broadcasting stage mode change: $e');
      }
    }
  }

  /// Add a stroke to whiteboard and broadcast to all attendees
  Future<void> addWhiteboardStroke(WhiteboardStrokeEntity stroke, {bool broadcast = true}) async {
    _whiteboardStrokes.add(stroke);
    notifyListeners();

    if (broadcast && _room?.localParticipant != null) {
      try {
        final payload = {
          'type': 'whiteboard_stroke',
          'stroke': stroke.toJson(),
        };
        final bytes = utf8.encode(jsonEncode(payload));
        await _room!.localParticipant!.publishData(
          bytes,
          reliable: true,
          topic: 'whiteboard',
        );
      } catch (e) {
        debugPrint('Error broadcasting whiteboard stroke: $e');
      }
    }
  }

  /// Undo the last whiteboard stroke and broadcast signal
  Future<void> undoWhiteboardStroke({bool broadcast = true}) async {
    if (_whiteboardStrokes.isNotEmpty) {
      _whiteboardStrokes.removeLast();
      notifyListeners();
    }

    if (broadcast && _room?.localParticipant != null) {
      try {
        final payload = {'type': 'whiteboard_undo'};
        final bytes = utf8.encode(jsonEncode(payload));
        await _room!.localParticipant!.publishData(
          bytes,
          reliable: true,
          topic: 'whiteboard',
        );
      } catch (e) {
        debugPrint('Error broadcasting whiteboard undo: $e');
      }
    }
  }

  /// Clear the entire whiteboard canvas and broadcast signal
  Future<void> clearWhiteboard({bool broadcast = true}) async {
    _whiteboardStrokes.clear();
    notifyListeners();

    if (broadcast && _room?.localParticipant != null) {
      try {
        final payload = {'type': 'whiteboard_clear'};
        final bytes = utf8.encode(jsonEncode(payload));
        await _room!.localParticipant!.publishData(
          bytes,
          reliable: true,
          topic: 'whiteboard',
        );
      } catch (e) {
        debugPrint('Error broadcasting whiteboard clear: $e');
      }
    }
  }

  /// Replace whiteboard strokes with a snapshot and broadcast sync
  Future<void> setWhiteboardStrokes(List<WhiteboardStrokeEntity> strokes, {bool broadcast = true}) async {
    _whiteboardStrokes.clear();
    _whiteboardStrokes.addAll(strokes);
    notifyListeners();

    if (broadcast && _room?.localParticipant != null) {
      try {
        final syncPayload = {
          'type': 'whiteboard_sync',
          'strokes': _whiteboardStrokes.map((s) => s.toJson()).toList(),
        };
        await _room!.localParticipant!.publishData(
          utf8.encode(jsonEncode(syncPayload)),
          reliable: true,
          topic: 'whiteboard',
        );
      } catch (e) {
        debugPrint('Error broadcasting whiteboard snapshot restore: $e');
      }
    }
  }

  /// Broadcast full vector history to newly joined attendees
  Future<void> _broadcastCurrentStateToAttendee() async {
    if (_room?.localParticipant == null) return;

    try {
      // 1. Sync stage mode
      final modePayload = {
        'type': 'stage_mode',
        'mode': _currentStageMode.name,
      };
      await _room!.localParticipant!.publishData(
        utf8.encode(jsonEncode(modePayload)),
        reliable: true,
        topic: 'stage_mode',
      );

      // 2. Sync whiteboard strokes if non-empty
      if (_whiteboardStrokes.isNotEmpty) {
        final syncPayload = {
          'type': 'whiteboard_sync',
          'strokes': _whiteboardStrokes.map((s) => s.toJson()).toList(),
        };
        await _room!.localParticipant!.publishData(
          utf8.encode(jsonEncode(syncPayload)),
          reliable: true,
          topic: 'whiteboard',
        );
      }

      // 3. Sync screen annotation overlay state
      if (_isScreenAnnotationEnabled) {
        await _room!.localParticipant!.publishData(
          utf8.encode(jsonEncode({
            'type': 'screen_annotation',
            'enabled': true,
          })),
          reliable: true,
          topic: 'whiteboard',
        );
      }
    } catch (e) {
      debugPrint('Error synchronizing room state to attendee: $e');
    }
  }

  /// Broadcast real-time chat message over ultra-low latency WebRTC Data Channel
  Future<void> sendChatMessage({
    required String message,
    required String senderName,
    required String senderRole,
  }) async {
    if (_room == null || _room!.localParticipant == null) return;

    final chatMsg = ClassroomChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      sessionId: _connectionDetails?.sessionId ?? '',
      senderName: senderName,
      senderRole: senderRole,
      message: message,
      timestamp: DateTime.now(),
      isMine: true,
    );

    _messages.add(chatMsg);
    notifyListeners();

    try {
      final jsonPayload = jsonEncode(chatMsg.toJson());
      final bytes = utf8.encode(jsonPayload);
      await _room!.localParticipant!.publishData(
        bytes,
        reliable: true,
        topic: 'chat',
      );
    } catch (e) {
      debugPrint('Error publishing chat message over WebRTC data channel: $e');
    }
  }

  /// Toggle Hand Raise state and notify instructor
  Future<void> toggleRaiseHand({
    required String participantIdentity,
    required String participantName,
  }) async {
    if (_room == null || _room!.localParticipant == null) return;

    _isHandRaised = !_isHandRaised;
    notifyListeners();

    try {
      final payload = {
        'type': _isHandRaised ? 'raise_hand' : 'lower_hand',
        'participant_identity': participantIdentity,
        'participant_name': participantName,
        'timestamp': DateTime.now().toIso8601String(),
      };
      final bytes = utf8.encode(jsonEncode(payload));
      await _room!.localParticipant!.publishData(
        bytes,
        reliable: true,
        topic: 'hand_raise',
      );
    } catch (e) {
      debugPrint('Error publishing hand raise signal: $e');
    }
  }

  /// Lower hand of a participant (Instructor dismissal)
  Future<void> lowerHand(String participantIdentity) async {
    _raisedHands.removeWhere((h) => h.participantIdentity == participantIdentity);
    notifyListeners();

    try {
      final payload = {
        'type': 'lower_hand',
        'participant_identity': participantIdentity,
        'timestamp': DateTime.now().toIso8601String(),
      };
      final bytes = utf8.encode(jsonEncode(payload));
      await _room?.localParticipant?.publishData(
        bytes,
        reliable: true,
        topic: 'hand_raise',
      );
    } catch (e) {
      debugPrint('Error broadcasting lower hand signal: $e');
    }
  }

  /// Disconnect and release room resources
  Future<void> disconnect() async {
    try {
      await _listener?.dispose();
      await _room?.disconnect();
      await _room?.dispose();
    } catch (e) {
      debugPrint('Error disposing LiveKit room: $e');
    } finally {
      _room = null;
      _listener = null;
      _status = ClassroomConnectionStatus.disconnected;
      _connectionDetails = null;
      _isCameraEnabled = false;
      _isMicrophoneEnabled = false;
      _isScreenShareEnabled = false;
      _isScreenAnnotationEnabled = false;
      _currentStageMode = ClassroomStageMode.camera;
      _whiteboardStrokes.clear();
      _messages.clear();
      _raisedHands.clear();
      _isHandRaised = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    disconnect();
    super.dispose();
  }
}
