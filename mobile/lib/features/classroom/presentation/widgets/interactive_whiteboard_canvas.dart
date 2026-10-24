import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/widgets/glassmorphism.dart';
import '../../domain/entities/whiteboard_stroke_entity.dart';
import '../controllers/classroom_controller.dart';

class InteractiveWhiteboardCanvas extends StatefulWidget {
  final ClassroomController controller;
  final bool isTeacher;
  final String? sessionId;

  const InteractiveWhiteboardCanvas({
    super.key,
    required this.controller,
    required this.isTeacher,
    this.sessionId,
  });

  @override
  State<InteractiveWhiteboardCanvas> createState() => _InteractiveWhiteboardCanvasState();
}

class _InteractiveWhiteboardCanvasState extends State<InteractiveWhiteboardCanvas> {
  WhiteboardTool _selectedTool = WhiteboardTool.pen;
  Color _selectedColor = const Color(0xFF0D9488); // Brand Teal
  double _strokeWidth = 4.0;
  bool _isDarkChalkboard = false;

  final List<WhiteboardPoint> _currentStrokePoints = [];
  bool _isSavingSnapshot = false;

  final List<Color> _palette = const [
    Color(0xFF0F172A), // Dark Slate / Ink
    Color(0xFF0D9488), // Brand Teal
    Color(0xFF2563EB), // Royal Blue
    Color(0xFFEF4444), // Coral Red
    Color(0xFF10B981), // Emerald Green
    Color(0xFFF59E0B), // Amber
    Color(0xFF8B5CF6), // Purple
    Color(0xFFFFFFFF), // Chalkboard White
  ];

  void _onPanStart(DragStartDetails details, Size size) {
    if (!widget.isTeacher) return; // Read-only for student unless permitted

    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final localPos = details.localPosition;
    final normalizedX = (localPos.dx / size.width).clamp(0.0, 1.0);
    final normalizedY = (localPos.dy / size.height).clamp(0.0, 1.0);

    setState(() {
      _currentStrokePoints.clear();
      _currentStrokePoints.add(WhiteboardPoint(x: normalizedX, y: normalizedY));
    });
  }

  void _onPanUpdate(DragUpdateDetails details, Size size) {
    if (!widget.isTeacher) return;

    final localPos = details.localPosition;
    final normalizedX = (localPos.dx / size.width).clamp(0.0, 1.0);
    final normalizedY = (localPos.dy / size.height).clamp(0.0, 1.0);

    setState(() {
      _currentStrokePoints.add(WhiteboardPoint(x: normalizedX, y: normalizedY));
    });
  }

  void _onPanEnd(DragEndDetails details) {
    if (!widget.isTeacher || _currentStrokePoints.isEmpty) return;

    final stroke = WhiteboardStrokeEntity(
      id: 'stk_${DateTime.now().millisecondsSinceEpoch}_${math.Random().nextInt(1000)}',
      tool: _selectedTool,
      colorValue: _selectedColor.toARGB32(),
      strokeWidth: _strokeWidth,
      points: List.from(_currentStrokePoints),
      authorIdentity: widget.controller.localParticipant?.identity ?? 'instructor',
      authorName: widget.controller.localParticipant?.name ?? 'Instructor',
      timestamp: DateTime.now(),
    );

    widget.controller.addWhiteboardStroke(stroke);

    setState(() {
      _currentStrokePoints.clear();
    });
  }

  Future<void> _saveSnapshotToBackend() async {
    final strokes = widget.controller.whiteboardStrokes;
    if (strokes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Whiteboard is empty. Draw something before saving notes.'),
          backgroundColor: Color(0xFFF59E0B),
        ),
      );
      return;
    }

    final titleController = TextEditingController(
      text: 'Lecture Slide v${DateTime.now().minute}:${DateTime.now().second}',
    );

    final shouldSave = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0F172A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: Colors.white.withValues(alpha: 0.15)),
        ),
        title: const Row(
          children: [
            Icon(Icons.bookmark_add, color: Color(0xFF2DD4BF)),
            SizedBox(width: 10),
            Text('Save Slide Snapshot', style: TextStyle(color: Colors.white, fontSize: 18)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter a title for this whiteboard slide note:',
              style: TextStyle(color: Colors.white70, fontSize: 13),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: titleController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.08),
                hintText: 'e.g. Limits & Derivatives Intro',
                hintStyle: const TextStyle(color: Colors.white38),
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
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel', style: TextStyle(color: Colors.white60)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0D9488),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (shouldSave != true || !mounted) return;

    setState(() => _isSavingSnapshot = true);

    try {
      final title = titleController.text.trim().isNotEmpty
          ? titleController.text.trim()
          : 'Lecture Slide Notes';

      final saved = await widget.controller.saveWhiteboardSnapshot(
        sessionId: widget.sessionId,
        title: title,
      );

      if (mounted) {
        if (saved != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Slide saved successfully! Version ${saved.version} (${strokes.length} strokes)'),
              backgroundColor: const Color(0xFF0D9488),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Notes saved to session memory!'),
              backgroundColor: Color(0xFF0D9488),
            ),
          );
        }
      }
    } finally {
      if (mounted) setState(() => _isSavingSnapshot = false);
    }
  }

  Future<void> _showSnapshotHistoryModal() async {
    final history = await widget.controller.loadWhiteboardHistory(sessionId: widget.sessionId);

    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return GlassmorphicContainer(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          blurSigma: 24.0,
          borderWidth: 1.2,
          borderColor: Colors.white.withValues(alpha: 0.22),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF1E293B).withValues(alpha: 0.95),
              const Color(0xFF0F172A).withValues(alpha: 0.98),
            ],
          ),
          padding: const EdgeInsets.all(20),
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.55,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 48,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white38,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Row(
                  children: [
                    Icon(Icons.collections_bookmark_outlined, color: Color(0xFF2DD4BF)),
                    SizedBox(width: 10),
                    Text(
                      'Whiteboard Slide History',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (history.isEmpty)
                  const Expanded(
                    child: Center(
                      child: Text(
                        'No saved whiteboard slides yet in this session.',
                        style: TextStyle(color: Colors.white60),
                      ),
                    ),
                  )
                else
                  Expanded(
                    child: ListView.separated(
                      itemCount: history.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final slide = history[index];
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.06),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 38,
                                height: 38,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF0D9488).withValues(alpha: 0.25),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Center(
                                  child: Text(
                                    'v${slide.version}',
                                    style: const TextStyle(
                                      color: Color(0xFF2DD4BF),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      slide.snapshotTitle,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                      ),
                                    ),
                                    Text(
                                      '${slide.strokeCount} strokes • By ${slide.authorName}',
                                      style: const TextStyle(
                                        color: Colors.white54,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (widget.isTeacher && slide.vectorData.isNotEmpty)
                                ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF0D9488),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  ),
                                  onPressed: () {
                                    widget.controller.restoreWhiteboardSnapshot(slide);
                                    Navigator.pop(ctx);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Restored "${slide.snapshotTitle}"'),
                                        backgroundColor: const Color(0xFF0D9488),
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.restore, size: 16, color: Colors.white),
                                  label: const Text('Restore', style: TextStyle(color: Colors.white, fontSize: 12)),
                                ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final strokes = widget.controller.whiteboardStrokes;
    final bgColor = _isDarkChalkboard ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC);

    return LayoutBuilder(
      builder: (context, constraints) {
        final canvasSize = Size(constraints.maxWidth, constraints.maxHeight);

        return Stack(
          children: [
            // 1. Drawing Surface
            Positioned.fill(
              child: GestureDetector(
                onPanStart: (d) => _onPanStart(d, canvasSize),
                onPanUpdate: (d) => _onPanUpdate(d, canvasSize),
                onPanEnd: _onPanEnd,
                child: Container(
                  color: bgColor,
                  child: CustomPaint(
                    size: canvasSize,
                    painter: WhiteboardPainter(
                      strokes: strokes,
                      activePoints: _currentStrokePoints,
                      activeTool: _selectedTool,
                      activeColor: _selectedColor,
                      activeStrokeWidth: _strokeWidth,
                      isDark: _isDarkChalkboard,
                    ),
                  ),
                ),
              ),
            ),

            // 2. Grid Pattern Overlay
            Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(
                  painter: WhiteboardGridPainter(isDark: _isDarkChalkboard),
                ),
              ),
            ),

            // 3. Floating Tool Palette (Instructor controls)
            if (widget.isTeacher)
              Positioned(
                top: 16,
                left: 16,
                right: 16,
                child: Center(
                  child: _buildFloatingToolbar(),
                ),
              ),

            // 4. Student View Indicator (If viewer is student)
            if (!widget.isTeacher)
              Positioned(
                bottom: 16,
                left: 16,
                child: GlassmorphicContainer(
                  borderRadius: BorderRadius.circular(16),
                  blurSigma: 16.0,
                  borderColor: Colors.white.withValues(alpha: 0.20),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: const Color(0xFF0D9488),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF0D9488).withValues(alpha: 0.8),
                              blurRadius: 6,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.draw, size: 16, color: Color(0xFF2DD4BF)),
                      const SizedBox(width: 8),
                      const Text(
                        'Live Broadcast • Instructor Drawing',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // 5. Canvas Settings (Chalkboard Mode & Snapshot Save)
            Positioned(
              bottom: 16,
              right: 16,
              child: GlassmorphicContainer(
                borderRadius: BorderRadius.circular(16),
                blurSigma: 16.0,
                borderColor: Colors.white.withValues(alpha: 0.20),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GlassmorphicScaleButton(
                      tooltip: _isDarkChalkboard ? 'Paper White Mode' : 'Chalkboard Dark Mode',
                      pressedScale: 0.88,
                      onPressed: () => setState(() => _isDarkChalkboard = !_isDarkChalkboard),
                      builder: (context, isPressed, isHovered) {
                        return Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isHovered
                                ? Colors.white.withValues(alpha: 0.15)
                                : Colors.transparent,
                          ),
                          child: Icon(
                            _isDarkChalkboard ? Icons.light_mode : Icons.dark_mode,
                            size: 20,
                            color: isHovered ? Colors.amberAccent : Colors.white70,
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 4),
                    GlassmorphicScaleButton(
                      tooltip: 'Slide Revisions & History',
                      pressedScale: 0.88,
                      onPressed: _showSnapshotHistoryModal,
                      builder: (context, isPressed, isHovered) {
                        return Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isHovered
                                ? Colors.white.withValues(alpha: 0.15)
                                : Colors.transparent,
                          ),
                          child: const Icon(
                            Icons.collections_bookmark_outlined,
                            size: 20,
                            color: Color(0xFF60A5FA),
                          ),
                        );
                      },
                    ),
                    if (widget.isTeacher) ...[
                      const SizedBox(width: 4),
                      GlassmorphicScaleButton(
                        tooltip: 'Save Notes Snapshot',
                        pressedScale: 0.88,
                        onPressed: _isSavingSnapshot ? null : _saveSnapshotToBackend,
                        builder: (context, isPressed, isHovered) {
                          return Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isHovered
                                  ? const Color(0xFF0D9488).withValues(alpha: 0.25)
                                  : Colors.transparent,
                            ),
                            child: _isSavingSnapshot
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Color(0xFF2DD4BF),
                                    ),
                                  )
                                : const Icon(
                                    Icons.bookmark_add,
                                    size: 20,
                                    color: Color(0xFF2DD4BF),
                                  ),
                          );
                        },
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFloatingToolbar() {
    return GlassmorphicContainer(
      borderRadius: BorderRadius.circular(22),
      blurSigma: 18.0,
      borderWidth: 1.2,
      borderColor: Colors.white.withValues(alpha: 0.22),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withValues(alpha: 0.14),
          const Color(0xFF1E1B4B).withValues(alpha: 0.70), // Cosmic Indigo
          const Color(0xFF0F172A).withValues(alpha: 0.88), // Deep Navy Slate
        ],
        stops: const [0.0, 0.45, 1.0],
      ),
      boxShadow: [
        BoxShadow(
          color: const Color(0xFF6366F1).withValues(alpha: 0.22), // Indigo halo
          blurRadius: 28,
          spreadRadius: 1,
          offset: const Offset(0, 4),
        ),
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.45),
          blurRadius: 22,
          offset: const Offset(0, 8),
        ),
      ],
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Tool selection buttons with micro-interactions
            _toolButton(WhiteboardTool.pen, Icons.edit, 'Pen'),
            _toolButton(WhiteboardTool.highlighter, Icons.brush, 'Highlighter'),
            _toolButton(WhiteboardTool.rectangle, Icons.crop_square, 'Rectangle'),
            _toolButton(WhiteboardTool.circle, Icons.circle_outlined, 'Circle'),
            _toolButton(WhiteboardTool.line, Icons.horizontal_rule, 'Line'),
            _toolButton(WhiteboardTool.arrow, Icons.arrow_outward, 'Arrow'),
            _toolButton(WhiteboardTool.coordinateSystem, Icons.timeline, 'Axes / Repère'),
            _toolButton(WhiteboardTool.laserPointer, Icons.flare, 'Laser Pointer'),
            _toolButton(WhiteboardTool.eraser, Icons.auto_fix_normal, 'Eraser'),

            _buildVerticalDivider(),

            // Color Palette with interactive scale-down swatches
            ..._palette.map((c) {
              final isSelected = _selectedColor.toARGB32() == c.toARGB32();
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3),
                child: GlassmorphicScaleButton(
                  tooltip: 'Select Color',
                  pressedScale: 0.82,
                  hoverScale: 1.15,
                  onPressed: () => setState(() => _selectedColor = c),
                  builder: (context, isPressed, isHovered) {
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 140),
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: c,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected
                              ? Colors.white
                              : (isHovered ? Colors.white70 : Colors.white38),
                          width: isSelected ? 2.5 : 1.0,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: c.withValues(alpha: 0.8),
                                  blurRadius: 8,
                                  spreadRadius: 1,
                                ),
                              ]
                            : (isHovered
                                ? [
                                    BoxShadow(
                                      color: c.withValues(alpha: 0.45),
                                      blurRadius: 6,
                                    ),
                                  ]
                                : null),
                      ),
                    );
                  },
                ),
              );
            }),

            _buildVerticalDivider(),

            // Stroke Width Selector Pills
            _strokeWidthPill(2.0, 'Thin'),
            const SizedBox(width: 4),
            _strokeWidthPill(5.0, 'Med'),
            const SizedBox(width: 4),
            _strokeWidthPill(10.0, 'Thick'),

            _buildVerticalDivider(),

            // Undo Action Button
            GlassmorphicScaleButton(
              tooltip: 'Undo',
              pressedScale: 0.88,
              onPressed: () => widget.controller.undoWhiteboardStroke(),
              builder: (context, isPressed, isHovered) {
                return Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isHovered
                        ? Colors.white.withValues(alpha: 0.15)
                        : Colors.transparent,
                  ),
                  child: Icon(
                    Icons.undo,
                    size: 19,
                    color: isHovered ? Colors.white : Colors.white70,
                  ),
                );
              },
            ),

            const SizedBox(width: 4),

            // Clear Board Button
            GlassmorphicScaleButton(
              tooltip: 'Clear Board',
              pressedScale: 0.88,
              onPressed: () => widget.controller.clearWhiteboard(),
              builder: (context, isPressed, isHovered) {
                return Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isHovered
                        ? Colors.redAccent.withValues(alpha: 0.22)
                        : Colors.transparent,
                  ),
                  child: Icon(
                    Icons.delete_outline,
                    size: 19,
                    color: isHovered ? Colors.white : Colors.redAccent,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVerticalDivider() {
    return Container(
      width: 1,
      height: 24,
      margin: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(1),
      ),
    );
  }

  Widget _toolButton(WhiteboardTool tool, IconData icon, String label) {
    final isSelected = _selectedTool == tool;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3),
      child: GlassmorphicScaleButton(
        tooltip: label,
        pressedScale: 0.88,
        onPressed: () => setState(() => _selectedTool = tool),
        builder: (context, isPressed, isHovered) {
          return AnimatedContainer(
            duration: const Duration(milliseconds: 140),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: isSelected
                  ? LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color(0xFF0D9488).withValues(alpha: 0.80),
                        const Color(0xFF14B8A6).withValues(alpha: 0.50),
                      ],
                    )
                  : (isHovered
                      ? LinearGradient(
                          colors: [
                            Colors.white.withValues(alpha: 0.16),
                            Colors.white.withValues(alpha: 0.08),
                          ],
                        )
                      : null),
              border: Border.all(
                color: isSelected
                    ? const Color(0xFF2DD4BF).withValues(alpha: 0.75)
                    : (isHovered
                        ? Colors.white.withValues(alpha: 0.28)
                        : Colors.transparent),
                width: 1.2,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: const Color(0xFF0D9488).withValues(alpha: 0.45),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Icon(
              icon,
              size: 19,
              color: isSelected
                  ? Colors.white
                  : (isHovered ? Colors.white : Colors.white70),
            ),
          );
        },
      ),
    );
  }

  Widget _strokeWidthPill(double width, String label) {
    final isSelected = _strokeWidth == width;

    return GlassmorphicScaleButton(
      tooltip: '$label Stroke',
      pressedScale: 0.88,
      onPressed: () => setState(() => _strokeWidth = width),
      builder: (context, isPressed, isHovered) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            gradient: isSelected
                ? LinearGradient(
                    colors: [
                      const Color(0xFF0D9488).withValues(alpha: 0.80),
                      const Color(0xFF14B8A6).withValues(alpha: 0.50),
                    ],
                  )
                : null,
            color: isSelected
                ? null
                : Colors.white.withValues(alpha: isHovered ? 0.16 : 0.08),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFF2DD4BF).withValues(alpha: 0.70)
                  : Colors.white.withValues(alpha: isHovered ? 0.28 : 0.14),
              width: 1.0,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: const Color(0xFF0D9488).withValues(alpha: 0.40),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: isSelected
                  ? Colors.white
                  : (isHovered ? Colors.white : Colors.white70),
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      },
    );
  }
}

class WhiteboardPainter extends CustomPainter {
  final List<WhiteboardStrokeEntity> strokes;
  final List<WhiteboardPoint> activePoints;
  final WhiteboardTool activeTool;
  final Color activeColor;
  final double activeStrokeWidth;
  final bool isDark;

  WhiteboardPainter({
    required this.strokes,
    required this.activePoints,
    required this.activeTool,
    required this.activeColor,
    required this.activeStrokeWidth,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Paint all committed strokes
    for (final s in strokes) {
      _drawStroke(canvas, size, s.tool, Color(s.colorValue), s.strokeWidth, s.points);
    }

    // 2. Paint current in-flight stroke
    if (activePoints.isNotEmpty) {
      _drawStroke(canvas, size, activeTool, activeColor, activeStrokeWidth, activePoints);
    }
  }

  void _drawStroke(
    Canvas canvas,
    Size size,
    WhiteboardTool tool,
    Color color,
    double strokeWidth,
    List<WhiteboardPoint> points,
  ) {
    if (points.isEmpty) return;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    if (tool == WhiteboardTool.highlighter) {
      paint
        ..color = color.withValues(alpha: 0.35)
        ..strokeWidth = strokeWidth * 3.5;
    } else if (tool == WhiteboardTool.eraser) {
      paint
        ..color = isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC)
        ..strokeWidth = strokeWidth * 5.0;
    } else {
      paint
        ..color = color
        ..strokeWidth = strokeWidth;
    }

    final offsets = points.map((p) => Offset(p.x * size.width, p.y * size.height)).toList();

    switch (tool) {
      case WhiteboardTool.pen:
      case WhiteboardTool.highlighter:
      case WhiteboardTool.eraser:
        if (offsets.length == 1) {
          canvas.drawCircle(offsets.first, strokeWidth / 2, paint..style = PaintingStyle.fill);
        } else {
          final path = Path()..moveTo(offsets.first.dx, offsets.first.dy);
          for (int i = 1; i < offsets.length; i++) {
            path.lineTo(offsets[i].dx, offsets[i].dy);
          }
          canvas.drawPath(path, paint);
        }
        break;

      case WhiteboardTool.rectangle:
        if (offsets.length >= 2) {
          final rect = Rect.fromPoints(offsets.first, offsets.last);
          canvas.drawRect(rect, paint);
        }
        break;

      case WhiteboardTool.circle:
        if (offsets.length >= 2) {
          final rect = Rect.fromPoints(offsets.first, offsets.last);
          canvas.drawOval(rect, paint);
        }
        break;

      case WhiteboardTool.line:
        if (offsets.length >= 2) {
          canvas.drawLine(offsets.first, offsets.last, paint);
        }
        break;

      case WhiteboardTool.arrow:
        if (offsets.length >= 2) {
          final start = offsets.first;
          final end = offsets.last;
          canvas.drawLine(start, end, paint);

          // Arrowhead math
          final angle = math.atan2(end.dy - start.dy, end.dx - start.dx);
          const arrowHeadSize = 14.0;
          final p1 = Offset(
            end.dx - arrowHeadSize * math.cos(angle - math.pi / 6),
            end.dy - arrowHeadSize * math.sin(angle - math.pi / 6),
          );
          final p2 = Offset(
            end.dx - arrowHeadSize * math.cos(angle + math.pi / 6),
            end.dy - arrowHeadSize * math.sin(angle + math.pi / 6),
          );
          final arrowPath = Path()
            ..moveTo(end.dx, end.dy)
            ..lineTo(p1.dx, p1.dy)
            ..lineTo(p2.dx, p2.dy)
            ..close();
          canvas.drawPath(arrowPath, paint..style = PaintingStyle.fill);
        }
        break;

      case WhiteboardTool.coordinateSystem:
        if (offsets.length >= 2) {
          final p1 = offsets.first;
          final p2 = offsets.last;
          final left = math.min(p1.dx, p2.dx);
          final right = math.max(p1.dx, p2.dx);
          final top = math.min(p1.dy, p2.dy);
          final bottom = math.max(p1.dy, p2.dy);
          final origin = Offset(
            left + (right - left) * 0.35,
            bottom - (bottom - top) * 0.35,
          );

          // Horizontal X-axis with arrowhead
          canvas.drawLine(Offset(left, origin.dy), Offset(right, origin.dy), paint);
          canvas.drawLine(Offset(right, origin.dy), Offset(right - 8, origin.dy - 5), paint);
          canvas.drawLine(Offset(right, origin.dy), Offset(right - 8, origin.dy + 5), paint);

          // Vertical Y-axis with arrowhead
          canvas.drawLine(Offset(origin.dx, bottom), Offset(origin.dx, top), paint);
          canvas.drawLine(Offset(origin.dx, top), Offset(origin.dx - 5, top + 8), paint);
          canvas.drawLine(Offset(origin.dx, top), Offset(origin.dx + 5, top + 8), paint);

          // Origin indicator O
          canvas.drawCircle(origin, 2.5, paint..style = PaintingStyle.fill);
        }
        break;

      case WhiteboardTool.laserPointer:
        if (offsets.isNotEmpty) {
          final target = offsets.last;
          final laserGlow = Paint()
            ..shader = RadialGradient(
              colors: [
                color.withValues(alpha: 0.95),
                color.withValues(alpha: 0.40),
                color.withValues(alpha: 0.0),
              ],
              stops: const [0.0, 0.40, 1.0],
            ).createShader(Rect.fromCircle(center: target, radius: 20.0));
          canvas.drawCircle(target, 20.0, laserGlow);
          canvas.drawCircle(target, 3.5, Paint()..color = Colors.white..style = PaintingStyle.fill);
        }
        break;

      case WhiteboardTool.text:
        break;
    }
  }

  @override
  bool shouldRepaint(covariant WhiteboardPainter oldDelegate) => true;
}

class WhiteboardGridPainter extends CustomPainter {
  final bool isDark;

  WhiteboardGridPainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = (isDark ? Colors.white : Colors.black).withValues(alpha: 0.035)
      ..strokeWidth = 1.0;

    const spacing = 32.0;

    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant WhiteboardGridPainter oldDelegate) => oldDelegate.isDark != isDark;
}
