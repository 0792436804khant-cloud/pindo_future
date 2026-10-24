import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pindo_future_mobile/features/teachers/presentation/widgets/teacher_verification_badge.dart';

void main() {
  group('TeacherVerificationBadge Widget Tests', () {
    testWidgets('Renders verified badge when isVerified is true', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: TeacherVerificationBadge(
                isVerified: true,
                showLabel: true,
              ),
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.verified), findsOneWidget);
      expect(find.text('أستاذ موثق'), findsOneWidget);
    });

    testWidgets('Renders SizedBox.shrink when isVerified is false', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: TeacherVerificationBadge(
                isVerified: false,
              ),
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.verified), findsNothing);
    });
  });
}
