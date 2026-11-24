import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pindo_future_mobile/core/widgets/glassmorphism.dart';
import 'package:pindo_future_mobile/core/widgets/bento_card.dart';
import 'package:pindo_future_mobile/features/student/data/models/student_dashboard_model.dart';
import 'package:pindo_future_mobile/features/chat/presentation/widgets/cohort_chat_room_modal.dart';
import 'package:pindo_future_mobile/features/chat/presentation/widgets/cohort_chats_hub_modal.dart';
import 'package:pindo_future_mobile/features/chat/services/cohort_chat_service.dart';
import 'package:pindo_future_mobile/features/teachers/presentation/widgets/modals/teacher_story_viewer_modal.dart';
import 'package:pindo_future_mobile/features/teachers/data/models/teacher_dashboard_model.dart';

class StudentHomeTab extends StatefulWidget {
  final StudentDashboardData dashboardData;
  final VoidCallback onRefresh;
  final Function(String sessionId) onJoinLiveClassroom;
  final Function(int recordingId) onOpenRecording;
  final VoidCallback onOpenExamBank;
  final VoidCallback onOpenWeeklySchedule;
  final VoidCallback onManageSubscriptions;
  final VoidCallback onOpenAccountSettings;
  final Function(String teacherId)? onOpenTeacherShowcase;

  const StudentHomeTab({
    super.key,
    required this.dashboardData,
    required this.onRefresh,
    required this.onJoinLiveClassroom,
    required this.onOpenRecording,
    required this.onOpenExamBank,
    required this.onOpenWeeklySchedule,
    required this.onManageSubscriptions,
    required this.onOpenAccountSettings,
    this.onOpenTeacherShowcase,
  });

  @override
  State<StudentHomeTab> createState() => _StudentHomeTabState();
}

class _StudentHomeTabState extends State<StudentHomeTab> {
  static const Color _brightCyan = Color(0xFF00E5FF);
  static const Color _electricPurple = Color(0xFF7C4DFF);
  static const Color _deepIndigo = Color(0xFF311B92);

  // Quick live join controller
  final TextEditingController _quickJoinController = TextEditingController();

  // Teacher Search state
  final TextEditingController _searchTeacherController = TextEditingController();
  int _selectedSearchChip = 0; // 0: الكل, 1: الرياضيات, 2: الفيزياء, 3: العلوم, 4: الفلسفة, 5: اللغات
  String _searchQuery = '';

  // Cycle marquee banner state
  int _activeCycleIndex = 0;
  Timer? _cycleTimer;

  // Today Schedule Alarm toggles
  final Set<String> _enabledScheduleAlarms = {'18:00'};

  final List<Map<String, dynamic>> _educationalCycles = [
    {
      'id': 'primary',
      'title': 'الطور الابتدائي (1AP - 5AP)',
      'subtitle': 'تأسيس متين وقواعد اللغة والحساب بأسلوب تفاعلي مشوّق',
      'badge': 'الابتدائي 1AP-5AP',
      'color': const Color(0xFF10B981),
      'icon': Icons.child_care_rounded,
      'stats': 'مرافقة يومية • معلمين أكفاء',
    },
    {
      'id': 'middle',
      'title': 'الطور المتوسط (BEM 1AM - 4AM)',
      'subtitle': 'تحضير مكثف لشهادة التعليم المتوسط مع بنك مواضيع BEM الرسمية',
      'badge': 'شهادة BEM 2025',
      'color': const Color(0xFF00E5FF),
      'icon': Icons.backpack_rounded,
      'stats': 'نسبة نجاح 98% • حلول نموذجية',
    },
    {
      'id': 'high',
      'title': 'الطور الثانوي (1AS - 3AS BAC)',
      'subtitle': 'دورات البكالوريا التخصصية مع نخبة أساتذة الجزائر ومعدي الامتحانات',
      'badge': 'بكالوريا BAC 2025',
      'color': const Color(0xFF7C4DFF),
      'icon': Icons.school_rounded,
      'stats': 'أعلى معدلات وطنية • 19+/20',
    },
    {
      'id': 'university',
      'title': 'الطور الجامعي (University & Grandes Écoles)',
      'subtitle': 'الرياضيات الجامعية، الفيزياء، الخوارزميات، واللغات الأكاديمية',
      'badge': 'الجامعي University',
      'color': const Color(0xFFF59E0B),
      'icon': Icons.account_balance_rounded,
      'stats': 'أساتذة دكاترة • بحوث ومشاريع',
    },
  ];

  @override
  void initState() {
    super.initState();
    _cycleTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (mounted) {
        setState(() {
          _activeCycleIndex = (_activeCycleIndex + 1) % _educationalCycles.length;
        });
      }
    });
  }

  @override
  void dispose() {
    _cycleTimer?.cancel();
    _quickJoinController.dispose();
    _searchTeacherController.dispose();
    super.dispose();
  }

  void _submitQuickLiveJoin() {
    final code = _quickJoinController.text.trim();
    if (code.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يرجى إدخال رمز حصة صالح أو رابط مباشر (مثال: SES_8PP4LVG1).'),
          backgroundColor: Color(0xFFEF4444),
        ),
      );
      return;
    }

    // Extract code if user pasted a full URL
    String cleanCode = code;
    if (code.contains('/')) {
      cleanCode = code.split('/').last.trim();
    }

    widget.onJoinLiveClassroom(cleanCode);
  }

  void _openTeacherStory(String teacherName, String subject) {
    final mockProfile = TeacherProfileInfo(
      id: 1,
      name: teacherName,
      email: 'teacher@pindofuture.com',
      teacherId: 'TCH_DZ_STORY',
      avatarUrl: null,
      coverImageUrl: 'https://images.unsplash.com/photo-1509062522246-3755977927d7?w=1200&q=80',
      isVerified: true,
      yearsOfExperience: 10,
      headline: 'أستاذ رئيسي لمادة $subject ومعد دورات المتفوقين',
      wilaya: 'الجزائر العاصمة',
      bio: 'أستاذ معتمد في منصة Pindo Future للتعليم التفاعلي عن بعد.',
      subjects: [subject],
      levels: const ['ثالثة ثانوي', 'ثانية ثانوي'],
      stories: [
        TeacherStoryItem(
          id: 'story_1',
          text: '🔴 تنبيه هام لجميع طلاب فوج $subject:\nالحصة التفاعلية المباشرة لمراجعة حل المسائل النموذجية تبدأ اليوم عند الساعة 18:00 مساءً. يرجى الاستعداد وتحضير كراس التمارين!',
          imageUrl: 'https://images.unsplash.com/photo-1516321318423-f06f85e504b3?w=800&q=80',
          mediaType: 'video',
          timeAgo: 'منذ ساعتين',
          viewsCount: 310,
          isLiveAlert: true,
          tag: '🔴 بث مباشر اليوم',
          actionButtonText: 'الانتقال لقاعة البث المباشر',
        ),
        TeacherStoryItem(
          id: 'story_2',
          text: '💡 نصيحة منهجية لطلاب البكالوريا:\nفي مسائل $subject، احرصوا على تدوين الخطوات المنهجية بدقة لأن سلم التنقيط الوزاري يمنح درجات تفصيلية لكل مرحلة!',
          imageUrl: 'https://images.unsplash.com/photo-1606326608606-aa0b62935f2b?w=800&q=80',
          mediaType: 'image',
          timeAgo: 'منذ 4 ساعات',
          viewsCount: 450,
          tag: '💡 نصيحة تفوق',
        ),
      ],
    );

    TeacherStoryViewerModal.show(
      context,
      stories: mockProfile.stories,
      teacherProfile: mockProfile,
    );
  }

  void _toggleScheduleAlarm(String time) {
    setState(() {
      if (_enabledScheduleAlarms.contains(time)) {
        _enabledScheduleAlarms.remove(time);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تم إلغاء التنبيه لحصة الساعة $time.'),
            backgroundColor: const Color(0xFF0F172A),
            duration: const Duration(seconds: 2),
          ),
        );
      } else {
        _enabledScheduleAlarms.add(time);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.alarm_on, color: Color(0xFF34D399), size: 18),
                const SizedBox(width: 8),
                Text('تم ضبط التنبيه لحصة الساعة $time! ستتلقى إشعاراً قبل 15 دقيقة ⏰'),
              ],
            ),
            backgroundColor: const Color(0xFF10B981),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final student = widget.dashboardData.student;
    final nextSession = widget.dashboardData.nextSession;
    final subscriptions = widget.dashboardData.subscriptions;

    return RefreshIndicator(
      onRefresh: () async => widget.onRefresh(),
      color: _brightCyan,
      backgroundColor: const Color(0xFF0F172A),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(18, 12, 18, 90),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Welcome & Greeting Bar
            _buildWelcomeBar(context, student),
            const SizedBox(height: 16),

            // 2. Teacher Stories Tray (شريط القصص المنشورة من طرف الأساتذة)
            _buildTeacherStoriesTray(),
            const SizedBox(height: 18),

            // 3. Quick Live Join Bar for New & Enrolled Students (خانة وضع رابط اللايف)
            _buildQuickLiveJoinBar(),
            const SizedBox(height: 18),

            // 4. Smart Teacher Search Bar (شريط البحث عن الأساتذة)
            _buildTeacherSearchBar(),
            const SizedBox(height: 18),

            // 5. Animated Educational Cycles Promotional Marquee (شريط ترويجي متحرك للأطوار)
            _buildAnimatedCyclesMarqueeBanner(),
            const SizedBox(height: 20),

            // 6. Next Session Hero Card (بطاقة الحصة القادمة)
            if (nextSession != null) ...[
              _buildNextSessionHeroCard(context, nextSession),
              const SizedBox(height: 20),
            ] else ...[
              _buildNoActiveSessionCard(context),
              const SizedBox(height: 20),
            ],

            // 7. Today's Master Schedule with Alarms & Notifications (جدول اليوم مع التنبيهات)
            _buildTodayScheduleCard(context),
            const SizedBox(height: 20),

            // 8. Subscriptions & Credit Ledger Summary (اشتراكاتي ورصيدي)
            _buildSubscriptionsSummary(subscriptions),
            const SizedBox(height: 20),

            // 9. Algerian National Exam Bank & Timed Simulations
            _buildExamBankBento(),
            const SizedBox(height: 20),

            // 10. Recent Protected Recordings (آخر التسجيلات)
            _buildRecentRecordingsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeBar(BuildContext context, StudentProfile student) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(2.5),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [_brightCyan, _electricPurple],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: _brightCyan.withValues(alpha: 0.35),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: CircleAvatar(
                radius: 22,
                backgroundColor: const Color(0xFF0F172A),
                child: Text(
                  student.name.isNotEmpty ? student.name[0].toUpperCase() : 'S',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'مرحباً، ${student.name.split(' ').first} 👋',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'منظومتك التعليمية الذكية • Pindo Future',
                  style: TextStyle(color: Colors.white60, fontSize: 11.5),
                ),
              ],
            ),
          ],
        ),
        Row(
          children: [
            // Cohort Chats Icon
            Stack(
              clipBehavior: Clip.none,
              children: [
                IconButton(
                  tooltip: 'محادثات الأفواج والرسائل',
                  icon: const Icon(Icons.forum_outlined, color: Colors.white, size: 21),
                  onPressed: () => CohortChatsHubModal.show(
                    context,
                    currentUserName: student.name,
                    currentUserRole: 'student',
                  ),
                ),
                Positioned(
                  top: 7,
                  right: 7,
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: const BoxDecoration(
                      color: _brightCyan,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(minWidth: 14, minHeight: 14),
                    child: Text(
                      '${CohortChatService().getTotalUnreadCount()}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color(0xFF070B14),
                        fontSize: 8.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            IconButton(
              icon: const Icon(Icons.settings_outlined, color: Colors.white70, size: 20),
              onPressed: widget.onOpenAccountSettings,
            ),
          ],
        ),
      ],
    );
  }

  // 1. Teacher Stories Tray (شريط القصص والبيانات الرسمية)
  Widget _buildTeacherStoriesTray() {
    final teachersWithStories = [
      {'name': 'منصة Pindo Future الرسمية', 'shortName': 'إعلانات المنصة', 'subject': 'قناة الإدارة الرسمية', 'avatar': 'P', 'hasLive': false},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.auto_stories_rounded, color: _brightCyan, size: 16),
            SizedBox(width: 6),
            Text(
              'قصص ومستجدات الأساتذة (Teacher Stories)',
              style: TextStyle(color: Colors.white, fontSize: 13.5, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 94,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: teachersWithStories.length,
            itemBuilder: (context, index) {
              final t = teachersWithStories[index];
              final hasLive = t['hasLive'] as bool;

              return Padding(
                padding: const EdgeInsets.only(left: 14),
                child: InkWell(
                  onTap: () => _openTeacherStory(t['name'] as String, t['subject'] as String),
                  borderRadius: BorderRadius.circular(36),
                  child: Column(
                    children: [
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(2.5),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: hasLive
                                    ? [const Color(0xFFEF4444), const Color(0xFFF59E0B)]
                                    : [_brightCyan, _electricPurple],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: (hasLive ? const Color(0xFFEF4444) : _brightCyan).withValues(alpha: 0.40),
                                  blurRadius: 8,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                            child: CircleAvatar(
                              radius: 26,
                              backgroundColor: const Color(0xFF0F172A),
                              child: Text(
                                t['avatar'] as String,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                          if (hasLive)
                            Positioned(
                              bottom: -2,
                              left: 0,
                              right: 0,
                              child: Center(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEF4444),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Text(
                                    'LIVE 🔴',
                                    style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      SizedBox(
                        width: 68,
                        child: Text(
                          t['shortName'] as String,
                          style: const TextStyle(color: Colors.white70, fontSize: 11),
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // 2. Quick Live Join Bar (خانة وضع رابط اللايف للطلبة الجدد)
  Widget _buildQuickLiveJoinBar() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF7F1D1D).withValues(alpha: 0.35),
            const Color(0xFF0F172A).withValues(alpha: 0.85),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFEF4444).withValues(alpha: 0.40)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.sensors, color: Color(0xFFEF4444), size: 18),
              SizedBox(width: 8),
              Text(
                'الانضمام السريع لحصة تفاعلية مباشرة 🔴',
                style: TextStyle(color: Colors.white, fontSize: 13.5, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'للطلبة الجدد: ضع رابط الحصة أو رمز الدخول (SES_XXXX) للانضمام فوراً للبث.',
            style: TextStyle(color: Colors.white60, fontSize: 11),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 42,
                  child: TextField(
                    controller: _quickJoinController,
                    style: const TextStyle(color: Colors.white, fontSize: 12.5),
                    decoration: InputDecoration(
                      hintText: 'SES_8PP4LVG1 أو رابط الحصة...',
                      hintStyle: const TextStyle(color: Colors.white38, fontSize: 11.5),
                      prefixIcon: const Icon(Icons.link_rounded, color: Colors.white54, size: 18),
                      filled: true,
                      fillColor: const Color(0xFF070B14),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.15)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.15)),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                height: 42,
                child: ElevatedButton.icon(
                  onPressed: _submitQuickLiveJoin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEF4444),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  icon: const Icon(Icons.play_arrow, size: 16),
                  label: const Text('دخول الحصة', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 3. Smart Teacher Search Bar (شريط البحث عن الأساتذة)
  Widget _buildTeacherSearchBar() {
    final chips = ['الكل 🌐', 'الرياضيات 📐', 'الفيزياء ⚡', 'العلوم 🔬', 'الفلسفة 📖', 'اللغات 🌍'];

    final teachersDirectory = <Map<String, String>>[];

    final matchingTeachers = teachersDirectory.where((t) {
      if (_selectedSearchChip == 1 && !t['subject']!.contains('الرياضيات')) return false;
      if (_selectedSearchChip == 2 && !t['subject']!.contains('الفيزياء')) return false;
      if (_selectedSearchChip == 3 && !t['subject']!.contains('العلوم')) return false;
      if (_selectedSearchChip == 4 && !t['subject']!.contains('الفلسفة')) return false;
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        final nameMatches = t['name']!.toLowerCase().contains(q);
        final subjectMatches = t['subject']!.toLowerCase().contains(q);
        return nameMatches || subjectMatches;
      }
      return true;
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.search_rounded, color: _brightCyan, size: 16),
            SizedBox(width: 6),
            Text(
              'البحث عن الأساتذة والمواد الدراسية',
              style: TextStyle(color: Colors.white, fontSize: 13.5, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 42,
          child: TextField(
            controller: _searchTeacherController,
            onChanged: (val) => setState(() => _searchQuery = val.trim()),
            style: const TextStyle(color: Colors.white, fontSize: 12.5),
            decoration: InputDecoration(
              hintText: 'ابحث عن أستاذ معتمد، مادة دراسية، أو شعبة...',
              hintStyle: const TextStyle(color: Colors.white38, fontSize: 11.5),
              prefixIcon: const Icon(Icons.search, color: _brightCyan, size: 18),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, color: Colors.white54, size: 16),
                      onPressed: () {
                        _searchTeacherController.clear();
                        setState(() => _searchQuery = '');
                      },
                    )
                  : null,
              filled: true,
              fillColor: const Color(0xFF0F172A).withValues(alpha: 0.8),
              contentPadding: const EdgeInsets.symmetric(horizontal: 10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.12)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.12)),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),

        // Filter chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: List.generate(chips.length, (idx) {
              final isSelected = _selectedSearchChip == idx;
              return Padding(
                padding: const EdgeInsets.only(left: 6),
                child: FilterChip(
                  label: Text(
                    chips[idx],
                    style: TextStyle(
                      color: isSelected ? const Color(0xFF070B14) : Colors.white70,
                      fontSize: 10.5,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  selected: isSelected,
                  onSelected: (_) => setState(() => _selectedSearchChip = idx),
                  backgroundColor: Colors.white.withValues(alpha: 0.05),
                  selectedColor: _brightCyan,
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  side: BorderSide(
                    color: isSelected ? _brightCyan : Colors.white.withValues(alpha: 0.10),
                  ),
                ),
              );
            }),
          ),
        ),

        // If searching or filtering, show quick results
        if (_searchQuery.isNotEmpty || _selectedSearchChip != 0) ...[
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _brightCyan.withValues(alpha: 0.25)),
            ),
            child: matchingTeachers.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        'لا توجد نتائج مطابقة لمعايير البحث حالياً.',
                        style: TextStyle(color: Colors.white60, fontSize: 12),
                      ),
                    ),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'نتائج البحث المطابقة (${matchingTeachers.length} أستاذ):',
                        style: const TextStyle(color: Colors.white70, fontSize: 11),
                      ),
                      const SizedBox(height: 6),
                      ...matchingTeachers.map((t) => Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 14,
                                      backgroundColor: _electricPurple.withValues(alpha: 0.3),
                                      child: Text(t['name']!.isNotEmpty ? t['name']![0] : 'أ', style: const TextStyle(color: Colors.white, fontSize: 11)),
                                    ),
                                    const SizedBox(width: 8),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(t['name'] ?? '', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                                        Text('${t['subject']} • خبرة ${t['exp']}', style: const TextStyle(color: Colors.white54, fontSize: 10)),
                                      ],
                                    ),
                                  ],
                                ),
                                OutlinedButton(
                                  onPressed: () {
                                    if (widget.onOpenTeacherShowcase != null) {
                                      widget.onOpenTeacherShowcase!(t['id']!);
                                    } else {
                                      _openTeacherStory(t['name']!, t['subject']!);
                                    }
                                  },
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: _brightCyan,
                                    side: const BorderSide(color: _brightCyan),
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    minimumSize: Size.zero,
                                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                                  ),
                                  child: const Text('الملف والأفواج', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                          )),
                    ],
                  ),
          ),
        ],
      ],
    );
  }

  // 4. Animated Educational Cycles Promotional Marquee Banner (شريط ترويجي متحرك للأطوار)
  Widget _buildAnimatedCyclesMarqueeBanner() {
    final cycle = _educationalCycles[_activeCycleIndex];
    final color = cycle['color'] as Color;

    return InkWell(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تم اختيار: ${cycle['title']}. يتم عرض البرامج المخصصة لهذا الطور.'),
            backgroundColor: const Color(0xFF0F172A),
            duration: const Duration(seconds: 2),
          ),
        );
      },
      borderRadius: BorderRadius.circular(18),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              color.withValues(alpha: 0.22),
              const Color(0xFF0F172A).withValues(alpha: 0.85),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: color.withValues(alpha: 0.45), width: 1.2),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.15),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.25),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(cycle['icon'] as IconData, color: color, size: 18),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      cycle['title'] as String,
                      style: const TextStyle(color: Colors.white, fontSize: 14.5, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.20),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: color, width: 0.8),
                  ),
                  child: Text(
                    cycle['badge'] as String,
                    style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              cycle['subtitle'] as String,
              style: const TextStyle(color: Colors.white70, fontSize: 11.5, height: 1.35),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  cycle['stats'] as String,
                  style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold),
                ),
                Row(
                  children: List.generate(_educationalCycles.length, (i) {
                    final isCurrent = i == _activeCycleIndex;
                    return Container(
                      margin: const EdgeInsets.only(left: 4),
                      width: isCurrent ? 16 : 6,
                      height: 5,
                      decoration: BoxDecoration(
                        color: isCurrent ? color : Colors.white24,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 5. No Active Live Session Placeholder Card
  Widget _buildNoActiveSessionCard(BuildContext context) {
    return GlassmorphicContainer(
      borderRadius: BorderRadius.circular(22),
      blurSigma: 16.0,
      borderWidth: 1.2,
      borderColor: Colors.white.withValues(alpha: 0.12),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          const Color(0xFF0F172A).withValues(alpha: 0.85),
          const Color(0xFF1E293B).withValues(alpha: 0.65),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _brightCyan.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.school_outlined, color: _brightCyan, size: 24),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'لا توجد حصة مباشرة نشطة الآن',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                ),
                SizedBox(height: 3),
                Text(
                  'راجع جدول مواعيد حصص اليوم، أو تصفح الأفواج الدراسية المتاحة للانضمام.',
                  style: TextStyle(color: Colors.white60, fontSize: 11.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 5. Next Session Hero Card
  Widget _buildNextSessionHeroCard(BuildContext context, StudentNextSession session) {
    final bool isLive = session.isLive;

    return GlassmorphicContainer(
      borderRadius: BorderRadius.circular(22),
      blurSigma: 18.0,
      borderWidth: 1.4,
      borderColor: isLive ? const Color(0xFFEF4444).withValues(alpha: 0.6) : _brightCyan.withValues(alpha: 0.4),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          isLive
              ? const Color(0xFF7F1D1D).withValues(alpha: 0.85)
              : _deepIndigo.withValues(alpha: 0.85),
          const Color(0xFF1E1B4B).withValues(alpha: 0.70),
          const Color(0xFF0F172A).withValues(alpha: 0.90),
        ],
      ),
      boxShadow: [
        BoxShadow(
          color: isLive ? const Color(0xFFEF4444).withValues(alpha: 0.3) : _brightCyan.withValues(alpha: 0.2),
          blurRadius: 24,
          offset: const Offset(0, 8),
        ),
      ],
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: isLive
                      ? const Color(0xFFEF4444).withValues(alpha: 0.25)
                      : _brightCyan.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isLive ? const Color(0xFFEF4444) : _brightCyan,
                    width: 1.2,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: isLive ? const Color(0xFFEF4444) : _brightCyan,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isLive ? 'الحصة بدأت الآن (بث حي)' : 'الحصة القادمة 🎥',
                      style: TextStyle(
                        color: isLive ? const Color(0xFFFCA5A5) : _brightCyan,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                isLive ? '🔴 LIVE' : 'اليوم 18:00',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          Text(
            session.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.bold,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.school_outlined, color: _brightCyan, size: 15),
              const SizedBox(width: 6),
              Text(
                '${session.subject} • ${session.teacherName}',
                style: const TextStyle(color: Colors.white70, fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.groups_outlined, color: Color(0xFF10B981), size: 15),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  session.cohortName,
                  style: const TextStyle(color: Colors.white60, fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          ElevatedButton(
            onPressed: () => widget.onJoinLiveClassroom(session.sessionId),
            style: ElevatedButton.styleFrom(
              backgroundColor: isLive ? const Color(0xFFEF4444) : _brightCyan,
              foregroundColor: isLive ? Colors.white : const Color(0xFF070B14),
              padding: const EdgeInsets.symmetric(vertical: 13),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              elevation: 4,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isLive ? Icons.sensors_rounded : Icons.login_rounded,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  isLive ? 'ادخل إلى الحصة الآن 🔴' : 'تفاصيل ودخول الحصة',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: () => CohortChatRoomModal.show(
              context,
              cohortId: session.sessionId,
              cohortName: session.cohortName,
              academicLevel: 'ثالثة ثانوي',
              currentUserName: widget.dashboardData.student.name,
              currentUserRole: 'student',
            ),
            icon: const Icon(Icons.forum_outlined, size: 16, color: _brightCyan),
            label: const Text(
              'محادثة ودردشة هذا الفوج 💬',
              style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
            ),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: Colors.white.withValues(alpha: 0.25)),
              backgroundColor: Colors.white.withValues(alpha: 0.05),
              padding: const EdgeInsets.symmetric(vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }

  // 6. Subscriptions & Credit Ledger Summary
  Widget _buildSubscriptionsSummary(StudentSubscriptionSummary subs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'اشتراكاتي ورصيدي',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: widget.onManageSubscriptions,
              style: TextButton.styleFrom(
                foregroundColor: _brightCyan,
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text('إدارة الاشتراك ←', style: TextStyle(fontSize: 12)),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            // Card 1: Remaining Credits
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: _brightCyan.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.confirmation_num_outlined, color: _brightCyan, size: 16),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'رصيد الحصص',
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '${subs.remainingCredits} حصص',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'متبقية في الباقة الحالية',
                      style: TextStyle(color: Color(0xFF10B981), fontSize: 11, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Card 2: Library Status
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981).withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.video_library_rounded, color: Color(0xFF10B981), size: 16),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'المكتبة المحمية',
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'متاحة ✓',
                      style: TextStyle(
                        color: Color(0xFF10B981),
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'وصول للتسجيلات والمذكرات',
                      style: TextStyle(color: Colors.white54, fontSize: 10.5),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // 7. Today's Master Schedule with Alarms & Notifications (جدول اليوم مع التنبيهات)
  Widget _buildTodayScheduleCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A).withValues(alpha: 0.70),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.calendar_today_rounded, color: _electricPurple, size: 18),
                  SizedBox(width: 8),
                  Text(
                    'جدول اليوم والرزنامة الأساسية',
                    style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              TextButton(
                onPressed: widget.onOpenWeeklySchedule,
                style: TextButton.styleFrom(
                  foregroundColor: _brightCyan,
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text('البرنامج الأسبوعي ←', style: TextStyle(fontSize: 12)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (widget.dashboardData.todaySchedule.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.event_available_outlined, color: Colors.white.withValues(alpha: 0.35), size: 32),
                    const SizedBox(height: 8),
                    const Text(
                      'لا توجد حصص مبرمجة لليوم في أفواجك',
                      style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'تفقد البرنامج الأسبوعي أو تصفح الأفواج المتاحة للاشتراك',
                      style: TextStyle(color: Colors.white38, fontSize: 11),
                    ),
                  ],
                ),
              ),
            )
          else
            ...widget.dashboardData.todaySchedule.map((item) {
            final isLive = item.status == 'live';
            final hasAlarm = _enabledScheduleAlarms.contains(item.time);

            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isLive ? _brightCyan.withValues(alpha: 0.10) : Colors.white.withValues(alpha: 0.04),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isLive ? _brightCyan.withValues(alpha: 0.35) : Colors.white10,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: _electricPurple.withValues(alpha: 0.20),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        item.time,
                        style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.subject,
                            style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${item.teacher} • ${item.time}',
                            style: const TextStyle(color: Colors.white60, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                    if (isLive)
                      ElevatedButton(
                        onPressed: () => widget.onJoinLiveClassroom(widget.dashboardData.nextSession?.sessionId ?? 'SES_LIVE'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFEF4444),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                        ),
                        child: const Text('دخول الآن 🔴', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                      )
                    else
                      IconButton(
                        tooltip: hasAlarm ? 'التنبيه مفعّل' : 'تفعيل التنبيه',
                        icon: Icon(
                          hasAlarm ? Icons.alarm_on : Icons.alarm_add_outlined,
                          color: hasAlarm ? const Color(0xFF34D399) : Colors.white60,
                          size: 20,
                        ),
                        onPressed: () => _toggleScheduleAlarm(item.time),
                      ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  // 8. Algerian National Exam Bank & Timed Simulations
  Widget _buildExamBankBento() {
    return BentoCard(
      isHero: true,
      title: 'بنك الامتحانات الرسمية والمحاكاة (BAC & BEM)',
      subtitle: 'تدرّب على مواضيع البكالوريا والتعليم المتوسط الرسمية (2008–2025) مع سلم التنقيط الوزاري ومحاكي الامتحانات الموقوت.',
      icon: Icons.history_edu_rounded,
      accentColor: const Color(0xFFF59E0B),
      secondaryAccent: const Color(0xFF10B981),
      badgeText: 'BEM & BAC 2008-2025',
      badgeColor: const Color(0xFFF59E0B),
      onTap: widget.onOpenExamBank,
    );
  }

  // 9. Recent Protected Recordings
  Widget _buildRecentRecordingsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.video_library_rounded, color: _brightCyan, size: 18),
            SizedBox(width: 8),
            Text(
              'آخر التسجيلات المتاحة لك',
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (widget.dashboardData.recentRecordings.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
            ),
            child: Center(
              child: Column(
                children: [
                  Icon(Icons.video_library_outlined, color: Colors.white.withValues(alpha: 0.35), size: 30),
                  const SizedBox(height: 8),
                  const Text(
                    'لا توجد تسجيلات متوفرة حالياً',
                    style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'سيتم حفظ وأرشفة تسجيلات حصصك التفاعلية هنا تلقائياً بعد انتهائها',
                    style: TextStyle(color: Colors.white38, fontSize: 11),
                  ),
                ],
              ),
            ),
          )
        else
          ...widget.dashboardData.recentRecordings.map((rec) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: InkWell(
              onTap: () => widget.onOpenRecording(rec.id),
              borderRadius: BorderRadius.circular(14),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: _brightCyan.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.play_arrow_rounded, color: _brightCyan, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            rec.title,
                            style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 3),
                          Text(
                            '${rec.subject} • ${rec.teacherName} • ${rec.durationMinutes} دقيقة',
                            style: const TextStyle(color: Colors.white60, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios, color: Colors.white38, size: 12),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}
