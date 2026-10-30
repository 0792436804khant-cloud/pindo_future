import 'package:flutter/material.dart';
import 'package:pindo_future_mobile/features/teachers/data/models/teacher_dashboard_model.dart';

class AddTeacherStoryModal extends StatefulWidget {
  final Function(TeacherStoryItem newStory) onStoryAdded;

  const AddTeacherStoryModal({
    super.key,
    required this.onStoryAdded,
  });

  static Future<void> show(
    BuildContext context, {
    required Function(TeacherStoryItem newStory) onStoryAdded,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddTeacherStoryModal(onStoryAdded: onStoryAdded),
    );
  }

  @override
  State<AddTeacherStoryModal> createState() => _AddTeacherStoryModalState();
}

class _AddTeacherStoryModalState extends State<AddTeacherStoryModal> {
  final TextEditingController _textController = TextEditingController();
  final TextEditingController _buttonTextController = TextEditingController();

  String _selectedTag = '💡 نصيحة منهجية';
  bool _isLiveAlert = false;

  final List<String> _tags = const [
    '💡 نصيحة منهجية',
    '🔴 بث مباشر اليوم',
    '📝 حل مسألة نموذجية',
    '🏆 فخر ونتائج البكالوريا',
    '📢 إعلان للأفواج',
  ];

  static const Color _brightCyan = Color(0xFF00E5FF);
  static const Color _electricPurple = Color(0xFF7C4DFF);

  @override
  void dispose() {
    _textController.dispose();
    _buttonTextController.dispose();
    super.dispose();
  }

  void _submit() {
    final text = _textController.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يرجى كتابة نص الستوري أولاً!'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    final newStory = TeacherStoryItem(
      id: 'story_${DateTime.now().millisecondsSinceEpoch}',
      text: text,
      timeAgo: 'الآن',
      viewsCount: 1,
      isLiveAlert: _isLiveAlert || _selectedTag.contains('بث مباشر'),
      tag: _selectedTag,
      actionButtonText: _buttonTextController.text.trim().isNotEmpty
          ? _buttonTextController.text.trim()
          : (_isLiveAlert ? 'الانتقال لقاعة البث المباشر' : null),
    );

    widget.onStoryAdded(newStory);
    Navigator.of(context).pop();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم نشر الستوري بنجاح! ستظهر لجميع طلابك ومتابعيك.'),
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
        border: Border.all(color: _electricPurple.withValues(alpha: 0.4), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.6),
            blurRadius: 30,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      padding: EdgeInsets.fromLTRB(20, 16, 20, 24 + bottomInset),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _electricPurple.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.add_circle_outline_rounded, color: _brightCyan, size: 22),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'إضافة ستوري جديدة (Story)',
                        style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'شارك نصيحة، تنبيه بث مباشر، أو إعلان يظهر في دائرة بروفايلك',
                        style: TextStyle(color: Colors.white60, fontSize: 11.5),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Tag selector chips
            const Text(
              'نوع الستوري والتصنيف:',
              style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _tags.map((tag) {
                final isSelected = _selectedTag == tag;
                return ChoiceChip(
                  label: Text(
                    tag,
                    style: TextStyle(
                      color: isSelected ? Colors.black : Colors.white,
                      fontSize: 11.5,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  selected: isSelected,
                  selectedColor: _brightCyan,
                  backgroundColor: Colors.white.withValues(alpha: 0.06),
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _selectedTag = tag;
                        if (tag.contains('بث مباشر')) {
                          _isLiveAlert = true;
                          _buttonTextController.text = 'الانتقال لقاعة البث المباشر';
                        }
                      });
                    }
                  },
                );
              }).toList(),
            ),

            const SizedBox(height: 18),

            // Story Text
            const Text(
              'محتوى الستوري:',
              style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _textController,
              maxLines: 4,
              maxLength: 280,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'اكتب نصيحة، ملاحظة هامة لطلابك، أو تنبيه موعد الحصة القادمة...',
                hintStyle: const TextStyle(color: Colors.white38, fontSize: 13),
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.05),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Colors.white12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: _brightCyan, width: 1.5),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Action button input
            const Text(
              'زر إجراء تفاعلي (اختياري):',
              style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _buttonTextController,
              style: const TextStyle(color: Colors.white, fontSize: 13),
              decoration: InputDecoration(
                hintText: 'مثال: الانتقال للبث، تحميل السلسلة...',
                hintStyle: const TextStyle(color: Colors.white38, fontSize: 12),
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.05),
                prefixIcon: const Icon(Icons.link_rounded, color: _brightCyan, size: 18),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.white12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: _brightCyan),
                ),
              ),
            ),

            const SizedBox(height: 22),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: _submit,
                icon: const Icon(Icons.send_rounded, size: 18),
                label: const Text(
                  'نشر الستوري في الملف الشخصي الآن',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _brightCyan,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 6,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
