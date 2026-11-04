import 'package:flutter/material.dart';
import '../../../../core/security/anti_piracy_shield.dart';
import '../../../../core/widgets/glassmorphism.dart';
import '../../../classroom/presentation/widgets/enhanced_dynamic_watermark.dart';

class ProtectedRecordingPlayerScreen extends StatefulWidget {
  final String title;
  final String? description;
  final String streamUrl;
  final String watermarkText;

  const ProtectedRecordingPlayerScreen({
    super.key,
    required this.title,
    this.description,
    required this.streamUrl,
    required this.watermarkText,
  });

  @override
  State<ProtectedRecordingPlayerScreen> createState() => _ProtectedRecordingPlayerScreenState();
}

class _ProtectedRecordingPlayerScreenState extends State<ProtectedRecordingPlayerScreen> {
  bool _isPlaying = true;
  double _currentPosition = 0.25;

  @override
  Widget build(BuildContext context) {
    return AntiPiracyShield(
      studentName: widget.watermarkText.isNotEmpty ? widget.watermarkText : 'طالب موثق',
      studentId: 'STU_2026',
      studentEmail: 'student@pindofuture.com',
      onBreachDetected: () {
        setState(() => _isPlaying = false);
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF070B14),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(
            widget.title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          actions: [
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.5)),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.shield_rounded, color: Color(0xFF10B981), size: 13),
                  SizedBox(width: 4),
                  Text(
                    'FLAG_SECURE',
                    style: TextStyle(color: Color(0xFF34D399), fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ],
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: SafeArea(
          child: Column(
            children: [
              // 1. Protected Video Player Viewport with Watermark Overlay
              AspectRatio(
                aspectRatio: 16 / 9,
                child: Stack(
                  children: [
                    // Video Mock Canvas / Stream Surface
                    Container(
                      color: Colors.black,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _isPlaying ? Icons.play_circle_fill : Icons.pause_circle_filled,
                              size: 64,
                              color: const Color(0xFF00E5FF).withValues(alpha: 0.85),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _isPlaying ? 'جارٍ تشغيل التسجيل المشفر • HLS DRM Active' : 'التسجيل متوقف مؤقتاً',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.7),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Multi-Vector Anti-Piracy Enhanced Dynamic Watermark
                    EnhancedDynamicWatermark(
                      studentName: widget.watermarkText.isNotEmpty ? widget.watermarkText : 'طالب موثق',
                      studentId: 'STU_2026',
                      wilaya: 'الجزائر العاصمة',
                    ),

                    // Bottom Player Controls
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              Colors.black.withValues(alpha: 0.8),
                              Colors.transparent,
                            ],
                          ),
                        ),
                        child: Row(
                          children: [
                            IconButton(
                              icon: Icon(
                                _isPlaying ? Icons.pause : Icons.play_arrow,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                setState(() {
                                  _isPlaying = !_isPlaying;
                                });
                              },
                            ),
                            Expanded(
                              child: SliderTheme(
                                data: SliderTheme.of(context).copyWith(
                                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                                  overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
                                  trackHeight: 3,
                                  activeTrackColor: const Color(0xFF00E5FF),
                                  inactiveTrackColor: Colors.white.withValues(alpha: 0.2),
                                  thumbColor: const Color(0xFF00E5FF),
                                ),
                                child: Slider(
                                  value: _currentPosition,
                                  onChanged: (val) {
                                    setState(() {
                                      _currentPosition = val;
                                    });
                                  },
                                ),
                              ),
                            ),
                            const Text(
                              '23:45 / 90:00',
                              style: TextStyle(color: Colors.white70, fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // 2. Session Metadata & Anti-Piracy Protection Badge
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ListView(
                    children: [
                      // Anti-Piracy DRM Hardware Badge
                      GlassmorphicContainer(
                        padding: const EdgeInsets.all(14),
                        borderRadius: BorderRadius.circular(14),
                        backgroundColor: const Color(0xFF1E1B4B).withValues(alpha: 0.25),
                        borderColor: const Color(0xFF00E5FF).withValues(alpha: 0.35),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(0xFF00E5FF).withValues(alpha: 0.15),
                              ),
                              child: const Icon(Icons.security_rounded, color: Color(0xFF00E5FF), size: 24),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'درع الحماية العتادي النشط (FLAG_SECURE DRM) 🛡️',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    'تم حظر لقطات الشاشة وتسجيل الفيديو عتادياً. التسجيل موسوم ببصمتك الرقمية (${widget.watermarkText}).',
                                    style: TextStyle(
                                      color: Colors.white.withValues(alpha: 0.65),
                                      fontSize: 10.5,
                                      height: 1.35,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 18),
                      Text(
                        widget.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (widget.description != null && widget.description!.isNotEmpty)
                        Text(
                          widget.description!,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.7),
                            fontSize: 13,
                            height: 1.5,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
