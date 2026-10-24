import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pindo_future_mobile/core/widgets/glassmorphism.dart';
import 'package:pindo_future_mobile/features/classroom/presentation/widgets/classroom_controls_bar.dart';

void main() {
  group('Phase 8: Classroom Glassmorphism & Micro-interactions Tests', () {
    testWidgets('ClassroomControlsBar renders GlassmorphicContainer and action buttons', (tester) async {
      bool micToggled = false;
      bool leaveTriggered = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: ClassroomControlsBar(
                canPublish: true,
                isMicEnabled: true,
                isCameraEnabled: true,
                isScreenShareEnabled: false,
                isWhiteboardActive: false,
                onToggleMic: () => micToggled = true,
                onToggleCamera: () {},
                onToggleScreenShare: () {},
                onToggleWhiteboard: () {},
                onLeaveSession: () => leaveTriggered = true,
                onToggleChat: () {},
                participantsCount: 12,
              ),
            ),
          ),
        ),
      );

      // Verify GlassmorphicContainer is rendered
      expect(find.byType(GlassmorphicContainer), findsOneWidget);

      // Verify buttons exist
      expect(find.byIcon(Icons.mic), findsOneWidget);
      expect(find.byIcon(Icons.videocam), findsOneWidget);
      expect(find.byIcon(Icons.call_end), findsOneWidget);
      expect(find.text('12'), findsOneWidget);

      // Verify scale buttons are present
      expect(find.byType(GlassmorphicScaleButton), findsWidgets);

      // Tap Mic button
      await tester.tap(find.byIcon(Icons.mic));
      await tester.pump();
      expect(micToggled, isTrue);

      // Tap Leave button
      await tester.tap(find.byIcon(Icons.call_end));
      await tester.pump();
      expect(leaveTriggered, isTrue);
    });

    testWidgets('GlassmorphicScaleButton scales down on pointer down', (tester) async {
      bool pressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: GlassmorphicScaleButton(
                pressedScale: 0.88,
                onPressed: () => pressed = true,
                child: const Icon(Icons.star),
              ),
            ),
          ),
        ),
      );

      final animatedScaleFinder = find.byType(AnimatedScale);
      expect(animatedScaleFinder, findsOneWidget);

      AnimatedScale scaleWidget = tester.widget(animatedScaleFinder);
      expect(scaleWidget.scale, 1.0);

      // Press down
      final gesture = await tester.startGesture(tester.getCenter(find.byType(GlassmorphicScaleButton)));
      await tester.pump(const Duration(milliseconds: 150));

      scaleWidget = tester.widget(animatedScaleFinder);
      expect(scaleWidget.scale, 0.88);

      // Release
      await gesture.up();
      await tester.pump(const Duration(milliseconds: 150));

      scaleWidget = tester.widget(animatedScaleFinder);
      expect(scaleWidget.scale, 1.0);
      expect(pressed, isTrue);
    });
  });
}
