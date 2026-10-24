import 'package:flutter/material.dart';
import '../../../../core/constants/algerian_education_constants.dart';
import '../../../../core/network/api_client.dart';
import '../../../auth/domain/entities/user.dart';
import '../../../library/data/datasources/library_remote_datasource.dart';
import '../../../library/data/repositories/library_repository_impl.dart';
import '../../../library/presentation/controllers/library_controller.dart';
import '../../../library/presentation/screens/cohort_library_screen.dart';
import '../../../teachers/presentation/widgets/teacher_verification_badge.dart';
import '../../domain/entities/study_cohort_entity.dart';
import '../controllers/cohort_controller.dart';

class StudentCohortExplorerScreen extends StatefulWidget {
  final User student;
  final CohortController cohortController;

  const StudentCohortExplorerScreen({
    super.key,
    required this.student,
    required this.cohortController,
  });

  @override
  State<StudentCohortExplorerScreen> createState() => _StudentCohortExplorerScreenState();
}

class _StudentCohortExplorerScreenState extends State<StudentCohortExplorerScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String? _selectedStream;
  String? _selectedLevel;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  void _loadData() {
    widget.cohortController.loadPublicCohorts(
      stream: _selectedStream,
      academicLevel: _selectedLevel,
      search: _searchController.text.trim().isEmpty ? null : _searchController.text.trim(),
    );

    if (widget.student.token != null) {
      widget.cohortController.loadStudentCohorts(widget.student.token!);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        elevation: 0,
        title: const Text(
          'الأفواج الدراسية - النظام الجزائري',
          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFF10B981),
          labelColor: const Color(0xFF10B981),
          unselectedLabelColor: Colors.white60,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          tabs: const [
            Tab(text: 'استكشاف المجموعات', icon: Icon(Icons.explore_outlined, size: 20)),
            Tab(text: 'أفواجي النشطة', icon: Icon(Icons.school_outlined, size: 20)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildExploreTab(context),
          _buildMyCohortsTab(context),
        ],
      ),
    );
  }

  Widget _buildExploreTab(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.cohortController,
      builder: (context, _) {
        final controller = widget.cohortController;

        return Column(
          children: [
            _buildSearchAndFilters(context),
            Expanded(
              child: controller.isLoading && controller.publicCohorts.isEmpty
                  ? const Center(child: CircularProgressIndicator(color: Color(0xFF10B981)))
                  : controller.publicCohorts.isEmpty
                      ? _buildNoResultsState(context)
                      : RefreshIndicator(
                          color: const Color(0xFF10B981),
                          onRefresh: () async => _loadData(),
                          child: ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: controller.publicCohorts.length,
                            itemBuilder: (context, index) {
                              return _buildPublicCohortCard(context, controller.publicCohorts[index]);
                            },
                          ),
                        ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSearchAndFilters(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: const Color(0xFF1E293B),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            style: const TextStyle(color: Colors.white, fontSize: 13),
            onSubmitted: (_) => _loadData(),
            decoration: InputDecoration(
              hintText: 'ابحث باسم الأستاذ، المادة، أو عنوان الفوج...',
              hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
              prefixIcon: const Icon(Icons.search, color: Color(0xFF10B981), size: 20),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, color: Colors.white54, size: 18),
                      onPressed: () {
                        _searchController.clear();
                        _loadData();
                      },
                    )
                  : null,
              filled: true,
              fillColor: const Color(0xFF0F172A),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
            ),
          ),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('الكل', _selectedStream == null, () {
                  setState(() => _selectedStream = null);
                  _loadData();
                }),
                ...AlgerianEducationConstants.secondaryStreams.map((st) {
                  final shortName = st.split(' (').first;
                  return _buildFilterChip(shortName, _selectedStream == shortName, () {
                    setState(() => _selectedStream = shortName);
                    _loadData();
                  });
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(left: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF10B981) : const Color(0xFF0F172A),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFF10B981) : Colors.white.withValues(alpha: 0.1),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.white70,
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildPublicCohortCard(BuildContext context, StudyCohortEntity cohort) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  cohort.name,
                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  cohort.formattedPrice,
                  style: const TextStyle(color: Color(0xFF10B981), fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.person, color: Colors.white70, size: 16),
              const SizedBox(width: 6),
              Text(
                cohort.teacherName ?? 'أستاذ المادة',
                style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
              ),
              const SizedBox(width: 6),
              TeacherVerificationBadge(
                isVerified: cohort.isTeacherVerified,
                size: 16,
              ),
              const Spacer(),
              if (cohort.teacherWilaya != null)
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined, color: Colors.white54, size: 14),
                    const SizedBox(width: 2),
                    Text(
                      cohort.wilayaName.split(' - ').last.split(' (').first,
                      style: const TextStyle(color: Colors.white60, fontSize: 11),
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              _buildSmallBadge(cohort.academicLevel, const Color(0xFF3B82F6)),
              if (cohort.stream != null) _buildSmallBadge(cohort.stream!, const Color(0xFF8B5CF6)),
              _buildSmallBadge(cohort.subject, const Color(0xFFEC4899)),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                cohort.isFull ? 'الفوج ممتلئ تماماً' : 'متبقي ${cohort.availableSeats} مقعد',
                style: TextStyle(
                  color: cohort.isFull ? const Color(0xFFEF4444) : const Color(0xFF10B981),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: cohort.isFull ? Colors.grey : const Color(0xFF10B981),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                icon: const Icon(Icons.group_add, size: 18),
                label: const Text('انضمام للفوج', style: TextStyle(fontWeight: FontWeight.bold)),
                onPressed: cohort.isFull
                    ? null
                    : () async {
                        if (widget.student.token != null) {
                          final success = await widget.cohortController.joinCohort(widget.student.token!, cohort.id);
                          if (success && context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('تم الانضمام إلى الفوج بنجاح! مرحباً بك 🎉'),
                                backgroundColor: Color(0xFF10B981),
                              ),
                            );
                            _tabController.animateTo(1);
                          }
                        }
                      },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMyCohortsTab(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.cohortController,
      builder: (context, _) {
        final controller = widget.cohortController;

        if (controller.isLoading && controller.studentCohorts.isEmpty) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFF10B981)));
        }

        if (controller.studentCohorts.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.school_outlined, size: 64, color: Colors.white.withValues(alpha: 0.3)),
                  const SizedBox(height: 16),
                  const Text(
                    'لست مسجلاً في أي فوج حالياً',
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'استكشف الأفواج الدراسية المتاحة للبكالوريا والمتوسط واختر فوج أستاذك المفضل.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 13),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                    ),
                    onPressed: () => _tabController.animateTo(0),
                    child: const Text('استكشاف الأفواج الآن'),
                  ),
                ],
              ),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.studentCohorts.length,
          itemBuilder: (context, index) {
            final cohort = controller.studentCohorts[index];

            return Container(
              margin: const EdgeInsets.only(bottom: 14),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          cohort.name,
                          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'عضو نشط ✅',
                          style: TextStyle(color: Color(0xFF10B981), fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text('المادة: ${cohort.subject} | الأستاذ: ${cohort.teacherName ?? "أستاذ المادة"}',
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 13)),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6C5CE7).withValues(alpha: 0.2),
                      foregroundColor: const Color(0xFFA29BFE),
                      side: const BorderSide(color: Color(0xFF6C5CE7), width: 0.8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      minimumSize: const Size.fromHeight(40),
                    ),
                    icon: const Icon(Icons.video_library_rounded, size: 18),
                    label: const Text(
                      'المكتبة التعليمية المحمية والتسجيلات 📚',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    onPressed: () {
                      final apiClient = ApiClient();
                      final ds = LibraryRemoteDataSourceImpl(apiClient: apiClient);
                      final repo = LibraryRepositoryImpl(remoteDataSource: ds);
                      final libController = LibraryController(repository: repo);

                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => CohortLibraryScreen(
                            cohortId: cohort.id,
                            cohortName: cohort.name,
                            controller: libController,
                            token: widget.student.token,
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'كود الفوج: ${cohort.cohortCode}',
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 11),
                      ),
                      TextButton.icon(
                        style: TextButton.styleFrom(foregroundColor: const Color(0xFFEF4444)),
                        icon: const Icon(Icons.exit_to_app, size: 16),
                        label: const Text('مغادرة الفوج', style: TextStyle(fontSize: 12)),
                        onPressed: () async {
                          if (widget.student.token != null) {
                            await widget.cohortController.leaveCohort(widget.student.token!, cohort.id);
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSmallBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildNoResultsState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 56, color: Colors.white.withValues(alpha: 0.3)),
            const SizedBox(height: 12),
            const Text(
              'لم يتم العثور على أي أفواج مطابقة للبحث',
              style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              'جرب تغيير الشعبة الدراسية أو تصفير شريط البحث.',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
