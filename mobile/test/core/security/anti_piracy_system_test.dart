import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pindo_future_mobile/core/security/anti_piracy_service.dart';
import 'package:pindo_future_mobile/core/security/anti_piracy_shield.dart';
import 'package:pindo_future_mobile/features/classroom/presentation/widgets/enhanced_dynamic_watermark.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Anti-Piracy & Anti-Screen-Capture Hardening Tests', () {
    late AntiPiracyService service;

    setUp(() {
      service = AntiPiracyService.instance;
      service.clearIncidents();
      service.setMockScreenCaptureStatus(false);
    });

    test('AntiPiracyService enables and disables secure mode cleanly', () async {
      final enabled = await service.enableSecureMode();
      expect(enabled, isTrue);
      expect(service.isSecureModeEnabled, isTrue);

      final disabled = await service.disableSecureMode();
      expect(disabled, isTrue);
      expect(service.isSecureModeEnabled, isFalse);
    });

    test('AntiPiracyService logs security incident correctly', () {
      final incident = service.logIncident(
        type: SecurityIncidentType.screenRecordingAttempt,
        studentId: 'STU_0001_2026',
        studentEmail: 'amine@pindofuture.com',
        details: 'Native screen recorder detected during live stream.',
      );

      expect(incident.id, startsWith('SEC_'));
      expect(incident.type, equals(SecurityIncidentType.screenRecordingAttempt));
      expect(incident.studentId, equals('STU_0001_2026'));
      expect(service.recordedIncidents.length, equals(1));
    });

    testWidgets('EnhancedDynamicWatermark renders roaming badge, corner hashes, and clock', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Stack(
              children: [
                Center(child: Text('Live Video Player')),
                EnhancedDynamicWatermark(
                  studentName: 'أمين قادري',
                  studentId: 'STU_0001_2026',
                  wilaya: 'الجزائر العاصمة',
                  enablePhantomFlash: false,
                ),
              ],
            ),
          ),
        ),
      );

      await tester.pump();

      // Check student details rendered
      expect(find.textContaining('أمين قادري'), findsOneWidget);
      expect(find.textContaining('STU_0001_2026'), findsWidgets);
      expect(find.textContaining('الجزائر العاصمة'), findsOneWidget);

      // Verify corner badges
      expect(find.textContaining('#STU_0001_2026'), findsWidgets);
      expect(find.textContaining('PINDO DRM'), findsOneWidget);

      // Verify IgnorePointer protects the video player taps
      expect(find.byType(IgnorePointer), findsWidgets);
    });

    testWidgets('AntiPiracyShield shows child normally and blocks on screen capture detection', (tester) async {
      bool breachReported = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AntiPiracyShield(
              studentName: 'أمين قادري',
              studentId: 'STU_0001_2026',
              studentEmail: 'amine@pindofuture.com',
              onBreachDetected: () {
                breachReported = true;
              },
              child: const Center(
                child: Text('Protected Classroom Content'),
              ),
            ),
          ),
        ),
      );

      await tester.pump();

      // Normal state: child is visible
      expect(find.text('Protected Classroom Content'), findsOneWidget);
      expect(find.textContaining('تم رصد محاولة تسجيل'), findsNothing);

      // Simulate native OS screen recording detection event
      service.setMockScreenCaptureStatus(true);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Barrier state: child is hidden by the Security Breach Barrier
      expect(breachReported, isTrue);
      expect(find.textContaining('تم رصد محاولة تسجيل أو مشاركة الشاشة'), findsOneWidget);
      expect(find.textContaining('تم حجب البث المباشر فوراً'), findsOneWidget);
      expect(find.textContaining('أمين قادري (STU_0001_2026)'), findsOneWidget);

      // Recheck button exists
      expect(find.textContaining('إعادة فحص الشاشة واستئناف المشاهدة'), findsOneWidget);

      // Simulate user stopped recording app
      service.setMockScreenCaptureStatus(false);
      await tester.tap(find.textContaining('إعادة فحص الشاشة واستئناف المشاهدة'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Restored state: content is visible again
      expect(find.text('Protected Classroom Content'), findsOneWidget);
    });
  });
}
