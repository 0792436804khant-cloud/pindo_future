import 'package:flutter/material.dart';
import 'package:pindo_future_mobile/features/courses/presentation/widgets/academic_explorer_widget.dart';
import 'package:pindo_future_mobile/core/widgets/bento_card.dart';

class StudentExploreTab extends StatefulWidget {
  final Function(String teacherId) onOpenTeacherShowcase;
  final Function(String sessionId) onJoinLiveClassroom;
  final VoidCallback onOpenCohortsExplorer;

  const StudentExploreTab({
    super.key,
    required this.onOpenTeacherShowcase,
    required this.onJoinLiveClassroom,
    required this.onOpenCohortsExplorer,
  });

  @override
  State<StudentExploreTab> createState() => _StudentExploreTabState();
}

class _StudentExploreTabState extends State<StudentExploreTab> {
  final _searchController = TextEditingController();
  static const Color _brightCyan = Color(0xFF00E5FF);
  static const Color _electricPurple = Color(0xFF7C4DFF);

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 90),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Title
          const Text(
            'استكشف الأساتذة والأفواج الدراسية 🔍',
            style: TextStyle(
              color: Colors.white,
              fontSize: 19,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'ابحث عن أساتذة معتمدين، تصفح برامج الأطوار التعليمية، واشترك في أفواج البكالوريا والمتوسط.',
            style: TextStyle(color: Colors.white60, fontSize: 12, height: 1.4),
          ),
          const SizedBox(height: 16),

          // Search Bar
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
            ),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.white, fontSize: 13.5),
              decoration: InputDecoration(
                hintText: 'ابحث باسم الأستاذ، المادة، أو الشعبة (مثلاً: Alan Turing, رياضيات)...',
                hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.35), fontSize: 12.5),
                prefixIcon: const Icon(Icons.search, color: _brightCyan, size: 20),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
              onSubmitted: (query) {
                if (query.trim().isNotEmpty) {
                  widget.onOpenTeacherShowcase(query.trim());
                }
              },
            ),
          ),
          const SizedBox(height: 20),

          // Algerian Study Cohorts Banner (أفواج البكالوريا والمتوسط)
          BentoCard(
            isHero: true,
            title: 'أفواج البكالوريا والتعليم المتوسط (BAC & BEM 2026)',
            subtitle: 'انضم إلى أفواج النخبة لشعبتك (علوم، رياضيات، تقني رياضي، آداب) مع أساتذة معتمدين في 58 ولاية.',
            icon: Icons.groups_rounded,
            accentColor: const Color(0xFF10B981),
            secondaryAccent: _brightCyan,
            badgeText: '58 ولاية',
            badgeColor: const Color(0xFF10B981),
            onTap: widget.onOpenCohortsExplorer,
          ),
          const SizedBox(height: 22),

          // Academic Explorer Widget (Level -> Year -> Subject -> Teachers)
          Row(
            children: [
              Container(
                width: 4,
                height: 18,
                decoration: BoxDecoration(
                  color: _brightCyan,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'المستكشف الأكاديمي الجزائري',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          AcademicExplorerWidget(
            onOpenTeacherShowcase: widget.onOpenTeacherShowcase,
            onJoinLiveClassroom: widget.onJoinLiveClassroom,
          ),
        ],
      ),
    );
  }
}
