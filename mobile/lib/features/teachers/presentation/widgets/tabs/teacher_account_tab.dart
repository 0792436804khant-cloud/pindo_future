import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pindo_future_mobile/features/teachers/data/models/teacher_dashboard_model.dart';
import '../modals/teacher_support_modal.dart';
import '../modals/teacher_story_viewer_modal.dart';
import '../modals/add_teacher_story_modal.dart';
import '../modals/add_workplace_modal.dart';
import '../modals/add_student_result_modal.dart';
import '../modals/add_cohort_schedule_modal.dart';
import '../modals/edit_teacher_profile_modal.dart';
import '../modals/live_camera_capture_modal.dart';

class TeacherAccountTab extends StatefulWidget {
  final TeacherDashboardModel dashboard;
  final VoidCallback onEditProfile;
  final VoidCallback onOpenAccountSettings;
  final VoidCallback onSignOut;
  final VoidCallback onPreviewShowcase;

  const TeacherAccountTab({
    super.key,
    required this.dashboard,
    required this.onEditProfile,
    required this.onOpenAccountSettings,
    required this.onSignOut,
    required this.onPreviewShowcase,
  });

  @override
  State<TeacherAccountTab> createState() => _TeacherAccountTabState();
}

class _TeacherAccountTabState extends State<TeacherAccountTab> {
  static const Color _brightCyan = Color(0xFF00E5FF);
  static const Color _electricPurple = Color(0xFF7C4DFF);
  static const Color _deepIndigo = Color(0xFF311B92);
  static const Color _gold = Color(0xFFFFD700);

  late TeacherProfileInfo _currentProfile;
  late List<TeacherStoryItem> _stories;
  late List<TeacherWorkplaceItem> _workplaces;
  late List<TeacherCohortScheduleItem> _cohortSchedules;
  late List<TeacherStudentResultItem> _studentResults;
  Uint8List? _customCoverBytes;
  String? _customCoverUrl;
  Uint8List? _customAvatarBytes;
  String? _customAvatarUrl;

  @override
  void initState() {
    super.initState();
    _currentProfile = widget.dashboard.teacherProfile;
    _stories = List.from(_currentProfile.stories);
    _workplaces = List.from(_currentProfile.workplaces);
    _cohortSchedules = List.from(_currentProfile.cohortSchedules);
    _studentResults = List.from(_currentProfile.studentResults);
    _customCoverUrl = _currentProfile.coverImageUrl;
    _customAvatarUrl = _currentProfile.avatarUrl;
  }

  void _openStoryViewer({int initialIndex = 0}) {
    if (_stories.isEmpty) {
      _openAddStoryModal();
      return;
    }
    TeacherStoryViewerModal.show(
      context,
      stories: _stories,
      teacherProfile: _currentProfile,
      initialIndex: initialIndex,
    );
  }

  void _openAddStoryModal() {
    AddTeacherStoryModal.show(
      context,
      onStoryAdded: (newStory) {
        setState(() {
          _stories.insert(0, newStory);
        });
      },
    );
  }

  void _openAddWorkplaceModal() {
    AddWorkplaceModal.show(
      context,
      onWorkplaceAdded: (newWp) {
        setState(() {
          _workplaces.add(newWp);
        });
      },
    );
  }

  void _deleteWorkplace(String id) {
    setState(() {
      _workplaces.removeWhere((wp) => wp.id == id);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم حذف مكان العمل من ملفك بنجاح.'),
        backgroundColor: Colors.orangeAccent,
      ),
    );
  }

  void _openAddCohortScheduleModal() {
    AddCohortScheduleModal.show(
      context,
      onCohortScheduleAdded: (newCs) {
        setState(() {
          _cohortSchedules.add(newCs);
        });
      },
    );
  }

  void _deleteCohortSchedule(String id) {
    setState(() {
      _cohortSchedules.removeWhere((cs) => cs.id == id);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم حذف موعد الفوج من جدولك بنجاح.'),
        backgroundColor: Colors.orangeAccent,
      ),
    );
  }

  void _openAddStudentResultModal() {
    AddStudentResultModal.show(
      context,
      onResultAdded: (newRes) {
        setState(() {
          _studentResults.insert(0, newRes);
        });
      },
    );
  }

  void _deleteStudentResult(String id) {
    setState(() {
      _studentResults.removeWhere((sr) => sr.id == id);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تمت إزالة النتيجة من لوحة الشرف.'),
        backgroundColor: Colors.orangeAccent,
      ),
    );
  }

  void _openEditProfileModal() {
    EditTeacherProfileModal.show(
      context,
      currentProfile: _currentProfile,
      onProfileSaved: (updated) {
        setState(() {
          _currentProfile = updated;
        });
      },
    );
  }

  Future<void> _changeAvatarPhoto() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0F172A),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'تحديث الصورة الشخصية للأستاذ',
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 14),
            ListTile(
              leading: const Icon(Icons.camera_alt_rounded, color: _brightCyan),
              title: const Text('التقاط صورة سيلفي بالكاميرا الحية 📷', style: TextStyle(color: Colors.white, fontSize: 13.5)),
              onTap: () async {
                Navigator.of(context).pop();
                final result = await LiveCameraCaptureModal.show(context);
                if (result != null) {
                  setState(() {
                    _customAvatarBytes = result.bytes;
                  });
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('تم تحديث الصورة الشخصية بنجاح! 🎉'), backgroundColor: Color(0xFF10B981)),
                    );
                  }
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_rounded, color: _electricPurple),
              title: const Text('اختيار صورة من المعرض أو الملفات 🖼️', style: TextStyle(color: Colors.white, fontSize: 13.5)),
              onTap: () async {
                Navigator.of(context).pop();
                try {
                  final picker = ImagePicker();
                  final picked = await picker.pickImage(source: ImageSource.gallery);
                  if (picked != null) {
                    final bytes = await picked.readAsBytes();
                    setState(() {
                      _customAvatarBytes = bytes;
                    });
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('تم تحديث الصورة الشخصية بنجاح! 🎉'), backgroundColor: Color(0xFF10B981)),
                      );
                    }
                    return;
                  }
                } catch (_) {
                  final res = await FilePicker.platform.pickFiles(type: FileType.image, withData: true);
                  if (res != null && res.files.isNotEmpty && res.files.first.bytes != null) {
                    setState(() {
                      _customAvatarBytes = res.files.first.bytes;
                    });
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('تم تحديث الصورة الشخصية بنجاح! 🎉'), backgroundColor: Color(0xFF10B981)),
                      );
                    }
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _changeCoverPhoto() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0F172A),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Container(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'تغيير صورة الغلاف للواجهة الشخصية',
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 14),
              ListTile(
                leading: const Icon(Icons.camera_alt_rounded, color: _brightCyan),
                title: const Text('التقاط صورة للغلاف بالكاميرا الحية 📷', style: TextStyle(color: Colors.white, fontSize: 13.5)),
                onTap: () async {
                  Navigator.of(context).pop();
                  final result = await LiveCameraCaptureModal.show(context);
                  if (result != null) {
                    setState(() {
                      _customCoverBytes = result.bytes;
                    });
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('تم تحديث صورة الغلاف بنجاح! 🎉'), backgroundColor: Color(0xFF10B981)),
                      );
                    }
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_rounded, color: _electricPurple),
                title: const Text('اختيار غلاف من جهازك 🖼️', style: TextStyle(color: Colors.white, fontSize: 13.5)),
                onTap: () async {
                  Navigator.of(context).pop();
                  try {
                    final picker = ImagePicker();
                    final picked = await picker.pickImage(source: ImageSource.gallery);
                    if (picked != null) {
                      final bytes = await picked.readAsBytes();
                      setState(() {
                        _customCoverBytes = bytes;
                      });
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('تم تحديث صورة الغلاف بنجاح! 🎉'), backgroundColor: Color(0xFF10B981)),
                        );
                      }
                      return;
                    }
                  } catch (_) {
                    final res = await FilePicker.platform.pickFiles(type: FileType.image, withData: true);
                    if (res != null && res.files.isNotEmpty && res.files.first.bytes != null) {
                      setState(() {
                        _customCoverBytes = res.files.first.bytes;
                      });
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('تم تحديث صورة الغلاف بنجاح! 🎉'), backgroundColor: Color(0xFF10B981)),
                        );
                      }
                    }
                  }
                },
              ),
              const Divider(color: Colors.white12),
              ListTile(
                leading: const Icon(Icons.palette_outlined, color: _brightCyan),
                title: const Text('غلاف الاستوديو الأكاديمي الرقمي', style: TextStyle(color: Colors.white, fontSize: 13.5)),
                onTap: () {
                  setState(() {
                    _customCoverBytes = null;
                    _customCoverUrl = 'https://images.unsplash.com/photo-1509062522246-3755977927d7?w=1200&q=80';
                  });
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم تحديث صورة الغلاف بنجاح!'), backgroundColor: Color(0xFF10B981)));
                },
              ),
              ListTile(
                leading: const Icon(Icons.school_outlined, color: _electricPurple),
                title: const Text('غلاف المدرج وقاعة المحاضرات', style: TextStyle(color: Colors.white, fontSize: 13.5)),
                onTap: () {
                  setState(() {
                    _customCoverBytes = null;
                    _customCoverUrl = 'https://images.unsplash.com/photo-1524178232363-1fb2b075b655?w=1200&q=80';
                  });
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم تحديث صورة الغلاف بنجاح!'), backgroundColor: Color(0xFF10B981)));
                },
              ),
              ListTile(
                leading: const Icon(Icons.science_outlined, color: _gold),
                title: const Text('غلاف المختبر والعلوم الطبيعية', style: TextStyle(color: Colors.white, fontSize: 13.5)),
                onTap: () {
                  setState(() {
                    _customCoverBytes = null;
                    _customCoverUrl = 'https://images.unsplash.com/photo-1532094349884-543bc11b234d?w=1200&q=80';
                  });
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم تحديث صورة الغلاف بنجاح!'), backgroundColor: Color(0xFF10B981)));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profile = _currentProfile;
    final deepLink = 'https://pindofuture.com/teacher/${profile.teacherId}';

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title (Preserves test check: '👤 حساب الأستاذ والمنصات')
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '👤 حساب الأستاذ والمنصات',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'الملف الشخصي الاحترافي، الواجهة العامة، والسطوريات التفاعلية',
                      style: TextStyle(fontSize: 12, color: Colors.white60),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: _openAddStoryModal,
                icon: const Icon(Icons.add_photo_alternate_rounded, size: 16),
                label: const Text('نشر ستوري', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _brightCyan,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // 1. Facebook-style Teacher Showcase & Profile Card
          _buildTeacherShowcaseCard(context, profile),

          const SizedBox(height: 18),

          // 2. Facebook/Instagram Stories Bar
          _buildStoriesBar(profile),

          const SizedBox(height: 20),

          // 3. Workplaces & Teaching Centers (أماكن عمله)
          _buildWorkplacesSection(),

          const SizedBox(height: 20),

          // 4. Cohorts Schedule & Timings (مواقيت وأجندة الأفواج)
          _buildCohortsScheduleSection(),

          const SizedBox(height: 20),

          // 5. Student BAC Marks & Hall of Fame (نقاط تلاميذه)
          _buildStudentResultsSection(),

          const SizedBox(height: 20),

          // 6. External Platforms & Smart Deep Link
          _buildDeepLinkSection(context, deepLink, profile),

          const SizedBox(height: 20),

          // 7. Reports & Analytics Preview
          _buildAnalyticsPreviewCard(context),

          const SizedBox(height: 20),

          // 8. Settings & Support Tiles
          _buildActionsMenu(context),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // --- 1. Teacher Showcase Card with Cover & Avatar Ring ---
  Widget _buildTeacherShowcaseCard(BuildContext context, TeacherProfileInfo profile) {
    final hasStories = _stories.isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A).withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _electricPurple.withValues(alpha: 0.4), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cover Banner
          Stack(
            children: [
              Container(
                height: 130,
                width: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF311B92), Color(0xFF0F172A), Color(0xFF00695C)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: _customCoverBytes != null
                    ? Image.memory(
                        _customCoverBytes!,
                        fit: BoxFit.cover,
                        color: Colors.black.withValues(alpha: 0.25),
                        colorBlendMode: BlendMode.darken,
                      )
                    : (_customCoverUrl != null
                        ? Image.network(
                            _customCoverUrl!,
                            fit: BoxFit.cover,
                            color: Colors.black.withValues(alpha: 0.35),
                            colorBlendMode: BlendMode.darken,
                            errorBuilder: (context, error, stackTrace) => const SizedBox(),
                          )
                        : null),
              ),
              Positioned(
                top: 10,
                left: 10,
                child: InkWell(
                  onTap: _changeCoverPhoto,
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.65),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.camera_alt_outlined, color: Colors.white, size: 14),
                        SizedBox(width: 4),
                        Text(
                          'تغيير الغلاف',
                          style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Profile Info Section with Overlapping Avatar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar with Story Ring
                Transform.translate(
                  offset: const Offset(0, -36),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // Avatar with glowing story ring
                      GestureDetector(
                        onTap: () => _openStoryViewer(),
                        child: Container(
                          padding: const EdgeInsets.all(3.5),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: hasStories
                                ? const LinearGradient(
                                    colors: [
                                      Color(0xFFFF007A),
                                      Color(0xFF7928CA),
                                      Color(0xFF0070F3),
                                      Color(0xFF00DFD8),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  )
                                : const LinearGradient(
                                    colors: [_brightCyan, _electricPurple],
                                  ),
                            boxShadow: hasStories
                                ? [
                                    BoxShadow(
                                      color: const Color(0xFFFF007A).withValues(alpha: 0.4),
                                      blurRadius: 12,
                                      spreadRadius: 2,
                                    ),
                                  ]
                                : null,
                          ),
                          child: Stack(
                            alignment: Alignment.bottomRight,
                            children: [
                              CircleAvatar(
                                radius: 36,
                                backgroundColor: _deepIndigo,
                                backgroundImage: _customAvatarBytes != null
                                    ? MemoryImage(_customAvatarBytes!)
                                    : (_customAvatarUrl != null
                                        ? NetworkImage(_customAvatarUrl!)
                                        : (profile.avatarUrl != null ? NetworkImage(profile.avatarUrl!) : null)) as ImageProvider<Object>?,
                                child: (_customAvatarBytes == null && _customAvatarUrl == null && profile.avatarUrl == null)
                                    ? Text(
                                        profile.name.isNotEmpty ? profile.name[0] : 'أ',
                                        style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold),
                                      )
                                    : null,
                              ),
                              GestureDetector(
                                onTap: _changeAvatarPhoto,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: _brightCyan,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.black, width: 1.5),
                                  ),
                                  child: const Icon(Icons.camera_alt_rounded, size: 12, color: Colors.black),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Quick badges
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Wrap(
                            spacing: 6,
                            runSpacing: 4,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: Colors.amber.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
                                ),
                                child: Text(
                                  'خبرة ${profile.yearsOfExperience} سنوات',
                                  style: const TextStyle(color: Colors.amber, fontSize: 10.5, fontWeight: FontWeight.bold),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: _brightCyan.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: _brightCyan.withValues(alpha: 0.3)),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.location_on_rounded, color: _brightCyan, size: 12),
                                    const SizedBox(width: 3),
                                    Text(
                                      profile.wilaya,
                                      style: const TextStyle(color: _brightCyan, fontSize: 10.5, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Name & Headline
                Transform.translate(
                  offset: const Offset(0, -22),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              profile.name,
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (profile.isVerified) ...[
                            const SizedBox(width: 6),
                            const Icon(Icons.verified_rounded, color: _brightCyan, size: 20),
                          ],
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        profile.headline,
                        style: const TextStyle(color: Colors.white70, fontSize: 12.5, height: 1.3),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        profile.bio,
                        style: const TextStyle(color: Colors.white54, fontSize: 12, height: 1.4),
                      ),
                      const SizedBox(height: 12),

                      // Subjects & Levels chips
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          ...profile.subjects.map((s) => _buildChip(s, _brightCyan)),
                          ...profile.levels.map((l) => _buildChip(l, _electricPurple)),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Action Buttons
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _openEditProfileModal,
                              icon: const Icon(Icons.edit_rounded, size: 16, color: _brightCyan),
                              label: const Text('تعديل الملف والشهادات', style: TextStyle(color: Colors.white, fontSize: 12)),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: _brightCyan),
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: widget.onPreviewShowcase,
                              icon: const Icon(Icons.preview_rounded, size: 16),
                              label: const Text('معاينة الواجهة العامة', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _electricPurple,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- 2. Stories Bar (سطوريات كانه فايسبوك) ---
  Widget _buildStoriesBar(TeacherProfileInfo profile) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A).withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white10),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Row(
                  children: [
                    Icon(Icons.amp_stories_rounded, color: Color(0xFFFF007A), size: 18),
                    SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'السطوريات والتحديثات الحية (Stories)',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: _openAddStoryModal,
                child: const Row(
                  children: [
                    Icon(Icons.add, color: _brightCyan, size: 16),
                    SizedBox(width: 2),
                    Text('إضافة ستوري', style: TextStyle(color: _brightCyan, fontSize: 12, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 92,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                // Create Story Bubble
                GestureDetector(
                  onTap: _openAddStoryModal,
                  child: Container(
                    width: 70,
                    margin: const EdgeInsets.only(left: 12),
                    child: Column(
                      children: [
                        Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            CircleAvatar(
                              radius: 26,
                              backgroundColor: Colors.white12,
                              backgroundImage: profile.avatarUrl != null ? NetworkImage(profile.avatarUrl!) : null,
                              child: profile.avatarUrl == null
                                  ? Text(profile.name.isNotEmpty ? profile.name[0] : 'أ', style: const TextStyle(color: Colors.white))
                                  : null,
                            ),
                            Container(
                              padding: const EdgeInsets.all(2),
                              decoration: const BoxDecoration(
                                color: _brightCyan,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.add, size: 14, color: Colors.black),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'ستوري جديدة',
                          style: TextStyle(color: Colors.white70, fontSize: 10.5),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),

                // Active Stories
                ..._stories.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final story = entry.value;
                  return GestureDetector(
                    onTap: () => _openStoryViewer(initialIndex: idx),
                    child: Container(
                      width: 74,
                      margin: const EdgeInsets.only(left: 10),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(2.5),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: story.isLiveAlert
                                    ? [Colors.red, Colors.deepOrangeAccent]
                                    : [const Color(0xFFFF007A), const Color(0xFF7928CA), _brightCyan],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            child: CircleAvatar(
                              radius: 25,
                              backgroundColor: const Color(0xFF1E293B),
                              child: story.isLiveAlert
                                  ? const Icon(Icons.sensors_rounded, color: Colors.redAccent, size: 22)
                                  : Text(
                                      '#${idx + 1}',
                                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            story.tag ?? story.timeAgo,
                            style: TextStyle(
                              color: story.isLiveAlert ? Colors.redAccent : Colors.white70,
                              fontSize: 10,
                              fontWeight: story.isLiveAlert ? FontWeight.bold : FontWeight.normal,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- 3. Workplaces & Teaching Centers (أماكن عمله) ---
  Widget _buildWorkplacesSection() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A).withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white12),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Row(
                  children: [
                    Icon(Icons.account_balance_rounded, color: _brightCyan, size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '🏢 أماكن العمل والمراكز التعليمية',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: _openAddWorkplaceModal,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _brightCyan.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: _brightCyan.withValues(alpha: 0.3)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.add, color: _brightCyan, size: 14),
                      SizedBox(width: 2),
                      Text('إضافة مؤسسة', style: TextStyle(color: _brightCyan, fontSize: 11, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'الثانويات، المدارس الخاصة، وأكاديميات دروس الدعم المعتمدة للأستاذ',
            style: TextStyle(color: Colors.white54, fontSize: 11.5),
          ),
          const SizedBox(height: 14),

          // Workplaces List
          ..._workplaces.map((wp) => Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.04),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white10),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _electricPurple.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.school_rounded, color: _brightCyan, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  wp.name,
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.teal.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  wp.type,
                                  style: const TextStyle(color: Colors.tealAccent, fontSize: 10, fontWeight: FontWeight.bold),
                                ),
                              ),
                              const SizedBox(width: 4),
                              InkWell(
                                onTap: () => _deleteWorkplace(wp.id),
                                child: const Padding(
                                  padding: EdgeInsets.all(4.0),
                                  child: Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 16),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            wp.role,
                            style: const TextStyle(color: Colors.white70, fontSize: 11.5),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.location_on_outlined, color: Colors.white54, size: 12),
                              const SizedBox(width: 2),
                              Text(wp.wilaya, style: const TextStyle(color: Colors.white54, fontSize: 11)),
                              const SizedBox(width: 12),
                              const Icon(Icons.calendar_today_outlined, color: Colors.white54, size: 11),
                              const SizedBox(width: 2),
                              Text(wp.period, style: const TextStyle(color: Colors.white54, fontSize: 11)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  // --- 4. Cohorts Schedule & Timings (مواقيت وأجندة الأفواج) ---
  Widget _buildCohortsScheduleSection() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A).withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white12),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Row(
                  children: [
                    Icon(Icons.calendar_month_rounded, color: _electricPurple, size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '📅 مواقيت وأجندة الأفواج الدراسية',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14.5),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: _openAddCohortScheduleModal,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _electricPurple.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: _electricPurple.withValues(alpha: 0.3)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.add, color: _brightCyan, size: 14),
                      SizedBox(width: 2),
                      Text('إضافة موعد وفوج', style: TextStyle(color: _brightCyan, fontSize: 11, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'مواعيد الحصص الأسبوعية، القاعات، وحالة التسجيل لكل فوج',
            style: TextStyle(color: Colors.white54, fontSize: 11.5),
          ),
          const SizedBox(height: 14),

          ..._cohortSchedules.map((cs) => Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.04),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: _electricPurple.withValues(alpha: 0.25)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            cs.cohortName,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: cs.status.contains('مفتوح')
                                ? const Color(0xFF10B981).withValues(alpha: 0.15)
                                : Colors.amber.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: cs.status.contains('مفتوح')
                                  ? const Color(0xFF10B981).withValues(alpha: 0.3)
                                  : Colors.amber.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Text(
                            cs.status,
                            style: TextStyle(
                              color: cs.status.contains('مفتوح') ? const Color(0xFF10B981) : Colors.amber,
                              fontSize: 10.5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        InkWell(
                          onTap: () => _deleteCohortSchedule(cs.id),
                          child: const Padding(
                            padding: EdgeInsets.all(4.0),
                            child: Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 16),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.access_time_rounded, color: _brightCyan, size: 14),
                        const SizedBox(width: 5),
                        Text(
                          cs.daysAndTimes,
                          style: const TextStyle(color: _brightCyan, fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.place_outlined, color: Colors.white60, size: 13),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            cs.location,
                            style: const TextStyle(color: Colors.white60, fontSize: 11.5),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'المقاعد: ${cs.enrolledCount} / ${cs.maxCapacity} طالب',
                          style: const TextStyle(color: Colors.white70, fontSize: 11),
                        ),
                        Text(
                          '${cs.monthlyPrice.toInt()} دج / شهرياً',
                          style: const TextStyle(color: Colors.amber, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  // --- 5. Student BAC Marks & Hall of Fame (نقاط تلاميذه) ---
  Widget _buildStudentResultsSection() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A).withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _gold.withValues(alpha: 0.3)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Row(
                  children: [
                    Icon(Icons.emoji_events_rounded, color: _gold, size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '🏆 لوحة الشرف ونقاط المتفوقين في البكالوريا',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13.5),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: _openAddStudentResultModal,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _gold.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: _gold.withValues(alpha: 0.3)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.add, color: _gold, size: 14),
                      SizedBox(width: 2),
                      Text('إضافة نتيجة', style: TextStyle(color: _gold, fontSize: 11, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'العلامات الممتازة وشهادات طلاب الأستاذ في امتحانات البكالوريا الرسمية',
            style: TextStyle(color: Colors.white54, fontSize: 11.5),
          ),
          const SizedBox(height: 14),

          ..._studentResults.map((sr) => Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.04),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: _gold.withValues(alpha: 0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Big Score Badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFB45309), Color(0xFF78350F)],
                            ),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: _gold, width: 1.2),
                          ),
                          child: Column(
                            children: [
                              Text(
                                '${sr.mark % 1 == 0 ? sr.mark.toInt() : sr.mark}',
                                style: const TextStyle(color: _gold, fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              const Text('/ 20', style: TextStyle(color: Colors.white70, fontSize: 9.5)),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),

                        // Student Info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Row(
                                      children: [
                                        Flexible(
                                          child: Text(
                                            sr.studentName,
                                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13.5),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          '(${sr.exam})',
                                          style: const TextStyle(color: Colors.white54, fontSize: 11),
                                        ),
                                      ],
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () => _deleteStudentResult(sr.id),
                                    child: const Padding(
                                      padding: EdgeInsets.all(4.0),
                                      child: Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 16),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${sr.stream} • ${sr.wilaya}',
                                style: const TextStyle(color: _brightCyan, fontSize: 11),
                              ),
                              if (sr.generalAverage != null) ...[
                                const SizedBox(height: 2),
                                Text(
                                  'المعدل العام للبكالوريا: ${sr.generalAverage}/20',
                                  style: const TextStyle(color: Colors.amber, fontSize: 11, fontWeight: FontWeight.w600),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (sr.testimonial.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '« ${sr.testimonial} »',
                          style: const TextStyle(color: Colors.white70, fontSize: 11.5, fontStyle: FontStyle.italic),
                        ),
                      ),
                    ],
                  ],
                ),
              )),
        ],
      ),
    );
  }

  // --- 6. External Platforms & Smart Deep Link ---
  Widget _buildDeepLinkSection(BuildContext context, String deepLink, TeacherProfileInfo profile) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white12),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.link_rounded, color: _brightCyan, size: 20),
              SizedBox(width: 8),
              Text(
                'الرابط الذكي لموقعك وعروضك الخارجية',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'شارك هذا الرابط في صفحتك على الفيسبوك أو الإنستغرام أو موقعك الخاص؛ سيفتح التطبيق مباشرة للطلاب وينقلهم لدروسك.',
            style: TextStyle(color: Colors.white60, fontSize: 11.5, height: 1.4),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    deepLink,
                    style: const TextStyle(color: _brightCyan, fontSize: 12, fontFamily: 'monospace'),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: deepLink));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('تم نسخ رابط الأستاذ الذكي للحافظة بنجاح!'),
                        backgroundColor: Color(0xFF10B981),
                      ),
                    );
                  },
                  tooltip: 'نسخ الرابط',
                  icon: const Icon(Icons.copy_rounded, color: Colors.white70, size: 18),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Social Platforms quick links
          const Text(
            'صفحاتك وقنواتك التعليمية:',
            style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildSocialBtn(
                  'فيسبوك',
                  Icons.facebook_rounded,
                  const Color(0xFF1877F2),
                  profile.facebookUrl ?? 'https://facebook.com',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildSocialBtn(
                  'تيليغرام',
                  Icons.send_rounded,
                  const Color(0xFF229ED9),
                  profile.telegramUrl ?? 'https://t.me',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildSocialBtn(
                  'يوتيوب',
                  Icons.play_circle_fill_rounded,
                  const Color(0xFFFF0000),
                  profile.youtubeUrl ?? 'https://youtube.com',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSocialBtn(String label, IconData icon, Color color, String url) {
    return InkWell(
      onTap: () {
        Clipboard.setData(ClipboardData(text: url));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تم نسخ رابط $label ($url) للحافظة!'),
            backgroundColor: color,
          ),
        );
      },
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 5),
            Text(label, style: TextStyle(color: color, fontSize: 11.5, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  // --- 7. Analytics Preview ---
  Widget _buildAnalyticsPreviewCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.insights_rounded, color: Colors.orangeAccent, size: 20),
              SizedBox(width: 8),
              Text(
                'تقارير الأداء ومعدل الحضور',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildReportMetric('متوسط الحضور', '91%', const Color(0xFF10B981)),
              _buildReportMetric('إتمام المنهاج', '68%', _brightCyan),
              _buildReportMetric('تجديد الاشتراكات', '85%', _electricPurple),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReportMetric(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(color: Colors.white60, fontSize: 11)),
      ],
    );
  }

  // --- 8. Settings & Support Actions Menu ---
  Widget _buildActionsMenu(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.support_agent_rounded, color: _brightCyan),
            title: const Text('الدعم الفني والمشكلات التقنية', style: TextStyle(color: Colors.white, fontSize: 13.5)),
            subtitle: const Text('الإبلاغ عن انقطاع البث أو استفسار مالي', style: TextStyle(color: Colors.white54, fontSize: 11)),
            trailing: const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white30, size: 14),
            onTap: () => TeacherSupportModal.show(context),
          ),
          const Divider(color: Colors.white10, height: 1),
          ListTile(
            leading: const Icon(Icons.settings_outlined, color: Colors.white70),
            title: const Text('إعدادات الحساب والأمان', style: TextStyle(color: Colors.white, fontSize: 13.5)),
            trailing: const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white30, size: 14),
            onTap: widget.onOpenAccountSettings,
          ),
          const Divider(color: Colors.white10, height: 1),
          ListTile(
            leading: const Icon(Icons.logout_rounded, color: Colors.redAccent),
            title: const Text('تسجيل الخروج', style: TextStyle(color: Colors.redAccent, fontSize: 13.5, fontWeight: FontWeight.bold)),
            onTap: widget.onSignOut,
          ),
        ],
      ),
    );
  }

  Widget _buildChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold)),
    );
  }
}
