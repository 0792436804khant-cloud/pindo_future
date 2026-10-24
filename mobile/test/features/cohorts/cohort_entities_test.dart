import 'package:flutter_test/flutter_test.dart';
import 'package:pindo_future_mobile/core/constants/algerian_education_constants.dart';
import 'package:pindo_future_mobile/features/cohorts/data/models/study_cohort_model.dart';
import 'package:pindo_future_mobile/features/cohorts/domain/entities/study_cohort_entity.dart';

void main() {
  group('Phase 1: Study Cohorts & Algerian Specialization Entities Tests', () {
    test('StudyCohortModel parses JSON correctly with full Algerian BAC stream data', () {
      final json = {
        'id': 101,
        'cohort_code': 'COHORT_BAC_MATH_2026',
        'teacher_id': 5,
        'name': 'فوج النخبة - رياضيات بكالوريا 2026',
        'subject': 'Mathématiques',
        'academic_level': '3AS BAC',
        'stream': 'علوم تجريبية',
        'max_students': 80,
        'enrolled_count': 45,
        'monthly_price': 3000.0,
        'schedule': [
          {'day': 'Friday', 'time': '18:00', 'duration_minutes': 120},
          {'day': 'Tuesday', 'time': '19:00', 'duration_minutes': 90},
        ],
        'is_active': true,
        'description': 'دورة مراجعة شاملة لجميع وحدات الرياضيات',
        'teacher': {
          'id': 5,
          'name': 'الأستاذ أحمد قاسم',
          'is_verified': true,
          'wilaya': 16,
        },
      };

      final cohort = StudyCohortModel.fromJson(json);

      expect(cohort.id, equals(101));
      expect(cohort.cohortCode, equals('COHORT_BAC_MATH_2026'));
      expect(cohort.name, equals('فوج النخبة - رياضيات بكالوريا 2026'));
      expect(cohort.stream, equals('علوم تجريبية'));
      expect(cohort.academicLevel, equals('3AS BAC'));
      expect(cohort.maxStudents, equals(80));
      expect(cohort.enrolledCount, equals(45));
      expect(cohort.availableSeats, equals(35));
      expect(cohort.isFull, isFalse);
      expect(cohort.monthlyPrice, equals(3000.0));
      expect(cohort.formattedPrice, equals('3000 دج/شهرياً'));
      expect(cohort.teacherName, equals('الأستاذ أحمد قاسم'));
      expect(cohort.isTeacherVerified, isTrue);
      expect(cohort.teacherWilaya, equals(16));
      expect(cohort.wilayaName, contains('الجزائر'));
    });

    test('StudyCohortEntity detects full capacity correctly', () {
      const fullCohort = StudyCohortEntity(
        id: 202,
        cohortCode: 'COHORT_FULL',
        teacherId: 10,
        name: 'فوج ممتلئ',
        subject: 'Physique',
        academicLevel: '3AS BAC',
        maxStudents: 50,
        enrolledCount: 50,
        monthlyPrice: 0.0,
      );

      expect(fullCohort.isFull, isTrue);
      expect(fullCohort.availableSeats, equals(0));
      expect(fullCohort.formattedPrice, equals('مجاني'));
    });

    test('AlgerianEducationConstants covers 58 Wilayas and BAC streams', () {
      expect(AlgerianEducationConstants.wilayas.length, equals(58));
      expect(AlgerianEducationConstants.wilayas[16], contains('الجزائر'));
      expect(AlgerianEducationConstants.wilayas[31], contains('وهران'));
      expect(AlgerianEducationConstants.wilayas[25], contains('قسنطينة'));
      expect(AlgerianEducationConstants.secondaryStreams, contains('علوم تجريبية (Sciences Expérimentales)'));
      expect(AlgerianEducationConstants.secondaryStreams, contains('رياضيات (Mathématiques)'));
      expect(AlgerianEducationConstants.secondaryStreams, contains('تقني رياضي (Technique Mathématique)'));
    });
  });
}
