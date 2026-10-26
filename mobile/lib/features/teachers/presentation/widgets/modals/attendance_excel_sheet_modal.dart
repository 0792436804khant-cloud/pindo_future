import 'package:flutter/material.dart';

class AttendanceExcelSheetModal extends StatefulWidget {
  final String cohortName;

  const AttendanceExcelSheetModal({
    super.key,
    required this.cohortName,
  });

  static void show(BuildContext context, {required String cohortName}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AttendanceExcelSheetModal(cohortName: cohortName),
    );
  }

  @override
  State<AttendanceExcelSheetModal> createState() => _AttendanceExcelSheetModalState();
}

class _AttendanceExcelSheetModalState extends State<AttendanceExcelSheetModal> {
  String _selectedMonth = 'نوفمبر 2026';
  final List<String> _months = const ['أكتوبر 2026', 'نوفمبر 2026', 'ديسمبر 2026'];

  final List<String> _dates = const ['1 نوفمبر', '4 نوفمبر', '8 نوفمبر', '11 نوفمبر', '15 نوفمبر'];

  // Status mapping: 'P' = 🟢 حاضر, 'L' = 🟡 متأخر, 'A' = 🔴 غائب, 'E' = ⚪ مبرر
  late List<Map<String, dynamic>> _studentsAttendance;

  static const Color _brightCyan = Color(0xFF00E5FF);
  static const Color _electricPurple = Color(0xFF7C4DFF);

  @override
  void initState() {
    super.initState();
    _studentsAttendance = [
      {'name': 'أحمد ياسين بن علي', 'records': ['P', 'P', 'L', 'P', 'P']},
      {'name': 'محمد أمين منصوري', 'records': ['P', 'A', 'P', 'P', 'P']},
      {'name': 'سارة مرابط', 'records': ['P', 'P', 'P', 'E', 'P']},
      {'name': 'فاطمة الزهراء بوعزيز', 'records': ['P', 'P', 'P', 'P', 'P']},
      {'name': 'بلال قادري', 'records': ['A', 'P', 'L', 'P', 'A']},
      {'name': 'يوسف العيداني', 'records': ['P', 'P', 'P', 'P', 'L']},
      {'name': 'إيناس رحماني', 'records': ['E', 'P', 'P', 'P', 'P']},
    ];
  }

  void _cycleStatus(int studentIndex, int dateIndex) {
    const statuses = ['P', 'L', 'A', 'E'];
    final current = _studentsAttendance[studentIndex]['records'][dateIndex] as String;
    final nextIndex = (statuses.indexOf(current) + 1) % statuses.length;

    setState(() {
      _studentsAttendance[studentIndex]['records'][dateIndex] = statuses[nextIndex];
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم تحديث حالة حضور «${_studentsAttendance[studentIndex]['name']}» وتسجيل التعديل.'),
        duration: const Duration(seconds: 1),
        backgroundColor: const Color(0xFF0F172A),
      ),
    );
  }

  double _calculateAttendanceRate(List<dynamic> records) {
    if (records.isEmpty) return 100.0;
    int attended = 0;
    for (var r in records) {
      if (r == 'P' || r == 'L' || r == 'E') attended++;
    }
    return (attended / records.length) * 100;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
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
              decoration: BoxDecoration(
                color: Colors.white30,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

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
                        Text(
                          'سجل الحضور الشهري (Excel Sheet)',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.cohortName,
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
                    value: _selectedMonth,
                    dropdownColor: const Color(0xFF0F172A),
                    style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                    icon: const Icon(Icons.arrow_drop_down, color: _brightCyan, size: 20),
                    items: _months.map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
                    onChanged: (val) => setState(() => _selectedMonth = val!),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Legend
          Wrap(
            spacing: 12,
            runSpacing: 6,
            children: [
              _buildLegendItem('🟢 حاضر', Colors.green),
              _buildLegendItem('🟡 متأخر', Colors.amber),
              _buildLegendItem('🔴 غائب', Colors.redAccent),
              _buildLegendItem('⚪ غياب مبرر', Colors.white70),
            ],
          ),

          const SizedBox(height: 16),

          // Interactive Excel Grid
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white12),
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: DataTable(
                    headingRowColor: WidgetStateProperty.all(
                      _electricPurple.withValues(alpha: 0.25),
                    ),
                    dataRowColor: WidgetStateProperty.resolveWith(
                      (states) => Colors.transparent,
                    ),
                    columnSpacing: 18,
                    horizontalMargin: 16,
                    columns: [
                      const DataColumn(
                        label: Text(
                          'اسم الطالب',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                      ),
                      ..._dates.map(
                        (d) => DataColumn(
                          label: Text(
                            d,
                            style: const TextStyle(color: _brightCyan, fontWeight: FontWeight.w600, fontSize: 12),
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
                    rows: List.generate(_studentsAttendance.length, (studentIdx) {
                      final student = _studentsAttendance[studentIdx];
                      final records = student['records'] as List<dynamic>;
                      final rate = _calculateAttendanceRate(records);

                      return DataRow(
                        cells: [
                          DataCell(
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 12,
                                  backgroundColor: _electricPurple.withValues(alpha: 0.3),
                                  child: Text(
                                    student['name'][0],
                                    style: const TextStyle(color: Colors.white, fontSize: 10),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  student['name'],
                                  style: const TextStyle(color: Colors.white, fontSize: 12.5),
                                ),
                              ],
                            ),
                          ),
                          ...List.generate(records.length, (dateIdx) {
                            final status = records[dateIdx] as String;
                            return DataCell(
                              InkWell(
                                onTap: () => _cycleStatus(studentIdx, dateIdx),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: _getStatusBg(status),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: Colors.white10),
                                  ),
                                  child: Text(
                                    _getStatusSymbol(status),
                                    style: const TextStyle(fontSize: 14),
                                  ),
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

          // Actions Row (Export to PDF/Excel)
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('تم تصدير تقرير الحضور الشهري بصيغة Excel / PDF بنجاح.'),
                        backgroundColor: Color(0xFF10B981),
                      ),
                    );
                  },
                  icon: const Icon(Icons.download_rounded, size: 18, color: Colors.white),
                  label: const Text('تصدير كـ Excel / PDF', style: TextStyle(color: Colors.white, fontSize: 13)),
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
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.check_rounded, size: 18),
                  label: const Text('إغلاق وحفظ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
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
