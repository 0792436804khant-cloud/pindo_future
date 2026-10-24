import 'package:flutter/material.dart';
import '../../../../core/widgets/glassmorphism.dart';
import '../../../classroom/presentation/widgets/floating_student_watermark.dart';

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
    return Scaffold(
      backgroundColor: const Color(0xFF070B14),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          widget.title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
        ),
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
                            color: const Color(0xFF00D26A).withValues(alpha: 0.8),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _isPlaying ? 'جارٍ تشغيل البث المباشر المشفر HLS' : 'متوقف مؤقتاً',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.7),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Floating Student Anti-Piracy Watermark Overlay
                  if (widget.watermarkText.isNotEmpty)
                    FloatingStudentWatermark(watermarkText: widget.watermarkText),

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
                              size: 22,
                            ),
                            onPressed: () => setState(() => _isPlaying = !_isPlaying),
                          ),
                          Expanded(
                            child: Slider(
                              value: _currentPosition,
                              activeColor: const Color(0xFF00D26A),
                              inactiveColor: Colors.white24,
                              onChanged: (val) => setState(() => _currentPosition = val),
                            ),
                          ),
                          const Text(
                            '25:00 / 1:30:00',
                            style: TextStyle(color: Colors.white70, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 2. Security Disclaimer & Lecture Meta
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: ListView(
                  children: [
                    // Security Badge
                    GlassmorphicContainer(
                      padding: const EdgeInsets.all(12),
                      borderRadius: BorderRadius.circular(12),
                      backgroundColor: Colors.white.withValues(alpha: 0.04),
                      borderColor: const Color(0xFF00D26A).withValues(alpha: 0.3),
                      child: Row(
                        children: [
                          const Icon(Icons.shield_outlined, color: Color(0xFF00D26A), size: 22),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'محتوى تعليمي محمي بعلامة مائية رقمية',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'هذا التسجيل مرخص لحسابك (${widget.watermarkText}). يمنع تسجيل الشاشة أو إعادة النشر.',
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.6),
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),
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
    );
  }
}
