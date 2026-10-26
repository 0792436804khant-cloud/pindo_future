import 'package:flutter/material.dart';

class CreateCohortModal extends StatefulWidget {
  final Future<void> Function(Map<String, dynamic> payload)? onSave;

  const CreateCohortModal({
    super.key,
    this.onSave,
  });

  static Future<void> show(BuildContext context, {Future<void> Function(Map<String, dynamic> payload)? onSave}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CreateCohortModal(onSave: onSave),
    );
  }

  @override
  State<CreateCohortModal> createState() => _CreateCohortModalState();
}

class _CreateCohortModalState extends State<CreateCohortModal> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController(text: '3500');
  final _maxStudentsController = TextEditingController(text: '50');

  String _selectedSubject = 'الرياضيات';
  String _selectedLevel = 'ثالثة ثانوي';
  String _selectedStream = 'علوم تجريبية';
  bool _includeLibrary = true;
  bool _isOpenRegistration = true;
  bool _isSubmitting = false;

  static const Color _brightCyan = Color(0xFF00E5FF);
  static const Color _electricPurple = Color(0xFF7C4DFF);

  final List<String> _subjects = const [
    'الرياضيات',
    'الفيزياء',
    'العلوم الطبيعية',
    'اللغة العربية',
    'اللغة الفرنسية',
    'اللغة الإنجليزية',
    'الفلسفة',
  ];

  final List<String> _levels = const [
    'ثالثة ثانوي',
    'ثانية ثانوي',
    'أولى ثانوي',
    'رابعة متوسط (BEM)',
    'ثالثة متوسط',
  ];

  final List<String> _streams = const [
    'علوم تجريبية',
    'رياضيات',
    'تقني رياضي',
    'تسيير واقتصاد',
    'آداب وفلسفة',
    'لغات أجنبية',
    'تعليم متوسط عام',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _maxStudentsController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);
    final payload = {
      'name': _nameController.text.trim(),
      'subject': _selectedSubject,
      'academic_level': _selectedLevel,
      'stream': _selectedStream,
      'description': _descriptionController.text.trim(),
      'monthly_price': double.tryParse(_priceController.text) ?? 3500.0,
      'max_students': int.tryParse(_maxStudentsController.text) ?? 50,
      'include_library': _includeLibrary,
      'is_active': _isOpenRegistration,
    };

    if (widget.onSave != null) {
      await widget.onSave!(payload);
    }

    if (mounted) {
      setState(() => _isSubmitting = false);
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم إنشاء الفوج الدراسي بنجاح وإضافته إلى قائمة أفواجك.'),
          backgroundColor: Color(0xFF10B981),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: 20,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.90,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFF0F172A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(top: BorderSide(color: Colors.white24, width: 1.2)),
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white30,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Row(
                children: [
                  Icon(Icons.group_add_rounded, color: _brightCyan, size: 24),
                  SizedBox(width: 8),
                  Text(
                    'إنشاء فوج دراسي جديد',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // اسم الفوج
              _buildLabel('اسم الفوج *'),
              TextFormField(
                controller: _nameController,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration(hint: 'مثال: رياضيات — بكالوريا 2027 تميز'),
                validator: (val) => val == null || val.trim().isEmpty ? 'يرجى إدخال اسم الفوج' : null,
              ),
              const SizedBox(height: 14),

              // المادة والمستوى
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('المادة الدراسية'),
                        _buildDropdown(
                          value: _selectedSubject,
                          items: _subjects,
                          onChanged: (val) => setState(() => _selectedSubject = val!),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('المستوى'),
                        _buildDropdown(
                          value: _selectedLevel,
                          items: _levels,
                          onChanged: (val) => setState(() => _selectedLevel = val!),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // الشعبة
              _buildLabel('الشعبة الدراسية'),
              _buildDropdown(
                value: _selectedStream,
                items: _streams,
                onChanged: (val) => setState(() => _selectedStream = val!),
              ),
              const SizedBox(height: 14),

              // السعر والحد الأقصى
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('سعر الاشتراك الشهري (دج) *'),
                        TextFormField(
                          controller: _priceController,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(color: Colors.white),
                          decoration: _inputDecoration(hint: '3500'),
                          validator: (val) => val == null || val.isEmpty ? 'مطلوب' : null,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('الحد الأقصى للطلاب'),
                        TextFormField(
                          controller: _maxStudentsController,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(color: Colors.white),
                          decoration: _inputDecoration(hint: '50'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // وصف البرنامج
              _buildLabel('وصف البرنامج ومواعيد الحصص (اختياري)'),
              TextFormField(
                controller: _descriptionController,
                maxLines: 2,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration(hint: 'حصة أسبوعية كل جمعة 18:00 تتضمن مراجعة وحل مواضيع وزارية.'),
              ),
              const SizedBox(height: 16),

              // خيارات إضافية (مكتبة + تسجيل مفتوح)
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                activeColor: _brightCyan,
                title: const Text('إتاحة مكتبة التسجيلات الإلكترونية للطلاب', style: TextStyle(color: Colors.white, fontSize: 13.5)),
                subtitle: const Text('تمكين المشتركين من مراجعة الحصص المسجلة مع علامة مائية', style: TextStyle(color: Colors.white54, fontSize: 11.5)),
                value: _includeLibrary,
                onChanged: (val) => setState(() => _includeLibrary = val),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                activeColor: _brightCyan,
                title: const Text('فتح التسجيل الفوري في الفوج', style: TextStyle(color: Colors.white, fontSize: 13.5)),
                subtitle: const Text('يظهر الفوج مباشرة في قسم اكتشف للطلاب', style: TextStyle(color: Colors.white54, fontSize: 11.5)),
                value: _isOpenRegistration,
                onChanged: (val) => setState(() => _isOpenRegistration = val),
              ),
              const SizedBox(height: 20),

              // زر التأكيد
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _electricPurple,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('حفظ وإنشاء الفوج الآن', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(text, style: const TextStyle(color: Colors.white70, fontSize: 12.5, fontWeight: FontWeight.w600)),
    );
  }

  InputDecoration _inputDecoration({required String hint}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.white30, fontSize: 13),
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.06),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.12)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _brightCyan),
      ),
    );
  }

  Widget _buildDropdown({
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          dropdownColor: const Color(0xFF0F172A),
          style: const TextStyle(color: Colors.white, fontSize: 13),
          icon: const Icon(Icons.arrow_drop_down, color: _brightCyan),
          items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
