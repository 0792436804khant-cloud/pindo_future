import 'package:flutter/material.dart';
import 'package:pindo_future_mobile/features/teachers/data/models/teacher_dashboard_model.dart';

class AddCohortScheduleModal extends StatefulWidget {
  final Function(TeacherCohortScheduleItem newCohortSchedule) onCohortScheduleAdded;

  const AddCohortScheduleModal({
    super.key,
    required this.onCohortScheduleAdded,
  });

  static Future<void> show(
    BuildContext context, {
    required Function(TeacherCohortScheduleItem newCohortSchedule) onCohortScheduleAdded,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddCohortScheduleModal(onCohortScheduleAdded: onCohortScheduleAdded),
    );
  }

  @override
  State<AddCohortScheduleModal> createState() => _AddCohortScheduleModalState();
}

class _AddCohortScheduleModalState extends State<AddCohortScheduleModal> {
  final TextEditingController _cohortNameController = TextEditingController(text: 'فوج التميز للبكالوريا');
  final TextEditingController _subjectController = TextEditingController(text: 'الرياضيات');
  final TextEditingController _daysAndTimesController = TextEditingController(text: 'الجمعة 15:00 - 17:30 | السبت 18:00 - 20:30');
  final TextEditingController _locationController = TextEditingController(text: 'أكاديمية النجاح (القبة) + بث مباشر بيندو');
  final TextEditingController _maxCapacityController = TextEditingController(text: '45');
  final TextEditingController _priceController = TextEditingController(text: '3500');

  String _selectedLevelAndStream = '3 ثانوي • شعبة علوم تجريبية + رياضيات';
  String _selectedStatus = 'مفتوح للتسجيل';

  final List<String> _levelsAndStreams = const [
    '3 ثانوي • شعبة علوم تجريبية + رياضيات',
    '3 ثانوي • شعبة تقني رياضي',
    '3 ثانوي • شعبة تسيير واقتصاد',
    '3 ثانوي • شعبة لغات أجنبية وآداب',
    '2 ثانوي • علوم تجريبية ورياضيات',
    '1 ثانوي • جذع مشترك علوم وتكنولوجيا',
    '4 متوسط • شهادة التعليم المتوسط (BEM)',
  ];

  final List<String> _statuses = const [
    'مفتوح للتسجيل',
    'آخر المقاعد المتبقية',
    'الفوج مكتمل',
  ];

  static const Color _brightCyan = Color(0xFF00E5FF);
  static const Color _electricPurple = Color(0xFF7C4DFF);

  @override
  void dispose() {
    _cohortNameController.dispose();
    _subjectController.dispose();
    _daysAndTimesController.dispose();
    _locationController.dispose();
    _maxCapacityController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _cohortNameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يرجى إدخال اسم الفوج الدراسي!'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    final maxCap = int.tryParse(_maxCapacityController.text.trim()) ?? 45;
    final price = double.tryParse(_priceController.text.trim()) ?? 3500.0;

    final newSchedule = TeacherCohortScheduleItem(
      id: 'cs_${DateTime.now().millisecondsSinceEpoch}',
      cohortName: name,
      subject: _subjectController.text.trim().isNotEmpty ? _subjectController.text.trim() : 'الرياضيات',
      levelAndStream: _selectedLevelAndStream,
      daysAndTimes: _daysAndTimesController.text.trim().isNotEmpty
          ? _daysAndTimesController.text.trim()
          : 'الجمعة 16:00 - 18:00',
      location: _locationController.text.trim().isNotEmpty
          ? _locationController.text.trim()
          : 'حضوري + عن بُعد',
      enrolledCount: 0,
      maxCapacity: maxCap,
      monthlyPrice: price,
      status: _selectedStatus,
    );

    widget.onCohortScheduleAdded(newSchedule);
    Navigator.of(context).pop();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تمت إضافة موعد الفوج إلى جدولك الشخصي بنجاح!'),
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
        border: Border.all(color: _electricPurple.withValues(alpha: 0.35), width: 1.2),
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
                    color: _electricPurple.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _electricPurple.withValues(alpha: 0.3)),
                  ),
                  child: const Icon(Icons.calendar_month_rounded, color: _brightCyan, size: 22),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'إضافة موعد وفوج جديد',
                        style: TextStyle(color: Colors.white, fontSize: 16.5, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'عرض أوقات الحصص والقاعات للطلبة وأولياء الأمور',
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

            // Cohort Name Field
            _buildField(
              label: 'اسم الفوج الدراسي',
              controller: _cohortNameController,
              hint: 'مثال: فوج النخبة للبكالوريا، الفوج النموذجي...',
              icon: Icons.groups_rounded,
            ),
            const SizedBox(height: 14),

            // Subject Field
            _buildField(
              label: 'المادة الدراسية',
              controller: _subjectController,
              hint: 'مثال: الرياضيات، العلوم الفيزيائية...',
              icon: Icons.menu_book_rounded,
            ),
            const SizedBox(height: 14),

            // Level & Stream Dropdown
            const Text(
              'المستوى والشعبة',
              style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white12),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedLevelAndStream,
                  dropdownColor: const Color(0xFF1E293B),
                  isExpanded: true,
                  style: const TextStyle(color: Colors.white, fontSize: 12.5),
                  items: _levelsAndStreams.map((lvl) {
                    return DropdownMenuItem(
                      value: lvl,
                      child: Text(lvl),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedLevelAndStream = val);
                  },
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Days & Times Field
            _buildField(
              label: 'أيام وتوقيت الحصص الأسبوعية',
              controller: _daysAndTimesController,
              hint: 'مثال: الجمعة 15:00 - 17:30 | السبت 18:00 - 20:30',
              icon: Icons.access_time_rounded,
            ),
            const SizedBox(height: 14),

            // Location Field
            _buildField(
              label: 'مقر التدريس / القاعة أو المنصة',
              controller: _locationController,
              hint: 'مثال: أكاديمية النجاح (القبة) + بث مباشر بيندو',
              icon: Icons.place_rounded,
            ),
            const SizedBox(height: 14),

            // Capacity & Price Row
            Row(
              children: [
                Expanded(
                  child: _buildField(
                    label: 'السعة القصوى (طالب)',
                    controller: _maxCapacityController,
                    hint: '50',
                    icon: Icons.people_alt_rounded,
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildField(
                    label: 'السعر الشهري (دج)',
                    controller: _priceController,
                    hint: '3500',
                    icon: Icons.payments_rounded,
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Registration Status
            const Text(
              'حالة التسجيل في الفوج',
              style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _statuses.map((status) {
                final isSelected = _selectedStatus == status;
                return ChoiceChip(
                  label: Text(
                    status,
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
                    if (selected) setState(() => _selectedStatus = status);
                  },
                );
              }).toList(),
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
                  'حفظ وإضافة الفوج لملفي الشخصي 🚀',
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
