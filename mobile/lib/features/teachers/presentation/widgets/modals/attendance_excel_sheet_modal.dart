import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pindo_future_mobile/core/network/api_client.dart';
import 'package:pindo_future_mobile/features/auth/data/datasources/auth_local_datasource.dart';

class AttendanceExcelSheetModal extends StatefulWidget {
  final int cohortId;
  final String cohortName;

  const AttendanceExcelSheetModal({
    super.key,
    required this.cohortId,
    required this.cohortName,
  });

  static void show(
    BuildContext context, {
    required int cohortId,
    required String cohortName,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AttendanceExcelSheetModal(
        cohortId: cohortId,
        cohortName: cohortName,
      ),
    );
  }

  @override
  State<AttendanceExcelSheetModal> createState() => _AttendanceExcelSheetModalState();
}

class _AttendanceExcelSheetModalState extends State<AttendanceExcelSheetModal> {
  final ApiClient _apiClient = ApiClient();

  late List<Map<String, String>> _monthOptions;
  late String _selectedMonthKey;

  bool _isLoading = true;
  bool _isSaving = false;
  String? _error;

  List<Map<String, dynamic>> _students = [];
  List<Map<String, dynamic>> _sessions = [];
  Map<String, String> _recordsMap = {};
  final Set<String> _dirtyKeys = {};

  static const Color _brightCyan = Color(0xFF00E5FF);
  static const Color _electricPurple = Color(0xFF7C4DFF);

  static const Map<int, String> _arabicMonthNames = {
    1: 'جانفي',
    2: 'فيفري',
    3: 'مارس',
    4: 'أفريل',
    5: 'ماي',
    6: 'جوان',
    7: 'جويلية',
    8: 'أوت',
    9: 'سبتمبر',
    10: 'أكتوبر',
    11: 'نوفمبر',
    12: 'ديسمبر',
  };

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _monthOptions = List.generate(6, (idx) {
      final dt = DateTime(now.year, now.month - 1 + idx, 1);
      final key = '${dt.year}-${dt.month.toString().padLeft(2, '0')}';
      final label = '${_arabicMonthNames[dt.month] ?? dt.month} ${dt.year}';
      return {'key': key, 'label': label};
    });
    _selectedMonthKey = '${now.year}-${now.month.toString().padLeft(2, '0')}';
    _loadAttendance();
  }

  Future<void> _loadAttendance() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final token = await AuthLocalDataSourceImpl().getToken();
      final response = await _apiClient.get(
        '/teacher/cohorts/${widget.cohortId}/attendance?month=$_selectedMonthKey',
        token: token,
      );

      final data = (response is Map<String, dynamic> ? response['data'] : null) as Map<String, dynamic>? ?? {};
      final rawStudents = (data['students'] as List<dynamic>? ?? [])
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
      final rawSessions = (data['sessions'] as List<dynamic>? ?? [])
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
      final rawRecords = data['records'] is Map ? Map<String, dynamic>.from(data['records'] as Map) : {};

      final parsedRecords = <String, String>{};
      rawRecords.forEach((k, v) {
        parsedRecords[k.toString()] = v.toString();
      });

      if (mounted) {
        setState(() {
          _students = rawStudents;
          _sessions = rawSessions;
          _recordsMap = parsedRecords;
          _dirtyKeys.clear();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = 'تعذر تحميل سجل الحضور: $e';
        });
      }
    }
  }

  void _cycleStatus(int studentId, String studentName, int sessionId) {
    const statuses = ['P', 'L', 'A', 'E'];
    final key = '${studentId}_$sessionId';
    final current = _recordsMap[key] ?? 'P';
    final nextIndex = (statuses.indexOf(current) + 1) % statuses.length;

    setState(() {
      _recordsMap[key] = statuses[nextIndex];
      _dirtyKeys.add(key);
    });
  }

  Future<void> _saveChanges({bool closeAfter = false}) async {
    if (_dirtyKeys.isEmpty && closeAfter) {
      Navigator.of(context).pop();
      return;
    }

    if (_dirtyKeys.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('لا توجد تعديلات جديدة للحفظ.'),
          backgroundColor: Color(0xFF0F172A),
        ),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      final token = await AuthLocalDataSourceImpl().getToken();
      final payloadRecords = _dirtyKeys.map((key) {
        final parts = key.split('_');
        return {
          'student_id': int.parse(parts[0]),
          'session_id': int.parse(parts[1]),
          'status': _recordsMap[key] ?? 'P',
        };
      }).toList();

      await _apiClient.post(
        '/teacher/cohorts/${widget.cohortId}/attendance/records',
        body: {'records': payloadRecords},
        token: token,
      );

      if (mounted) {
        setState(() {
          _dirtyKeys.clear();
          _isSaving = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم حفظ سجل الحضور في قاعدة البيانات بنجاح ✅'),
            backgroundColor: Color(0xFF10B981),
          ),
        );
        if (closeAfter) {
          Navigator.of(context).pop();
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('فشل حفظ الحضور: $e'), backgroundColor: Colors.redAccent),
        );
      }
    }
  }

  Future<void> _showAddSessionDialog() async {
    final now = DateTime.now();
    final defaultDate = '$_selectedMonthKey-${now.day.toString().padLeft(2, '0')}';
    final labelCtrl = TextEditingController(text: 'الحصة ${_sessions.length + 1}');
    final dateCtrl = TextEditingController(text: defaultDate);
    bool saving = false;

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlgState) => AlertDialog(
          backgroundColor: const Color(0xFF0F172A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: _brightCyan.withValues(alpha: 0.4)),
          ),
          title: const Text(
            'تحديد وإضافة حصة جديدة 📅',
            style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('عنوان / رقم الحصة:', style: TextStyle(color: Colors.white70, fontSize: 12)),
              const SizedBox(height: 6),
              TextField(
                controller: labelCtrl,
                style: const TextStyle(color: Colors.white, fontSize: 13),
                decoration: InputDecoration(
                  hintText: 'مثال: الحصة 1 - الدوال',
                  hintStyle: const TextStyle(color: Colors.white30),
                  filled: true,
                  fillColor: Colors.white.withValues(alpha: 0.06),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 12),
              const Text('تاريخ الحصة (YYYY-MM-DD):', style: TextStyle(color: Colors.white70, fontSize: 12)),
              const SizedBox(height: 6),
              TextField(
                controller: dateCtrl,
                style: const TextStyle(color: _brightCyan, fontSize: 13),
                decoration: InputDecoration(
                  hintText: '2026-11-27',
                  hintStyle: const TextStyle(color: Colors.white30),
                  filled: true,
                  fillColor: Colors.white.withValues(alpha: 0.06),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: saving ? null : () => Navigator.of(ctx).pop(),
              child: const Text('إلغاء', style: TextStyle(color: Colors.white60)),
            ),
            ElevatedButton(
              onPressed: saving
                  ? null
                  : () async {
                      if (labelCtrl.text.trim().isEmpty || dateCtrl.text.trim().isEmpty) return;
                      setDlgState(() => saving = true);
                      try {
                        final token = await AuthLocalDataSourceImpl().getToken();
                        await _apiClient.post(
                          '/teacher/cohorts/${widget.cohortId}/attendance/sessions',
                          body: {
                            'label': labelCtrl.text.trim(),
                            'session_date': dateCtrl.text.trim(),
                            'month_key': _selectedMonthKey,
                          },
                          token: token,
                        );
                        if (ctx.mounted) Navigator.of(ctx).pop();
                        await _loadAttendance();
                      } catch (e) {
                        setDlgState(() => saving = false);
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('تعذر إضافة الحصة: $e'), backgroundColor: Colors.redAccent),
                          );
                        }
                      }
                    },
              style: ElevatedButton.styleFrom(backgroundColor: _brightCyan, foregroundColor: Colors.black),
              child: saving
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('إضافة الحصة', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteSession(int sessionId, String label) async {
    try {
      final token = await AuthLocalDataSourceImpl().getToken();
      await _apiClient.delete(
        '/teacher/cohorts/${widget.cohortId}/attendance/sessions/$sessionId',
        token: token,
      );
      await _loadAttendance();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('تم حذف الحصة «$label».'), backgroundColor: const Color(0xFF0F172A)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('تعذر حذف الحصة: $e'), backgroundColor: Colors.redAccent),
        );
      }
    }
  }

  double _calculateAttendanceRate(int studentId) {
    if (_sessions.isEmpty) return 100.0;
    int attended = 0;
    for (final s in _sessions) {
      final sId = s['id'] as int;
      final status = _recordsMap['${studentId}_$sId'] ?? 'P';
      if (status == 'P' || status == 'L' || status == 'E') attended++;
    }
    return (attended / _sessions.length) * 100;
  }

  void _copyCsvExport() {
    if (_students.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('لا توجد بيانات طلاب للتصدير حالياً.'),
          backgroundColor: Color(0xFF0F172A),
        ),
      );
      return;
    }

    final headers = ['الرقم', 'اسم التلميذ', ..._sessions.map((s) => s['label'].toString()), 'نسبة الالتزام'];
    final lines = <String>[headers.join(',')];
    for (var i = 0; i < _students.length; i++) {
      final st = _students[i];
      final stId = st['student_id'] as int;
      final cells = _sessions.map((s) => _recordsMap['${stId}_${s['id']}'] ?? 'P').toList();
      final rate = '${_calculateAttendanceRate(stId).toStringAsFixed(0)}%';
      lines.add(['${i + 1}', st['name'].toString(), ...cells, rate].join(','));
    }

    Clipboard.setData(ClipboardData(text: lines.join('\n')));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم نسخ جدول الحضور الحقيقي (CSV / Excel) إلى الحافظة بنجاح ✅'),
        backgroundColor: Color(0xFF10B981),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.90,
      ),
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

          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.table_chart_rounded, color: Color(0xFF10B981), size: 22),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'سجل الحضور الفعلي وتحديد الحصص',
                            style: TextStyle(fontSize: 15.5, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${widget.cohortName} • (${_students.length} تلميذ مسجل)',
                      style: const TextStyle(fontSize: 12, color: _brightCyan),
                    ),
                  ],
                ),
              ),

              // Month Selector
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white12),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedMonthKey,
                    dropdownColor: const Color(0xFF0F172A),
                    style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                    icon: const Icon(Icons.arrow_drop_down, color: _brightCyan, size: 20),
                    items: _monthOptions
                        .map((m) => DropdownMenuItem(value: m['key'], child: Text(m['label']!)))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() => _selectedMonthKey = val);
                        _loadAttendance();
                      }
                    },
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Legend & Add Session Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    _buildLegendItem('🟢 حاضر', Colors.green),
                    _buildLegendItem('🟡 متأخر', Colors.amber),
                    _buildLegendItem('🔴 غائب', Colors.redAccent),
                    _buildLegendItem('⚪ مبرر', Colors.white70),
                  ],
                ),
              ),
              ElevatedButton.icon(
                onPressed: _showAddSessionDialog,
                icon: const Icon(Icons.add_circle_outline_rounded, size: 16),
                label: const Text('تحديد حصة جديدة', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _electricPurple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Body: Real Empty State OR Real Numbered Grid
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: _brightCyan))
                : _error != null
                    ? Center(child: Text(_error!, style: const TextStyle(color: Colors.redAccent, fontSize: 13)))
                    : _students.isEmpty
                        ? Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.28),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.white12),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.group_off_rounded, color: Colors.white.withValues(alpha: 0.25), size: 54),
                                const SizedBox(height: 12),
                                const Text(
                                  'لا يوجد أي تلميذ مسجل في هذا الفوج حالياً (0)',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.white, fontSize: 14.5, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 6),
                                const Text(
                                  'تم إزالة جميع البيانات الوهمية. بمجرد انضمام أول تلميذ أو إضافته من «قائمة الطلاب»، سيظهر هنا مرقماً (1، 2، 3...).',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.white54, fontSize: 12, height: 1.5),
                                ),
                                if (_sessions.isNotEmpty) ...[
                                  const SizedBox(height: 16),
                                  Text(
                                    'الحصص المحددة لهذا الشهر (${_sessions.length}):',
                                    style: const TextStyle(color: _brightCyan, fontSize: 12, fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 8),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 6,
                                    children: _sessions.map((s) {
                                      return Chip(
                                        backgroundColor: _electricPurple.withValues(alpha: 0.25),
                                        label: Text(
                                          '${s['label']} (${s['session_date']})',
                                          style: const TextStyle(color: Colors.white, fontSize: 11),
                                        ),
                                        deleteIcon: const Icon(Icons.close, size: 15, color: Colors.redAccent),
                                        onDeleted: () => _deleteSession(s['id'] as int, s['label'].toString()),
                                      );
                                    }).toList(),
                                  ),
                                ],
                              ],
                            ),
                          )
                        : Container(
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.white12),
                            ),
                            child: _sessions.isEmpty
                                ? Center(
                                    child: Padding(
                                      padding: const EdgeInsets.all(24),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Text(
                                            'يوجد تلاميذ مسجلون لكن لم تحدد أي حصص لهذا الشهر بعد.',
                                            style: TextStyle(color: Colors.white70, fontSize: 13),
                                            textAlign: TextAlign.center,
                                          ),
                                          const SizedBox(height: 12),
                                          ElevatedButton.icon(
                                            onPressed: _showAddSessionDialog,
                                            icon: const Icon(Icons.add_rounded),
                                            label: const Text('تحديد أول حصة الآن'),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: _brightCyan,
                                              foregroundColor: Colors.black,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                : SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: SingleChildScrollView(
                                      scrollDirection: Axis.vertical,
                                      child: DataTable(
                                        headingRowColor: WidgetStateProperty.all(
                                          _electricPurple.withValues(alpha: 0.25),
                                        ),
                                        dataRowColor: WidgetStateProperty.resolveWith((_) => Colors.transparent),
                                        columnSpacing: 18,
                                        horizontalMargin: 16,
                                        columns: [
                                          const DataColumn(
                                            label: Text(
                                              '#',
                                              style: TextStyle(color: _brightCyan, fontWeight: FontWeight.bold, fontSize: 13),
                                            ),
                                          ),
                                          const DataColumn(
                                            label: Text(
                                              'اسم الطالب',
                                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                                            ),
                                          ),
                                          ..._sessions.map(
                                            (s) => DataColumn(
                                              label: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      Text(
                                                        s['label'].toString(),
                                                        style: const TextStyle(color: _brightCyan, fontWeight: FontWeight.w600, fontSize: 12),
                                                      ),
                                                      Text(
                                                        s['session_date'].toString(),
                                                        style: const TextStyle(color: Colors.white54, fontSize: 10),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(width: 4),
                                                  InkWell(
                                                    onTap: () => _deleteSession(s['id'] as int, s['label'].toString()),
                                                    child: const Icon(Icons.close_rounded, color: Colors.redAccent, size: 14),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          const DataColumn(
                                            label: Text(
                                              'نسبة الالتزام',
                                              style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 12),
                                            ),
                                          ),
                                        ],
                                        rows: List.generate(_students.length, (studentIdx) {
                                          final student = _students[studentIdx];
                                          final studentId = student['student_id'] as int;
                                          final studentName = student['name'].toString();
                                          final rate = _calculateAttendanceRate(studentId);

                                          return DataRow(
                                            cells: [
                                              DataCell(
                                                Container(
                                                  width: 26,
                                                  height: 26,
                                                  alignment: Alignment.center,
                                                  decoration: BoxDecoration(
                                                    color: _electricPurple.withValues(alpha: 0.35),
                                                    borderRadius: BorderRadius.circular(8),
                                                    border: Border.all(color: _brightCyan.withValues(alpha: 0.4)),
                                                  ),
                                                  child: Text(
                                                    '${studentIdx + 1}',
                                                    style: const TextStyle(color: _brightCyan, fontSize: 12, fontWeight: FontWeight.bold),
                                                  ),
                                                ),
                                              ),
                                              DataCell(
                                                Text(
                                                  studentName,
                                                  style: const TextStyle(color: Colors.white, fontSize: 12.5, fontWeight: FontWeight.w600),
                                                ),
                                              ),
                                              ..._sessions.map((s) {
                                                final sessionId = s['id'] as int;
                                                final status = _recordsMap['${studentId}_$sessionId'] ?? 'P';
                                                return DataCell(
                                                  InkWell(
                                                    onTap: () => _cycleStatus(studentId, studentName, sessionId),
                                                    child: Container(
                                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                                      decoration: BoxDecoration(
                                                        color: _getStatusBg(status),
                                                        borderRadius: BorderRadius.circular(8),
                                                        border: Border.all(color: Colors.white10),
                                                      ),
                                                      child: Text(_getStatusSymbol(status), style: const TextStyle(fontSize: 14)),
                                                    ),
                                                  ),
                                                );
                                              }),
                                              DataCell(
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                  decoration: BoxDecoration(
                                                    color: rate >= 80
                                                        ? Colors.green.withValues(alpha: 0.15)
                                                        : Colors.orange.withValues(alpha: 0.15),
                                                    borderRadius: BorderRadius.circular(8),
                                                  ),
                                                  child: Text(
                                                    '${rate.toStringAsFixed(0)}%',
                                                    style: TextStyle(
                                                      color: rate >= 80 ? const Color(0xFF10B981) : Colors.orangeAccent,
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          );
                                        }),
                                      ),
                                    ),
                                  ),
                          ),
          ),

          const SizedBox(height: 14),

          // Actions Row
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _copyCsvExport,
                  icon: const Icon(Icons.download_rounded, size: 18, color: Colors.white),
                  label: const Text('تصدير كـ Excel / CSV', style: TextStyle(color: Colors.white, fontSize: 13)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.white24),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _isSaving ? null : () => _saveChanges(closeAfter: true),
                  icon: _isSaving
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.check_rounded, size: 18),
                  label: Text(
                    _dirtyKeys.isNotEmpty ? 'حفظ التعديلات (${_dirtyKeys.length})' : 'إغلاق وحفظ',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _brightCyan,
                    foregroundColor: const Color(0xFF0F172A),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(text, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold)),
    );
  }

  String _getStatusSymbol(String code) {
    switch (code) {
      case 'P':
        return '🟢';
      case 'L':
        return '🟡';
      case 'A':
        return '🔴';
      case 'E':
        return '⚪';
      default:
        return '🟢';
    }
  }

  Color _getStatusBg(String code) {
    switch (code) {
      case 'P':
        return Colors.green.withValues(alpha: 0.15);
      case 'L':
        return Colors.amber.withValues(alpha: 0.15);
      case 'A':
        return Colors.red.withValues(alpha: 0.15);
      case 'E':
        return Colors.white.withValues(alpha: 0.12);
      default:
        return Colors.transparent;
    }
  }
}
