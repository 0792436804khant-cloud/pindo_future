import 'package:flutter/material.dart';

class ProtectedWebVideoPlayer extends StatelessWidget {
  final String streamUrl;
  final bool isPlaying;

  const ProtectedWebVideoPlayer({
    super.key,
    required this.streamUrl,
    this.isPlaying = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isPlaying ? Icons.play_circle_fill : Icons.pause_circle_filled,
              size: 64,
              color: const Color(0xFF00E5FF).withValues(alpha: 0.85),
            ),
            const SizedBox(height: 8),
            Text(
              isPlaying ? 'جارٍ تشغيل التسجيل المشفر • Secure Stream' : 'التسجيل متوقف مؤقتاً',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
