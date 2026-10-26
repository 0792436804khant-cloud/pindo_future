import 'package:flutter/material.dart';
import 'package:pindo_future_mobile/features/teachers/data/models/teacher_dashboard_model.dart';

class CreateSessionModal extends StatefulWidget {
  final List<TeacherCohortItem> cohorts;
  final Future<void> Function(Map<String, dynamic> payload)? onSave;

  const CreateSessionModal({
    super.key,
    required this.cohorts,
    this.onSave,
  });

  static Future<void> show(
    BuildContext context, {
    required List<TeacherCohortItem> cohorts,
    Future<void> Function(Map<String, dynamic> payload)? onSave,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CreateSessionModal(cohorts: cohorts, onSave: onSave),
    );
  }

  @override
  State<CreateSessionModal> createState() => _CreateSessionModalState();
}

class _CreateSessionModalState extends State<CreateSessionModal> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _durationController = TextEditingController(text: '120');

  late int _selectedCohortId;
  DateTime _selectedDate = DateTime.now().add(const Duration(hours: 2));
  TimeOfDay _selectedTime = const TimeOfDay(hour: 18, minute: 0);

  bool _allowChat = true;
  bool _recordSession = true;
  bool _muteOnEntry = true;
  bool _isSubmitting = false;

  static const Color _brightCyan = Color(0xFF00E5FF);
  static const Color _electricPurple = Color(0xFF7C4DFF);

  @override
  void initState() {
    super.initState();
    _selectedCohortId = widget.cohorts.isNotEmpty ? widget.cohorts.first.id : 1;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);
    final scheduledDateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    final payload = {
      'cohort_id': _selectedCohortId,
      'title': _titleController.text.trim(),
      'scheduled_at': scheduledDateTime.toIso8601String(),
      'duration_minutes': int.tryParse(_durationController.text) ?? 120,
      'allow_chat': _allowChat,
      'record_session': _recordSession,
      'mute_on_entry': _muteOnEntry,
    };

    if (widget.onSave != null) {
      await widget.onSave!(payload);
    }

    if (mounted) {
      setState(() => _isSubmitting = false);
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تمت جدولة الحصة بنجاح وإرسال إشعار للطلاب المشتركين.'),
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
                  Icon(Icons.video_call_rounded, color: _brightCyan, size: 24),
                  SizedBox(width: 8),
                  Text(
                    'برمجة حصة مباشرة جديدة',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // عنوان الحصة
              _buildLabel('عنوان الحصة أو موضوع الدرس *'),
              TextFormField(
                controller: _titleController,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration(hint: 'مثال: حل النموذج الشامل لمسائل الاحتمالات'),
                validator: (val) => val == null || val.trim().isEmpty ? 'يرجى كتابة عنوان الحصة' : null,
              ),
              const SizedBox(height: 14),

              // الفوج الموجه إليه
              _buildLabel('الفوج الدراسي المرتبط *'),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    value: _selectedCohortId,
                    isExpanded: true,
                    dropdownColor: const Color(0xFF0F172A),
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                    icon: const Icon(Icons.arrow_drop_down, color: _brightCyan),
                    items: widget.cohorts.isEmpty
                        ? const <DropdownMenuItem<int>>[
                            DropdownMenuItem<int>(value: 1, child: Text('فوج الرياضيات العام')),
                          ]
                        : widget.cohorts
                            .map((c) => DropdownMenuItem<int>(value: c.id, child: Text(c.name)))
                            .toList(),
                    onChanged: (val) => setState(() => _selectedCohortId = val ?? 1),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // التاريخ والوقت
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('تاريخ الحصة'),
                        InkWell(
                          onTap: () async {
                            final d = await showDatePicker(
                              context: context,
                              initialDate: _selectedDate,
                              firstDate: DateTime.now(),
                              lastDate: DateTime.now().add(const Duration(days: 90)),
                            );
                            if (d != null) setState(() => _selectedDate = d);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.06),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.white12),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.calendar_today, size: 16, color: _brightCyan),
                                const SizedBox(width: 8),
                                Text(
                                  '${_selectedDate.year}/${_selectedDate.month}/${_selectedDate.day}',
                                  style: const TextStyle(color: Colors.white, fontSize: 13),
                                ),
                              ],
                            ),
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
                        _buildLabel('توقيت البداية'),
                        InkWell(
                          onTap: () async {
                            final t = await showTimePicker(
                              context: context,
                              initialTime: _selectedTime,
                            );
                            if (t != null) setState(() => _selectedTime = t);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.06),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.white12),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.access_time_rounded, size: 16, color: _brightCyan),
                                const SizedBox(width: 8),
                                Text(
                                  _selectedTime.format(context),
                                  style: const TextStyle(color: Colors.white, fontSize: 13),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // المدة المتوقعة
              _buildLabel('المدة المتوقعة (بالدقائق)'),
              TextFormField(
                controller: _durationController,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration(hint: '120 دقيقة (ساعتان)'),
              ),
              const SizedBox(height: 16),

              // خيارات الغرفة التفاعلية
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                activeColor: _brightCyan,
                title: const Text('تسجيل الحصة تلقائياً وحفظها في المكتبة', style: TextStyle(color: Colors.white, fontSize: 13)),
                value: _recordSession,
                onChanged: (val) => setState(() => _recordSession = val),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                activeColor: _brightCyan,
                title: const Text('السماح بالمحادثة النصية أثناء الشرح', style: TextStyle(color: Colors.white, fontSize: 13)),
                value: _allowChat,
                onChanged: (val) => setState(() => _allowChat = val),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                activeColor: _brightCyan,
                title: const Text('كتم ميكروفونات الطلاب تلقائياً عند الدخول', style: TextStyle(color: Colors.white, fontSize: 13)),
                value: _muteOnEntry,
                onChanged: (val) => setState(() => _muteOnEntry = val),
              ),
              const SizedBox(height: 20),

              // زر الحفظ
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
                      : const Text('جدولة الحصة وإرسال التنبيه', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
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
}
