import 'package:flutter/material.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/widgets/glassmorphism.dart';
import '../../data/datasources/auth_local_datasource.dart';
import '../../domain/entities/user.dart';
import '../../../courses/domain/entities/teacher_showcase_entity.dart';

class TeacherProfileEditorModal extends StatefulWidget {
  final User user;
  final String? initialHeadline;
  final String? initialBio;
  final String? initialAvatarUrl;
  final int? initialExperience;
  final List<String> initialSubjects;
  final List<String> initialYears;
  final List<String> initialLevels;
  final List<StudentAchievementEntity> initialAchievements;
  final Function(User updatedUser, List<StudentAchievementEntity> updatedAchievements) onSaveSuccess;

  const TeacherProfileEditorModal({
    super.key,
    required this.user,
    this.initialHeadline,
    this.initialBio,
    this.initialAvatarUrl,
    this.initialExperience,
    this.initialSubjects = const [],
    this.initialYears = const [],
    this.initialLevels = const [],
    this.initialAchievements = const [],
    required this.onSaveSuccess,
  });

  static Future<void> show({
    required BuildContext context,
    required User user,
    String? initialHeadline,
    String? initialBio,
    String? initialAvatarUrl,
    int? initialExperience,
    List<String> initialSubjects = const [],
    List<String> initialYears = const [],
    List<String> initialLevels = const [],
    List<StudentAchievementEntity> initialAchievements = const [],
    required Function(User updatedUser, List<StudentAchievementEntity> updatedAchievements) onSaveSuccess,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => TeacherProfileEditorModal(
        user: user,
        initialHeadline: initialHeadline,
        initialBio: initialBio,
        initialAvatarUrl: initialAvatarUrl,
        initialExperience: initialExperience,
        initialSubjects: initialSubjects,
        initialYears: initialYears,
        initialLevels: initialLevels,
        initialAchievements: initialAchievements,
        onSaveSuccess: onSaveSuccess,
      ),
    );
  }

  @override
  State<TeacherProfileEditorModal> createState() => _TeacherProfileEditorModalState();
}

class _TeacherProfileEditorModalState extends State<TeacherProfileEditorModal> {
  late TextEditingController _avatarController;
  late TextEditingController _headlineController;
  late TextEditingController _bioController;
  late TextEditingController _experienceController;
  late TextEditingController _newSubjectController;

  late List<String> _subjects;
  late List<String> _years;
  late List<String> _levels;
  late List<StudentAchievementEntity> _achievements;

  bool _isSaving = false;
  String? _errorMessage;

  static const Color _brightCyan = Color(0xFF00E5FF);
  static const Color _electricPurple = Color(0xFF7C4DFF);
  static const Color _deepIndigo = Color(0xFF311B92);

  static const List<String> _availableLevels = [
    'Primary School (Primaire)',
    'Middle School (CEM)',
    'High School (Secondary)',
    'University & Higher Ed',
  ];

  static const List<String> _availableYears = [
    '5th Year Primary (5AP)',
    '4th Middle School (BEM)',
    '1st Year Secondary (1AS)',
    '2nd Year Secondary (2AS)',
    '3rd Year Secondary (BAC)',
    'License & University (L1-L3)',
  ];

  static const List<String> _suggestedSubjects = [
    'Advanced Mathematics',
    'Physics & Chemistry',
    'Computer Science & Algorithms',
    'Natural & Life Sciences',
    'Arabic Language & Literature',
    'English Language & TOEFL',
    'French Language',
    'Philosophy',
  ];

  @override
  void initState() {
    super.initState();
    _avatarController = TextEditingController(text: widget.initialAvatarUrl ?? widget.user.avatarUrl ?? '');
    _headlineController = TextEditingController(text: widget.initialHeadline ?? widget.user.headline ?? 'Verified Instructor at Pindo Future');
    _bioController = TextEditingController(text: widget.initialBio ?? widget.user.bio ?? '');
    _experienceController = TextEditingController(text: (widget.initialExperience ?? widget.user.yearsOfExperience ?? 5).toString());
    _newSubjectController = TextEditingController();

    _subjects = List<String>.from(widget.initialSubjects.isNotEmpty ? widget.initialSubjects : widget.user.teachingSubjects);
    _years = List<String>.from(widget.initialYears.isNotEmpty ? widget.initialYears : widget.user.teachingYears);
    _levels = List<String>.from(widget.initialLevels.isNotEmpty ? widget.initialLevels : widget.user.teachingLevels);
    _achievements = List<StudentAchievementEntity>.from(widget.initialAchievements);

    _avatarController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _avatarController.dispose();
    _headlineController.dispose();
    _bioController.dispose();
    _experienceController.dispose();
    _newSubjectController.dispose();
    super.dispose();
  }

  void _addSubject(String subject) {
    final trimmed = subject.trim();
    if (trimmed.isNotEmpty && !_subjects.contains(trimmed)) {
      setState(() {
        _subjects.add(trimmed);
        _newSubjectController.clear();
      });
    }
  }

  void _removeSubject(String subject) {
    setState(() {
      _subjects.remove(subject);
    });
  }

  void _toggleLevel(String level) {
    setState(() {
      if (_levels.contains(level)) {
        _levels.remove(level);
      } else {
        _levels.add(level);
      }
    });
  }

  void _toggleYear(String year) {
    setState(() {
      if (_years.contains(year)) {
        _years.remove(year);
      } else {
        _years.add(year);
      }
    });
  }

  void _showAddDegreeDialog() {
    final titleCtrl = TextEditingController(text: 'BAC Mathématiques — Mention Très Bien');
    final studentCtrl = TextEditingController();
    final gradeCtrl = TextEditingController(text: '19.25 / 20');
    final yearCtrl = TextEditingController(text: DateTime.now().year.toString());
    final photoCtrl = TextEditingController(text: 'https://images.unsplash.com/photo-1589330694653-ded6df03f754?auto=format&fit=crop&w=800&q=80');
    final descCtrl = TextEditingController(text: 'Admitted to Higher National School of Computer Science (ESI).');

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          photoCtrl.addListener(() => setDialogState(() {}));

          return AlertDialog(
            backgroundColor: const Color(0xFF0F172A),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(color: Colors.white.withValues(alpha: 0.20), width: 1.2),
            ),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [Colors.amber.shade700, Colors.orange.shade800]),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.workspace_premium_rounded, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'Add Student Degree & Honor',
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Showcase previous student degrees, BAC mentions, or awards with certificate photos:',
                    style: TextStyle(color: Colors.white70, fontSize: 12.5),
                  ),
                  const SizedBox(height: 14),
                  _buildModalTextField(
                    label: 'Degree / Certificate Title *',
                    controller: titleCtrl,
                    hint: 'e.g. BAC Mathématiques — Mention Très Bien',
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _buildModalTextField(
                          label: 'Student Name',
                          controller: studentCtrl,
                          hint: 'e.g. Amine Belkacem',
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildModalTextField(
                          label: 'Score / Grade',
                          controller: gradeCtrl,
                          hint: 'e.g. 19.45 / 20',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _buildModalTextField(
                    label: 'Academic Year',
                    controller: yearCtrl,
                    hint: 'e.g. 2024',
                  ),
                  const SizedBox(height: 10),
                  _buildModalTextField(
                    label: 'Certificate / Degree Photo URL',
                    controller: photoCtrl,
                    hint: 'https://images.unsplash.com/... or image link',
                  ),
                  const SizedBox(height: 6),
                  // Quick sample photo pickers
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: [
                      _buildPresetChip(
                        label: 'Diploma Sample 1',
                        onTap: () => photoCtrl.text = 'https://images.unsplash.com/photo-1589330694653-ded6df03f754?auto=format&fit=crop&w=800&q=80',
                      ),
                      _buildPresetChip(
                        label: 'Honor Degree 2',
                        onTap: () => photoCtrl.text = 'https://images.unsplash.com/photo-1606326608606-aa0b62935f2b?auto=format&fit=crop&w=800&q=80',
                      ),
                      _buildPresetChip(
                        label: 'Graduation Medal 3',
                        onTap: () => photoCtrl.text = 'https://images.unsplash.com/photo-1523240795612-9a054b0db644?auto=format&fit=crop&w=800&q=80',
                      ),
                    ],
                  ),
                  if (photoCtrl.text.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Container(
                      height: 100,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          photoCtrl.text,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Center(
                            child: Icon(Icons.broken_image, color: Colors.white38),
                          ),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 10),
                  _buildModalTextField(
                    label: 'Description / Honors Notes',
                    controller: descCtrl,
                    maxLines: 2,
                    hint: 'e.g. Admitted to Higher National School of Computer Science (ESI).',
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Cancel', style: TextStyle(color: Colors.white60)),
              ),
              FuturisticCapsuleButton(
                text: 'Add to Hall of Fame',
                icon: Icons.check_circle_rounded,
                accentColor: Colors.amber,
                secondaryColor: Colors.orange.shade800,
                height: 38,
                fontSize: 12.5,
                onPressed: () {
                  final title = titleCtrl.text.trim();
                  if (title.isEmpty) return;

                  final newAch = StudentAchievementEntity(
                    id: 'ach_${DateTime.now().millisecondsSinceEpoch}',
                    title: title,
                    studentName: studentCtrl.text.trim(),
                    gradeOrScore: gradeCtrl.text.trim(),
                    year: yearCtrl.text.trim(),
                    photoUrl: photoCtrl.text.trim(),
                    description: descCtrl.text.trim(),
                  );

                  setState(() {
                    _achievements.add(newAch);
                  });

                  Navigator.of(ctx).pop();
                },
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _saveProfile() async {
    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    try {
      final apiClient = ApiClient();
      final authLocal = AuthLocalDataSourceImpl();
      final token = await authLocal.getToken();

      final expVal = int.tryParse(_experienceController.text.trim()) ?? 5;

      final body = {
        'headline': _headlineController.text.trim(),
        'bio': _bioController.text.trim(),
        'avatar_url': _avatarController.text.trim(),
        'years_of_experience': expVal,
        'teaching_levels': _levels,
        'teaching_years': _years,
        'teaching_subjects': _subjects,
        'student_achievements': _achievements.map((a) => a.toJson()).toList(),
      };

      await apiClient.put(
        '/teacher/platform',
        body: body,
        token: token,
      );

      final updatedUser = widget.user.copyWith(
        avatarUrl: _avatarController.text.trim(),
        yearsOfExperience: expVal,
        headline: _headlineController.text.trim(),
        bio: _bioController.text.trim(),
        teachingLevels: _levels,
        teachingYears: _years,
        teachingSubjects: _subjects,
      );

      widget.onSaveSuccess(updatedUser, _achievements);

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: _brightCyan, size: 20),
                SizedBox(width: 8),
                Text('✨ Teacher profile & Hall of Fame updated successfully!'),
              ],
            ),
            backgroundColor: _deepIndigo,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSaving = false;
          _errorMessage = e.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 720, maxHeight: 750),
        decoration: BoxDecoration(
          color: const Color(0xFF0F172A).withValues(alpha: 0.96),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withValues(alpha: 0.22), width: 1.2),
          boxShadow: [
            BoxShadow(
              color: _deepIndigo.withValues(alpha: 0.40),
              blurRadius: 36,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Column(
            children: [
              // 1. Header
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  border: Border(bottom: BorderSide(color: Colors.white.withValues(alpha: 0.12))),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [_deepIndigo, _electricPurple]),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.person_pin_rounded, color: _brightCyan, size: 22),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Edit Teacher Profile & Credentials',
                            style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Manage photo, experience, subjects, and previous student degree honors',
                            style: TextStyle(color: Colors.white60, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white70),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),

              // 2. Scrollable Body
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    if (_errorMessage != null) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.redAccent.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.redAccent.withValues(alpha: 0.4)),
                        ),
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(color: Colors.redAccent, fontSize: 12.5),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Section 1: Profile Photo
                    _buildSectionTitle('1. Profile Avatar Photo', Icons.camera_alt_outlined),
                    const SizedBox(height: 10),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: _brightCyan, width: 2.0),
                            boxShadow: [
                              BoxShadow(
                                color: _brightCyan.withValues(alpha: 0.35),
                                blurRadius: 12,
                              ),
                            ],
                          ),
                          child: CircleAvatar(
                            radius: 36,
                            backgroundColor: _deepIndigo,
                            backgroundImage: _avatarController.text.trim().isNotEmpty
                                ? NetworkImage(_avatarController.text.trim())
                                : null,
                            child: _avatarController.text.trim().isEmpty
                                ? Text(
                                    widget.user.name.isNotEmpty ? widget.user.name[0].toUpperCase() : 'T',
                                    style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                                  )
                                : null,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildModalTextField(
                                label: 'Avatar Photo URL',
                                controller: _avatarController,
                                hint: 'https://images.unsplash.com/... or paste image URL',
                              ),
                              const SizedBox(height: 6),
                              Wrap(
                                spacing: 6,
                                runSpacing: 4,
                                children: [
                                  _buildPresetChip(
                                    label: 'Professor Avatar 1',
                                    onTap: () => _avatarController.text = 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=400&q=80',
                                  ),
                                  _buildPresetChip(
                                    label: 'Doctor Avatar 2',
                                    onTap: () => _avatarController.text = 'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?auto=format&fit=crop&w=400&q=80',
                                  ),
                                  _buildPresetChip(
                                    label: 'Instructor Avatar 3',
                                    onTap: () => _avatarController.text = 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=400&q=80',
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const Divider(height: 32, color: Colors.white12),

                    // Section 2: Professional Headline, Bio & Experience
                    _buildSectionTitle('2. Professional Experience & Bio', Icons.badge_outlined),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: _buildModalTextField(
                            label: 'Professional Headline',
                            controller: _headlineController,
                            hint: 'e.g. Senior Secondary Physics & BAC Preparation Specialist',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 1,
                          child: _buildModalTextField(
                            label: 'Years Exp',
                            controller: _experienceController,
                            keyboardType: TextInputType.number,
                            hint: '14',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    _buildModalTextField(
                      label: 'Teacher Bio / Teaching Philosophy',
                      controller: _bioController,
                      maxLines: 3,
                      hint: 'Describe your pedagogy, past student success rates, and methodology...',
                    ),

                    const Divider(height: 32, color: Colors.white12),

                    // Section 3: Teaching Classifications (Cycles & Years)
                    _buildSectionTitle('3. Educational Levels & Academic Years', Icons.school_outlined),
                    const SizedBox(height: 6),
                    const Text('Select the cycles you teach so students can discover you via Academic Explorer:', style: TextStyle(color: Colors.white60, fontSize: 12)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: _availableLevels.map((lvl) {
                        final isSelected = _levels.contains(lvl);
                        return FilterChip(
                          label: Text(lvl, style: TextStyle(color: isSelected ? Colors.white : Colors.white70, fontSize: 11.5)),
                          selected: isSelected,
                          selectedColor: _electricPurple,
                          backgroundColor: Colors.white.withValues(alpha: 0.08),
                          checkmarkColor: _brightCyan,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          onSelected: (_) => _toggleLevel(lvl),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 14),
                    const Text('Academic Years / Grades Taught:', style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: _availableYears.map((yr) {
                        final isSelected = _years.contains(yr);
                        return FilterChip(
                          label: Text(yr, style: TextStyle(color: isSelected ? Colors.white : Colors.white70, fontSize: 11.5)),
                          selected: isSelected,
                          selectedColor: _deepIndigo,
                          backgroundColor: Colors.white.withValues(alpha: 0.08),
                          checkmarkColor: _brightCyan,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          onSelected: (_) => _toggleYear(yr),
                        );
                      }).toList(),
                    ),

                    const Divider(height: 32, color: Colors.white12),

                    // Section 4: Teaching Subjects
                    _buildSectionTitle('4. Specialized Subjects', Icons.auto_stories_outlined),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: _buildModalTextField(
                            label: 'Add Subject',
                            controller: _newSubjectController,
                            hint: 'Type subject (e.g. Kinematics, English BAC)',
                          ),
                        ),
                        const SizedBox(width: 8),
                        FuturisticCapsuleButton(
                          text: 'Add',
                          icon: Icons.add,
                          accentColor: _brightCyan,
                          secondaryColor: _electricPurple,
                          height: 42,
                          fontSize: 12.5,
                          onPressed: () => _addSubject(_newSubjectController.text),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: _subjects.map((s) {
                        return Chip(
                          label: Text(s, style: const TextStyle(color: Colors.white, fontSize: 11.5)),
                          backgroundColor: _electricPurple.withValues(alpha: 0.35),
                          deleteIcon: const Icon(Icons.close, size: 14, color: Colors.white70),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          onDeleted: () => _removeSubject(s),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 6),
                    const Text('Quick Suggestions:', style: TextStyle(color: Colors.white60, fontSize: 11)),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: _suggestedSubjects.where((s) => !_subjects.contains(s)).map((s) {
                        return InkWell(
                          onTap: () => _addSubject(s),
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.06),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.white12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.add, size: 12, color: _brightCyan),
                                const SizedBox(width: 3),
                                Text(s, style: const TextStyle(color: Colors.white70, fontSize: 10.5)),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    const Divider(height: 32, color: Colors.white12),

                    // Section 5: Student Hall of Fame & Best Degrees
                    Row(
                      children: [
                        _buildSectionTitle('5. Hall of Fame: Previous Student Degrees', Icons.workspace_premium_rounded),
                        const Spacer(),
                        FuturisticCapsuleButton(
                          text: '+ Add Degree',
                          icon: Icons.add_photo_alternate_rounded,
                          accentColor: Colors.amber,
                          secondaryColor: Colors.orange.shade800,
                          height: 34,
                          fontSize: 12,
                          onPressed: _showAddDegreeDialog,
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Attach photos of best diplomas, BAC/BEM transcripts, and competition medals achieved by your students:',
                      style: TextStyle(color: Colors.white60, fontSize: 12),
                    ),
                    const SizedBox(height: 12),
                    if (_achievements.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.04),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.white12),
                        ),
                        child: const Center(
                          child: Text(
                            'No student honors added yet. Click "+ Add Degree" to showcase your past students\' highest honors!',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white54, fontSize: 12),
                          ),
                        ),
                      )
                    else
                      ..._achievements.asMap().entries.map((entry) {
                        final idx = entry.key;
                        final ach = entry.value;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.06),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color: _deepIndigo,
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: ach.photoUrl.isNotEmpty
                                      ? Image.network(ach.photoUrl, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.school, color: Colors.white38))
                                      : const Icon(Icons.workspace_premium_rounded, color: Colors.amber),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      ach.title,
                                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                                    ),
                                    const SizedBox(height: 2),
                                    Row(
                                      children: [
                                        if (ach.studentName.isNotEmpty) ...[
                                          Text(ach.studentName, style: const TextStyle(color: _brightCyan, fontSize: 11.5, fontWeight: FontWeight.w600)),
                                          const SizedBox(width: 8),
                                        ],
                                        if (ach.gradeOrScore.isNotEmpty)
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                            decoration: BoxDecoration(
                                              color: Colors.amber.withValues(alpha: 0.20),
                                              borderRadius: BorderRadius.circular(6),
                                              border: Border.all(color: Colors.amber.withValues(alpha: 0.5)),
                                            ),
                                            child: Text(ach.gradeOrScore, style: const TextStyle(color: Colors.amber, fontSize: 10, fontWeight: FontWeight.bold)),
                                          ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                                tooltip: 'Remove Degree',
                                onPressed: () {
                                  setState(() {
                                    _achievements.removeAt(idx);
                                  });
                                },
                              ),
                            ],
                          ),
                        );
                      }),
                  ],
                ),
              ),

              // 3. Footer with Save / Cancel
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.04),
                  border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.12))),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
                      child: const Text('Cancel', style: TextStyle(color: Colors.white60)),
                    ),
                    const SizedBox(width: 12),
                    FuturisticCapsuleButton(
                      text: _isSaving ? 'Saving Profile...' : 'Save Profile & Hall of Fame',
                      icon: _isSaving ? Icons.hourglass_top_rounded : Icons.save_rounded,
                      accentColor: _brightCyan,
                      secondaryColor: _electricPurple,
                      height: 44,
                      fontSize: 13.5,
                      onPressed: _isSaving ? null : _saveProfile,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: _brightCyan, size: 18),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(color: Colors.white, fontSize: 14.5, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildModalTextField({
    required String label,
    required TextEditingController controller,
    String? hint,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600)),
        const SizedBox(height: 5),
        TextField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          style: const TextStyle(color: Colors.white, fontSize: 13),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.white38, fontSize: 12),
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.07),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.14)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: _brightCyan, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPresetChip({required String label, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: _brightCyan.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: _brightCyan.withValues(alpha: 0.3)),
        ),
        child: Text(
          label,
          style: const TextStyle(color: _brightCyan, fontSize: 10, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
