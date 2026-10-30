import 'package:flutter/material.dart';
import 'package:pindo_future_mobile/features/teachers/data/models/teacher_dashboard_model.dart';

class AddStudentResultModal extends StatefulWidget {
  final Function(TeacherStudentResultItem newResult) onResultAdded;

  const AddStudentResultModal({
    super.key,
    required this.onResultAdded,
  });

  static Future<void> show(
    BuildContext context, {
    required Function(TeacherStudentResultItem newResult) onResultAdded,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddStudentResultModal(onResultAdded: onResultAdded),
    );
  }

  @override
  State<AddStudentResultModal> createState() => _AddStudentResultModalState();
}

class _AddStudentResultModalState extends State<AddStudentResultModal> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _markController = TextEditingController(text: '19.5');
  final TextEditingController _averageController = TextEditingController(text: '18.40');
  final TextEditingController _wilayaController = TextEditingController(text: 'الجزائر العاصمة');
  final TextEditingController _schoolController = TextEditingController(text: 'ثانوية الرياضيات بالقبة');
  final TextEditingController _testimonialController = TextEditingController();

  String _selectedExam = 'بكالوريا 2024';
  String _selectedStream = 'شعبة علوم تجريبية';

  final List<String> _exams = const [
    'بكالوريا 2024',
    'بكالوريا 2023',
    'شهادة التعليم المتوسط (BEM)',
    'امتحان البكالوريا التجريبية',
  ];

  final List<String> _streams = const [
    'شعبة علوم تجريبية',
    'شعبة رياضيات',
    'شعبة تقني رياضي',
    'شعبة تسيير واقتصاد',
    'شعبة لغات أجنبية وآداب',
    'التعليم المتوسط (BEM)',
  ];

  static const Color _brightCyan = Color(0xFF00E5FF);
  static const Color _gold = Color(0xFFFFD700);

  @override
  void dispose() {
    _nameController.dispose();
    _markController.dispose();
    _averageController.dispose();
    _wilayaController.dispose();
    _schoolController.dispose();
    _testimonialController.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يرجى إدخال اسم التلميذ المتفوق!'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    final mark = double.tryParse(_markController.text.replaceAll(',', '.')) ?? 19.0;
    final average = double.tryParse(_averageController.text.replaceAll(',', '.'));

    final newResult = TeacherStudentResultItem(
      id: 'sr_${DateTime.now().millisecondsSinceEpoch}',
      studentName: name,
      exam: _selectedExam,
      stream: _selectedStream,
      mark: mark,
      generalAverage: average,
      appreciation: mark >= 19.0 ? 'امتياز وتفوق وطني 🏆' : 'تفوق ونجاح باهر 🌟',
      wilaya: _wilayaController.text.trim().isNotEmpty ? _wilayaController.text.trim() : 'الجزائر العاصمة',
      school: _schoolController.text.trim().isNotEmpty ? _schoolController.text.trim() : null,
      testimonial: _testimonialController.text.trim().isNotEmpty
          ? _testimonialController.text.trim()
          : 'شكراً للأستاذ على المتابعة القيمة والشرح المتميز الذي أوصلني لهذا المعدل المشرف.',
    );

    widget.onResultAdded(newResult);
    Navigator.of(context).pop();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تمت إضافة نتيجة التلميذ إلى لوحة الشرف بنجاح! 🎉'),
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
        border: Border.all(color: _gold.withValues(alpha: 0.4), width: 1.2),
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

            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _gold.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.emoji_events_rounded, color: _gold, size: 24),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'إضافة نتيجة تلميذ إلى لوحة الشرف',
                        style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'احتفل بنقاط ومعدلات طلابك المتفوقين في البكالوريا وشهادة التعليم المتوسط',
                        style: TextStyle(color: Colors.white60, fontSize: 11.5),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Student Name
            const Text(
              'اسم التلميذ(ة):',
              style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              style: const TextStyle(color: Colors.white, fontSize: 13.5),
              decoration: InputDecoration(
                hintText: 'مثال: سارة مهدي، كريم بلقاسم...',
                hintStyle: const TextStyle(color: Colors.white38, fontSize: 12),
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.05),
                prefixIcon: const Icon(Icons.person_outline, color: _gold, size: 18),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.white12)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: _gold)),
              ),
            ),

            const SizedBox(height: 14),

            // Exam & Stream Row
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('الامتحان:', style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white12),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedExam,
                            dropdownColor: const Color(0xFF1E293B),
                            isExpanded: true,
                            icon: const Icon(Icons.arrow_drop_down, color: _gold),
                            style: const TextStyle(color: Colors.white, fontSize: 12),
                            items: _exams.map((e) => DropdownMenuItem(value: e, child: Text(e, overflow: TextOverflow.ellipsis))).toList(),
                            onChanged: (val) {
                              if (val != null) setState(() => _selectedExam = val);
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('الشعبة الدراسية:', style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white12),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedStream,
                            dropdownColor: const Color(0xFF1E293B),
                            isExpanded: true,
                            icon: const Icon(Icons.arrow_drop_down, color: _gold),
                            style: const TextStyle(color: Colors.white, fontSize: 12),
                            items: _streams.map((s) => DropdownMenuItem(value: s, child: Text(s, overflow: TextOverflow.ellipsis))).toList(),
                            onChanged: (val) {
                              if (val != null) setState(() => _selectedStream = val);
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            // Mark & General Average Row
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('نقطة المادة (من 20):', style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _markController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        style: const TextStyle(color: _gold, fontSize: 14, fontWeight: FontWeight.bold),
                        decoration: InputDecoration(
                          hintText: 'مثال: 19.5',
                          hintStyle: const TextStyle(color: Colors.white38, fontSize: 12),
                          filled: true,
                          fillColor: Colors.white.withValues(alpha: 0.05),
                          prefixIcon: const Icon(Icons.grade_rounded, color: _gold, size: 16),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.white12)),
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: _gold)),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('المعدل العام (اختياري):', style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _averageController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        style: const TextStyle(color: _brightCyan, fontSize: 14, fontWeight: FontWeight.bold),
                        decoration: InputDecoration(
                          hintText: 'مثال: 18.72',
                          hintStyle: const TextStyle(color: Colors.white38, fontSize: 12),
                          filled: true,
                          fillColor: Colors.white.withValues(alpha: 0.05),
                          prefixIcon: const Icon(Icons.analytics_outlined, color: _brightCyan, size: 16),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.white12)),
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: _brightCyan)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            // Wilaya & School
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('الولاية:', style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _wilayaController,
                        style: const TextStyle(color: Colors.white, fontSize: 13),
                        decoration: InputDecoration(
                          hintText: 'الجزائر العاصمة',
                          hintStyle: const TextStyle(color: Colors.white38, fontSize: 11),
                          filled: true,
                          fillColor: Colors.white.withValues(alpha: 0.05),
                          prefixIcon: const Icon(Icons.location_on_outlined, color: Colors.white60, size: 16),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.white12)),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('الثانوية / المدرسة:', style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _schoolController,
                        style: const TextStyle(color: Colors.white, fontSize: 13),
                        decoration: InputDecoration(
                          hintText: 'ثانوية الرياضيات بالقبة',
                          hintStyle: const TextStyle(color: Colors.white38, fontSize: 11),
                          filled: true,
                          fillColor: Colors.white.withValues(alpha: 0.05),
                          prefixIcon: const Icon(Icons.account_balance_outlined, color: Colors.white60, size: 16),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.white12)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            // Testimonial
            const Text(
              'كلمة التلميذ أو الانطباع (Testimonial):',
              style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _testimonialController,
              maxLines: 2,
              style: const TextStyle(color: Colors.white, fontSize: 13),
              decoration: InputDecoration(
                hintText: 'اكتب كلمة التلميذ حول استفادته من الحصص وسلاسل التمارين...',
                hintStyle: const TextStyle(color: Colors.white38, fontSize: 12),
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.05),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.white12)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: _gold)),
              ),
            ),

            const SizedBox(height: 22),

            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: _submit,
                icon: const Icon(Icons.star_rounded, size: 20),
                label: const Text(
                  'نشر النتيجة في لوحة الشرف 🏆',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _gold,
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
