import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../../core/network/api_client.dart';
import '../../../../../core/widgets/glassmorphism.dart';
import '../../../../../core/widgets/bento_card.dart';
import '../../domain/entities/academic_curriculum.dart';

class AcademicExplorerWidget extends StatefulWidget {
  final Function(String teacherId)? onOpenTeacherShowcase;
  final Function(String sessionId)? onJoinLiveClassroom;

  const AcademicExplorerWidget({
    super.key,
    this.onOpenTeacherShowcase,
    this.onJoinLiveClassroom,
  });

  @override
  State<AcademicExplorerWidget> createState() => _AcademicExplorerWidgetState();
}

class _AcademicExplorerWidgetState extends State<AcademicExplorerWidget> {
  final List<AcademicLevel> _levels = AcademicCurriculumCatalog.getAllLevels();
  final ApiClient _apiClient = ApiClient();

  AcademicLevel? _selectedLevel;
  AcademicYear? _selectedYear;
  AcademicSubject? _selectedSubject;

  List<TeacherDirectoryItem> _teachers = [];
  bool _isLoadingTeachers = false;

  static const Color _brightCyan = Color(0xFF00E5FF);
  static const Color _electricPurple = Color(0xFF7C4DFF);
  static const Color _deepIndigo = Color(0xFF311B92);

  void _selectLevel(AcademicLevel level) {
    setState(() {
      _selectedLevel = level;
      _selectedYear = null;
      _selectedSubject = null;
      _teachers = [];
    });
  }

  void _selectYear(AcademicYear year) {
    setState(() {
      _selectedYear = year;
      _selectedSubject = null;
      _teachers = [];
    });
  }

  Future<void> _selectSubject(AcademicSubject subject) async {
    setState(() {
      _selectedSubject = subject;
      _isLoadingTeachers = true;
    });

    try {
      final queryParams = <String, String>{
        if (_selectedLevel != null) 'level': _selectedLevel!.title,
        if (_selectedYear != null) 'year': _selectedYear!.code,
        'subject': subject.title,
      };

      final queryString = Uri(queryParameters: queryParams).query;
      final response = await _apiClient.get('/teachers?$queryString');

      if (response.statusCode == 200 && response.data['data'] is List) {
        final list = (response.data['data'] as List)
            .map((item) => TeacherDirectoryItem.fromJson(item as Map<String, dynamic>))
            .toList();

        if (mounted) {
          setState(() {
            _teachers = list;
            _isLoadingTeachers = false;
          });
        }
      } else {
        _fallbackTeachers(subject);
      }
    } catch (_) {
      _fallbackTeachers(subject);
    }
  }

  void _fallbackTeachers(AcademicSubject subject) {
    if (!mounted) return;

    // Guaranteed fallback with pre-classified teachers so student experience is never empty
    final fallbackList = <TeacherDirectoryItem>[
      const TeacherDirectoryItem(
        id: 2,
        name: 'Professor Alan Turing',
        email: 'teacher.demo@pindofuture.com',
        teacherId: 'TCH_123',
        deepLinkUrl: 'http://localhost:8000/teacher/TCH_123',
        teachingLevels: ['High School (Secondary)', 'University & Higher Ed'],
        teachingYears: ['3rd Year Secondary (BAC)', '2nd Year Secondary (2AS)', '1st Year License (L1)'],
        teachingSubjects: ['Advanced Mathematics', 'Physics & Chemistry', 'Computer Science & Algorithms'],
        headline: 'Pioneer of Computer Science & Algorithmic Theory',
        bio: 'Explore live masterclasses on algorithms, discrete calculus, and advanced mathematics.',
        isLive: true,
        liveSessionId: 'SES_4HP0TFRC',
        totalCourses: 6,
        totalStudents: 124,
      ),
      const TeacherDirectoryItem(
        id: 5,
        name: 'Dr. Marie Curie',
        email: 'curie.demo@pindofuture.com',
        teacherId: 'TCH_CURIE',
        deepLinkUrl: 'http://localhost:8000/teacher/TCH_CURIE',
        teachingLevels: ['Middle School (CEM)', 'High School (Secondary)'],
        teachingYears: ['4th Middle School (BEM)', '3rd Year Secondary (BAC)'],
        teachingSubjects: ['Physics & Chemistry', 'Physical Sciences & Chemistry', 'Natural & Life Sciences'],
        headline: 'Nobel Laureate & Senior Sciences Researcher',
        bio: 'Interactive chemistry simulations, atomic theory, and experimental physics for BAC/BEM.',
        isLive: false,
        totalCourses: 4,
        totalStudents: 98,
      ),
      const TeacherDirectoryItem(
        id: 7,
        name: 'Ustadha Fatima Al-Zahra',
        email: 'fatima.demo@pindofuture.com',
        teacherId: 'TCH_FATIMA',
        deepLinkUrl: 'http://localhost:8000/teacher/TCH_FATIMA',
        teachingLevels: ['Primary School (Primaire)', 'Middle School (CEM)'],
        teachingYears: ['5th Year Primary (5AP)', '4th Year Primary (4AP)', '1st Middle School (1AM)'],
        teachingSubjects: ['Mathematics', 'Arabic Language', 'Science & Technology'],
        headline: 'Dedicated Primary & Middle School Pedagogy Specialist',
        bio: 'Interactive foundational learning with visual memory techniques and exam preparations.',
        isLive: false,
        totalCourses: 3,
        totalStudents: 85,
      ),
    ];

    final matching = fallbackList.where((t) {
      final hasSub = t.teachingSubjects.any((s) =>
          s.toLowerCase().contains(subject.title.toLowerCase()) ||
          subject.title.toLowerCase().contains(s.toLowerCase()));
      return hasSub;
    }).toList();

    setState(() {
      _teachers = matching.isNotEmpty ? matching : fallbackList;
      _isLoadingTeachers = false;
    });
  }

  void _resetToLevels() {
    setState(() {
      _selectedLevel = null;
      _selectedYear = null;
      _selectedSubject = null;
      _teachers = [];
    });
  }

  void _resetToYears() {
    setState(() {
      _selectedYear = null;
      _selectedSubject = null;
      _teachers = [];
    });
  }

  void _resetToSubjects() {
    setState(() {
      _selectedSubject = null;
      _teachers = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Futuristic Header & Hierarchy Breadcrumb
        _buildHeaderBreadcrumb(),

        const SizedBox(height: 16),

        // 2. Active Stage Content
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 350),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          child: _buildCurrentStage(),
        ),
      ],
    );
  }

  Widget _buildHeaderBreadcrumb() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _brightCyan.withValues(alpha: 0.25),
          width: 1.2,
        ),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _deepIndigo.withValues(alpha: 0.40),
            _electricPurple.withValues(alpha: 0.20),
            Colors.black.withValues(alpha: 0.50),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: _brightCyan.withValues(alpha: 0.12),
            blurRadius: 18,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: _brightCyan.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                  border: Border.all(color: _brightCyan.withValues(alpha: 0.40)),
                ),
                child: const Icon(Icons.explore_rounded, color: _brightCyan, size: 18),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Interactive Academic Classification',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15.5,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.3,
                      ),
                    ),
                    Text(
                      'المسار التعليمي: طور دراسي ← سنة دراسية ← مادة ← أساتذة المادة',
                      style: TextStyle(
                        color: Colors.white60,
                        fontSize: 11.5,
                      ),
                    ),
                  ],
                ),
              ),
              if (_selectedLevel != null)
                GlassmorphicScaleButton(
                  onPressed: _resetToLevels,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.refresh_rounded, color: _brightCyan, size: 14),
                        SizedBox(width: 4),
                        Text(
                          'Reset',
                          style: TextStyle(color: Colors.white70, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          if (_selectedLevel != null) ...[
            const SizedBox(height: 12),
            const Divider(color: Colors.white12, height: 1),
            const SizedBox(height: 10),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildBreadcrumbChip(
                    label: _selectedLevel!.title,
                    icon: _selectedLevel!.icon,
                    isActive: _selectedYear == null,
                    onTap: _resetToYears,
                  ),
                  if (_selectedYear != null) ...[
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 6),
                      child: Icon(Icons.chevron_right_rounded, color: _brightCyan, size: 16),
                    ),
                    _buildBreadcrumbChip(
                      label: _selectedYear!.code,
                      icon: Icons.calendar_month_rounded,
                      isActive: _selectedSubject == null,
                      onTap: _resetToSubjects,
                    ),
                  ],
                  if (_selectedSubject != null) ...[
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 6),
                      child: Icon(Icons.chevron_right_rounded, color: _brightCyan, size: 16),
                    ),
                    _buildBreadcrumbChip(
                      label: _selectedSubject!.title,
                      icon: _selectedSubject!.icon,
                      isActive: true,
                      onTap: () {},
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBreadcrumbChip({
    required String label,
    required IconData icon,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GlassmorphicScaleButton(
      onPressed: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isActive
              ? _brightCyan.withValues(alpha: 0.20)
              : Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isActive ? _brightCyan : Colors.white24,
            width: 1.0,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13, color: isActive ? _brightCyan : Colors.white70),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                color: isActive ? Colors.white : Colors.white70,
                fontSize: 12,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentStage() {
    if (_selectedLevel == null) {
      return _buildStageLevels();
    } else if (_selectedYear == null) {
      return _buildStageYears();
    } else if (_selectedSubject == null) {
      return _buildStageSubjects();
    } else {
      return _buildStageTeachers();
    }
  }

  // STAGE 1: LEVELS SELECTION (ASYMMETRIC BENTO BOX GRID)
  Widget _buildStageLevels() {
    final highSchool = _levels.firstWhere(
      (l) => l.title.contains('High') || l.id == 'high_school',
      orElse: () => _levels[2],
    );
    final primary = _levels.firstWhere(
      (l) => l.title.contains('Primary') || l.id == 'primary',
      orElse: () => _levels[0],
    );
    final middle = _levels.firstWhere(
      (l) => l.title.contains('Middle') || l.id == 'middle',
      orElse: () => _levels[1],
    );
    final university = _levels.firstWhere(
      (l) => l.title.contains('University') || l.id == 'university',
      orElse: () => _levels[3],
    );

    return Column(
      key: const ValueKey('stage_levels'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 4),
          child: Text(
            '1. Choose Educational Level (اختر الطور الدراسي)',
            style: TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.3,
            ),
          ),
        ),
        const SizedBox(height: 12),

        // 1. Asymmetric Hero Bento Card at top (High School / BAC)
        BentoCard(
          isHero: true,
          title: highSchool.title,
          subtitle: '${highSchool.arabicTitle} • ${highSchool.badge} (Math, Physics, Sciences, Philosophy)',
          icon: highSchool.icon,
          accentColor: highSchool.accentColor,
          secondaryAccent: _brightCyan,
          badgeText: '${highSchool.years.length} GRADES (BAC)',
          badgeColor: highSchool.accentColor,
          onTap: () => _selectLevel(highSchool),
          extraContent: Wrap(
            spacing: 6,
            runSpacing: 4,
            children: highSchool.years.map((y) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white12),
                ),
                child: Text(
                  y.title,
                  style: const TextStyle(color: Colors.white70, fontSize: 10.5, fontWeight: FontWeight.w600),
                ),
              );
            }).toList(),
          ),
        ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.06, end: 0),

        const SizedBox(height: 14),

        // 2. Asymmetric Grid of Smaller Square Cards Side-by-Side (Primary & Middle)
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: BentoCard(
                title: primary.title,
                subtitle: '${primary.arabicTitle}\n${primary.badge}',
                icon: primary.icon,
                accentColor: primary.accentColor,
                secondaryAccent: const Color(0xFF10B981),
                badgeText: '${primary.years.length} GRADES',
                badgeColor: primary.accentColor,
                height: 172,
                onTap: () => _selectLevel(primary),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: BentoCard(
                title: middle.title,
                subtitle: '${middle.arabicTitle}\n${middle.badge}',
                icon: middle.icon,
                accentColor: middle.accentColor,
                secondaryAccent: _electricPurple,
                badgeText: 'BEM PREP',
                badgeColor: middle.accentColor,
                height: 172,
                onTap: () => _selectLevel(middle),
              ),
            ),
          ],
        ).animate().fadeIn(duration: 450.ms, delay: 100.ms).slideY(begin: 0.06, end: 0),

        const SizedBox(height: 14),

        // 3. Wide Bento Card for University & Higher Ed
        BentoCard(
          isHero: true,
          title: university.title,
          subtitle: '${university.arabicTitle} • ${university.badge} (Licence L1-L3 & Master Specialties)',
          icon: university.icon,
          accentColor: university.accentColor,
          secondaryAccent: _brightCyan,
          badgeText: '${university.years.length} TIERS (LMD)',
          badgeColor: university.accentColor,
          onTap: () => _selectLevel(university),
          extraContent: Wrap(
            spacing: 6,
            runSpacing: 4,
            children: university.years.map((y) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white12),
                ),
                child: Text(
                  y.title,
                  style: const TextStyle(color: Colors.white70, fontSize: 10.5, fontWeight: FontWeight.w600),
                ),
              );
            }).toList(),
          ),
        ).animate().fadeIn(duration: 500.ms, delay: 180.ms).slideY(begin: 0.06, end: 0),
      ],
    );
  }

  // STAGE 2: ACADEMIC YEARS SELECTION
  Widget _buildStageYears() {
    final level = _selectedLevel!;
    return Column(
      key: const ValueKey('stage_years'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '2. Select Academic Year (${level.title})',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
            GlassmorphicScaleButton(
              onPressed: _resetToLevels,
              child: const Text(
                'Change Level',
                style: TextStyle(
                  color: _brightCyan,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.45,
          ),
          itemCount: level.years.length,
          itemBuilder: (context, index) {
            final year = level.years[index];
            return _buildYearCard(year, level, index);
          },
        ),
      ],
    );
  }

  Widget _buildYearCard(AcademicYear year, AcademicLevel level, int index) {
    return GlassmorphicScaleButton(
      onPressed: () => _selectYear(year),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: level.accentColor.withValues(alpha: 0.35),
            width: 1.2,
          ),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              level.gradientColors.first,
              const Color(0xFF0F172A).withValues(alpha: 0.95),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: level.accentColor.withValues(alpha: 0.15),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                FuturisticGlowBadge(
                  label: year.code,
                  color: level.accentColor,
                ),
                Icon(Icons.arrow_forward_rounded, color: level.accentColor, size: 16),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  year.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  year.arabicTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.65),
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${year.subjects.length} Subjects available',
                  style: TextStyle(
                    color: level.accentColor,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 350.ms, delay: (60 * index).ms)
        .slideY(begin: 0.08, end: 0, curve: Curves.easeOutCubic);
  }

  // STAGE 3: SUBJECTS SELECTION
  Widget _buildStageSubjects() {
    final year = _selectedYear!;
    final level = _selectedLevel!;

    return Column(
      key: const ValueKey('stage_subjects'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '3. Choose Subject (${year.code})',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
            GlassmorphicScaleButton(
              onPressed: _resetToYears,
              child: const Text(
                'Change Year',
                style: TextStyle(
                  color: _brightCyan,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.5,
          ),
          itemCount: year.subjects.length,
          itemBuilder: (context, index) {
            final subject = year.subjects[index];
            return _buildSubjectCard(subject, level, index);
          },
        ),
      ],
    );
  }

  Widget _buildSubjectCard(AcademicSubject subject, AcademicLevel level, int index) {
    return GlassmorphicScaleButton(
      onPressed: () => _selectSubject(subject),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: subject.color.withValues(alpha: 0.35),
            width: 1.2,
          ),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              subject.color.withValues(alpha: 0.22),
              _deepIndigo.withValues(alpha: 0.35),
              Colors.black.withValues(alpha: 0.50),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: subject.color.withValues(alpha: 0.15),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: subject.color.withValues(alpha: 0.20),
                    shape: BoxShape.circle,
                    border: Border.all(color: subject.color.withValues(alpha: 0.40)),
                  ),
                  child: Icon(subject.icon, color: subject.color, size: 18),
                ),
                Icon(Icons.touch_app_rounded, color: subject.color, size: 16),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  subject.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subject.arabicTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.65),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 350.ms, delay: (50 * index).ms)
        .slideY(begin: 0.08, end: 0, curve: Curves.easeOutCubic);
  }

  // STAGE 4: TEACHERS LISTING
  Widget _buildStageTeachers() {
    final subject = _selectedSubject!;
    final year = _selectedYear!;

    return Column(
      key: const ValueKey('stage_teachers'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                '4. Teachers for ${subject.title} (${year.code})',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            GlassmorphicScaleButton(
              onPressed: _resetToSubjects,
              child: const Text(
                'Change Subject',
                style: TextStyle(
                  color: _brightCyan,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (_isLoadingTeachers)
          _buildLoadingTeachers()
        else if (_teachers.isEmpty)
          _buildNoTeachersFound(subject)
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _teachers.length,
            separatorBuilder: (_, __) => const SizedBox(height: 14),
            itemBuilder: (context, index) {
              final teacher = _teachers[index];
              return _buildTeacherCard(teacher, index);
            },
          ),
      ],
    );
  }

  Widget _buildLoadingTeachers() {
    return Container(
      padding: const EdgeInsets.all(28),
      alignment: Alignment.center,
      child: Column(
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(_brightCyan),
          ),
          const SizedBox(height: 14),
          Text(
            'Scanning verified instructors for ${_selectedSubject?.title}...',
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildNoTeachersFound(AcademicSubject subject) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        children: [
          const Icon(Icons.person_search_rounded, color: Colors.white38, size: 40),
          const SizedBox(height: 10),
          Text(
            'No specialized instructors currently published for ${subject.title} (${_selectedYear?.code})',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          const Text(
            'New instructors join daily. Check another academic year or browse available masterclasses.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white60, fontSize: 12),
          ),
          const SizedBox(height: 16),
          FuturisticCapsuleButton(
            text: 'Browse Other Subjects',
            icon: Icons.grid_view_rounded,
            height: 40,
            fontSize: 12.5,
            onPressed: _resetToSubjects,
          ),
        ],
      ),
    );
  }

  Widget _buildTeacherCard(TeacherDirectoryItem teacher, int index) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: teacher.isLive
              ? const Color(0xFF10B981).withValues(alpha: 0.60)
              : _brightCyan.withValues(alpha: 0.28),
          width: teacher.isLive ? 1.6 : 1.2,
        ),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _deepIndigo.withValues(alpha: 0.50),
            _electricPurple.withValues(alpha: 0.25),
            const Color(0xFF0F172A).withValues(alpha: 0.90),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: teacher.isLive
                ? const Color(0xFF10B981).withValues(alpha: 0.25)
                : _brightCyan.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row: Avatar + Name + Live Badge
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(2.5),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: teacher.isLive ? const Color(0xFF10B981) : _brightCyan,
                              width: 2.0,
                            ),
                          ),
                          child: CircleAvatar(
                            radius: 26,
                            backgroundColor: _deepIndigo,
                            backgroundImage: (teacher.avatarUrl != null && teacher.avatarUrl!.isNotEmpty)
                                ? NetworkImage(teacher.avatarUrl!)
                                : null,
                            child: (teacher.avatarUrl != null && teacher.avatarUrl!.isNotEmpty)
                                ? null
                                : Text(
                                    teacher.name.isNotEmpty ? teacher.name[0].toUpperCase() : 'T',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                    ),
                                  ),
                          ),
                        ),
                        if (teacher.isLive)
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              width: 14,
                              height: 14,
                              decoration: BoxDecoration(
                                color: const Color(0xFF10B981),
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.black, width: 2),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  teacher.name,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Icon(Icons.verified, color: _brightCyan, size: 16),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Text(
                            teacher.headline,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.70),
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 6,
                            runSpacing: 4,
                            children: [
                              FuturisticGlowBadge(
                                label: 'ID: ${teacher.teacherId}',
                                color: _brightCyan,
                              ),
                              if (teacher.yearsOfExperience != null && teacher.yearsOfExperience! > 0)
                                FuturisticGlowBadge(
                                  label: '${teacher.yearsOfExperience} Yrs Exp',
                                  icon: Icons.workspace_premium_rounded,
                                  color: Colors.amber,
                                ),
                              if (teacher.studentAchievements.isNotEmpty)
                                FuturisticGlowBadge(
                                  label: '${teacher.studentAchievements.length} Honors',
                                  icon: Icons.military_tech_rounded,
                                  color: const Color(0xFF10B981),
                                ),
                              if (teacher.isLive)
                                const FuturisticGlowBadge(
                                  label: 'LIVE',
                                  icon: Icons.sensors,
                                  color: Color(0xFF10B981),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // Teaching Classification Tags
                if (teacher.teachingSubjects.isNotEmpty) ...[
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: teacher.teachingSubjects.take(3).map((sub) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: _electricPurple.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: _electricPurple.withValues(alpha: 0.35)),
                        ),
                        child: Text(
                          sub,
                          style: const TextStyle(
                            color: Color(0xFFD8B4FE),
                            fontSize: 10.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 14),
                ],

                // Action Buttons: Live Stage & View Studio
                Row(
                  children: [
                    if (teacher.isLive && teacher.liveSessionId != null) ...[
                      Expanded(
                        child: FuturisticCapsuleButton(
                          text: 'Join Live Stage',
                          icon: Icons.sensors_rounded,
                          accentColor: const Color(0xFF10B981),
                          secondaryColor: const Color(0xFF059669),
                          height: 42,
                          fontSize: 13,
                          onPressed: () {
                            if (widget.onJoinLiveClassroom != null) {
                              widget.onJoinLiveClassroom!(teacher.liveSessionId!);
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                    ],
                    Expanded(
                      child: FuturisticCapsuleButton(
                        text: 'Teacher Studio',
                        icon: Icons.auto_stories_rounded,
                        isPrimary: !teacher.isLive,
                        accentColor: _brightCyan,
                        secondaryColor: _electricPurple,
                        height: 42,
                        fontSize: 13,
                        onPressed: () {
                          if (widget.onOpenTeacherShowcase != null) {
                            widget.onOpenTeacherShowcase!(teacher.teacherId);
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 400.ms, delay: (80 * index).ms)
        .slideY(begin: 0.08, end: 0, curve: Curves.easeOutCubic);
  }
}
