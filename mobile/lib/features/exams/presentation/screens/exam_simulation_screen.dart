import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/exam_paper_entity.dart';
import '../controllers/exam_bank_controller.dart';

class ExamSimulationScreen extends StatefulWidget {
  final ExamPaperEntity paper;
  final ExamBankController controller;

  const ExamSimulationScreen({
    super.key,
    required this.paper,
    required this.controller,
  });

  @override
  State<ExamSimulationScreen> createState() => _ExamSimulationScreenState();
}

class _ExamSimulationScreenState extends State<ExamSimulationScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _notesController.text = widget.controller.simulationNotes;

    // Load exercises if not already loaded
    if (widget.controller.currentExercises.isEmpty ||
        widget.controller.selectedExam?.id != widget.paper.id) {
      widget.controller.loadExamDetails(widget.paper.id);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Color _getTimerColor() {
    if (widget.controller.isCriticalTimeLimit) {
      return Colors.red.shade600;
    } else if (widget.controller.isNearTimeLimit) {
      return Colors.amber.shade800;
    }
    return AppTheme.secondaryColor;
  }

  void _showFinishDialog() {
    final scoreController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.fact_check, color: AppTheme.primaryColor),
            SizedBox(width: 8),
            Text(
              'إنهاء المحاكاة والتقييم الذاتي',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'راجع إجاباتك بمقارنتها مع سلم التنقيط الوزاري الرسمي، وسجّل علامتك المستحقة من 20:',
                style: TextStyle(fontSize: 14, color: Color(0xFF475569)),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: scoreController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'العلامة التقديرية (من 20)',
                  hintText: 'مثلاً: 16.50',
                  suffixText: '/ 20',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.grade),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'يرجى إدخال العلامة التقديرية';
                  }
                  final numVal = double.tryParse(val.trim());
                  if (numVal == null || numVal < 0 || numVal > 20) {
                    return 'العلامة يجب أن تكون بين 0 و 20';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('متابعة الحل'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade700,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () async {
              if (formKey.currentState?.validate() ?? false) {
                final score = double.parse(scoreController.text.trim());
                Navigator.pop(ctx);
                final success = await widget.controller.finishSimulation(
                  selfAssessmentScore: score,
                  notes: _notesController.text,
                );

                if (mounted && success) {
                  _showCongratulatorySheet(score);
                }
              }
            },
            child: const Text('تأكيد وتسجيل النتيجة'),
          ),
        ],
      ),
    );
  }

  void _showCongratulatorySheet(double score) {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.green.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.emoji_events, size: 36, color: Colors.green.shade800),
            ),
            const SizedBox(height: 16),
            const Text(
              'أحسنت! اكتملت المحاكاة بنجاح 🇩🇿',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'علامتك المسجلة في هذا الامتحان: ${score.toStringAsFixed(2)} / 20',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: score >= 10 ? Colors.green.shade800 : Colors.red.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'الوقت المستغرق: ${widget.controller.activeSimulation?.formattedTimeSpent ?? ""}',
              style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx); // Close sheet
                  Navigator.pop(context); // Exit simulation screen
                },
                child: const Text('العودة إلى بنك الامتحانات'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, _) {
        final timerColor = _getTimerColor();

        return Scaffold(
          appBar: AppBar(
            title: Text(
              widget.paper.cycleBadge == 'BAC' ? 'محاكاة البكالوريا الرسمية' : 'محاكاة شهادة التعليم المتوسط',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            bottom: TabBar(
              controller: _tabController,
              indicatorColor: AppTheme.accentColor,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white70,
              tabs: const [
                Tab(icon: Icon(Icons.assignment, size: 18), text: 'التمارين'),
                Tab(icon: Icon(Icons.edit_note, size: 18), text: 'المسودة'),
                Tab(icon: Icon(Icons.rule, size: 18), text: 'سلم التنقيط'),
              ],
            ),
          ),
          body: Column(
            children: [
              // 1. Timer Banner Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                color: timerColor.withAlpha(25),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.hourglass_top, color: timerColor, size: 24),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'الوقت المتبقي للامتحان',
                              style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                            ),
                            Text(
                              widget.controller.formattedRemainingTime,
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: timerColor,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    ElevatedButton.icon(
                      onPressed: _showFinishDialog,
                      icon: const Icon(Icons.check, size: 18),
                      label: const Text('إنهاء وتقييم'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade700,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ],
                ),
              ),

              // Urgent Warnings
              if (widget.controller.isCriticalTimeLimit)
                Container(
                  color: Colors.red.shade100,
                  padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
                  child: Row(
                    children: [
                      Icon(Icons.warning_amber_rounded, size: 18, color: Colors.red.shade800),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'تنبيه عاجل: تبقت 5 دقائق فقط! ابدأ بمراجعة الإجابات ونقلها بدقة.',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.red.shade900,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              // 2. Tab Views
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // Tab 1: Exercises Checklist
                    _buildExercisesTab(),

                    // Tab 2: Scratchpad & Notes
                    _buildScratchpadTab(),

                    // Tab 3: Official Marking Rubric (سلم التنقيط الوزاري)
                    _buildRubricTab(),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildExercisesTab() {
    final exercises = widget.controller.currentExercises;

    if (widget.controller.isLoadingDetails) {
      return const Center(child: CircularProgressIndicator());
    }

    if (exercises.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.menu_book, size: 48, color: Colors.grey.shade400),
              const SizedBox(height: 12),
              Text(
                widget.paper.title,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(
                widget.paper.description ?? 'موضوع رسمي من الديوان الوطني للامتحانات والمسابقات.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: exercises.length,
      itemBuilder: (context, index) {
        final exercise = exercises[index];
        final isChecked = widget.controller.completedExerciseNumbers.contains(exercise.exerciseNumber);

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(
              color: isChecked ? Colors.green.shade400 : Colors.grey.shade200,
              width: isChecked ? 1.5 : 1.0,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        exercise.title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isChecked ? Colors.green.shade900 : const Color(0xFF1E293B),
                          decoration: isChecked ? TextDecoration.lineThrough : null,
                        ),
                      ),
                    ),
                    Checkbox(
                      value: isChecked,
                      activeColor: Colors.green.shade700,
                      onChanged: (_) {
                        widget.controller.toggleExerciseCompleted(exercise.exerciseNumber);
                      },
                    ),
                  ],
                ),
                if (exercise.topic != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'المحور: ${exercise.topic!}',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
                const SizedBox(height: 10),
                if (exercise.instructions != null) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Text(
                      exercise.instructions!,
                      style: const TextStyle(fontSize: 13, height: 1.5, color: Color(0xFF334155)),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'العلامة: ${exercise.points} نقاط',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    Text(
                      isChecked ? 'تم الحل والمراجعة ✓' : 'قيد الإنجاز...',
                      style: TextStyle(
                        fontSize: 12,
                        color: isChecked ? Colors.green.shade700 : Colors.amber.shade800,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildScratchpadTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'مسودة التلميذ (Brouillon & Notes):',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          const Text(
            'استخدم هذه المساحة لتدوين خطوات الحل والمعادلات والملاحظات أثناء المحاكاة.',
            style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: TextField(
              controller: _notesController,
              maxLines: null,
              expands: true,
              textAlignVertical: TextAlignVertical.top,
              onChanged: (text) {
                widget.controller.updateSimulationNotes(text);
              },
              decoration: InputDecoration(
                hintText: 'اكتب هنا مسودة الحل والملاحظات...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                fillColor: Colors.white,
                filled: true,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRubricTab() {
    final exercises = widget.controller.currentExercises;

    if (exercises.isEmpty) {
      return const Center(child: Text('لا توجد معايير تنقيط مفصلة متاحة حالياً.'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: exercises.length,
      itemBuilder: (context, index) {
        final exercise = exercises[index];
        final rubric = exercise.officialMarkingRubric;

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      exercise.title,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withAlpha(20),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${exercise.points} ن',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const Divider(height: 18),
                if (rubric.isNotEmpty) ...[
                  const Text(
                    'شبكة التنقيط الوزاري الرسمية (Barème détaillé):',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF475569)),
                  ),
                  const SizedBox(height: 8),
                  ...rubric.map(
                    (step) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.arrow_right, size: 16, color: Colors.grey.shade700),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              step.step,
                              style: const TextStyle(fontSize: 13, color: Color(0xFF1E293B)),
                            ),
                          ),
                          Text(
                            '+${step.points} ن',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                if (exercise.solutionExplanation != null) ...[
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'شرح توجيهي: ${exercise.solutionExplanation!}',
                      style: TextStyle(fontSize: 12, color: Colors.blue.shade900),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
