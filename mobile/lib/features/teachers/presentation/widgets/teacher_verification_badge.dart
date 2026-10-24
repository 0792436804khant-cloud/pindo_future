import 'package:flutter/material.dart';

class TeacherVerificationBadge extends StatelessWidget {
  final bool isVerified;
  final double size;
  final bool showLabel;

  const TeacherVerificationBadge({
    super.key,
    required this.isVerified,
    this.size = 18.0,
    this.showLabel = false,
  });

  @override
  Widget build(BuildContext context) {
    if (!isVerified) return const SizedBox.shrink();

    final badge = Container(
      padding: EdgeInsets.symmetric(
        horizontal: showLabel ? 8.0 : 2.0,
        vertical: 2.0,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0D8ABC), Color(0xFF10B981)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF10B981).withValues(alpha: 0.3),
            blurRadius: 6,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.verified,
            color: Colors.white,
            size: size,
          ),
          if (showLabel) ...[
            const SizedBox(width: 4),
            const Text(
              'أستاذ موثق',
              style: TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ],
      ),
    );

    return Tooltip(
      message: 'أستاذ معتمد وموثق من منصة بيندو فيوتشر ✅',
      child: GestureDetector(
        onTap: () => _showVerificationInfo(context),
        child: badge,
      ),
    );
  }

  void _showVerificationInfo(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border.all(
            color: const Color(0xFF10B981).withValues(alpha: 0.3),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF10B981).withValues(alpha: 0.15),
              ),
              child: const Icon(
                Icons.verified_user_rounded,
                color: Color(0xFF10B981),
                size: 48,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'أستاذ معتمد وموثق رسمياً',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'تم التحقق من الهوية الوطنية والمؤهلات الأكاديمية والشهادات التدريسية لهذا الأستاذ من قِبل إدارة منصة Pindo Future لضمان أعلى معايير الجودة والأمان لأبنائنا التلاميذ.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: 13,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              ),
              onPressed: () => Navigator.pop(ctx),
              child: const Text(
                'حسناً، فهمت',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
