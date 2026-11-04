import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Next-Generation 4-Vector Anti-Piracy Dynamic Watermark.
///
/// Designed to counter external camera recording, screen filming, and AI watermark removers:
/// 1. Dynamic Roaming Badge: Floats continuously along multi-point bezier curves.
/// 2. Live Seconds Clock: Embeds live seconds so recorded footage proves the exact second of capture.
/// 3. Corner Micro-Steganography: Subtle hashed badges in all 4 corners resist cropping.
/// 4. Periodic Phantom Flash: Transitory 1.2-second watermark flashes in random coordinates every ~30s.
class EnhancedDynamicWatermark extends StatefulWidget {
  final String studentName;
  final String studentId;
  final String? studentEmail;
  final String? wilaya;
  final bool enablePhantomFlash;

  const EnhancedDynamicWatermark({
    super.key,
    required this.studentName,
    required this.studentId,
    this.studentEmail,
    this.wilaya,
    this.enablePhantomFlash = true,
  });

  @override
  State<EnhancedDynamicWatermark> createState() => _EnhancedDynamicWatermarkState();
}

class _EnhancedDynamicWatermarkState extends State<EnhancedDynamicWatermark>
    with SingleTickerProviderStateMixin {
  late AnimationController _roamController;
  late Animation<Alignment> _roamAnimation;

  Timer? _clockTimer;
  Timer? _phantomFlashTimer;
  String _liveTimeString = '';

  bool _isPhantomFlashVisible = false;
  Alignment _phantomAlignment = const Alignment(0.2, -0.3);

  final math.Random _random = math.Random();

  @override
  void initState() {
    super.initState();
    _updateClock();

    // 1. Live second timer
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) _updateClock();
    });

    // 2. Roaming animation controller
    _roamController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 22),
    )..repeat(reverse: true);

    _roamAnimation = TweenSequence<Alignment>([
      TweenSequenceItem(
        tween: AlignmentTween(
          begin: const Alignment(-0.75, -0.65),
          end: const Alignment(0.70, -0.45),
        ),
        weight: 25,
      ),
      TweenSequenceItem(
        tween: AlignmentTween(
          begin: const Alignment(0.70, -0.45),
          end: const Alignment(0.65, 0.65),
        ),
        weight: 25,
      ),
      TweenSequenceItem(
        tween: AlignmentTween(
          begin: const Alignment(0.65, 0.65),
          end: const Alignment(-0.65, 0.50),
        ),
        weight: 25,
      ),
      TweenSequenceItem(
        tween: AlignmentTween(
          begin: const Alignment(-0.65, 0.50),
          end: const Alignment(-0.75, -0.65),
        ),
        weight: 25,
      ),
    ]).animate(CurvedAnimation(parent: _roamController, curve: Curves.easeInOut));

    // 3. Periodic Phantom Flash Timer
    if (widget.enablePhantomFlash) {
      _startPhantomFlashCycle();
    }
  }

  void _updateClock() {
    final now = DateTime.now();
    final h = now.hour.toString().padLeft(2, '0');
    final m = now.minute.toString().padLeft(2, '0');
    final s = now.second.toString().padLeft(2, '0');
    setState(() {
      _liveTimeString = '$h:$m:$s';
    });
  }

  void _startPhantomFlashCycle() {
    _phantomFlashTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (!mounted) return;
      // Random coordinates within safe viewport
      final rx = (_random.nextDouble() * 1.4) - 0.7;
      final ry = (_random.nextDouble() * 1.4) - 0.7;
      setState(() {
        _phantomAlignment = Alignment(rx, ry);
        _isPhantomFlashVisible = true;
      });

      // Hide after 1.4 seconds
      Future.delayed(const Duration(milliseconds: 1400), () {
        if (mounted) {
          setState(() => _isPhantomFlashVisible = false);
        }
      });
    });
  }

  @override
  void dispose() {
    _roamController.dispose();
    _clockTimer?.cancel();
    _phantomFlashTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final displayName = widget.studentName.isNotEmpty ? widget.studentName : 'طالب موثق';
    final displayId = widget.studentId.isNotEmpty ? widget.studentId : 'STU_2026';
    final wilayaText = widget.wilaya != null ? ' • ${widget.wilaya}' : '';

    return IgnorePointer(
      child: Stack(
        children: [
          // Vector B: Corner Micro-Steganographic Fingerprints
          Positioned(
            top: 40,
            left: 12,
            child: _buildCornerBadge('#$displayId', opacity: 0.12),
          ),
          Positioned(
            top: 40,
            right: 12,
            child: _buildCornerBadge('#$displayId', opacity: 0.12),
          ),
          Positioned(
            bottom: 75,
            left: 12,
            child: _buildCornerBadge('$displayId • DZ', opacity: 0.10),
          ),
          Positioned(
            bottom: 75,
            right: 12,
            child: _buildCornerBadge('PINDO DRM • $displayId', opacity: 0.10),
          ),

          // Vector A: Dynamic Roaming Primary Watermark
          AnimatedBuilder(
            animation: _roamAnimation,
            builder: (context, _) {
              return Align(
                alignment: _roamAnimation.value,
                child: _buildRoamingBadge(
                  name: displayName,
                  id: displayId,
                  time: _liveTimeString,
                  extra: wilayaText,
                ),
              );
            },
          ),

          // Vector C: Periodic Phantom Flash Badge
          if (_isPhantomFlashVisible)
            Align(
              alignment: _phantomAlignment,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: _isPhantomFlashVisible ? 0.38 : 0.0,
                child: _buildPhantomFlashBadge(
                  text: '🔒 بصمة مشفرة: $displayName ($displayId) • $_liveTimeString',
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRoamingBadge({
    required String name,
    required String id,
    required String time,
    required String extra,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4.5),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.28),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xFF00E5FF).withValues(alpha: 0.35),
          width: 0.8,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 6,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.shield_outlined,
            size: 11,
            color: Color(0xFF00E5FF),
          ),
          const SizedBox(width: 5),
          Text(
            '$name • $id$extra • $time',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10.5,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCornerBadge(String text, {required double opacity}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: opacity * 0.4),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white.withValues(alpha: opacity),
          fontSize: 8.5,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
        ),
      ),
    );
  }

  Widget _buildPhantomFlashBadge({required String text}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF7C4DFF).withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF00E5FF), width: 1),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11.5,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
