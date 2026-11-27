import 'package:flutter/material.dart';
import '../../../../../core/config/platform_payment_config.dart';
import '../../../../../core/constants/algerian_education_constants.dart';

class CreateCohortModal extends StatefulWidget {
  final Future<void> Function(Map<String, dynamic> payload)? onSave;
  final List<String> allowedTeachingYears;
  final List<String> allowedTeachingSubjects;

  const CreateCohortModal({
    super.key,
    this.onSave,
    this.allowedTeachingYears = const [],
    this.allowedTeachingSubjects = const [],
  });

  static Future<void> show(
    BuildContext context, {
    Future<void> Function(Map<String, dynamic> payload)? onSave,
    List<String> allowedTeachingYears = const [],
    List<String> allowedTeachingSubjects = const [],
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CreateCohortModal(
        onSave: onSave,
        allowedTeachingYears: allowedTeachingYears,
        allowedTeachingSubjects: allowedTeachingSubjects,
      ),
    );
  }

  @override
  State<CreateCohortModal> createState() => _CreateCohortModalState();
}

class _CreateCohortModalState extends State<CreateCohortModal> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _livePriceController = TextEditingController(text: '2500');
  final _libraryPriceController = TextEditingController(text: '1500');
  final _bundlePriceController = TextEditingController(text: '3500');
  final _maxStudentsController = TextEditingController(text: '50');

  late List<String> _levels;
  late List<String> _streams;
  late List<String> _subjects;

  late String _selectedLevel;
  late String _selectedStream;
  late String _selectedSubject;
  bool _includeLibrary = true;
  bool _isOpenRegistration = true;
  bool _isSubmitting = false;

  static const Color _brightCyan = Color(0xFF00E5FF);
  static const Color _electricPurple = Color(0xFF7C4DFF);

  @override
  void initState() {
    super.initState();
    _levels = AlgerianEducationConstants.resolveTeacherCohortYears(
      widget.allowedTeachingYears,
    );
    _selectedLevel = _levels.first;
    _streams = AlgerianEducationConstants.streamsForYearLabel(_selectedLevel);
    _selectedStream = _streams.first;
    _subjects = _buildSubjectOptions(_selectedLevel);
    _selectedSubject = _subjects.first;

    _livePriceController.addListener(_refreshPricingPreview);
    _libraryPriceController.addListener(_refreshPricingPreview);
    _bundlePriceController.addListener(_refreshPricingPreview);
  }

  void _refreshPricingPreview() {
    if (mounted) setState(() {});
  }

  List<String> _buildSubjectOptions(String level) {
    final base = AlgerianEducationConstants.subjectsForYearLabel(level);
    final merged = <String>[...base];
    for (final s in widget.allowedTeachingSubjects) {
      final clean = s.trim();
      if (clean.isNotEmpty && !merged.any((m) => m.contains(clean) || clean.contains(m))) {
        merged.insert(0, clean);
      }
    }
    return merged;
  }

  void _onLevelChanged(String newLevel) {
    final newStreams = AlgerianEducationConstants.streamsForYearLabel(newLevel);
    final newSubjects = _buildSubjectOptions(newLevel);
    setState(() {
      _selectedLevel = newLevel;
      _streams = newStreams;
      if (!_streams.contains(_selectedStream)) {
        _selectedStream = _streams.first;
      }
      _subjects = newSubjects;
      if (!_subjects.contains(_selectedSubject)) {
        _selectedSubject = _subjects.first;
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _livePriceController.dispose();
    _libraryPriceController.dispose();
    _bundlePriceController.dispose();
    _maxStudentsController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final livePrice = double.tryParse(_livePriceController.text.trim()) ?? 2500.0;
    final libPrice = _includeLibrary ? (double.tryParse(_libraryPriceController.text.trim()) ?? 1500.0) : 0.0;
    final bundlePrice = _includeLibrary
        ? (double.tryParse(_bundlePriceController.text.trim()) ?? (livePrice + libPrice))
        : livePrice;

    setState(() => _isSubmitting = true);
    final payload = {
      'name': _nameController.text.trim(),
      'subject': _selectedSubject,
      'academic_level': _selectedLevel,
      'stream': _selectedStream,
      'description': _descriptionController.text.trim(),
      'monthly_price': bundlePrice,
      'live_sessions_price': livePrice,
      'library_price': libPrice,
      'bundle_price': bundlePrice,
      'max_students': int.tryParse(_maxStudentsController.text) ?? 50,
      'include_library': _includeLibrary,
      'is_active': _isOpenRegistration,
    };

    try {
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
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تعذر حفظ الفوج: $e'),
            backgroundColor: const Color(0xFFEF4444),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final liveInt = int.tryParse(_livePriceController.text.trim()) ?? 0;
    final libInt = _includeLibrary ? (int.tryParse(_libraryPriceController.text.trim()) ?? 0) : 0;
    final bundleInt = _includeLibrary ? (int.tryParse(_bundlePriceController.text.trim()) ?? (liveInt + libInt)) : liveInt;
    final liveNet = PlatformPaymentConfig.calculateCommission(
      totalPriceDzd: liveInt,
      packageName: 'live_only',
      packageType: PlatformPaymentConfig.packageLiveOnly,
    ).teacherPayoutDzd;
    final libNet = PlatformPaymentConfig.calculateCommission(
      totalPriceDzd: libInt,
      packageName: 'library_only',
      packageType: PlatformPaymentConfig.packageLibraryOnly,
    ).teacherPayoutDzd;
    final bundleNet = PlatformPaymentConfig.calculateCommission(
      totalPriceDzd: bundleInt,
      packageName: 'full_bundle',
      packageType: PlatformPaymentConfig.packageFullBundle,
      livePriceDzd: liveInt,
      libraryPriceDzd: libInt,
    ).teacherPayoutDzd;

    return Container(
      padding: EdgeInsets.only(
        top: 20,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.92,
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
                  Expanded(
                    child: Text(
                      'إنشاء فوج دراسي جديد',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
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

              // المستوى (مصفى حسب سنوات الأستاذ المختارة عند التسجيل) والمادة
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('السنة / المستوى'),
                        _buildDropdown(
                          value: _selectedLevel,
                          items: _levels,
                          onChanged: (val) {
                            if (val != null) _onLevelChanged(val);
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
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
                ],
              ),
              if (widget.allowedTeachingYears.isNotEmpty) ...[
                const SizedBox(height: 6),
                const Text(
                  '✓ السنوات المعروضة مفلترة تلقائياً حسب سنوات التدريس التي اخترتها في حسابك.',
                  style: TextStyle(color: Color(0xFF34D399), fontSize: 10.5),
                ),
              ],
              const SizedBox(height: 14),

              // الشعبة والحد الأقصى للطلاب
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('الشعبة الدراسية'),
                        _buildDropdown(
                          value: _selectedStream,
                          items: _streams,
                          onChanged: (val) => setState(() => _selectedStream = val!),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
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
              const SizedBox(height: 16),

              // هيكلة التسعير المقسمة (حصص حضورية/مباشرة vs مكتبة رقمية vs باقة متكاملة)
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.04),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: _brightCyan.withValues(alpha: 0.25)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.payments_outlined, color: _brightCyan, size: 18),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'تقسيم الأسعار الشهرية والباقة المتكاملة (دج)',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    _buildLabel('1. سعر الحصص المباشرة / الحضورية فقط (دج) *'),
                    TextFormField(
                      controller: _livePriceController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: Colors.white),
                      decoration: _inputDecoration(hint: '2500'),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) return 'مطلوب';
                        if (double.tryParse(val.trim()) == null) return 'رقم غير صالح';
                        return null;
                      },
                    ),
                    const SizedBox(height: 8),

                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      activeColor: _brightCyan,
                      title: const Text(
                        'إتاحة مكتبة التسجيلات الإلكترونية للطلاب',
                        style: TextStyle(color: Colors.white, fontSize: 13),
                      ),
                      subtitle: const Text(
                        'تمكين خيار شراء المكتبة منفردة أو ضمن الباقة المتكاملة',
                        style: TextStyle(color: Colors.white54, fontSize: 11),
                      ),
                      value: _includeLibrary,
                      onChanged: (val) => setState(() => _includeLibrary = val),
                    ),

                    if (_includeLibrary) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel('2. سعر المكتبة فقط (دج) *'),
                                TextFormField(
                                  controller: _libraryPriceController,
                                  keyboardType: TextInputType.number,
                                  style: const TextStyle(color: Colors.white),
                                  decoration: _inputDecoration(hint: '1500'),
                                  validator: (val) {
                                    if (!_includeLibrary) return null;
                                    if (val == null || val.trim().isEmpty) return 'مطلوب';
                                    if (double.tryParse(val.trim()) == null) return 'رقم غير صالح';
                                    return null;
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel('3. الباقة المتكاملة (الكل) *'),
                                TextFormField(
                                  controller: _bundlePriceController,
                                  keyboardType: TextInputType.number,
                                  style: const TextStyle(color: Colors.white),
                                  decoration: _inputDecoration(hint: '3500'),
                                  validator: (val) {
                                    if (!_includeLibrary) return null;
                                    if (val == null || val.trim().isEmpty) return 'مطلوب';
                                    if (double.tryParse(val.trim()) == null) return 'رقم غير صالح';
                                    return null;
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 10),

                    // ملخص صافي أرباح الأستاذ والمنصة بدقة
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.25)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'صافي ربحك التقديري لكل تلميذ بعد عمولة المنصة:',
                            style: TextStyle(color: Color(0xFF34D399), fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Wrap(
                            spacing: 10,
                            runSpacing: 4,
                            children: [
                              Text('الحصص (85%): $liveNet دج', style: const TextStyle(color: Colors.white70, fontSize: 11)),
                              if (_includeLibrary) ...[
                                Text('المكتبة (90%): $libNet دج', style: const TextStyle(color: Colors.white70, fontSize: 11)),
                                Text('المتكاملة (85%): $bundleNet دج', style: const TextStyle(color: _brightCyan, fontSize: 11, fontWeight: FontWeight.bold)),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
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
              const SizedBox(height: 12),

              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                activeColor: _brightCyan,
                title: const Text('فتح التسجيل الفوري في الفوج', style: TextStyle(color: Colors.white, fontSize: 13.5)),
                subtitle: const Text('يظهر الفوج مباشرة في قسم اكتشف للطلاب', style: TextStyle(color: Colors.white54, fontSize: 11.5)),
                value: _isOpenRegistration,
                onChanged: (val) => setState(() => _isOpenRegistration = val),
              ),
              const SizedBox(height: 16),

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
      child: Text(text, style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600)),
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
    final safeValue = items.contains(value) ? value : items.first;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: safeValue,
          isExpanded: true,
          dropdownColor: const Color(0xFF0F172A),
          style: const TextStyle(color: Colors.white, fontSize: 12.5),
          icon: const Icon(Icons.arrow_drop_down, color: _brightCyan),
          items: items
              .map(
                (e) => DropdownMenuItem(
                  value: e,
                  child: Text(e, overflow: TextOverflow.ellipsis),
                ),
              )
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
