import 'package:flutter_test/flutter_test.dart';
import 'package:pindo_future_mobile/features/courses/domain/entities/course_entity.dart';
import 'package:pindo_future_mobile/features/courses/domain/entities/enrollment_entity.dart';

void main() {
  group('CourseEntity Deserialization', () {
    test('parses decimal string price from PostgreSQL correctly', () {
      final json = {
        'id': 1,
        'teacher_id': 2,
        'title': 'Advanced WebRTC',
        'slug': 'advanced-webrtc',
        'description': 'Master WebRTC',
        'category': 'Computer Science',
        'price': '49.99',
        'status': 'published',
        'modules': [],
      };

      final course = CourseEntity.fromJson(json);

      expect(course.id, 1);
      expect(course.teacherId, 2);
      expect(course.title, 'Advanced WebRTC');
      expect(course.price, 49.99);
      expect(course.isFree, false);
      expect(course.isPublished, true);
    });

    test('parses 0.00 string price as free', () {
      final json = {
        'id': 2,
        'teacher_id': 2,
        'title': 'Free Introduction',
        'slug': 'free-intro',
        'price': '0.00',
        'status': 'published',
      };

      final course = CourseEntity.fromJson(json);

      expect(course.price, 0.0);
      expect(course.isFree, true);
    });

    test('parses numeric float price correctly', () {
      final json = {
        'id': 3,
        'teacher_id': 2,
        'title': 'Numeric Price Course',
        'slug': 'num-price',
        'price': 19.95,
        'status': 'draft',
      };

      final course = CourseEntity.fromJson(json);

      expect(course.price, 19.95);
      expect(course.isFree, false);
      expect(course.isPublished, false);
    });
  });

  group('EnrollmentEntity Deserialization', () {
    test('parses nested course structure and completed status correctly', () {
      final json = {
        'enrollment_id': 10,
        'status': 'completed',
        'enrolled_at': '2026-10-12T19:00:00Z',
        'progress_percentage': 100,
        'course': {
          'id': 5,
          'title': 'WebRTC Mastery',
          'slug': 'webrtc-mastery',
          'category': 'Computer Science',
          'teacher': {
            'id': 2,
            'name': 'Professor Alan Turing',
            'headline': 'Computer Science Pioneer',
          },
          'total_modules': 4,
          'total_lessons': 12,
          'live_lessons_count': 2,
          'next_live_session': {
            'session_id': 'SES_123',
            'title': 'Live Stage',
            'is_live': true,
          },
        },
      };

      final enrollment = EnrollmentEntity.fromJson(json);

      expect(enrollment.enrollmentId, 10);
      expect(enrollment.courseId, 5);
      expect(enrollment.courseTitle, 'WebRTC Mastery');
      expect(enrollment.status, 'completed');
      expect(enrollment.progressPercentage, 100);
      expect(enrollment.isCompleted, true);
      expect(enrollment.teacherName, 'Professor Alan Turing');
      expect(enrollment.totalModules, 4);
      expect(enrollment.totalLessons, 12);
      expect(enrollment.liveLessonsCount, 2);
      expect(enrollment.nextLiveSessionId, 'SES_123');
      expect(enrollment.isLiveNow, true);
    });

    test('parses active flat structure correctly', () {
      final json = {
        'id': 15,
        'course_id': 8,
        'course_title': 'Draft Course',
        'course_slug': 'draft-course',
        'status': 'active',
        'progress_percentage': 40,
        'enrolled_at': '2026-10-12T19:00:00Z',
      };

      final enrollment = EnrollmentEntity.fromJson(json);

      expect(enrollment.enrollmentId, 15);
      expect(enrollment.courseId, 8);
      expect(enrollment.courseTitle, 'Draft Course');
      expect(enrollment.status, 'active');
      expect(enrollment.progressPercentage, 40);
      expect(enrollment.isCompleted, false);
    });
  });
}
