import 'dart:async';
import 'package:flutter/material.dart';
import 'anti_piracy_service.dart';

/// AntiPiracyShield wraps protected classroom or lecture video players.
///
/// Features:
/// 1. Activates OS hardware-level protection (FLAG_SECURE on Android, screen capture observation on iOS).
/// 2. Blanks out the screen on app switcher / multitasking (`AppLifecycleState.inactive` or `paused`).
/// 3. Detects active screen recording apps, AirPlay, or mirroring and immediately displays a blocking Security Breach Barrier.
/// 4. Logs all attempts with student identity for administrative sanctions.
class AntiPiracyShield extends StatefulWidget {
  final Widget child;
  final String studentName;
  final String studentId;
  final String studentEmail;
  final VoidCallback? onBreachDetected;
  final bool autoEnable;

  const AntiPiracyShield({
    super.key,
    required this.child,
    required this.studentName,
    required this.studentId,
    required this.studentEmail,
    this.onBreachDetected,
    this.autoEnable = true,
  });

  @override
  State<AntiPiracyShield> createState() => _AntiPiracyShieldState();
}

class _AntiPiracyShieldState extends State<AntiPiracyShield> with WidgetsBindingObserver {
  bool _isObscuredByLifecycle = false;
  bool _isScreenRecordingActive = false;
  StreamSubscription<bool>? _captureSubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    if (widget.autoEnable) {
      AntiPiracyService.instance.enableSecureMode();
    }

    _captureSubscription = AntiPiracyService.instance.onScreenCaptureChanged.listen((isCaptured) {
      if (mounted) {
        setState(() {
          _isScreenRecordingActive = isCaptured;
        });
        if (isCaptured) {
          widget.onBreachDetected?.call();
          AntiPiracyService.instance.logIncident(
            type: SecurityIncidentType.screenRecordingAttempt,
            studentId: widget.studentId,
            studentEmail: widget.studentEmail,
            details: 'Active recording intercepted by AntiPiracyShield.',
          );
        }
      }
    });

    // Check initial capture status
    AntiPiracyService.instance.checkScreenCaptureStatus().then((isCaptured) {
      if (mounted && isCaptured) {
        setState(() => _isScreenRecordingActive = true);
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _captureSubscription?.cancel();
    if (widget.autoEnable) {
      AntiPiracyService.instance.disableSecureMode();
    }
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive || state == AppLifecycleState.paused) {
      // User opened app switcher or pull-down menu: blackout screen immediately to prevent thumbnail/screenshot leaks
      if (!_isObscuredByLifecycle && mounted) {
        setState(() => _isObscuredByLifecycle = true);
      }
    } else if (state == AppLifecycleState.resumed) {
      if (_isObscuredByLifecycle && mounted) {
        setState(() => _isObscuredByLifecycle = false);
      }
    }
  }

  Future<void> _recheckScreenState() async {
    final isCaptured = await AntiPiracyService.instance.checkScreenCaptureStatus();
    if (mounted) {
      setState(() {
        _isScreenRecordingActive = isCaptured;
      });
      if (!isCaptured) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم التحقق بنجاح: الشاشة محمية ولا يوجد تسجيل نشط.'),
            backgroundColor: Color(0xFF10B981),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('ما زال برنامج التسجيل أو مشاركة الشاشة يعمل. يرجى إيقافه للمتابعة.'),
            backgroundColor: Color(0xFFEF4444),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // 1. App Switcher / Notification blackout curtain
    if (_isObscuredByLifecycle) {
      return Container(
        color: const Color(0xFF030712),
        alignment: Alignment.center,
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.lock_rounded, color: Color(0xFF00E5FF), size: 48),
            SizedBox(height: 12),
            Text(
              'محتوى تعليمي محمي • Pindo Future DRM',
              style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      );
    }

    // 2. Active Screen Recording / Mirroring Barrier (Red Alert)
    if (_isScreenRecordingActive) {
      return Container(
        color: const Color(0xFF0F0508),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFEF4444).withValues(alpha: 0.15),
                border: Border.all(color: const Color(0xFFEF4444), width: 2),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFEF4444).withValues(alpha: 0.3),
                    blurRadius: 24,
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: const Icon(
                Icons.gpp_bad_rounded,
                color: Color(0xFFEF4444),
                size: 56,
              ),
            ),
            const SizedBox(height: 22),
            const Text(
              '🚨 تم رصد محاولة تسجيل أو مشاركة الشاشة!',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.2,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'تم حجب البث المباشر فوراً لحماية حقوق الملكية الفكرية للأستاذ.\nيُمنع منعاً باتاً تسجيل أو تصوير أو بث الحصص التعليمية.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: 13,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1B4B).withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF7C4DFF).withValues(alpha: 0.3)),
              ),
              child: Column(
                children: [
                  Text(
                    'الهوية الموثقة: ${widget.studentName} (${widget.studentId})',
                    style: const TextStyle(color: Color(0xFF00E5FF), fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'تم توثيق الواقعة برقم الهوية وسجل النشاط وإرسال تنبيه للمشرف.',
                    style: TextStyle(color: Colors.white60, fontSize: 11),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 26),
            ElevatedButton.icon(
              onPressed: _recheckScreenState,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00E5FF),
                foregroundColor: const Color(0xFF0F172A),
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text(
                'إعادة فحص الشاشة واستئناف المشاهدة',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ),
          ],
        ),
      );
    }

    // 3. Normal rendering wrapped with child
    return widget.child;
  }
}
