import 'package:flutter/material.dart';
import 'package:pindo_future_mobile/features/teachers/data/models/teacher_dashboard_model.dart';

class EditTeacherProfileModal extends StatefulWidget {
  final TeacherProfileInfo currentProfile;
  final Function(TeacherProfileInfo updatedProfile) onProfileSaved;

  const EditTeacherProfileModal({
    super.key,
    required this.currentProfile,
    required this.onProfileSaved,
  });

  static Future<void> show(
    BuildContext context, {
    required TeacherProfileInfo currentProfile,
    required Function(TeacherProfileInfo updatedProfile) onProfileSaved,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => EditTeacherProfileModal(
        currentProfile: currentProfile,
        onProfileSaved: onProfileSaved,
      ),
    );
  }

  @override
  State<EditTeacherProfileModal> createState() => _EditTeacherProfileModalState();
}

class _EditTeacherProfileModalState extends State<EditTeacherProfileModal> {
  late final TextEditingController _nameController;
  late final TextEditingController _headlineController;
  late final TextEditingController _bioController;
  late final TextEditingController _wilayaController;
  late final TextEditingController _experienceController;
  late final TextEditingController _facebookController;
  late final TextEditingController _telegramController;
  late final TextEditingController _youtubeController;

  static const Color _brightCyan = Color(0xFF00E5FF);
  static const Color _electricPurple = Color(0xFF7C4DFF);

  @override
  void initState() {
    super.initState();
    final p = widget.currentProfile;
    _nameController = TextEditingController(text: p.name);
    _headlineController = TextEditingController(text: p.headline);
    _bioController = TextEditingController(text: p.bio);
    _wilayaController = TextEditingController(text: p.wilaya);
    _experienceController = TextEditingController(text: p.yearsOfExperience.toString());
    _facebookController = TextEditingController(text: p.facebookUrl ?? 'https://facebook.com');
    _telegramController = TextEditingController(text: p.telegramUrl ?? 'https://t.me');
    _youtubeController = TextEditingController(text: p.youtubeUrl ?? 'https://youtube.com');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _headlineController.dispose();
    _bioController.dispose();
    _wilayaController.dispose();
    _experienceController.dispose();
    _facebookController.dispose();
    _telegramController.dispose();
    _youtubeController.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يرجى إدخال اسم الأستاذ!'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    final exp = int.tryParse(_experienceController.text.trim()) ?? widget.currentProfile.yearsOfExperience;

    final updated = TeacherProfileInfo(
      id: widget.currentProfile.id,
      name: name,
      email: widget.currentProfile.email,
      teacherId: widget.currentProfile.teacherId,
      avatarUrl: widget.currentProfile.avatarUrl,
      coverImageUrl: widget.currentProfile.coverImageUrl,
      isVerified: widget.currentProfile.isVerified,
      yearsOfExperience: exp,
      headline: _headlineController.text.trim().isNotEmpty
          ? _headlineController.text.trim()
          : widget.currentProfile.headline,
      wilaya: _wilayaController.text.trim().isNotEmpty
          ? _wilayaController.text.trim()
          : widget.currentProfile.wilaya,
      bio: _bioController.text.trim().isNotEmpty
          ? _bioController.text.trim()
          : widget.currentProfile.bio,
      subjects: widget.currentProfile.subjects,
      levels: widget.currentProfile.levels,
      stories: widget.currentProfile.stories,
      workplaces: widget.currentProfile.workplaces,
      cohortSchedules: widget.currentProfile.cohortSchedules,
      studentResults: widget.currentProfile.studentResults,
      facebookUrl: _facebookController.text.trim(),
      telegramUrl: _telegramController.text.trim(),
      youtubeUrl: _youtubeController.text.trim(),
    );

    widget.onProfileSaved(updated);
    Navigator.of(context).pop();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم تحديث بيانات الملف الشخصي بنجاح! 🎉'),
        backgroundColor: Color(0xFF10B981),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border.all(color: _brightCyan.withValues(alpha: 0.35), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.6),
            blurRadius: 25,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      padding: EdgeInsets.fromLTRB(20, 16, 20, 20 + bottomInset),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle Bar
            Center(
              child: Container(
                width: 44,
                height: 4.5,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 18),

            // Modal Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: _brightCyan.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _brightCyan.withValues(alpha: 0.3)),
                  ),
                  child: const Icon(Icons.manage_accounts_rounded, color: _brightCyan, size: 22),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'تعديل واجهة وملف الأستاذ',
                        style: TextStyle(color: Colors.white, fontSize: 16.5, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'تحديث الاسم، التخصص، النبذة التعريفية، وروابط التواصل',
                        style: TextStyle(color: Colors.white60, fontSize: 11.5),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: Colors.white60),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Name Field
            _buildField(
              label: 'الاسم الكامل واللقب',
              controller: _nameController,
              hint: 'الأستاذ محمد بن عيسى',
              icon: Icons.person_rounded,
            ),
            const SizedBox(height: 14),

            // Headline Field
            _buildField(
              label: 'المسمى الوظيفي / التخصص',
              controller: _headlineController,
              hint: 'أستاذ رئيسي لمادة الرياضيات ومعد سلاسل البكالوريا',
              icon: Icons.school_rounded,
            ),
            const SizedBox(height: 14),

            // Bio Field
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'النبذة التعريفية (Bio)',
                  style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: _bioController,
                  maxLines: 3,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                  decoration: InputDecoration(
                    hintText: 'اكتب نبذة عن مسارك الأكاديمي، طريقتك في التدريس، ورسالتك لطلاب البكالوريا...',
                    hintStyle: const TextStyle(color: Colors.white30, fontSize: 12),
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.05),
                    contentPadding: const EdgeInsets.all(14),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.white12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: _brightCyan, width: 1.2),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Wilaya & Experience Row
            Row(
              children: [
                Expanded(
                  child: _buildField(
                    label: 'الولاية والمدينة',
                    controller: _wilayaController,
                    hint: 'الجزائر العاصمة',
                    icon: Icons.location_on_rounded,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildField(
                    label: 'سنوات الخبرة',
                    controller: _experienceController,
                    hint: '12',
                    icon: Icons.workspace_premium_rounded,
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),

            // Social Accounts Header
            const Row(
              children: [
                Icon(Icons.share_rounded, color: _electricPurple, size: 16),
                SizedBox(width: 6),
                Text(
                  'حسابات ومنصات التواصل الاجتماعي',
                  style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Facebook URL
            _buildField(
              label: 'رابط صفحة الفيسبوك (Facebook)',
              controller: _facebookController,
              hint: 'https://facebook.com/prof.math',
              icon: Icons.facebook_rounded,
            ),
            const SizedBox(height: 12),

            // Telegram URL
            _buildField(
              label: 'رابط قناة التيليغرام (Telegram)',
              controller: _telegramController,
              hint: 'https://t.me/prof_math',
              icon: Icons.send_rounded,
            ),
            const SizedBox(height: 12),

            // YouTube URL
            _buildField(
              label: 'رابط قناة اليوتيوب (YouTube)',
              controller: _youtubeController,
              hint: 'https://youtube.com/@prof_math',
              icon: Icons.play_circle_fill_rounded,
            ),
            const SizedBox(height: 24),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: _submit,
                icon: const Icon(Icons.check_circle_rounded, size: 18),
                label: const Text(
                  'حفظ التعديلات في الملف الشخصي ✨',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _brightCyan,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: const TextStyle(color: Colors.white, fontSize: 13),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.white30, fontSize: 12),
            prefixIcon: Icon(icon, color: Colors.white54, size: 18),
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.05),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.white12),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _brightCyan, width: 1.2),
            ),
          ),
        ),
      ],
    );
  }
}
