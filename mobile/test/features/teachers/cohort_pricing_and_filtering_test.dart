import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pindo_future_mobile/core/config/platform_payment_config.dart';
import 'package:pindo_future_mobile/core/constants/algerian_education_constants.dart';
import 'package:pindo_future_mobile/features/courses/domain/entities/academic_curriculum.dart';
import 'package:pindo_future_mobile/features/student/presentation/widgets/modals/subscription_package_modal.dart';
import 'package:pindo_future_mobile/features/teachers/presentation/widgets/modals/create_cohort_modal.dart';

void main() {
  test('Curriculum & Education constants include Social Studies and Islamic Sciences across cycles', () {
    expect(
      AlgerianEducationConstants.arabicSubjects.any((s) => s.contains('الاجتماعيات')),
      isTrue,
    );
    expect(
      AlgerianEducationConstants.arabicSubjects.any((s) => s.contains('العلوم الإسلامية')),
      isTrue,
    );

    final levels = AcademicCurriculumCatalog.getAllLevels();
    for (final level in levels) {
      if (level.id == 'primary' || level.id == 'middle' || level.id == 'high') {
        for (final year in level.years) {
          expect(
            year.subjects.any((s) => s.arabicTitle.contains('التاريخ والجغرافيا')),
            isTrue,
            reason: '${year.code} should include History & Geography (الاجتماعيات)',
          );
        }
      }
    }
  });

  test('Teacher registration years filter cohort year options strictly', () {
    final filtered = AlgerianEducationConstants.resolveTeacherCohortYears(['3AS (BAC)', '2AS']);
    expect(filtered, equals(['ثالثة ثانوي (BAC)', 'ثانية ثانوي (2AS)']));
    expect(filtered.any((y) => y.contains('متوسط')), isFalse);
  });

  test('PlatformPaymentConfig calculates 15% live, 10% library, and proportional bundle cuts', () {
    final liveOnly = PlatformPaymentConfig.calculateCommission(
      totalPriceDzd: 2000,
      packageName: 'باقة الحصص فقط',
      packageType: PlatformPaymentConfig.packageLiveOnly,
    );
    expect(liveOnly.platformCommissionDzd, equals(300));
    expect(liveOnly.teacherPayoutDzd, equals(1700));

    final libraryOnly = PlatformPaymentConfig.calculateCommission(
      totalPriceDzd: 1000,
      packageName: 'باقة المكتبة الرقمية فقط',
      packageType: PlatformPaymentConfig.packageLibraryOnly,
    );
    expect(libraryOnly.platformCommissionDzd, equals(100));
    expect(libraryOnly.teacherPayoutDzd, equals(900));

    final bundle = PlatformPaymentConfig.calculateCommission(
      totalPriceDzd: 3500,
      packageName: 'الباقة المتكاملة',
      packageType: PlatformPaymentConfig.packageFullBundle,
      livePriceDzd: 2500,
      libraryPriceDzd: 1500,
    );
    // 2500 * 15% (375) + 1500 * 10% (150) = 525 => teacher = 3500 - 525 = 2975
    expect(bundle.platformCommissionDzd, equals(525));
    expect(bundle.teacherPayoutDzd, equals(2975));

    // Distinct custom component formula check: 2000 * 15% (300) + 1000 * 10% (100) = 400 => 2700 - 400 = 2300
    final discountedBundle = PlatformPaymentConfig.calculateCommission(
      totalPriceDzd: 2700,
      packageName: 'الباقة المتكاملة',
      packageType: PlatformPaymentConfig.packageFullBundle,
      livePriceDzd: 2000,
      libraryPriceDzd: 1000,
    );
    expect(discountedBundle.platformCommissionDzd, equals(400));
    expect(discountedBundle.teacherPayoutDzd, equals(2300));
  });

  testWidgets('CreateCohortModal filters by teacher years and submits split pricing payload', (tester) async {
    Map<String, dynamic>? savedPayload;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => CreateCohortModal.show(
                context,
                allowedTeachingYears: const ['3AS (BAC)'],
                allowedTeachingSubjects: const ['التاريخ والجغرافيا (الاجتماعيات)'],
                onSave: (payload) async {
                  savedPayload = payload;
                },
              ),
              child: const Text('Open'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    expect(find.text('ثالثة ثانوي (BAC)'), findsOneWidget);
    expect(find.text('رابعة متوسط (BEM)'), findsNothing);
    expect(find.textContaining('سعر الحصص المباشرة'), findsOneWidget);
    expect(find.textContaining('سعر المكتبة فقط'), findsOneWidget);
    expect(find.textContaining('الباقة المتكاملة'), findsWidgets);

    await tester.enterText(
      find.byType(TextFormField).first,
      'فوج الاجتماعيات للبكالوريا',
    );
    await tester.ensureVisible(find.text('حفظ وإنشاء الفوج الآن'));
    await tester.tap(find.text('حفظ وإنشاء الفوج الآن'));
    await tester.pumpAndSettle();

    expect(savedPayload, isNotNull);
    expect(savedPayload!['name'], equals('فوج الاجتماعيات للبكالوريا'));
    expect(savedPayload!['academic_level'], equals('ثالثة ثانوي (BAC)'));
    expect(savedPayload!['live_sessions_price'], equals(2500.0));
    expect(savedPayload!['library_price'], equals(1500.0));
    expect(savedPayload!['bundle_price'], equals(3500.0));
  });

  testWidgets('SubscriptionPackageModal shows Live Only, Library Only, and Integrated Bundle tiers', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => SubscriptionPackageModal.show(
                context,
                cohortName: 'فوج النخبة',
                teacherName: 'الأستاذ أمين',
                subject: 'الاجتماعيات',
                currentPackageName: 'باقة الحصص فقط',
                liveSessionsPriceDzd: 2200,
                libraryPriceDzd: 1400,
                fullBundlePriceDzd: 3200,
                hasLibrary: true,
              ),
              child: const Text('Packages'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Packages'));
    await tester.pumpAndSettle();

    expect(find.textContaining('2200 دج'), findsWidgets);
    expect(find.textContaining('1400 دج'), findsWidgets);
    expect(find.textContaining('3200 دج'), findsWidgets);
  });
}
