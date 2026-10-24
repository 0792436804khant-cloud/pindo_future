import 'package:flutter/material.dart';
import '../../../../core/widgets/glassmorphism.dart';

class ClassroomControlsBar extends StatelessWidget {
  final bool canPublish;
  final bool isMicEnabled;
  final bool isCameraEnabled;
  final bool isScreenShareEnabled;
  final bool isWhiteboardActive;
  final VoidCallback onToggleMic;
  final VoidCallback onToggleCamera;
  final VoidCallback? onToggleScreenShare;
  final VoidCallback? onToggleWhiteboard;
  final VoidCallback onLeaveSession;
  final VoidCallback onToggleChat;
  final int unreadChatCount;
  final bool isHandRaised;
  final VoidCallback? onRaiseHand;
  final int raisedHandsCount;
  final VoidCallback? onOpenRaisedHandsQueue;
  final int participantsCount;

  const ClassroomControlsBar({
    super.key,
    required this.canPublish,
    required this.isMicEnabled,
    required this.isCameraEnabled,
    this.isScreenShareEnabled = false,
    this.isWhiteboardActive = false,
    required this.onToggleMic,
    required this.onToggleCamera,
    this.onToggleScreenShare,
    this.onToggleWhiteboard,
    required this.onLeaveSession,
    required this.onToggleChat,
    this.unreadChatCount = 0,
    this.isHandRaised = false,
    this.onRaiseHand,
    this.raisedHandsCount = 0,
    this.onOpenRaisedHandsQueue,
    this.participantsCount = 1,
  });

  @override
  Widget build(BuildContext context) {
    return GlassmorphicContainer(
      borderRadius: BorderRadius.circular(28),
      blurSigma: 18.0,
      borderWidth: 1.2,
      borderColor: Colors.white.withValues(alpha: 0.22),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withValues(alpha: 0.14),
          const Color(0xFF1E1B4B).withValues(alpha: 0.70), // Cosmic Indigo
          const Color(0xFF0F172A).withValues(alpha: 0.88), // Deep Navy Slate
        ],
        stops: const [0.0, 0.45, 1.0],
      ),
      boxShadow: [
        BoxShadow(
          color: const Color(0xFF6366F1).withValues(alpha: 0.22), // Indigo halo
          blurRadius: 28,
          spreadRadius: 1,
          offset: const Offset(0, 4),
        ),
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.48),
          blurRadius: 24,
          offset: const Offset(0, 8),
        ),
      ],
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 1. Microphone Toggle (Publisher Only)
          if (canPublish) ...[
            _buildCircularButton(
              icon: isMicEnabled ? Icons.mic : Icons.mic_off,
              isActive: isMicEnabled,
              activeColor: const Color(0xFF10B981), // Emerald
              inactiveColor: const Color(0xFFEF4444), // Coral Red
              tooltip: isMicEnabled ? 'Mute Microphone' : 'Unmute Microphone',
              onPressed: onToggleMic,
            ),
            const SizedBox(width: 10),
          ],

          // 2. Camera Toggle (Publisher Only)
          if (canPublish) ...[
            _buildCircularButton(
              icon: isCameraEnabled ? Icons.videocam : Icons.videocam_off,
              isActive: isCameraEnabled,
              activeColor: const Color(0xFF10B981),
              inactiveColor: const Color(0xFFEF4444),
              tooltip: isCameraEnabled ? 'Turn Off Camera' : 'Turn On Camera',
              onPressed: onToggleCamera,
            ),
            const SizedBox(width: 10),
          ],

          // 3. Screen Sharing Toggle (Publisher Only)
          if (canPublish && onToggleScreenShare != null) ...[
            _buildCircularButton(
              icon: isScreenShareEnabled ? Icons.stop_screen_share : Icons.screen_share,
              isActive: isScreenShareEnabled,
              activeColor: const Color(0xFF2563EB), // Royal Blue
              inactiveColor: const Color(0xFF334155),
              tooltip: isScreenShareEnabled ? 'Stop Screen Sharing' : 'Share Screen',
              onPressed: onToggleScreenShare!,
            ),
            const SizedBox(width: 10),
          ],

          // 4. Whiteboard Toggle (Publisher Only)
          if (canPublish && onToggleWhiteboard != null) ...[
            _buildCircularButton(
              icon: Icons.draw,
              isActive: isWhiteboardActive,
              activeColor: const Color(0xFF0D9488), // Brand Teal
              inactiveColor: const Color(0xFF334155),
              tooltip: isWhiteboardActive ? 'Hide Whiteboard' : 'Open Whiteboard',
              onPressed: onToggleWhiteboard!,
            ),
            const SizedBox(width: 10),
          ],

          // Vertical Glass Accent Divider
          if (canPublish) ...[
            _buildVerticalDivider(),
            const SizedBox(width: 10),
          ],

          // 5. Teacher: Raised Hands Queue Viewer
          if (canPublish && onOpenRaisedHandsQueue != null) ...[
            Badge(
              isLabelVisible: raisedHandsCount > 0,
              label: Text('$raisedHandsCount'),
              backgroundColor: const Color(0xFFF59E0B),
              child: _buildCircularButton(
                icon: Icons.front_hand,
                isActive: raisedHandsCount > 0,
                activeColor: const Color(0xFFF59E0B),
                inactiveColor: const Color(0xFF334155),
                tooltip: 'View Raised Hands Queue ($raisedHandsCount)',
                onPressed: onOpenRaisedHandsQueue!,
              ),
            ),
            const SizedBox(width: 10),
          ],

          // 6. Student: Raise Hand Toggle
          if (!canPublish && onRaiseHand != null) ...[
            _buildCircularButton(
              icon: Icons.front_hand,
              isActive: isHandRaised,
              activeColor: const Color(0xFFF59E0B), // Vibrant Amber
              inactiveColor: const Color(0xFF334155),
              tooltip: isHandRaised ? 'Lower Hand' : 'Raise Hand to Ask Question',
              onPressed: onRaiseHand!,
            ),
            const SizedBox(width: 10),
          ],

          // 7. Classroom Live Chat Button
          Badge(
            isLabelVisible: unreadChatCount > 0,
            label: Text('$unreadChatCount'),
            backgroundColor: const Color(0xFF38BDF8),
            child: _buildCircularButton(
              icon: Icons.chat_bubble_outline,
              isActive: false,
              activeColor: const Color(0xFF38BDF8),
              inactiveColor: const Color(0xFF334155),
              tooltip: 'Toggle Classroom Chat',
              onPressed: onToggleChat,
            ),
          ),
          const SizedBox(width: 10),

          // 8. Participants Counter Frosted Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.18),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.groups, color: Colors.white70, size: 16),
                const SizedBox(width: 6),
                Text(
                  '$participantsCount',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    letterSpacing: 0.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),

          _buildVerticalDivider(),
          const SizedBox(width: 10),

          // 9. Leave Classroom Button (Glowing Red Glass)
          _buildCircularButton(
            icon: Icons.call_end,
            isActive: true,
            activeColor: const Color(0xFFEF4444), // Coral Red
            inactiveColor: const Color(0xFFEF4444),
            tooltip: 'Leave Classroom',
            onPressed: onLeaveSession,
          ),
        ],
      ),
    );
  }

  Widget _buildVerticalDivider() {
    return Container(
      width: 1,
      height: 26,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(1),
      ),
    );
  }

  Widget _buildCircularButton({
    required IconData icon,
    required bool isActive,
    required Color activeColor,
    required Color inactiveColor,
    required String tooltip,
    required VoidCallback onPressed,
  }) {
    return GlassmorphicScaleButton(
      tooltip: tooltip,
      pressedScale: 0.88,
      onPressed: onPressed,
      builder: (context, isPressed, isHovered) {
        final Color baseColor = isActive ? activeColor : inactiveColor;
        final bool isRedLeave = icon == Icons.call_end;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: isActive
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      baseColor.withValues(alpha: 0.95),
                      baseColor.withValues(alpha: 0.75),
                    ],
                  )
                : LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withValues(alpha: isHovered ? 0.20 : 0.12),
                      const Color(0xFF334155).withValues(alpha: isHovered ? 0.70 : 0.50),
                    ],
                  ),
            border: Border.all(
              color: isActive
                  ? Colors.white.withValues(alpha: 0.38)
                  : Colors.white.withValues(alpha: isHovered ? 0.30 : 0.18),
              width: 1.2,
            ),
            boxShadow: [
              if (isActive || isRedLeave)
                BoxShadow(
                  color: baseColor.withValues(alpha: isHovered ? 0.55 : 0.40),
                  blurRadius: isHovered ? 14 : 10,
                  offset: const Offset(0, 2),
                )
              else
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.25),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
            ],
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 20,
          ),
        );
      },
    );
  }
}
