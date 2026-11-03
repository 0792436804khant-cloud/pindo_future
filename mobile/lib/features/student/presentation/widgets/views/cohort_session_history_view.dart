import 'package:flutter/material.dart';
import 'package:pindo_future_mobile/features/chat/presentation/widgets/cohort_chat_room_modal.dart';
import 'package:pindo_future_mobile/features/library/presentation/screens/protected_recording_player_screen.dart';

class CohortSessionHistoryView extends StatefulWidget {
  final String cohortId;
  final String cohortName;
  final String teacherName;
  final String subject;
  final String studentName;
  final String studentEmail;
  final String initialEnrollmentDate;
  final int remainingCredits;
  final Function(String sessionId) onJoinLiveClassroom;

  const CohortSessionHistoryView({
    super.key,
    required this.cohortId,
    required this.cohortName,
    required this.teacherName,
    required this.subject,
    required this.studentName,
    required this.studentEmail,
    required this.initialEnrollmentDate,
    required this.remainingCredits,
    required this.onJoinLiveClassroom,
  });

  static void open(
    BuildContext context, {
    required String cohortId,
    required String cohortName,
    required String teacherName,
    required String subject,
    required String studentName,
    required String studentEmail,
    required String initialEnrollmentDate,
    required int remainingCredits,
    required Function(String sessionId) onJoinLiveClassroom,
  }) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CohortSessionHistoryView(
          cohortId: cohortId,
          cohortName: cohortName,
          teacherName: teacherName,
          subject: subject,
          studentName: studentName,
          studentEmail: studentEmail,
          initialEnrollmentDate: initialEnrollmentDate,
          remainingCredits: remainingCredits,
          onJoinLiveClassroom: onJoinLiveClassroom,
        ),
      ),
    );
  }

  @override
  State<CohortSessionHistoryView> createState() => _CohortSessionHistoryViewState();
}

class _CohortSessionHistoryViewState extends State<CohortSessionHistoryView> {
  int _selectedFilterIndex = 0; // 0: الكل, 1: السابقة, 2: القادمة
  final Set<int> _alarmEnabledSessions = {10, 11};

  static const Color _brightCyan = Color(0xFF00E5FF);
  static const Color _electricPurple = Color(0xFF7C4DFF);
  static const Color _deepIndigo = Color(0xFF070B14);

  late final List<Map<String, dynamic>> _allSessions;

  @override
  void initState() {
    super.initState();
    _allSessions = [
      {
        'index': 1,
        'title': 'مدخل إلى الدوال العددية، النهايات، وقابلية الاشتقاق',
        'date': '2026-09-05',
        'time': '18:00 - 19:30',
        'status': 'حاضر',
        'duration': '92 دقيقة',
        'isLive': false,
        'isPast': true,
        'recordingId': 101,
      },
      {
        'index': 2,
        'title': 'الاستمرارية ونظرية القيم المتوسطة وتطبيقاتها البيانية',
        'date': '2026-09-12',
        'time': '18:00 - 19:30',
        'status': 'حاضر',
        'duration': '89 دقيقة',
        'isLive': false,
        'isPast': true,
        'recordingId': 102,
      },
      {
        'index': 3,
        'title': 'الدوال اللوغاريتمية النيبيرية: الخواص، المعادلات والمتراجحات',
        'date': '2026-09-19',
        'time': '18:00 - 19:30',
        'status': 'غائب',
        'duration': '0 دقيقة (مبرر)',
        'isLive': false,
        'isPast': true,
        'recordingId': 103,
      },
      {
        'index': 4,
        'title': 'الدوال الأسية والتزايد المقارن ودراسة الفروع اللانهائية',
        'date': '2026-09-26',
        'time': '18:00 - 19:30',
        'status': 'حاضر',
        'duration': '94 دقيقة',
        'isLive': false,
        'isPast': true,
        'recordingId': 104,
      },
      {
        'index': 5,
        'title': 'حل موضوع بكالوريا دورة 2024: مسألة شاملة في الدوال',
        'date': '2026-10-03',
        'time': '18:00 - 19:30',
        'status': 'حاضر',
        'duration': '90 دقيقة',
        'isLive': false,
        'isPast': true,
        'recordingId': 105,
      },
      {
        'index': 6,
        'title': 'المتتاليات العددية: البرهان بالتراجع، الرتابة، والتقارب',
        'date': '2026-10-10',
        'time': '18:00 - 19:30',
        'status': 'متأخر',
        'duration': '72 دقيقة',
        'isLive': false,
        'isPast': true,
        'recordingId': 106,
      },
      {
        'index': 7,
        'title': 'المتتاليات الحسابية والهندسية وحساب المجاميع والجداءات',
        'date': '2026-10-17',
        'time': '18:00 - 19:30',
        'status': 'حاضر',
        'duration': '91 دقيقة',
        'isLive': false,
        'isPast': true,
        'recordingId': 107,
      },
      {
        'index': 8,
        'title': 'المسائل المركبة للمتتاليات والدوال في الامتحانات الرسمية',
        'date': '2026-10-24',
        'time': '18:00 - 19:30',
        'status': 'حاضر',
        'duration': '95 دقيقة',
        'isLive': false,
        'isPast': true,
        'recordingId': 108,
      },
      {
        'index': 9,
        'title': 'الأعداد المركبة: الشكل الجبري، المثلثي، ودستور موافر (حصة مباشرة)',
        'date': 'اليوم (2026-11-03)',
        'time': '18:00 - 19:30',
        'status': 'مباشر الآن 🔴',
        'duration': 'جارٍ البث التفاعلي',
        'isLive': true,
        'isPast': false,
        'recordingId': null,
      },
      {
        'index': 10,
        'title': 'التحويلات النقطية (الانسحاب، التحاكي، الدوران) وتطبيقات الهندسة',
        'date': '2026-11-10',
        'time': '18:00 - 19:30',
        'status': 'قادمة ⏳',
        'duration': 'لم تنعقد بعد',
        'isLive': false,
        'isPast': false,
        'recordingId': null,
      },
      {
        'index': 11,
        'title': 'الهندسة الفضائية: الجداء السلمي ومعادلة المستوي والمستقيم',
        'date': '2026-11-17',
        'time': '18:00 - 19:30',
        'status': 'قادمة ⏳',
        'duration': 'لم تنعقد بعد',
        'isLive': false,
        'isPast': false,
        'recordingId': null,
      },
      {
        'index': 12,
        'title': 'الاحتمالات الشرطية والمتغيرات العشوائية وقانون برنولي',
        'date': '2026-11-24',
        'time': '18:00 - 19:30',
        'status': 'قادمة ⏳',
        'duration': 'لم تنعقد بعد',
        'isLive': false,
        'isPast': false,
        'recordingId': null,
      },
    ];
  }

  void _openRecording(int recordingId, String title) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ProtectedRecordingPlayerScreen(
          title: title,
          description: 'تسجيل حصة تفاعلية محمية بالعلامة المائية الرقمية المخصصة للتلميذ: ${widget.studentName}.',
          streamUrl: 'https://pindofuture-production.up.railway.app/api/v1/student/recordings/$recordingId/stream',
          watermarkText: '${widget.studentName} • ${widget.studentEmail}',
        ),
      ),
    );
  }

  void _toggleAlarm(int index) {
    setState(() {
      if (_alarmEnabledSessions.contains(index)) {
        _alarmEnabledSessions.remove(index);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم إلغاء التنبيه لهذه الحصة.'),
            backgroundColor: Color(0xFF0F172A),
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        _alarmEnabledSessions.add(index);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.alarm_on, color: Color(0xFF34D399), size: 18),
                SizedBox(width: 8),
                Text('تم تفعيل التنبيه بنجاح! ستتلقى إشعاراً قبل 15 دقيقة من انطلاق الحصة ⏰'),
              ],
            ),
            backgroundColor: Color(0xFF10B981),
            duration: Duration(seconds: 3),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final filteredSessions = _allSessions.where((s) {
      if (_selectedFilterIndex == 1) return s['isPast'] == true;
      if (_selectedFilterIndex == 2) return s['isPast'] == false;
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: _deepIndigo,
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A).withValues(alpha: 0.95),
        elevation: 0,
        title: Text(
          widget.cohortName,
          style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          // Cohort Chat direct access button
          TextButton.icon(
            onPressed: () => CohortChatRoomModal.show(
              context,
              cohortId: widget.cohortId,
              cohortName: widget.cohortName,
              academicLevel: 'ثالثة ثانوي',
              currentUserName: widget.studentName,
              currentUserRole: 'student',
            ),
            icon: const Icon(Icons.forum_outlined, color: _brightCyan, size: 18),
            label: const Text(
              'محادثة الفوج 💬',
              style: TextStyle(color: _brightCyan, fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Enrollment Header Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1E1B4B), Color(0xFF0F172A)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: _electricPurple.withValues(alpha: 0.4)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'المادة: ${widget.subject}',
                            style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'الأستاذ المشرف: ${widget.teacherName}',
                            style: const TextStyle(color: Colors.white70, fontSize: 12),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: _brightCyan.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: _brightCyan),
                        ),
                        child: Text(
                          'الرصيد: ${widget.remainingCredits} حصص متبقية',
                          style: const TextStyle(color: _brightCyan, fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Divider(color: Colors.white12, height: 1),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 16,
                    runSpacing: 8,
                    children: [
                      _statPill('تاريخ أول اشتراك:', widget.initialEnrollmentDate),
                      _statPill('إجمالي الحصص:', '${_allSessions.length} حصة'),
                      _statPill('نسبة الحضور:', '92% (11 حاضر / 1 غائب)'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // Section Title & Filter Chips
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'جدول الحصص التاريخي الكامل (من أول اشتراك):',
                  style: TextStyle(color: Colors.white, fontSize: 14.5, fontWeight: FontWeight.bold),
                ),
                Text(
                  '${filteredSessions.length} حصة',
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Filter Tabs
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  _filterButton(0, 'جميع الحصص (${_allSessions.length})'),
                  _filterButton(1, 'الحصص السابقة والمسجلة (8)'),
                  _filterButton(2, 'الحصص الحالية والقادمة (4)'),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Chronological Session Table Cards
            ...filteredSessions.map((session) => _sessionCard(session)),
          ],
        ),
      ),
    );
  }

  Widget _statPill(String label, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: const TextStyle(color: Colors.white54, fontSize: 11)),
        const SizedBox(width: 4),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _filterButton(int index, String label) {
    final isSelected = _selectedFilterIndex == index;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _selectedFilterIndex = index),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 7),
          decoration: BoxDecoration(
            color: isSelected ? _electricPurple : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.white60,
              fontSize: 10.5,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _sessionCard(Map<String, dynamic> session) {
    final index = session['index'] as int;
    final title = session['title'] as String;
    final date = session['date'] as String;
    final time = session['time'] as String;
    final status = session['status'] as String;
    final duration = session['duration'] as String;
    final isLive = session['isLive'] as bool;
    final isPast = session['isPast'] as bool;
    final recordingId = session['recordingId'] as int?;

    Color statusColor;
    if (isLive) {
      statusColor = const Color(0xFFEF4444);
    } else if (status.contains('حاضر')) {
      statusColor = const Color(0xFF10B981);
    } else if (status.contains('متأخر')) {
      statusColor = const Color(0xFFF59E0B);
    } else if (status.contains('غائب')) {
      statusColor = const Color(0xFF6B7280);
    } else {
      statusColor = _brightCyan;
    }

    final hasAlarm = _alarmEnabledSessions.contains(index);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isLive ? const Color(0xFF1E1B4B) : const Color(0xFF0F172A).withValues(alpha: 0.70),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isLive ? const Color(0xFFEF4444) : Colors.white.withValues(alpha: 0.10),
          width: isLive ? 1.5 : 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row: Session # & Status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: _electricPurple.withValues(alpha: 0.20),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: _electricPurple.withValues(alpha: 0.5)),
                    ),
                    child: Text(
                      'الحصة #$index',
                      style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '$date • $time',
                    style: const TextStyle(color: Colors.white60, fontSize: 11),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: statusColor),
                ),
                child: Text(
                  status,
                  style: TextStyle(color: statusColor, fontSize: 10.5, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Title
          Text(
            title,
            style: const TextStyle(color: Colors.white, fontSize: 13.5, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),

          // Duration / Info
          Row(
            children: [
              const Icon(Icons.timelapse_outlined, color: Colors.white54, size: 14),
              const SizedBox(width: 4),
              Text(
                'مدة الحضور: $duration',
                style: const TextStyle(color: Colors.white54, fontSize: 11),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Action Button based on state
          if (isLive)
            SizedBox(
              width: double.infinity,
              height: 38,
              child: ElevatedButton.icon(
                onPressed: () => widget.onJoinLiveClassroom(widget.cohortId),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEF4444),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                icon: const Icon(Icons.sensors, size: 16),
                label: const Text('ادخل الحصة فوراً 🔴 (بث مباشر)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              ),
            )
          else if (isPast && recordingId != null)
            SizedBox(
              width: double.infinity,
              height: 38,
              child: OutlinedButton.icon(
                onPressed: () => _openRecording(recordingId, title),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: _brightCyan),
                  backgroundColor: _brightCyan.withValues(alpha: 0.08),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                icon: const Icon(Icons.play_circle_outline, size: 16, color: _brightCyan),
                label: const Text('مشاهدة التسجيل المحمي 🎬', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              ),
            )
          else
            SizedBox(
              width: double.infinity,
              height: 38,
              child: OutlinedButton.icon(
                onPressed: () => _toggleAlarm(index),
                style: OutlinedButton.styleFrom(
                  foregroundColor: hasAlarm ? const Color(0xFF10B981) : Colors.white70,
                  side: BorderSide(color: hasAlarm ? const Color(0xFF10B981) : Colors.white24),
                  backgroundColor: hasAlarm ? const Color(0xFF10B981).withValues(alpha: 0.12) : Colors.transparent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                icon: Icon(hasAlarm ? Icons.alarm_on : Icons.alarm_add, size: 16, color: hasAlarm ? const Color(0xFF34D399) : Colors.white60),
                label: Text(
                  hasAlarm ? 'تم تفعيل التنبيه ⏰ (منبه مفعّل)' : 'تفعيل تنبيه الحصة 🔔',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
