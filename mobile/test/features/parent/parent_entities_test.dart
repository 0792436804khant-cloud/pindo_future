import 'package:flutter_test/flutter_test.dart';
import 'package:pindo_future_mobile/features/parent/domain/entities/child_academic_course_entity.dart';
import 'package:pindo_future_mobile/features/parent/domain/entities/child_attendance_record_entity.dart';
import 'package:pindo_future_mobile/features/parent/domain/entities/child_overview_entity.dart';
import 'package:pindo_future_mobile/features/parent/domain/entities/child_schedule_entity.dart';
import 'package:pindo_future_mobile/features/parent/domain/entities/guardian_note_entity.dart';

void main() {
  group('Phase 6: Parent Portal Domain Entities Tests', () {
    test('ChildOverviewEntity parses JSON correctly', () {
      final json = {
        'id': 3,
        'name': 'Ada Lovelace',
        'email': 'student.demo@pindofuture.com',
        'relationship': 'Mother',
        'linked_at': '2026-10-10T12:00:00Z',
        'academics': {
          'enrolled_courses_count': 4,
          'completed_courses_count': 2,
          'average_progress': 50.0,
        },
        'attendance': {
          'total_watch_seconds': 3120,
          'total_watch_minutes': 52.0,
          'sessions_attended_count': 1,
        },
        'notes_count': 2,
      };

      final entity = ChildOverviewEntity.fromJson(json);

      expect(entity.id, 3);
      expect(entity.name, 'Ada Lovelace');
      expect(entity.relationship, 'Mother');
      expect(entity.enrolledCoursesCount, 4);
      expect(entity.completedCoursesCount, 2);
      expect(entity.averageProgress, 50.0);
      expect(entity.totalWatchMinutes, 52.0);
      expect(entity.sessionsAttendedCount, 1);
      expect(entity.notesCount, 2);
    });

    test('ChildAcademicCourseEntity parses JSON correctly', () {
      final json = {
        'enrollment_id': 1,
        'status': 'active',
        'enrolled_at': '2026-10-10T10:00:00Z',
        'progress_percentage': 35,
        'course': {
          'id': 101,
          'title': 'Cryptography Masterclass',
          'slug': 'crypto-masterclass',
          'category': 'Computer Science',
          'description': 'Advanced course',
          'total_modules': 4,
          'total_lessons': 12,
          'completed_lessons': 4,
          'teacher': {
            'name': 'Alan Turing',
            'headline': 'Computer Science Pioneer',
          },
        },
      };

      final entity = ChildAcademicCourseEntity.fromJson(json);

      expect(entity.enrollmentId, 1);
      expect(entity.title, 'Cryptography Masterclass');
      expect(entity.category, 'Computer Science');
      expect(entity.progressPercentage, 35);
      expect(entity.totalModules, 4);
      expect(entity.totalLessons, 12);
      expect(entity.completedLessons, 4);
      expect(entity.teacherName, 'Alan Turing');
    });

    test('ChildAttendanceRecordEntity parses JSON correctly', () {
      final json = {
        'id': 1,
        'session_id': 'SES_DEMO_LIVE',
        'session_title': 'WebRTC Masterclass',
        'joined_at': '2026-10-10T14:00:00Z',
        'left_at': '2026-10-10T14:52:00Z',
        'duration_seconds': 3120,
        'duration_minutes': 52.0,
        'session_status': 'ended',
      };

      final entity = ChildAttendanceRecordEntity.fromJson(json);

      expect(entity.id, 1);
      expect(entity.sessionId, 'SES_DEMO_LIVE');
      expect(entity.durationMinutes, 52.0);
      expect(entity.sessionStatus, 'ended');
    });

    test('GuardianNoteEntity parses JSON correctly', () {
      final json = {
        'id': 2,
        'title': 'Midterm Commendation',
        'content': 'Outstanding performance in lab.',
        'type': 'progress_report',
        'is_acknowledged': true,
        'created_at': '2026-10-10T12:00:00Z',
        'author': {
          'id': 2,
          'name': 'Alan Turing',
          'role': 'teacher',
        },
      };

      final entity = GuardianNoteEntity.fromJson(json);

      expect(entity.id, 2);
      expect(entity.title, 'Midterm Commendation');
      expect(entity.type, 'progress_report');
      expect(entity.isAcknowledged, true);
      expect(entity.authorName, 'Alan Turing');
      expect(entity.authorRole, 'teacher');
    });

    test('ChildScheduleEntity parses JSON correctly', () {
      final json = {
        'session_id': 'SES_LIVE_1',
        'title': 'Interactive SFU Lab',
        'status': 'active',
        'is_live': true,
        'scheduled_at': '2026-10-10T15:00:00Z',
        'course_title': 'WebRTC Scaling',
        'teacher_name': 'Alan Turing',
      };

      final entity = ChildScheduleEntity.fromJson(json);

      expect(entity.sessionId, 'SES_LIVE_1');
      expect(entity.isLive, true);
      expect(entity.courseTitle, 'WebRTC Scaling');
    });
  });
}
