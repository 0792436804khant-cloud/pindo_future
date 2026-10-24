import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/exam_paper_entity.dart';
import '../controllers/exam_bank_controller.dart';
import '../widgets/exam_paper_card.dart';
import 'exam_simulation_screen.dart';

class ExamBankExplorerScreen extends StatefulWidget {
  final ExamBankController controller;

  const ExamBankExplorerScreen({
    super.key,
    required this.controller,
  });

  @override
  State<ExamBankExplorerScreen> createState() => _ExamBankExplorerScreenState();
}

class _ExamBankExplorerScreenState extends State<ExamBankExplorerScreen> {
  final TextEditingController _searchController = TextEditingController();

  final List<({String id, String label})> _streams = [
    (id: 'all', label: 'جميع الشعب'),
    (id: 'experimental_sciences', label: 'علوم تجريبية'),
    (id: 'mathematics', label: 'رياضيات'),
    (id: 'math_technical', label: 'تقني رياضي'),
    (id: 'management_economics', label: 'تسيير واقتصاد'),
    (id: 'foreign_languages', label: 'لغات أجنبية'),
    (id: 'literature_philosophy', label: 'آداب وفلسفة'),
  ];

  @override
  void initState() {
    super.initState();
    widget.controller.loadExams();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onStartSimulation(ExamPaperEntity paper) async {
    await widget.controller.startSimulation(paper);
    if (!mounted) return;

    if (widget.controller.errorMessage != null &&
        !widget.controller.isSimulationRunning) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.controller.errorMessage!),
          backgroundColor: Colors.red.shade700,
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ExamSimulationScreen(
          paper: paper,
          controller: widget.controller,
        ),
      ),
    );
  }

  void _showPaperDetails(ExamPaperEntity paper) {
    widget.controller.loadExamDetails(paper.id);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (ctx, scrollController) => Padding(
          padding: const EdgeInsets.all(20),
          child: ListView(
            controller: scrollController,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withAlpha(25),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      paper.cycleBadge,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ),
                  Text(
                    'دورة ${paper.year} (${paper.sessionType == "main" ? "الدورة العادية" : "الدورة الاستثنائية"})',
                    style: TextStyle(color: Colors.grey.shade700, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                paper.title,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'الشعبة: ${paper.streamDisplayAr} • المدة: ${paper.formattedDuration} • المعامل: ${paper.coefficient}',
                style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
              ),
              const SizedBox(height: 16),
              if (paper.description != null) ...[
                Text(
                  paper.description!,
                  style: const TextStyle(fontSize: 14, height: 1.5, color: Color(0xFF334155)),
                ),
                const SizedBox(height: 16),
              ],
              const Divider(),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(ctx);
                    _onStartSimulation(paper);
                  },
                  icon: const Icon(Icons.timer_outlined),
                  label: const Text('بدء محاكاة مؤقتة لهذا الموضوع ⏱️'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accentColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showHistoryModal() {
    widget.controller.loadStudentSimulations();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.85,
        minChildSize: 0.4,
        expand: false,
        builder: (ctx, scrollController) => ListenableBuilder(
          listenable: widget.controller,
          builder: (context, _) {
            final history = widget.controller.studentHistory;

            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Row(
                    children: [
                      Icon(Icons.history, color: AppTheme.primaryColor),
                      SizedBox(width: 8),
                      Text(
                        'سجل المحاكيات السابقة',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (history.isEmpty)
                    const Expanded(
                      child: Center(
                        child: Text('لم تقم بأي محاكاة بعد. ابدأ محاكاتك الأولى الآن!'),
                      ),
                    )
                  else
                    Expanded(
                      child: ListView.builder(
                        controller: scrollController,
                        itemCount: history.length,
                        itemBuilder: (ctx, i) {
                          final item = history[i];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 10),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: item.selfAssessmentScore != null &&
                                        item.selfAssessmentScore! >= 10
                                    ? Colors.green.shade100
                                    : Colors.amber.shade100,
                                child: Text(
                                  item.selfAssessmentScore?.toStringAsFixed(1) ?? '—',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                    color: item.selfAssessmentScore != null &&
                                            item.selfAssessmentScore! >= 10
                                        ? Colors.green.shade900
                                        : Colors.amber.shade900,
                                  ),
                                ),
                              ),
                              title: Text(
                                item.examPaper?.title ?? 'محاكاة اختبار رسمي',
                                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                              ),
                              subtitle: Text(
                                'الوقت: ${item.formattedTimeSpent} • الحالة: ${item.status == "completed" ? "مكتمل" : "قيد الحل"}',
                                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.school, size: 20),
            SizedBox(width: 8),
            Text('بنك الامتحانات الرسمية 🇩🇿'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'سجل المحاكيات',
            onPressed: _showHistoryModal,
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: widget.controller,
        builder: (context, _) {
          return Column(
            children: [
              // 1. Search & Cycle Segment
              Container(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                color: Colors.white,
                child: Column(
                  children: [
                    // Search field
                    TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'ابحث عن مادة، سنة، أو موضوع (مثلاً: رياضيات، 2024)...',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  _searchController.clear();
                                  widget.controller.setSearchQuery('');
                                },
                              )
                            : null,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                      ),
                      onSubmitted: (query) => widget.controller.setSearchQuery(query),
                    ),
                    const SizedBox(height: 12),

                    // Cycle Segmented Control
                    Row(
                      children: [
                        _CyclePill(
                          label: 'الكل',
                          isSelected: widget.controller.selectedCycle == 'all',
                          onTap: () => widget.controller.setCycle('all'),
                        ),
                        const SizedBox(width: 8),
                        _CyclePill(
                          label: 'شهادة البكالوريا (BAC)',
                          isSelected: widget.controller.selectedCycle == 'bac',
                          onTap: () => widget.controller.setCycle('bac'),
                        ),
                        const SizedBox(width: 8),
                        _CyclePill(
                          label: 'التعليم المتوسط (BEM)',
                          isSelected: widget.controller.selectedCycle == 'bem',
                          onTap: () => widget.controller.setCycle('bem'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // 2. Stream Filter Pills (Visible when All or BAC is selected)
              if (widget.controller.selectedCycle != 'bem')
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.only(bottom: 8),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: _streams.map((stream) {
                        final isSelected = (stream.id == 'all' && widget.controller.selectedStream == null) ||
                            (widget.controller.selectedStream == stream.id);

                        return Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: FilterChip(
                            label: Text(stream.label),
                            selected: isSelected,
                            onSelected: (_) {
                              widget.controller.setStream(stream.id == 'all' ? null : stream.id);
                            },
                            selectedColor: AppTheme.primaryColor.withAlpha(30),
                            checkmarkColor: AppTheme.primaryColor,
                            labelStyle: TextStyle(
                              fontSize: 12,
                              color: isSelected ? AppTheme.primaryColor : Colors.grey.shade800,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),

              const Divider(height: 1),

              // 3. Exams List
              Expanded(
                child: widget.controller.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : widget.controller.errorMessage != null
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.error_outline, size: 48, color: Colors.red.shade400),
                                  const SizedBox(height: 12),
                                  Text(
                                    widget.controller.errorMessage!,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(color: Colors.red),
                                  ),
                                  const SizedBox(height: 12),
                                  ElevatedButton(
                                    onPressed: widget.controller.loadExams,
                                    child: const Text('إعادة المحاولة'),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : widget.controller.exams.isEmpty
                            ? Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(24),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.menu_book, size: 48, color: Colors.grey.shade400),
                                      const SizedBox(height: 12),
                                      const Text(
                                        'لا توجد مواضيع مطابقة للفلاتر المحددة حالياً.',
                                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                itemCount: widget.controller.exams.length,
                                itemBuilder: (context, index) {
                                  final paper = widget.controller.exams[index];
                                  return ExamPaperCard(
                                    paper: paper,
                                    onTap: () => _showPaperDetails(paper),
                                    onStartSimulation: () => _onStartSimulation(paper),
                                  );
                                },
                              ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _CyclePill extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _CyclePill({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.primaryColor : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? AppTheme.primaryColor : Colors.grey.shade300,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.white : Colors.grey.shade700,
            ),
          ),
        ),
      ),
    );
  }
}
