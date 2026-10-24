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

class LiveKitRoomService extends ChangeNotifier {
  Room? _room;
  EventsListener<RoomEvent>? _listener;

  ClassroomConnectionStatus _status = ClassroomConnectionStatus.disconnected;
  RoomConnectionDetails? _connectionDetails;
  String? _errorMessage;

  bool _isCameraEnabled = false;
  bool _isMicrophoneEnabled = false;
  bool _isScreenShareEnabled = false;

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

      // 2. Configure Room optimized for 30,000 Concurrent Attendees
      const roomOptions = RoomOptions(
        adaptiveStream: true, // Only request video resolution matching subscriber tile size
        dynacast: true,       // Pause publishing resolutions no subscribers are watching
        defaultAudioCaptureOptions: AudioCaptureOptions(
          echoCancellation: true,
          noiseSuppression: true,
          autoGainControl: true,
        ),
        defaultCameraCaptureOptions: CameraCaptureOptions(
          params: VideoParametersPresets.h720_169, // HD 720p 16:9 for instructor
        ),
        defaultScreenShareCaptureOptions: ScreenShareCaptureOptions(
          params: VideoParametersPresets.h1080_169, // Full HD for presentations
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

      // 4. If publisher (teacher), initialize camera and microphone
      if (details.canPublish) {
        try {
          await _room!.localParticipant?.setCameraEnabled(true);
          _isCameraEnabled = true;
        } catch (e) {
          debugPrint('Warning: Camera could not be initialized automatically: $e');
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
          } else if (type == 'hand_raise') {
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

  /// Toggle local camera track
  Future<void> toggleCamera() async {
    if (_room == null || !canPublish) return;

    try {
      _isCameraEnabled = !_isCameraEnabled;
      await _room!.localParticipant?.setCameraEnabled(_isCameraEnabled);
      notifyListeners();
    } catch (e) {
      debugPrint('Error toggling camera: $e');
    }
  }

  /// Toggle local microphone track
  Future<void> toggleMicrophone() async {
    if (_room == null || !canPublish) return;

    try {
      _isMicrophoneEnabled = !_isMicrophoneEnabled;
      await _room!.localParticipant?.setMicrophoneEnabled(_isMicrophoneEnabled);
      notifyListeners();
    } catch (e) {
      debugPrint('Error toggling microphone: $e');
    }
  }

  /// Toggle Screen Sharing display media track
  Future<void> toggleScreenShare() async {
    if (_room == null || !canPublish) return;

    try {
      _isScreenShareEnabled = !_isScreenShareEnabled;
      await _room!.localParticipant?.setScreenShareEnabled(
        _isScreenShareEnabled,
        captureScreenAudio: true,
      );

      if (_isScreenShareEnabled) {
        await setStageMode(ClassroomStageMode.screenShare);
      } else {
        await setStageMode(ClassroomStageMode.camera);
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error toggling screen share: $e');
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
