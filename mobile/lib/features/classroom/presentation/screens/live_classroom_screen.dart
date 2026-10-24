import 'package:flutter/material.dart';
import 'package:livekit_client/livekit_client.dart';
import '../../domain/entities/classroom_stage_mode.dart';
import '../controllers/classroom_controller.dart';
import '../widgets/classroom_chat_panel.dart';
import '../widgets/classroom_controls_bar.dart';
import '../widgets/classroom_stage_switcher.dart';
import '../widgets/floating_student_watermark.dart';
import '../widgets/interactive_whiteboard_canvas.dart';
import '../widgets/raised_hands_dialog.dart';
import '../widgets/video_track_card.dart';

class LiveClassroomScreen extends StatefulWidget {
  final String sessionId;
  final String? roomTitle;
  final ClassroomController controller;

  const LiveClassroomScreen({
    super.key,
    required this.sessionId,
    this.roomTitle,
    required this.controller,
  });

  @override
  State<LiveClassroomScreen> createState() => _LiveClassroomScreenState();
}

class _LiveClassroomScreenState extends State<LiveClassroomScreen> {
  bool _isChatOpen = false;
  @override
  void initState() {
    super.initState();
    // Auto-join upon entering screen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.controller.joinClassroom(sessionId: widget.sessionId);
    });
  }

  void _confirmLeave() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Leave Classroom?'),
        content: const Text('Are you sure you want to disconnect from this live session?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.of(ctx).pop();
              await widget.controller.leaveClassroom();
              if (mounted) Navigator.of(context).pop();
            },
            child: const Text('Leave'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;

    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: const Color(0xFF0A0F1D), // Dark theater mode
          body: SafeArea(
            child: Stack(
              children: [
                // 1. Main Classroom Content
                if (controller.isLoading)
                  _buildConnectingView(controller)
                else if (controller.state == ClassroomUiState.error)
                  _buildErrorView(controller)
                else if (controller.isConnected)
                  _buildActiveRoomView(controller),

                // 1.1 Anti-Piracy Floating Watermark (Identity overlay)
                if (controller.isConnected && (controller.connectionDetails?.watermarkText?.isNotEmpty ?? false))
                  FloatingStudentWatermark(
                    watermarkText: controller.connectionDetails!.watermarkText!,
                  ),

                // 2. Header Bar Overlay
                Positioned(
                  top: 12,
                  left: 16,
                  right: 16,
                  child: _buildHeaderOverlay(controller),
                ),

                // 3. Floating Bottom Controls Bar
                if (controller.isConnected)
                  Positioned(
                    bottom: 20,
                    left: 20,
                    right: 20,
                    child: Center(
                      child: ClassroomControlsBar(
                        canPublish: controller.canPublish,
                        isMicEnabled: controller.isMicrophoneEnabled,
                        isCameraEnabled: controller.isCameraEnabled,
                        isScreenShareEnabled: controller.isScreenShareEnabled,
                        isWhiteboardActive: controller.currentStageMode == ClassroomStageMode.whiteboard,
                        participantsCount: controller.totalParticipantsCount,
                        onToggleMic: controller.toggleMicrophone,
                        onToggleCamera: controller.toggleCamera,
                        onToggleScreenShare: controller.canPublish ? controller.toggleScreenShare : null,
                        onToggleWhiteboard: controller.canPublish
                            ? () {
                                final isWhiteboard = controller.currentStageMode == ClassroomStageMode.whiteboard;
                                controller.setStageMode(
                                  isWhiteboard ? ClassroomStageMode.camera : ClassroomStageMode.whiteboard,
                                );
                              }
                            : null,
                        onLeaveSession: _confirmLeave,
                        onToggleChat: () {
                          setState(() {
                            _isChatOpen = !_isChatOpen;
                          });
                        },
                        unreadChatCount: controller.messages.length,
                        isHandRaised: controller.isHandRaised,
                        raisedHandsCount: controller.raisedHandsCount,
                        onRaiseHand: () {
                          controller.toggleRaiseHand(
                            participantIdentity: controller.localParticipant?.identity ?? 'student',
                            participantName: controller.localParticipant?.name ?? 'Student',
                          );
                        },
                        onOpenRaisedHandsQueue: controller.canPublish
                            ? () {
                                showDialog(
                                  context: context,
                                  builder: (_) => RaisedHandsDialog(controller: controller),
                                );
                              }
                            : null,
                      ),
                    ),
                  ),

                // 4. Slide-Out Classroom Chat Panel
                if (controller.isConnected && _isChatOpen)
                  Positioned(
                    top: 0,
                    bottom: 0,
                    right: 0,
                    child: ClassroomChatPanel(
                      controller: controller,
                      currentUserName: controller.localParticipant?.name ??
                          (controller.canPublish ? 'Instructor' : 'Student'),
                      currentUserRole: controller.canPublish ? 'teacher' : 'student',
                      onClose: () => setState(() => _isChatOpen = false),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeaderOverlay(ClassroomController controller) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A).withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        children: [
          // Live status badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.redAccent.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.redAccent, width: 1),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.circle, size: 8, color: Colors.redAccent),
                SizedBox(width: 4),
                Text(
                  'LIVE',
                  style: TextStyle(
                    color: Colors.redAccent,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),

          // Title & Session ID
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.roomTitle ?? 'Dynamic Classroom',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'Room ID: ${widget.sessionId}',
                  style: const TextStyle(color: Colors.white54, fontSize: 11),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // Stage Mode Switcher (Webcam | Whiteboard | ScreenShare)
          ClassroomStageSwitcher(
            currentMode: controller.currentStageMode,
            isScreenShareActive: controller.isScreenShareEnabled,
            onModeChanged: (mode) => controller.setStageMode(mode),
          ),
          const SizedBox(width: 8),

          // Leave Shortcut Button
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white70, size: 20),
            onPressed: _confirmLeave,
            tooltip: 'Leave Session',
          ),
        ],
      ),
    );
  }

  Widget _buildConnectingView(ClassroomController controller) {
    final statusText = controller.state == ClassroomUiState.requestingToken
        ? 'Requesting signed LiveKit token from API...'
        : 'Connecting to LiveKit SFU WebRTC Gateway...';

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(color: Color(0xFF0D9488)),
          const SizedBox(height: 20),
          Text(
            statusText,
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 8),
          Text(
            'Room: ${widget.sessionId}',
            style: const TextStyle(color: Colors.white38, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView(ClassroomController controller) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Colors.redAccent, size: 48),
            const SizedBox(height: 16),
            const Text(
              'Failed to Join Classroom',
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              controller.errorMessage ?? 'An error occurred while connecting to the live session.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70, fontSize: 13),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Back to Dashboard'),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () => controller.joinClassroom(sessionId: widget.sessionId),
                  child: const Text('Retry Connection'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveRoomView(ClassroomController controller) {
    final isTeacher = controller.canPublish;
    final localParticipant = controller.localParticipant;
    final remoteParticipants = controller.remoteParticipants;

    // Resolve stage participant (If student, stage is remote teacher; if teacher, stage is local)
    Participant? stageParticipant;
    VideoTrack? stageVideoTrack;

    if (isTeacher) {
      stageParticipant = localParticipant;
      stageVideoTrack = localParticipant?.videoTrackPublications.firstOrNull?.track as VideoTrack?;
    } else {
      // Find remote instructor or fallback to local participant
      if (remoteParticipants.isNotEmpty) {
        stageParticipant = remoteParticipants.first;
        stageVideoTrack = remoteParticipants.first.videoTrackPublications.firstOrNull?.track as VideoTrack?;
      } else {
        stageParticipant = localParticipant;
        stageVideoTrack = localParticipant?.videoTrackPublications.firstOrNull?.track as VideoTrack?;
      }
    }

    // 1. Resolve Active Stage Content
    final stageMode = controller.currentStageMode;
    Widget stageContent;

    if (stageMode == ClassroomStageMode.whiteboard) {
      // Interactive Whiteboard Stage with PiP Camera
      stageContent = Stack(
        children: [
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: InteractiveWhiteboardCanvas(
                controller: controller,
                isTeacher: isTeacher,
              ),
            ),
          ),
          if (stageParticipant != null && stageVideoTrack != null)
            Positioned(
              bottom: 16,
              right: 16,
              width: 160,
              height: 110,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFF0D9488), width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.4),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: VideoTrackCard(
                    participant: stageParticipant,
                    videoTrack: stageVideoTrack,
                    isMainStage: false,
                    customLabel: isTeacher ? 'You (PiP)' : stageParticipant.name,
                  ),
                ),
              ),
            ),
        ],
      );
    } else if (stageMode == ClassroomStageMode.screenShare) {
      // Screen Sharing Stage with PiP Camera
      final screenSharePub = controller.activeScreenSharePublication;
      final screenShareTrack = screenSharePub?.track as VideoTrack?;

      stageContent = Stack(
        children: [
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: screenShareTrack != null
                  ? VideoTrackCard(
                      participant: stageParticipant ?? localParticipant!,
                      videoTrack: screenShareTrack,
                      isMainStage: true,
                      customLabel: isTeacher ? 'Your Screen Presentation' : 'Instructor Screen Presentation',
                    )
                  : Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E293B),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.screen_share, size: 48, color: Color(0xFF38BDF8)),
                          const SizedBox(height: 14),
                          Text(
                            isTeacher
                                ? 'Click "Share Screen" on the controls bar to begin streaming your display.'
                                : 'Waiting for Instructor to start screen sharing...',
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.white70, fontSize: 14),
                          ),
                          if (isTeacher) ...[
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF2563EB),
                                foregroundColor: Colors.white,
                              ),
                              icon: const Icon(Icons.screen_share),
                              label: const Text('Start Screen Share Now'),
                              onPressed: () => controller.toggleScreenShare(),
                            ),
                          ],
                        ],
                      ),
                    ),
            ),
          ),
          if (stageParticipant != null && stageVideoTrack != null && screenShareTrack != null)
            Positioned(
              bottom: 16,
              right: 16,
              width: 160,
              height: 110,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFF2563EB), width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.4),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: VideoTrackCard(
                    participant: stageParticipant,
                    videoTrack: stageVideoTrack,
                    isMainStage: false,
                    customLabel: isTeacher ? 'You (PiP)' : stageParticipant.name,
                  ),
                ),
              ),
            ),
        ],
      );
    } else {
      // Standard Camera Spotlight Stage
      stageContent = stageParticipant != null
          ? VideoTrackCard(
              participant: stageParticipant,
              videoTrack: stageVideoTrack,
              isMainStage: true,
              customLabel: isTeacher ? 'You (Instructor)' : stageParticipant.name,
            )
          : const Center(
              child: Text(
                'Waiting for Instructor to broadcast video...',
                style: TextStyle(color: Colors.white54),
              ),
            );
    }

    return Padding(
      padding: const EdgeInsets.only(top: 70, bottom: 90, left: 16, right: 16),
      child: Column(
        children: [
          // 1. Spotlight Stage (Camera | Whiteboard | ScreenShare)
          Expanded(
            flex: 3,
            child: stageContent,
          ),

          // 2. Attendee Filmstrip (When other participants are present and not in full whiteboard)
          if (remoteParticipants.isNotEmpty && isTeacher && stageMode == ClassroomStageMode.camera) ...[
            const SizedBox(height: 12),
            SizedBox(
              height: 110,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: remoteParticipants.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  final participant = remoteParticipants[index];
                  final videoTrack = participant.videoTrackPublications.firstOrNull?.track as VideoTrack?;

                  return SizedBox(
                    width: 140,
                    child: VideoTrackCard(
                      participant: participant,
                      videoTrack: videoTrack,
                      isMainStage: false,
                    ),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }
}
