import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:pindo_future_mobile/core/widgets/glassmorphism.dart';
import 'package:pindo_future_mobile/features/notifications/data/models/app_notification_model.dart';

class FloatingLiveAlertBanner extends StatelessWidget {
  final AppNotificationModel notification;
  final VoidCallback onJoinLive;
  final VoidCallback onDismiss;

  const FloatingLiveAlertBanner({
    super.key,
    required this.notification,
    required this.onJoinLive,
    required this.onDismiss,
  });

  static const Color _brightCyan = Color(0xFF00E5FF);
  static const Color _electricPurple = Color(0xFF7C4DFF);
  static const Color _neonRed = Color(0xFFEF4444);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: GlassmorphicContainer(
        borderRadius: BorderRadius.circular(20),
        borderColor: _neonRed.withValues(alpha: 0.60),
        borderWidth: 1.5,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        gradient: LinearGradient(
          colors: [
            _neonRed.withValues(alpha: 0.25),
            const Color(0xFF1E1B4B).withValues(alpha: 0.85),
            const Color(0xFF0F172A).withValues(alpha: 0.95),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        child: Row(
          children: [
            // Pulsing live indicator
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: _neonRed.withValues(alpha: 0.20),
                shape: BoxShape.circle,
                border: Border.all(color: _neonRed.withValues(alpha: 0.80), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: _neonRed.withValues(alpha: 0.40),
                    blurRadius: 12,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: const Icon(
                Icons.sensors_rounded,
                color: _neonRed,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),

            // Notification text content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: _neonRed,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'مباشر LIVE',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          notification.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    notification.body,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 11.5,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),

            // Join Live Class button
            ElevatedButton(
              onPressed: onJoinLive,
              style: ElevatedButton.styleFrom(
                backgroundColor: _electricPurple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'انضم الآن',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(width: 4),
                  Icon(Icons.arrow_forward_rounded, size: 14),
                ],
              ),
            ),
            const SizedBox(width: 6),

            // Dismiss
            InkWell(
              onTap: onDismiss,
              borderRadius: BorderRadius.circular(12),
              child: const Padding(
                padding: EdgeInsets.all(4),
                child: Icon(Icons.close_rounded, color: Colors.white54, size: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
