import 'dart:async';
import 'package:flutter/material.dart';
import 'package:livekit_client/livekit_client.dart';
import '../../domain/entities/classroom_stage_mode.dart';
import '../../services/live_session_recorder.dart';
import '../../services/livekit_room_service.dart';
import '../controllers/classroom_controller.dart';
import '../widgets/classroom_chat_panel.dart';
import '../widgets/classroom_controls_bar.dart';
import '../widgets/classroom_stage_switcher.dart';
import '../widgets/floating_student_watermark.dart';
import '../widgets/enhanced_dynamic_watermark.dart';
import '../../../../core/security/anti_piracy_shield.dart';
import '../widgets/interactive_whiteboard_canvas.dart';
import '../widgets/raised_hands_dialog.dart';
import '../widgets/recording_save_methods_modal.dart';
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
  bool _showSelfScreenPreview = false;
  final LiveSessionRecorder _recorder = LiveSessionRecorder();
  Timer? _recTicker;

  @override
  void initState() {
    super.initState();
    // Auto-join upon entering screen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.controller.joinClassroom(sessionId: widget.sessionId);
    });
  }

  @override
  void dispose() {
    _recTicker?.cancel();
    _recorder.dispose();
    super.dispose();
  }

  void _syncRecTicker() {
    _recTicker?.cancel();
    if (_recorder.isRecording) {
      _recTicker = Timer.periodic(const Duration(seconds: 1), (_) {
        if (mounted) setState(() {});
      });
    }
    if (mounted) setState(() {});
  }

  Future<void> _handleToggleScreenShare(ClassroomController controller) async {
    final err = await controller.toggleScreenShare();
    if (err != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(err),
          backgroundColor: const Color(0xFFEF4444),
        ),
      );
    }
  }

  void _openRecordingModal(ClassroomController controller) {
    RecordingSaveMethodsModal.show(
      context,
      sessionId: widget.sessionId,
      sessionTitle: widget.roomTitle ?? 'حصة مباشرة',
      recorder: _recorder,
      isRecording: _recorder.isRecording,
      onRecordingStateChanged: _syncRecTicker,
    );
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

    return AntiPiracyShield(
      studentName: controller.connectionDetails?.watermarkText ?? 'طالب موثق',
      studentId: controller.connectionDetails?.identity ?? 'STU_2026',
      studentEmail: 'student@pindofuture.com',
      child: ListenableBuilder(
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

                  // 1.1 Next-Gen Multi-Vector Anti-Piracy Enhanced Dynamic Watermark
                  if (controller.isConnected)
                    EnhancedDynamicWatermark(
                      studentName: controller.connectionDetails?.watermarkText ?? 'طالب موثق',
                      studentId: controller.connectionDetails?.identity ?? 'STU_2026',
                      wilaya: 'الجزائر العاصمة',
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
                        isScreenAnnotationActive: controller.isScreenAnnotationEnabled,
                        isRecording: _recorder.isRecording,
                        onToggleMic: controller.toggleMicrophone,
                        onToggleCamera: controller.toggleCamera,
                        onToggleScreenShare: controller.canPublish
                            ? () => _handleToggleScreenShare(controller)
                            : null,
                        onToggleWhiteboard: controller.canPublish
                            ? () {
                                final isWhiteboard = controller.currentStageMode == ClassroomStageMode.whiteboard;
                                controller.setStageMode(
                                  isWhiteboard ? ClassroomStageMode.camera : ClassroomStageMode.whiteboard,
                                );
                              }
                            : null,
                        onToggleScreenAnnotation: controller.canPublish
                            ? () => controller.toggleScreenAnnotation()
                            : null,
                        onOpenRecordingSheet: controller.canPublish
                            ? () => _openRecordingModal(controller)
                            : null,
                        participantsCount: controller.totalParticipantsCount,
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
    ),
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

          // Anti-Piracy Hardware Shield Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.6), width: 0.8),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.shield_rounded, color: Color(0xFF10B981), size: 12),
                SizedBox(width: 4),
                Text(
                  'FLAG_SECURE 🔒',
                  style: TextStyle(color: Color(0xFF34D399), fontSize: 9.5, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // Live Recording Timer Pill if active
          if (_recorder.isRecording) ...[
            GestureDetector(
              onTap: () => _openRecordingModal(controller),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFEF4444).withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFEF4444)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.fiber_manual_record, color: Color(0xFFEF4444), size: 10),
                    const SizedBox(width: 4),
                    Text(
                      'REC ${_recorder.elapsedSeconds ~/ 60}:${(_recorder.elapsedSeconds % 60).toString().padLeft(2, '0')}',
                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 6),
          ],

          // Stream Quality / Max FPS Preset Selector (Publisher Only)
          if (controller.canPublish) ...[
            PopupMenuButton<LiveStreamQualityPreset>(
              tooltip: 'جودة البث والسرعة (Max FPS)',
              color: const Color(0xFF0F172A),
              onSelected: (preset) => controller.setQualityPreset(preset),
              itemBuilder: (_) => LiveStreamQualityPreset.values
                  .map(
                    (preset) => PopupMenuItem<LiveStreamQualityPreset>(
                      value: preset,
                      child: Row(
                        children: [
                          Icon(
                            controller.qualityPreset == preset
                                ? Icons.check_circle
                                : Icons.circle_outlined,
                            size: 16,
                            color: const Color(0xFF00E5FF),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            preset.arabicLabel,
                            style: const TextStyle(color: Colors.white, fontSize: 12.5),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF00E5FF).withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF00E5FF).withValues(alpha: 0.5)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.hd_rounded, color: Color(0xFF00E5FF), size: 14),
                    const SizedBox(width: 4),
                    Text(
                      controller.qualityPreset.shortBadge,
                      style: const TextStyle(color: Color(0xFF00E5FF), fontSize: 9.5, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 6),
          ],

          // Stage Mode Switcher (Webcam | Whiteboard | ScreenShare)
          ClassroomStageSwitcher(
            currentMode: controller.currentStageMode,
            isScreenShareActive: controller.isScreenShareEnabled,
            onModeChanged: (mode) {
              if (mode == ClassroomStageMode.screenShare && controller.canPublish && !controller.isScreenShareEnabled) {
                _handleToggleScreenShare(controller);
              } else {
                controller.setStageMode(mode);
              }
            },
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

    // Resolve stage participant & explicit CAMERA track (never confuse camera with screenShare track)
    Participant? stageParticipant;
    VideoTrack? stageVideoTrack;

    if (isTeacher) {
      stageParticipant = localParticipant;
      stageVideoTrack = controller.cameraTrackFor(localParticipant);
    } else {
      if (remoteParticipants.isNotEmpty) {
        stageParticipant = remoteParticipants.first;
        stageVideoTrack = controller.cameraTrackFor(remoteParticipants.first);
      } else {
        stageParticipant = localParticipant;
        stageVideoTrack = controller.cameraTrackFor(localParticipant);
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
                sessionId: widget.sessionId,
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
      final screenSharePub = controller.activeScreenSharePublication;
      final screenShareTrack = screenSharePub?.track as VideoTrack?;
      final isLocalPresenter = isTeacher &&
          screenSharePub != null &&
          screenSharePub.participant.identity == localParticipant?.identity;

      stageContent = Stack(
        children: [
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: screenShareTrack != null
                  ? (isLocalPresenter && !_showSelfScreenPreview
                      ? Container(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [Color(0xFF0F172A), Color(0xFF1E1B4B)],
                            ),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: const Color(0xFF00E5FF).withValues(alpha: 0.4)),
                          ),
                          alignment: Alignment.center,
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF00E5FF).withValues(alpha: 0.14),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.cast_connected_rounded, size: 48, color: Color(0xFF00E5FF)),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'أنت تشارك شاشتك الآن للتلاميذ (${controller.qualityPreset.shortBadge})',
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'تم إيقاف المعاينة المتكررة تلقائياً لمنع تداخل الشاشة (Infinite Mirror).\nالتلاميذ يشاهدون شاشتك الآن بأعلى دقة ممكنة مع إمكانية الرسم والكتابة فوقها.',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.5),
                              ),
                              const SizedBox(height: 20),
                              Wrap(
                                spacing: 10,
                                runSpacing: 10,
                                alignment: WrapAlignment.center,
                                children: [
                                  ElevatedButton.icon(
                                    onPressed: () => controller.toggleScreenAnnotation(),
                                    icon: Icon(
                                      controller.isScreenAnnotationEnabled ? Icons.edit_off : Icons.gesture_rounded,
                                      size: 18,
                                    ),
                                    label: Text(
                                      controller.isScreenAnnotationEnabled ? 'إيقاف قلم الشاشة' : 'الكتابة والرسم على الشاشة',
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF00E5FF),
                                      foregroundColor: const Color(0xFF0A0F1E),
                                    ),
                                  ),
                                  OutlinedButton.icon(
                                    onPressed: () => setState(() => _showSelfScreenPreview = true),
                                    icon: const Icon(Icons.visibility_outlined, size: 18, color: Colors.white70),
                                    label: const Text('معاينة البث (إذا شاركت شاشة أخرى)', style: TextStyle(color: Colors.white70)),
                                    style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.white24)),
                                  ),
                                  ElevatedButton.icon(
                                    onPressed: () => _handleToggleScreenShare(controller),
                                    icon: const Icon(Icons.stop_screen_share, size: 18),
                                    label: const Text('إيقاف مشاركة الشاشة'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFFEF4444),
                                      foregroundColor: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        )
                      : Stack(
                          children: [
                            Positioned.fill(
                              child: VideoTrackCard(
                                participant: screenSharePub?.participant ?? stageParticipant ?? localParticipant!,
                                videoTrack: screenShareTrack,
                                isMainStage: true,
                                fit: VideoViewFit.contain,
                                customLabel: isTeacher ? 'معاينة شاشتك المباشرة' : 'شاشة الأستاذ المباشرة',
                              ),
                            ),
                            if (isLocalPresenter && _showSelfScreenPreview)
                              Positioned(
                                top: 12,
                                right: 12,
                                child: ElevatedButton.icon(
                                  onPressed: () => setState(() => _showSelfScreenPreview = false),
                                  icon: const Icon(Icons.visibility_off, size: 15),
                                  label: const Text('إخفاء المعاينة', style: TextStyle(fontSize: 11)),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.black87,
                                    foregroundColor: Colors.white,
                                  ),
                                ),
                              ),
                          ],
                        ))
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
                                ? 'اضغط «بدء مشاركة الشاشة» واختر النافذة أو الشاشة الأخرى للبث بأعلى دقة.'
                                : 'في انتظار مشاركة الشاشة من الأستاذ...',
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
                              label: const Text('بدء مشاركة الشاشة الآن'),
                              onPressed: () => _handleToggleScreenShare(controller),
                            ),
                          ],
                        ],
                      ),
                    ),
            ),
          ),
          // Transparent live annotation overlay directly on top of screen share!
          if (controller.isScreenAnnotationEnabled || (isTeacher && controller.whiteboardStrokes.isNotEmpty && controller.isScreenAnnotationEnabled))
            Positioned.fill(
              child: InteractiveWhiteboardCanvas(
                controller: controller,
                isTeacher: isTeacher,
                sessionId: widget.sessionId,
                isOverlayMode: true,
                onCloseOverlay: isTeacher ? () => controller.toggleScreenAnnotation(enabled: false) : null,
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
                    customLabel: isTeacher ? 'أنت (PiP)' : stageParticipant.name,
                  ),
                ),
              ),
            ),
        ],
      );
    } else {
      // Standard Camera Spotlight Stage with optional transparent On-Screen Drawing Overlay!
      stageContent = Stack(
        children: [
          Positioned.fill(
            child: stageParticipant != null
                ? VideoTrackCard(
                    participant: stageParticipant,
                    videoTrack: stageVideoTrack,
                    isMainStage: true,
                    customLabel: isTeacher ? 'أنت (الأستاذ)' : stageParticipant.name,
                  )
                : const Center(
                    child: Text(
                      'في انتظار بث الكاميرا من الأستاذ...',
                      style: TextStyle(color: Colors.white54),
                    ),
                  ),
          ),
          if (controller.isScreenAnnotationEnabled)
            Positioned.fill(
              child: InteractiveWhiteboardCanvas(
                controller: controller,
                isTeacher: isTeacher,
                sessionId: widget.sessionId,
                isOverlayMode: true,
                onCloseOverlay: isTeacher ? () => controller.toggleScreenAnnotation(enabled: false) : null,
              ),
            ),
        ],
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
