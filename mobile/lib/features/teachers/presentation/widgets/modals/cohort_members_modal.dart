import 'package:flutter/material.dart';
import 'package:pindo_future_mobile/core/network/api_client.dart';
import 'package:pindo_future_mobile/features/auth/data/datasources/auth_local_datasource.dart';

class CohortMembersModal extends StatefulWidget {
  final int cohortId;
  final String cohortName;
  final VoidCallback? onMembersChanged;

  const CohortMembersModal({
    super.key,
    required this.cohortId,
    required this.cohortName,
    this.onMembersChanged,
  });

  static Future<void> show(
    BuildContext context, {
    required int cohortId,
    required String cohortName,
    VoidCallback? onMembersChanged,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CohortMembersModal(
        cohortId: cohortId,
        cohortName: cohortName,
        onMembersChanged: onMembersChanged,
      ),
    );
  }

  @override
  State<CohortMembersModal> createState() => _CohortMembersModalState();
}

class _CohortMembersModalState extends State<CohortMembersModal> {
  final ApiClient _apiClient = ApiClient();
  bool _isLoading = true;
  String? _error;
  List<Map<String, dynamic>> _members = [];

  static const Color _brightCyan = Color(0xFF00E5FF);
  static const Color _electricPurple = Color(0xFF7C4DFF);

  @override
  void initState() {
    super.initState();
    _loadMembers();
  }

  Future<void> _loadMembers() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final token = await AuthLocalDataSourceImpl().getToken();
      final response = await _apiClient.get(
        '/teacher/cohorts/${widget.cohortId}/members',
        token: token,
      );
      final rawList = (response is Map<String, dynamic> ? response['data'] : null) as List<dynamic>? ?? [];
      final parsed = rawList.map((e) => Map<String, dynamic>.from(e as Map)).toList();
      if (mounted) {
        setState(() {
          _members = parsed;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = 'تعذر تحميل قائمة طلاب الفوج: $e';
        });
      }
    }
  }

  Future<void> _showAddStudentDialog() async {
    final ctrl = TextEditingController();
    bool submitting = false;

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFF0F172A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: _brightCyan.withValues(alpha: 0.4)),
          ),
          title: const Text(
            'إضافة طالب مسجل إلى الفوج',
            style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'أدخل البريد الإلكتروني أو المعرّف الدراسي (Student ID) للتلميذ:',
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: ctrl,
                style: const TextStyle(color: Colors.white, fontSize: 13),
                decoration: InputDecoration(
                  hintText: 'student@example.com أو STU_...',
                  hintStyle: const TextStyle(color: Colors.white30),
                  filled: true,
                  fillColor: Colors.white.withValues(alpha: 0.06),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: submitting ? null : () => Navigator.of(ctx).pop(),
              child: const Text('إلغاء', style: TextStyle(color: Colors.white60)),
            ),
            ElevatedButton(
              onPressed: submitting
                  ? null
                  : () async {
                      final identifier = ctrl.text.trim();
                      if (identifier.isEmpty) return;
                      setDialogState(() => submitting = true);
                      try {
                        final token = await AuthLocalDataSourceImpl().getToken();
                        await _apiClient.post(
                          '/teacher/cohorts/${widget.cohortId}/members',
                          body: {'student_identifier': identifier},
                          token: token,
                        );
                        if (ctx.mounted) Navigator.of(ctx).pop();
                        await _loadMembers();
                        widget.onMembersChanged?.call();
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('تمت إضافة التلميذ إلى الفوج بنجاح ✅'),
                              backgroundColor: Color(0xFF10B981),
                            ),
                          );
                        }
                      } catch (e) {
                        setDialogState(() => submitting = false);
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('تعذر إضافة التلميذ: $e'),
                              backgroundColor: Colors.redAccent,
                            ),
                          );
                        }
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: _brightCyan,
                foregroundColor: Colors.black,
              ),
              child: submitting
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('إضافة', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _removeStudent(int studentId, String studentName) async {
    try {
      final token = await AuthLocalDataSourceImpl().getToken();
      await _apiClient.delete('/teacher/cohorts/${widget.cohortId}/members/$studentId', token: token);
      await _loadMembers();
      widget.onMembersChanged?.call();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تم إزالة «$studentName» من الفوج.'),
            backgroundColor: const Color(0xFF0F172A),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('تعذر الحذف: $e'), backgroundColor: Colors.redAccent),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85),
      decoration: const BoxDecoration(
        color: Color(0xFF0F172A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(top: BorderSide(color: Colors.white24, width: 1.2)),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(color: Colors.white30, borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '👥 قائمة طلاب الفوج (${_members.length})',
                      style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      widget.cohortName,
                      style: const TextStyle(color: _brightCyan, fontSize: 12),
                    ),
                  ],
                ),
              ),
              ElevatedButton.icon(
                onPressed: _showAddStudentDialog,
                icon: const Icon(Icons.person_add_alt_1_rounded, size: 16),
                label: const Text('إضافة تلميذ', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _electricPurple,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(color: Colors.white12, height: 1),
          const SizedBox(height: 10),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: _brightCyan))
                : _error != null
                    ? Center(child: Text(_error!, style: const TextStyle(color: Colors.redAccent, fontSize: 13)))
                    : _members.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.school_outlined, color: Colors.white.withValues(alpha: 0.25), size: 52),
                                const SizedBox(height: 12),
                                const Text(
                                  'لا يوجد أي تلميذ مسجل في هذا الفوج حالياً (0 تلاميذ).',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 6),
                                const Text(
                                  'عند تسجيل التلاميذ في الفوج أو إضافتهم يدوياً، سيظهرون هنا مرقمين بالترتيب (1، 2، 3...).',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.white54, fontSize: 12),
                                ),
                              ],
                            ),
                          )
                        : ListView.separated(
                            itemCount: _members.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 8),
                            itemBuilder: (context, idx) {
                              final m = _members[idx];
                              final student = (m['student'] as Map?) ?? {};
                              final studentId = (m['student_id'] ?? student['id'] ?? 0) as int;
                              final name = student['name']?.toString() ?? 'طالب #$studentId';
                              final email = student['email']?.toString() ?? '';
                              final pkg = m['package_type']?.toString() ?? 'full_bundle';

                              return Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.05),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: Colors.white10),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 30,
                                      height: 30,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: _electricPurple.withValues(alpha: 0.28),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: _brightCyan.withValues(alpha: 0.45)),
                                      ),
                                      child: Text(
                                        '${idx + 1}',
                                        style: const TextStyle(
                                          color: _brightCyan,
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            name,
                                            style: const TextStyle(color: Colors.white, fontSize: 13.5, fontWeight: FontWeight.bold),
                                          ),
                                          if (email.isNotEmpty)
                                            Text(email, style: const TextStyle(color: Colors.white54, fontSize: 11)),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF10B981).withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        pkg == 'library_only'
                                            ? 'مكتبة'
                                            : (pkg == 'live_only' ? 'حصص' : 'متكاملة'),
                                        style: const TextStyle(color: Color(0xFF34D399), fontSize: 10.5, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 18),
                                      onPressed: () => _removeStudent(studentId, name),
                                      tooltip: 'حذف من الفوج',
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }
}
