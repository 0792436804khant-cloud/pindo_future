import 'package:flutter/material.dart';
import 'package:pindo_future_mobile/features/teachers/data/models/teacher_dashboard_model.dart';
import '../modals/create_session_modal.dart';

class TeacherScheduleTab extends StatefulWidget {
  final List<TeacherScheduleItem> schedule;
  final List<TeacherCohortItem> cohorts;
  final VoidCallback onStartLiveSession;
  final void Function(TeacherScheduleItem item)? onStartScheduledSession;
  final Future<void> Function(Map<String, dynamic> payload)? onCreateSession;

  const TeacherScheduleTab({
    super.key,
    required this.schedule,
    required this.cohorts,
    required this.onStartLiveSession,
    this.onStartScheduledSession,
    this.onCreateSession,
  });

  @override
  State<TeacherScheduleTab> createState() => _TeacherScheduleTabState();
}

class _TeacherScheduleTabState extends State<TeacherScheduleTab> {
  /// Null means "All upcoming days"; non-null filters to that calendar date.
  DateTime? _selectedDate;

  static const Color _brightCyan = Color(0xFF00E5FF);
  static const Color _electricPurple = Color(0xFF7C4DFF);

  static const List<String> _arabicWeekdays = [
    'الإثنين',
    'الثلاثاء',
    'الأربعاء',
    'الخميس',
    'الجمعة',
    'السبت',
    'الأحد',
  ];

  static const List<String> _arabicMonths = [
    'جانفي',
    'فيفري',
    'مارس',
    'أفريل',
    'ماي',
    'جوان',
    'جويلية',
    'أوت',
    'سبتمبر',
    'أكتوبر',
    'نوفمبر',
    'ديسمبر',
  ];

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  List<DateTime> _buildCalendarDays() {
    final today = _dateOnly(DateTime.now());
    final anchor = _selectedDate != null && _selectedDate!.isAfter(today.add(const Duration(days: 25)))
        ? _dateOnly(_selectedDate!).subtract(const Duration(days: 3))
        : today;
    return List.generate(30, (index) => anchor.add(Duration(days: index)));
  }

  List<TeacherScheduleItem> _sessionsForDate(DateTime date) {
    return widget.schedule.where((item) {
      if (item.scheduledAt == null) {
        return _isSameDay(date, DateTime.now());
      }
      return _isSameDay(item.scheduledAt!, date);
    }).toList();
  }

  List<TeacherScheduleItem> get _filteredSchedule {
    if (_selectedDate == null) return widget.schedule;
    return _sessionsForDate(_selectedDate!);
  }

  String _weekdayName(DateTime d) => _arabicWeekdays[(d.weekday - 1) % 7];

  String _monthName(DateTime d) => _arabicMonths[(d.month - 1) % 12];

  String _dayHeadlineLabel(DateTime d) {
    final today = _dateOnly(DateTime.now());
    if (_isSameDay(d, today)) return 'اليوم';
    if (_isSameDay(d, today.add(const Duration(days: 1)))) return 'غداً';
    return _weekdayName(d);
  }

  String _fullArabicDate(DateTime d) =>
      '${_weekdayName(d)} ${d.day} ${_monthName(d)} ${d.year}';

  Future<void> _pickAnyDateFromCalendar() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 2),
      builder: (ctx, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: _brightCyan,
              onPrimary: Color(0xFF0A0F1E),
              surface: Color(0xFF0F172A),
              onSurface: Colors.white,
            ),
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
    if (picked != null && mounted) {
      setState(() => _selectedDate = _dateOnly(picked));
    }
  }

  @override
  Widget build(BuildContext context) {
    final calendarDays = _buildCalendarDays();
    final visibleSessions = _filteredSchedule;
    final headerDate = _selectedDate ?? DateTime.now();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 90),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Header & Action Bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'الجدول والرزنامة الدراسية 🗓️',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'عرض جميع أيام الأسبوع وتنظيم الحصص وإطلاق البث المباشر',
                      style: TextStyle(color: Colors.white60, fontSize: 12),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: () => CreateSessionModal.show(
                  context,
                  cohorts: widget.cohorts,
                  initialDate: _selectedDate,
                  onSave: widget.onCreateSession,
                ),
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text('برمجة حصة', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _brightCyan,
                  foregroundColor: const Color(0xFF0A0F1E),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Month / All-Days Control Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white12),
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => setState(() => _selectedDate = null),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      color: _selectedDate == null
                          ? _electricPurple.withValues(alpha: 0.35)
                          : Colors.white.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: _selectedDate == null ? _electricPurple : Colors.white12,
                      ),
                    ),
                    child: Text(
                      'كل الحصص (${widget.schedule.length})',
                      style: TextStyle(
                        color: _selectedDate == null ? Colors.white : Colors.white70,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _selectedDate == null
                        ? '${_monthName(headerDate)} ${headerDate.year} • رزنامة 30 يوماً'
                        : _fullArabicDate(_selectedDate!),
                    style: const TextStyle(color: Colors.white70, fontSize: 12.5, fontWeight: FontWeight.w600),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                TextButton.icon(
                  onPressed: _pickAnyDateFromCalendar,
                  icon: const Icon(Icons.calendar_month_rounded, size: 16, color: _brightCyan),
                  label: const Text(
                    'اختيار يوم',
                    style: TextStyle(color: _brightCyan, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Full 7-Day Rolling Calendar Strip (30 Days — All Weekdays Included)
          SizedBox(
            height: 82,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: calendarDays.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, idx) {
                final dayDate = calendarDays[idx];
                final isSelected = _selectedDate != null && _isSameDay(dayDate, _selectedDate!);
                final daySessions = _sessionsForDate(dayDate);
                final hasSessions = daySessions.isNotEmpty;
                final isToday = _isSameDay(dayDate, DateTime.now());

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        _selectedDate = null;
                      } else {
                        _selectedDate = dayDate;
                      }
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: 78,
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? _electricPurple
                          : isToday
                              ? _brightCyan.withValues(alpha: 0.12)
                              : Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSelected
                            ? _brightCyan.withValues(alpha: 0.7)
                            : hasSessions
                                ? _brightCyan.withValues(alpha: 0.45)
                                : Colors.white12,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _dayHeadlineLabel(dayDate),
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.white70,
                            fontWeight: FontWeight.w600,
                            fontSize: 11,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          '${dayDate.day}',
                          style: TextStyle(
                            color: isSelected ? Colors.white : (isToday ? _brightCyan : Colors.white),
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Flexible(
                              child: Text(
                                _monthName(dayDate),
                                style: TextStyle(
                                  color: isSelected ? Colors.white70 : Colors.white38,
                                  fontSize: 9.5,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (hasSessions) ...[
                              const SizedBox(width: 4),
                              Container(
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: isSelected ? Colors.white : _brightCyan,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 18),

          // Sessions List
          if (visibleSessions.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white10),
              ),
              child: Column(
                children: [
                  Icon(Icons.event_note_rounded, color: Colors.white.withValues(alpha: 0.35), size: 36),
                  const SizedBox(height: 10),
                  Text(
                    _selectedDate == null
                        ? 'لا توجد حصص مجدولة حالياً'
                        : 'لا توجد حصص مجدولة ليوم ${_fullArabicDate(_selectedDate!)}',
                    style: const TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'اضغط على «برمجة حصة» لجدولة موعد جديد أو اختر يوماً آخر من الرزنامة.',
                    style: const TextStyle(color: Colors.white38, fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: visibleSessions.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, idx) => _buildSessionTimelineCard(context, visibleSessions[idx]),
            ),
        ],
      ),
    );
  }

  Widget _buildSessionTimelineCard(BuildContext context, TeacherScheduleItem item) {
    final isLive = item.status == 'active';
    final scheduledAt = item.scheduledAt;
    final dateTag = scheduledAt != null
        ? '${_dayHeadlineLabel(scheduledAt)} ${scheduledAt.day}/${scheduledAt.month}'
        : '';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isLive ? _brightCyan.withValues(alpha: 0.08) : Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isLive ? _brightCyan.withValues(alpha: 0.5) : Colors.white12,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: isLive ? _brightCyan.withValues(alpha: 0.2) : _electricPurple.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isLive ? Icons.sensors_rounded : Icons.schedule_rounded,
                      size: 14,
                      color: isLive ? _brightCyan : Colors.white,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      dateTag.isNotEmpty ? '$dateTag • ${item.timeFormatted}' : item.timeFormatted,
                      style: TextStyle(
                        color: isLive ? _brightCyan : Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12.5,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  isLive ? 'بث مباشر الآن' : 'مجدولة • ${item.durationMinutes} د',
                  style: TextStyle(
                    color: isLive ? _brightCyan : Colors.white70,
                    fontSize: 10.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            item.title,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 4),
          Text(
            '${item.subject} • ${item.cohortName}',
            style: const TextStyle(color: Colors.white60, fontSize: 12),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                if (widget.onStartScheduledSession != null) {
                  widget.onStartScheduledSession!(item);
                } else {
                  widget.onStartLiveSession();
                }
              },
              icon: Icon(isLive ? Icons.play_circle_fill_rounded : Icons.video_camera_front_rounded, size: 18),
              label: Text(
                isLive ? 'الدخول لقاعة البث الجارية' : 'بدء الحصة المباشرة',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: isLive ? _brightCyan : _electricPurple,
                foregroundColor: isLive ? const Color(0xFF0A0F1E) : Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
