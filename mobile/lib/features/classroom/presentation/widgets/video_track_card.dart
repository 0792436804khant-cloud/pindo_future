import 'package:flutter/material.dart';
import 'package:livekit_client/livekit_client.dart';

class VideoTrackCard extends StatelessWidget {
  final Participant participant;
  final VideoTrack? videoTrack;
  final bool isMainStage;
  final String? customLabel;

  const VideoTrackCard({
    super.key,
    required this.participant,
    this.videoTrack,
    this.isMainStage = false,
    this.customLabel,
  });

  @override
  Widget build(BuildContext context) {
    final displayName = customLabel ?? (participant.name.isNotEmpty ? participant.name : participant.identity);
    final hasActiveVideo = videoTrack != null && !videoTrack!.muted;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B), // Dark slate canvas
        borderRadius: BorderRadius.circular(isMainStage ? 16 : 12),
        border: Border.all(
          color: participant.isSpeaking ? Colors.greenAccent : Colors.white10,
          width: participant.isSpeaking ? 2.5 : 1.0,
        ),
        boxShadow: isMainStage
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // 1. Video Stream or Placeholder Avatar
          if (hasActiveVideo)
            Positioned.fill(
              child: VideoTrackRenderer(
                videoTrack!,
                fit: VideoViewFit.cover,
              ),
            )
          else
            Positioned.fill(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(
                      radius: isMainStage ? 44 : 26,
                      backgroundColor: const Color(0xFF334155),
                      child: Text(
                        displayName.isNotEmpty ? displayName[0].toUpperCase() : '?',
                        style: TextStyle(
                          fontSize: isMainStage ? 34 : 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      displayName,
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: isMainStage ? 14 : 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.videocam_off, size: 14, color: Colors.white38),
                        SizedBox(width: 4),
                        Text(
                          'Camera Off',
                          style: TextStyle(fontSize: 11, color: Colors.white38),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

          // 2. Participant Label Badge
          Positioned(
            left: 10,
            bottom: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.65),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    displayName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Icon(
                    participant.isMuted ? Icons.mic_off : Icons.mic,
                    size: 14,
                    color: participant.isMuted ? Colors.redAccent : Colors.greenAccent,
                  ),
                ],
              ),
            ),
          ),

          // 3. Main Stage "Instructor" Banner
          if (isMainStage)
            Positioned(
              top: 10,
              left: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF0D9488),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.record_voice_over, color: Colors.white, size: 12),
                    SizedBox(width: 4),
                    Text(
                      'STAGE HOST',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
