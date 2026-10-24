import 'package:flutter/material.dart';
import 'package:livekit_client/livekit_client.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/classroom_chat_message.dart';
import '../../domain/entities/classroom_stage_mode.dart';
import '../../domain/entities/hand_raise_request.dart';
import '../../domain/entities/room_connection_details.dart';
import '../../domain/entities/whiteboard_stroke_entity.dart';
import '../../domain/usecases/get_room_token_usecase.dart';
import '../../services/livekit_room_service.dart';

enum ClassroomUiState {
  initial,
  requestingToken,
  connectingSfu,
  connected,
  leaving,
  error,
}

class ClassroomController extends ChangeNotifier {
  final GetRoomTokenUseCase getRoomTokenUseCase;
  final LiveKitRoomService roomService;

  ClassroomUiState _state = ClassroomUiState.initial;
  RoomConnectionDetails? _connectionDetails;
  String? _errorMessage;

  ClassroomController({
    required this.getRoomTokenUseCase,
    required this.roomService,
  }) {
    roomService.addListener(_onRoomServiceUpdated);
  }

  void _onRoomServiceUpdated() {
    notifyListeners();
  }

  ClassroomUiState get state => _state;
  RoomConnectionDetails? get connectionDetails => _connectionDetails;
  String? get errorMessage => _errorMessage;

  bool get isLoading =>
      _state == ClassroomUiState.requestingToken ||
      _state == ClassroomUiState.connectingSfu;
  bool get isConnected =>
      _state == ClassroomUiState.connected && roomService.isConnected;

  Room? get room => roomService.room;
  LocalParticipant? get localParticipant => roomService.localParticipant;
  List<RemoteParticipant> get remoteParticipants => roomService.remoteParticipants;
  int get totalParticipantsCount => 1 + remoteParticipants.length;

  bool get canPublish => roomService.canPublish;
  bool get isCameraEnabled => roomService.isCameraEnabled;
  bool get isMicrophoneEnabled => roomService.isMicrophoneEnabled;
  bool get isScreenShareEnabled => roomService.isScreenShareEnabled;
  ClassroomStageMode get currentStageMode => roomService.currentStageMode;
  TrackPublication? get activeScreenSharePublication => roomService.activeScreenSharePublication;
  List<WhiteboardStrokeEntity> get whiteboardStrokes => roomService.whiteboardStrokes;

  List<ClassroomChatMessage> get messages => roomService.messages;
  List<HandRaiseRequest> get raisedHands => roomService.raisedHands;
  bool get isHandRaised => roomService.isHandRaised;
  int get raisedHandsCount => roomService.raisedHandsCount;

  Future<void> sendChatMessage({
    required String message,
    required String senderName,
    required String senderRole,
  }) =>
      roomService.sendChatMessage(
        message: message,
        senderName: senderName,
        senderRole: senderRole,
      );

  Future<void> toggleRaiseHand({
    required String participantIdentity,
    required String participantName,
  }) =>
      roomService.toggleRaiseHand(
        participantIdentity: participantIdentity,
        participantName: participantName,
      );

  Future<void> lowerHand(String participantIdentity) =>
      roomService.lowerHand(participantIdentity);

  /// Request token from Laravel and connect directly to LiveKit SFU
  Future<bool> joinClassroom({
    required String sessionId,
    String? participantName,
  }) async {
    _state = ClassroomUiState.requestingToken;
    _errorMessage = null;
    notifyListeners();

    try {
      // 1. Fetch token and room grants from Laravel API
      final details = await getRoomTokenUseCase(
        sessionId: sessionId,
        participantName: participantName,
      );
      _connectionDetails = details;

      // 2. Connect to LiveKit WebRTC SFU Gateway
      _state = ClassroomUiState.connectingSfu;
      notifyListeners();

      final success = await roomService.connect(details);
      if (success) {
        _state = ClassroomUiState.connected;
        notifyListeners();
        return true;
      } else {
        _state = ClassroomUiState.error;
        _errorMessage = roomService.errorMessage ?? 'Could not establish connection to SFU.';
        notifyListeners();
        return false;
      }
    } on Failure catch (f) {
      _state = ClassroomUiState.error;
      _errorMessage = f.message;
      notifyListeners();
      return false;
    } catch (e) {
      _state = ClassroomUiState.error;
      _errorMessage = 'Unexpected error joining classroom: $e';
      notifyListeners();
      return false;
    }
  }

  Future<void> toggleCamera() async => await roomService.toggleCamera();
  Future<void> toggleMicrophone() async => await roomService.toggleMicrophone();
  Future<void> toggleScreenShare() async => await roomService.toggleScreenShare();
  Future<void> setStageMode(ClassroomStageMode mode) async => await roomService.setStageMode(mode);

  Future<void> addWhiteboardStroke(WhiteboardStrokeEntity stroke) async =>
      await roomService.addWhiteboardStroke(stroke);
  Future<void> undoWhiteboardStroke() async => await roomService.undoWhiteboardStroke();
  Future<void> clearWhiteboard() async => await roomService.clearWhiteboard();

  /// Leave classroom and disconnect from SFU
  Future<void> leaveClassroom() async {
    _state = ClassroomUiState.leaving;
    notifyListeners();

    await roomService.disconnect();

    _connectionDetails = null;
    _state = ClassroomUiState.initial;
    notifyListeners();
  }

  @override
  void dispose() {
    roomService.removeListener(_onRoomServiceUpdated);
    roomService.dispose();
    super.dispose();
  }
}
