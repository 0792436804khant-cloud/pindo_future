import 'package:flutter/material.dart';
import 'package:pindo_future_mobile/features/teachers/data/models/teacher_dashboard_model.dart';

class AddWorkplaceModal extends StatefulWidget {
  final Function(TeacherWorkplaceItem newWorkplace) onWorkplaceAdded;

  const AddWorkplaceModal({
    super.key,
    required this.onWorkplaceAdded,
  });

  static Future<void> show(
    BuildContext context, {
    required Function(TeacherWorkplaceItem newWorkplace) onWorkplaceAdded,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddWorkplaceModal(onWorkplaceAdded: onWorkplaceAdded),
    );
  }

  @override
  State<AddWorkplaceModal> createState() => _AddWorkplaceModalState();
}

class _AddWorkplaceModalState extends State<AddWorkplaceModal> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _wilayaController = TextEditingController(text: 'الجزائر العاصمة');
  final TextEditingController _roleController = TextEditingController(text: 'أستاذ رئيسي لمادة الرياضيات');
  final TextEditingController _periodController = TextEditingController(text: '2023 — حتى الآن');

  String _selectedType = 'ثانوية عمومية';

  final List<String> _types = const [
    'ثانوية عمومية',
    'أكاديمية تدريب ودعم مدرسي',
    'مدرسة خاصة معتمدة',
    'منصة واستوديو رقمي',
    'مركز دروس تقوية',
  ];

  static const Color _brightCyan = Color(0xFF00E5FF);
  static const Color _electricPurple = Color(0xFF7C4DFF);

  @override
  void dispose() {
    _nameController.dispose();
    _wilayaController.dispose();
    _roleController.dispose();
    _periodController.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يرجى إدخال اسم المؤسسة أو المدرسة أو المركز!'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    final newWorkplace = TeacherWorkplaceItem(
      id: 'wp_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      type: _selectedType,
      wilaya: _wilayaController.text.trim().isNotEmpty ? _wilayaController.text.trim() : 'الجزائر',
      role: _roleController.text.trim().isNotEmpty ? _roleController.text.trim() : 'أستاذ معتمد',
      period: _periodController.text.trim().isNotEmpty ? _periodController.text.trim() : 'حالياً',
      isCurrent: true,
    );

    widget.onWorkplaceAdded(newWorkplace);
    Navigator.of(context).pop();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تمت إضافة المؤسسة / مكان العمل إلى ملفك بنجاح!'),
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
                    color: _brightCyan.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.school_rounded, color: _brightCyan, size: 22),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'إضافة مؤسسة / مكان عمل جديد',
                        style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'أظهر لتلاميذك المدارس والثانويات والمراكز التي تعمل بها',
                        style: TextStyle(color: Colors.white60, fontSize: 11.5),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Name
            const Text(
              'اسم المؤسسة / الثانوية / الأكاديمية:',
              style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              style: const TextStyle(color: Colors.white, fontSize: 13.5),
              decoration: InputDecoration(
                hintText: 'مثال: ثانوية حسيبة بن بوعلي، أكاديمية النجاح...',
                hintStyle: const TextStyle(color: Colors.white38, fontSize: 12),
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.05),
                prefixIcon: const Icon(Icons.account_balance_rounded, color: _brightCyan, size: 18),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.white12)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: _brightCyan)),
              ),
            ),

            const SizedBox(height: 14),

            // Type
            const Text(
              'نوع المؤسسة:',
              style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white12),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedType,
                  dropdownColor: const Color(0xFF1E293B),
                  isExpanded: true,
                  icon: const Icon(Icons.arrow_drop_down, color: _brightCyan),
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                  items: _types.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedType = val);
                  },
                ),
              ),
            ),

            const SizedBox(height: 14),

            // Wilaya & Period
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('الولاية / المدينة:', style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _wilayaController,
                        style: const TextStyle(color: Colors.white, fontSize: 13),
                        decoration: InputDecoration(
                          hintText: 'الجزائر العاصمة',
                          hintStyle: const TextStyle(color: Colors.white38, fontSize: 11),
                          filled: true,
                          fillColor: Colors.white.withValues(alpha: 0.05),
                          prefixIcon: const Icon(Icons.location_on_outlined, color: _brightCyan, size: 16),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.white12)),
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: _brightCyan)),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('فترة العمل:', style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _periodController,
                        style: const TextStyle(color: Colors.white, fontSize: 13),
                        decoration: InputDecoration(
                          hintText: '2020 — حالياً',
                          hintStyle: const TextStyle(color: Colors.white38, fontSize: 11),
                          filled: true,
                          fillColor: Colors.white.withValues(alpha: 0.05),
                          prefixIcon: const Icon(Icons.calendar_today_outlined, color: _electricPurple, size: 16),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.white12)),
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: _electricPurple)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            // Role
            const Text(
              'صفتك أو دورك في المؤسسة:',
              style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _roleController,
              style: const TextStyle(color: Colors.white, fontSize: 13),
              decoration: InputDecoration(
                hintText: 'مثال: أستاذ التعليم الثانوي لمادة الرياضيات',
                hintStyle: const TextStyle(color: Colors.white38, fontSize: 12),
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.05),
                prefixIcon: const Icon(Icons.badge_outlined, color: _brightCyan, size: 18),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.white12)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: _brightCyan)),
              ),
            ),

            const SizedBox(height: 22),

            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: _submit,
                icon: const Icon(Icons.check_rounded, size: 18),
                label: const Text(
                  'حفظ وإضافة إلى ملفي الشخصي',
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
