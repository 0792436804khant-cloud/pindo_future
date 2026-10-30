import 'dart:math';
import 'package:flutter/material.dart';
import 'package:pindo_future_mobile/features/teachers/data/models/teacher_dashboard_model.dart';

class AddTeacherStoryModal extends StatefulWidget {
  final Function(TeacherStoryItem newStory) onStoryAdded;

  const AddTeacherStoryModal({
    super.key,
    required this.onStoryAdded,
  });

  static Future<void> show(
    BuildContext context, {
    required Function(TeacherStoryItem newStory) onStoryAdded,
  }) {
    return showDialog(
      context: context,
      barrierColor: Colors.black,
      useSafeArea: false,
      builder: (_) => AddTeacherStoryModal(onStoryAdded: onStoryAdded),
    );
  }

  @override
  State<AddTeacherStoryModal> createState() => _AddTeacherStoryModalState();
}

enum _StoryMode {
  camera,
  video,
  text,
  gallery,
}

class _AddTeacherStoryModalState extends State<AddTeacherStoryModal> {
  _StoryMode _activeMode = _StoryMode.text;

  final TextEditingController _textController = TextEditingController();
  final FocusNode _textFocusNode = FocusNode();

  // Instagram-style gradient presets
  static const List<List<Color>> _gradientPresets = [
    [Color(0xFF833AB4), Color(0xFFFD1D1D), Color(0xFFFCB045)], // Instagram Classic
    [Color(0xFF4158D0), Color(0xFFC850C0), Color(0xFFFFCC70)], // Neon Sunrise
    [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)], // Midnight Cyan
    [Color(0xFF11998E), Color(0xFF38EF7D)],                   // Emerald Mint
    [Color(0xFFFF416C), Color(0xFFFF4B2B)],                   // Crimson Flame
    [Color(0xFF0D1B2A), Color(0xFF1B263B), Color(0xFF415A77)], // Deep Cosmic
  ];

  // Gallery template presets for educational stories
  static const List<Map<String, String>> _galleryPresets = [
    {
      'title': 'حل مسألة البكالوريا',
      'url': 'https://images.unsplash.com/photo-1606326608606-aa0b62935f2b?w=900&q=80',
      'tag': '📝 حل نموذجي',
    },
    {
      'title': 'بث مباشر من الاستوديو',
      'url': 'https://images.unsplash.com/photo-1516321318423-f06f85e504b3?w=900&q=80',
      'tag': '🔴 بث مباشر',
    },
    {
      'title': 'لوحة شرف المتفوقين',
      'url': 'https://images.unsplash.com/photo-1523240795612-9a054b0db644?w=900&q=80',
      'tag': '🏆 تفوق ونتائج',
    },
    {
      'title': 'مدرج وثانوية البكالوريا',
      'url': 'https://images.unsplash.com/photo-1524178232363-1fb2b075b655?w=900&q=80',
      'tag': '📢 إعلان الفوج',
    },
  ];

  int _selectedGradientIndex = 0;
  String? _selectedImageUrl;
  bool _isVideoRecording = false;
  int _recordingSeconds = 0;
  bool _hasRecordedVideo = false;

  // Text Styling Overlay
  bool _isEditingText = false;
  Color _selectedTextColor = Colors.white;
  bool _textHighlightPill = true;
  String? _selectedSticker = '💡 نصيحة بكالوريا';

  final List<Color> _textColors = const [
    Colors.white,
    Color(0xFFFFEB3B), // Yellow
    Color(0xFF00E5FF), // Cyan
    Color(0xFFFF5252), // Red
    Color(0xFF69F0AE), // Mint Green
    Color(0xFFE040FB), // Magenta
  ];

  final List<String> _stickers = const [
    '💡 نصيحة بكالوريا',
    '🔴 بث مباشر اليوم',
    '📝 حل تمرين ومسألة',
    '🏆 تهنئة وتفوق 20/20',
    '⚡ سؤال تحدي',
    '📢 إعلان هام',
  ];

  @override
  void dispose() {
    _textController.dispose();
    _textFocusNode.dispose();
    super.dispose();
  }

  void _cycleGradient() {
    setState(() {
      _selectedGradientIndex = (_selectedGradientIndex + 1) % _gradientPresets.length;
      _selectedImageUrl = null;
    });
  }

  void _capturePhoto() {
    // Instant camera capture simulation
    setState(() {
      _selectedImageUrl = _galleryPresets[Random().nextInt(_galleryPresets.length)]['url'];
      _activeMode = _StoryMode.camera;
      _isEditingText = true;
    });
    _textFocusNode.requestFocus();
  }

  void _toggleVideoRecording() {
    if (!_isVideoRecording) {
      setState(() {
        _isVideoRecording = true;
        _recordingSeconds = 0;
        _hasRecordedVideo = false;
      });
      Future.delayed(const Duration(seconds: 1), _tickRecording);
    } else {
      setState(() {
        _isVideoRecording = false;
        _hasRecordedVideo = true;
        _isEditingText = true;
      });
      _textFocusNode.requestFocus();
    }
  }

  void _tickRecording() {
    if (!mounted || !_isVideoRecording) return;
    if (_recordingSeconds < 15) {
      setState(() => _recordingSeconds++);
      Future.delayed(const Duration(seconds: 1), _tickRecording);
    } else {
      setState(() {
        _isVideoRecording = false;
        _hasRecordedVideo = true;
        _isEditingText = true;
      });
    }
  }

  void _selectGalleryItem(Map<String, String> item) {
    setState(() {
      _selectedImageUrl = item['url'];
      _selectedSticker = item['tag'];
      _activeMode = _StoryMode.gallery;
      _isEditingText = true;
    });
    _textFocusNode.requestFocus();
  }

  void _publishStory() {
    final text = _textController.text.trim();

    String defaultText = 'ستوري جديدة للأستاذ';
    if (_hasRecordedVideo) {
      defaultText = text.isNotEmpty ? text : '🎥 تسجيل فيديو مباشر من الأستاذ لطلابه';
    } else if (_selectedImageUrl != null) {
      defaultText = text.isNotEmpty ? text : '📸 صورة وملاحظة هامة من الأستاذ';
    } else if (text.isNotEmpty) {
      defaultText = text;
    }

    final newStory = TeacherStoryItem(
      id: 'story_${DateTime.now().millisecondsSinceEpoch}',
      text: defaultText,
      imageUrl: _selectedImageUrl,
      videoUrl: _hasRecordedVideo ? 'mock_video_recording.mp4' : null,
      mediaType: _hasRecordedVideo ? 'video' : (_selectedImageUrl != null ? 'image' : 'text'),
      timeAgo: 'الآن',
      viewsCount: 1,
      isLiveAlert: (_selectedSticker != null && _selectedSticker!.contains('مباشر')),
      tag: _selectedSticker,
      actionButtonText: (_selectedSticker != null && _selectedSticker!.contains('مباشر'))
          ? 'الانتقال للبث المباشر'
          : null,
    );

    widget.onStoryAdded(newStory);
    Navigator.of(context).pop();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تمت مشاركة الستوري في قصتك بنجاح! 🚀'),
        backgroundColor: Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.black,
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        top: false,
        child: Stack(
          children: [
            // 1. Full Screen Story Canvas (Background Gradient, Image, or Video Simulation)
            Positioned.fill(
              child: GestureDetector(
                onTap: () {
                  if (_isEditingText) {
                    FocusScope.of(context).unfocus();
                    setState(() => _isEditingText = false);
                  } else {
                    setState(() => _isEditingText = true);
                    _textFocusNode.requestFocus();
                  }
                },
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: _gradientPresets[_selectedGradientIndex],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Photo background if selected
                      if (_selectedImageUrl != null)
                        Image.network(
                          _selectedImageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const SizedBox(),
                        ),

                      // Video recording preview overlay
                      if (_hasRecordedVideo)
                        Container(
                          color: Colors.black45,
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(18),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.15),
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white30, width: 2),
                                  ),
                                  child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 54),
                                ),
                                const SizedBox(height: 12),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.black54,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Text(
                                    '🎥 معاينة مقطع الفيديو المسجل (15s)',
                                    style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                      // Dimming gradient for legibility
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.black.withValues(alpha: 0.55),
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.65),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            stops: const [0.0, 0.5, 1.0],
                          ),
                        ),
                      ),

                      // Active Sticker on Canvas
                      if (_selectedSticker != null)
                        Positioned(
                          top: 100,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: _selectedSticker!.contains('مباشر')
                                    ? Colors.red.withValues(alpha: 0.85)
                                    : Colors.black.withValues(alpha: 0.7),
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(color: Colors.white30, width: 1.2),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.3),
                                    blurRadius: 10,
                                  ),
                                ],
                              ),
                              child: Text(
                                _selectedSticker!,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        ),

                      // Live Text on Canvas
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 28),
                          child: _isEditingText
                              ? TextField(
                                  controller: _textController,
                                  focusNode: _textFocusNode,
                                  autofocus: true,
                                  maxLines: null,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: _selectedTextColor,
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    height: 1.5,
                                    backgroundColor: _textHighlightPill
                                        ? Colors.black.withValues(alpha: 0.65)
                                        : Colors.transparent,
                                  ),
                                  decoration: const InputDecoration(
                                    hintText: 'اكتب على الستوري...\n(انقر في أي مكان)',
                                    hintStyle: TextStyle(color: Colors.white54, fontSize: 20),
                                    border: InputBorder.none,
                                  ),
                                )
                              : Text(
                                  _textController.text.isNotEmpty
                                      ? _textController.text
                                      : 'انقر للكتابة على الصورة أو الفيديو ✨',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: _selectedTextColor,
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    height: 1.5,
                                    backgroundColor: _textHighlightPill && _textController.text.isNotEmpty
                                        ? Colors.black.withValues(alpha: 0.65)
                                        : Colors.transparent,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // 2. Top Instagram Action Bar
            Positioned(
              top: MediaQuery.of(context).padding.top + 8,
              left: 12,
              right: 12,
              child: Row(
                children: [
                  // Close button (X)
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded, color: Colors.white, size: 28),
                  ),
                  const Spacer(),

                  // Text tool 'Aa'
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _isEditingText = !_isEditingText;
                        if (_isEditingText) _textFocusNode.requestFocus();
                      });
                    },
                    icon: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: _isEditingText ? Colors.white : Colors.white24,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        'Aa',
                        style: TextStyle(
                          color: _isEditingText ? Colors.black : Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),

                  // Background Gradient / Palette Tool
                  IconButton(
                    onPressed: _cycleGradient,
                    icon: Container(
                      width: 28,
                      height: 28,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: SweepGradient(
                          colors: [Colors.red, Colors.yellow, Colors.green, Colors.cyan, Colors.purple, Colors.red],
                        ),
                      ),
                    ),
                  ),

                  // Sticker / Tag tool
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.sticky_note_2_outlined, color: Colors.white, size: 26),
                    color: const Color(0xFF1E293B),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    onSelected: (sticker) => setState(() => _selectedSticker = sticker),
                    itemBuilder: (_) => _stickers
                        .map(
                          (s) => PopupMenuItem(
                            value: s,
                            child: Text(s, style: const TextStyle(color: Colors.white, fontSize: 13)),
                          ),
                        )
                        .toList(),
                  ),
                ],
              ),
            ),

            // 3. Text Editing Colors Bar (Shown when typing)
            if (_isEditingText)
              Positioned(
                top: MediaQuery.of(context).padding.top + 64,
                left: 16,
                right: 16,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Toggle background highlight
                    InkWell(
                      onTap: () => setState(() => _textHighlightPill = !_textHighlightPill),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        margin: const EdgeInsets.only(left: 8),
                        decoration: BoxDecoration(
                          color: _textHighlightPill ? Colors.white : Colors.white24,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'A',
                          style: TextStyle(
                            color: _textHighlightPill ? Colors.black : Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                    // Color bubbles
                    ..._textColors.map(
                      (c) => GestureDetector(
                        onTap: () => setState(() => _selectedTextColor = c),
                        child: Container(
                          width: 26,
                          height: 26,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            color: c,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: _selectedTextColor == c ? Colors.white : Colors.transparent,
                              width: 2.5,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // 4. Bottom Controls: Gallery Carousel / Camera Shutter / Video Record / Share Bar
            Positioned(
              bottom: 16 + bottomInset,
              left: 0,
              right: 0,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Mode: Gallery Presets preview
                  if (_activeMode == _StoryMode.gallery)
                    Container(
                      height: 84,
                      margin: const EdgeInsets.only(bottom: 14),
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        children: _galleryPresets.map((preset) {
                          final isSelected = _selectedImageUrl == preset['url'];
                          return GestureDetector(
                            onTap: () => _selectGalleryItem(preset),
                            child: Container(
                              width: 70,
                              margin: const EdgeInsets.only(left: 10),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected ? const Color(0xFF00E5FF) : Colors.white30,
                                  width: isSelected ? 2.5 : 1,
                                ),
                                image: DecorationImage(
                                  image: NetworkImage(preset['url']!),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),

                  // Camera / Video Shutter Controls (Instagram Style)
                  if (_activeMode == _StoryMode.camera || _activeMode == _StoryMode.video)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (_activeMode == _StoryMode.video)
                            // Video Record Button (Red circle)
                            GestureDetector(
                              onTap: _toggleVideoRecording,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 4),
                                ),
                                child: Container(
                                  width: 64,
                                  height: 64,
                                  decoration: BoxDecoration(
                                    color: Colors.redAccent,
                                    borderRadius: BorderRadius.circular(_isVideoRecording ? 14 : 32),
                                  ),
                                  child: Center(
                                    child: _isVideoRecording
                                        ? Text(
                                            '${15 - _recordingSeconds}s',
                                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                          )
                                        : const Icon(Icons.videocam_rounded, color: Colors.white, size: 30),
                                  ),
                                ),
                              ),
                            )
                          else
                            // Camera Photo Shutter Button (White ring with inner circle)
                            GestureDetector(
                              onTap: _capturePhoto,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 4),
                                ),
                                child: Container(
                                  width: 64,
                                  height: 64,
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.camera_alt_rounded, color: Colors.black, size: 28),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),

                  // Bottom Mode Selector: [ صورة | فيديو | كتابة | المعرض ]
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildModeTab('✍️ كتابة', _StoryMode.text),
                        _buildModeTab('📸 صورة', _StoryMode.camera),
                        _buildModeTab('🎥 فيديو', _StoryMode.video),
                        _buildModeTab('🖼️ المعرض', _StoryMode.gallery),
                      ],
                    ),
                  ),

                  // Instagram Bottom Footer: "قصتك (Your Story)" + Share Button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
                    child: Row(
                      children: [
                        // "قصتك" (Your Story) button
                        InkWell(
                          onTap: _publishStory,
                          borderRadius: BorderRadius.circular(24),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(color: Colors.white24),
                            ),
                            child: const Row(
                              children: [
                                CircleAvatar(
                                  radius: 12,
                                  backgroundColor: Color(0xFF00E5FF),
                                  child: Icon(Icons.add, size: 14, color: Colors.black),
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'قصتك',
                                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const Spacer(),

                        // Prominent Share to Story Button
                        ElevatedButton.icon(
                          onPressed: _publishStory,
                          icon: const Icon(Icons.send_rounded, size: 16),
                          label: const Text(
                            'مشاركة في الستوري',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00E5FF),
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                            elevation: 8,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModeTab(String label, _StoryMode mode) {
    final isSelected = _activeMode == mode;
    return GestureDetector(
      onTap: () {
        setState(() {
          _activeMode = mode;
          if (mode == _StoryMode.gallery && _selectedImageUrl == null) {
            _selectedImageUrl = _galleryPresets[0]['url'];
          }
          if (mode == _StoryMode.text) {
            _isEditingText = true;
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white24 : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.white60,
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
