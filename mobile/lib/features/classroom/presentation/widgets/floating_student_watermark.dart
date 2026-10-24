import 'package:flutter/material.dart';

/// Floating & repeated anti-piracy watermark overlay for protected live classrooms and lecture recordings.
/// Displays student identity (Name + Guardian Link Code / Wilaya) with translucent opacity.
/// Ignores pointer touches to never obstruct whiteboard drawing or media controls.
class FloatingStudentWatermark extends StatefulWidget {
  final String watermarkText;

  const FloatingStudentWatermark({
    super.key,
    required this.watermarkText,
  });

  @override
  State<FloatingStudentWatermark> createState() => _FloatingStudentWatermarkState();
}

class _FloatingStudentWatermarkState extends State<FloatingStudentWatermark>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<Alignment> _alignmentAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 18),
    )..repeat(reverse: true);

    _alignmentAnimation = TweenSequence<Alignment>([
      TweenSequenceItem(
        tween: AlignmentTween(
          begin: const Alignment(-0.7, -0.6),
          end: const Alignment(0.7, -0.4),
        ),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: AlignmentTween(
          begin: const Alignment(0.7, -0.4),
          end: const Alignment(0.6, 0.7),
        ),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: AlignmentTween(
          begin: const Alignment(0.6, 0.7),
          end: const Alignment(-0.6, 0.5),
        ),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: AlignmentTween(
          begin: const Alignment(-0.6, 0.5),
          end: const Alignment(-0.7, -0.6),
        ),
        weight: 1,
      ),
    ]).animate(CurvedAnimation(parent: _animController, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.watermarkText.isEmpty) {
      return const SizedBox.shrink();
    }

    return IgnorePointer(
      child: Stack(
        children: [
          // 1. Static subtle tiled watermarks across corners
          Positioned(
            top: 60,
            left: 20,
            child: _buildWatermarkBadge(widget.watermarkText, opacity: 0.14),
          ),
          Positioned(
            bottom: 90,
            right: 20,
            child: _buildWatermarkBadge(widget.watermarkText, opacity: 0.14),
          ),

          // 2. Dynamic drifting badge that moves continuously across the viewport
          AnimatedBuilder(
            animation: _alignmentAnimation,
            builder: (context, _) {
              return Align(
                alignment: _alignmentAnimation.value,
                child: _buildWatermarkBadge(widget.watermarkText, opacity: 0.22),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildWatermarkBadge(String text, {required double opacity}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: opacity * 0.5),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: Colors.white.withValues(alpha: opacity * 0.4),
          width: 0.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.verified_user_outlined,
            size: 11,
            color: Colors.white.withValues(alpha: opacity),
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.4,
              color: Colors.white.withValues(alpha: opacity),
            ),
          ),
        ],
      ),
    );
  }
}
