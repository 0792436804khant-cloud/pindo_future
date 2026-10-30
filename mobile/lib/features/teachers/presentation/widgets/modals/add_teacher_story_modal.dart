import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
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
  final ImagePicker _picker = ImagePicker();

  // Real local media state
  Uint8List? _pickedImageBytes;
  String? _pickedImageName;
  String? _pickedVideoName;
  String? _pickedFileName;
  int? _pickedFileSize;

  // Real Link Sticker (Instagram style)
  String? _customLinkUrl;
  String? _customLinkTitle;

  // Text Styling Overlay
  bool _isEditingText = false;
  Color _selectedTextColor = Colors.white;
  bool _textHighlightPill = true;
  String? _selectedSticker;

  // Instagram-style gradient presets
  static const List<List<Color>> _gradientPresets = [
    [Color(0xFF833AB4), Color(0xFFFD1D1D), Color(0xFFFCB045)], // Instagram Classic
    [Color(0xFF4158D0), Color(0xFFC850C0), Color(0xFFFFCC70)], // Neon Sunrise
    [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)], // Midnight Cyan
    [Color(0xFF11998E), Color(0xFF38EF7D)],                   // Emerald Mint
    [Color(0xFFFF416C), Color(0xFFFF4B2B)],                   // Crimson Flame
    [Color(0xFF0D1B2A), Color(0xFF1B263B), Color(0xFF415A77)], // Deep Cosmic
  ];

  int _selectedGradientIndex = 0;

  final List<Color> _textColors = const [
    Colors.white,
    Color(0xFFFFEB3B), // Yellow
    Color(0xFF00E5FF), // Cyan
    Color(0xFFFF5252), // Red
    Color(0xFF69F0AE), // Mint Green
    Color(0xFFE040FB), // Magenta
  ];

  final List<String> _quickStickers = const [
    '🔴 بث مباشر اليوم',
    '💡 نصيحة بكالوريا',
    '📝 حل مسألة وتمرين',
    '🏆 تهنئة وتفوق 20/20',
    '📢 إعلان هام للفوج',
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
    });
  }

  // --- Real Image Picker from Gallery / Files ---
  Future<void> _pickRealImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 88,
      );
      if (image != null) {
        final bytes = await image.readAsBytes();
        setState(() {
          _pickedImageBytes = bytes;
          _pickedImageName = image.name;
          _pickedVideoName = null;
          _activeMode = _StoryMode.gallery;
          _isEditingText = true;
        });
        _textFocusNode.requestFocus();
        return;
      }
    } catch (e) {
      // Fallback to FilePicker if image_picker channel fails
      try {
        final result = await FilePicker.platform.pickFiles(
          type: FileType.image,
          withData: true,
        );
        if (result != null && result.files.isNotEmpty) {
          final file = result.files.first;
          if (file.bytes != null) {
            setState(() {
              _pickedImageBytes = file.bytes;
              _pickedImageName = file.name;
              _pickedVideoName = null;
              _activeMode = _StoryMode.gallery;
              _isEditingText = true;
            });
            _textFocusNode.requestFocus();
            return;
          }
        }
      } catch (inner) {
        _showErrorSnackBar('تعذر فتح معرض الصور: $inner');
        return;
      }
      _showErrorSnackBar('تعذر فتح المعرض: $e');
    }
  }

  // --- Real Camera Photo Capture ---
  Future<void> _takeRealPhotoWithCamera() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 88,
      );
      if (photo != null) {
        final bytes = await photo.readAsBytes();
        setState(() {
          _pickedImageBytes = bytes;
          _pickedImageName = photo.name;
          _pickedVideoName = null;
          _activeMode = _StoryMode.camera;
          _isEditingText = true;
        });
        _textFocusNode.requestFocus();
        return;
      }
    } catch (_) {
      // Fallback to gallery / file picker if camera is unavailable on device/browser
      await _pickRealImageFromGallery();
    }
  }

  // --- Real Video Picker ---
  Future<void> _pickRealVideo() async {
    try {
      final XFile? video = await _picker.pickVideo(
        source: ImageSource.gallery,
        maxDuration: const Duration(seconds: 60),
      );
      if (video != null) {
        setState(() {
          _pickedVideoName = video.name;
          _pickedImageBytes = null;
          _activeMode = _StoryMode.video;
          _isEditingText = true;
        });
        _textFocusNode.requestFocus();
        return;
      }
    } catch (e) {
      // Fallback to FilePicker if video picker channel fails
      try {
        final result = await FilePicker.platform.pickFiles(
          type: FileType.video,
          withData: true,
        );
        if (result != null && result.files.isNotEmpty) {
          final file = result.files.first;
          setState(() {
            _pickedVideoName = file.name;
            _pickedImageBytes = null;
            _activeMode = _StoryMode.video;
            _isEditingText = true;
          });
          _textFocusNode.requestFocus();
          return;
        }
      } catch (inner) {
        _showErrorSnackBar('تعذر اختيار الفيديو: $inner');
        return;
      }
      _showErrorSnackBar('تعذر اختيار الفيديو: $e');
    }
  }

  // --- Real Document / PDF Picker ---
  Future<void> _pickRealDocument() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'png', 'jpg', 'zip'],
        withData: true,
      );
      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        setState(() {
          _pickedFileName = file.name;
          _pickedFileSize = file.size;
          if (file.bytes != null && (file.extension == 'jpg' || file.extension == 'png')) {
            _pickedImageBytes = file.bytes;
          }
          _selectedSticker = '📄 ملحق ملف: ${file.name}';
          _isEditingText = true;
        });
        _textFocusNode.requestFocus();
      }
    } catch (e) {
      _showErrorSnackBar('تعذر اختيار الملف: $e');
    }
  }

  // --- Real Link Sticker Dialog (مثل ستيكر رابط إنستغرام) ---
  void _openAddLinkDialog() {
    final urlController = TextEditingController(text: _customLinkUrl ?? 'https://');
    final titleController = TextEditingController(text: _customLinkTitle ?? 'تحميل السلسلة PDF');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0F172A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFF00E5FF), width: 1.2),
        ),
        title: const Row(
          children: [
            Icon(Icons.link_rounded, color: Color(0xFF00E5FF), size: 24),
            SizedBox(width: 8),
            Text('إضافة ستيكر رابط (Link Sticker)', style: TextStyle(color: Colors.white, fontSize: 16)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'أدخل الرابط الحقيقي الذي سينتقل إليه الطلاب عند النقر على الستوري:',
              style: TextStyle(color: Colors.white70, fontSize: 12),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: urlController,
              style: const TextStyle(color: Color(0xFF00E5FF), fontSize: 13),
              decoration: InputDecoration(
                labelText: 'عنوان الرابط (URL)',
                labelStyle: const TextStyle(color: Colors.white60, fontSize: 12),
                hintText: 'https://t.me/... أو https://drive.google.com/...',
                hintStyle: const TextStyle(color: Colors.white30, fontSize: 11),
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.05),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: titleController,
              style: const TextStyle(color: Colors.white, fontSize: 13),
              decoration: InputDecoration(
                labelText: 'النص الظاهر على الملصق',
                labelStyle: const TextStyle(color: Colors.white60, fontSize: 12),
                hintText: 'مثال: تحميل سلسلة التمارين PDF، انضم لقناة التيليغرام...',
                hintStyle: const TextStyle(color: Colors.white30, fontSize: 11),
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.05),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('إلغاء', style: TextStyle(color: Colors.white60)),
          ),
          ElevatedButton.icon(
            onPressed: () {
              final url = urlController.text.trim();
              final title = titleController.text.trim();
              if (url.isNotEmpty) {
                setState(() {
                  _customLinkUrl = url;
                  _customLinkTitle = title.isNotEmpty ? title : 'زيارة الرابط 🔗';
                });
              }
              Navigator.of(ctx).pop();
            },
            icon: const Icon(Icons.check, size: 16),
            label: const Text('إضافة الملصق', style: TextStyle(fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00E5FF),
              foregroundColor: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.redAccent),
    );
  }

  void _publishStory() {
    final text = _textController.text.trim();

    String defaultText = 'ستوري جديدة للأستاذ';
    if (_pickedVideoName != null) {
      defaultText = text.isNotEmpty ? text : '🎥 تسجيل فيديو: $_pickedVideoName';
    } else if (_pickedFileName != null) {
      defaultText = text.isNotEmpty ? text : '📄 ملف مرفق: $_pickedFileName';
    } else if (_pickedImageName != null) {
      defaultText = text.isNotEmpty ? text : '📸 صورة وملاحظة: $_pickedImageName';
    } else if (text.isNotEmpty) {
      defaultText = text;
    }

    final newStory = TeacherStoryItem(
      id: 'story_${DateTime.now().millisecondsSinceEpoch}',
      text: defaultText,
      imageBytes: _pickedImageBytes,
      videoUrl: _pickedVideoName,
      fileName: _pickedFileName,
      fileSizeBytes: _pickedFileSize,
      customLinkUrl: _customLinkUrl,
      customLinkTitle: _customLinkTitle,
      mediaType: _pickedVideoName != null
          ? 'video'
          : (_pickedFileName != null
              ? 'file'
              : (_pickedImageBytes != null ? 'image' : 'text')),
      timeAgo: 'الآن',
      viewsCount: 1,
      isLiveAlert: (_selectedSticker != null && _selectedSticker!.contains('مباشر')),
      tag: _selectedSticker ?? (_customLinkTitle != null ? '🔗 $_customLinkTitle' : null),
      actionButtonText: _customLinkTitle ??
          ((_selectedSticker != null && _selectedSticker!.contains('مباشر'))
              ? 'الانتقال للبث المباشر'
              : null),
      actionLink: _customLinkUrl,
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

    return Scaffold(
      backgroundColor: Colors.black,
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        top: false,
        child: Stack(
          children: [
            // 1. Full Screen Story Canvas (Real Image, Video preview, or Vibrant Instagram Gradient)
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
                      // Real Image Bytes preview (From device gallery/camera/files)
                      if (_pickedImageBytes != null)
                        Image.memory(
                          _pickedImageBytes!,
                          fit: BoxFit.cover,
                        ),

                      // Real Video Preview Simulation
                      if (_pickedVideoName != null)
                        Container(
                          color: Colors.black54,
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
                                    color: Colors.black87,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: Colors.redAccent.withValues(alpha: 0.6)),
                                  ),
                                  child: Text(
                                    '🎥 فيديو: $_pickedVideoName',
                                    style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                      // Real Document / PDF File Sticker
                      if (_pickedFileName != null)
                        Positioned(
                          top: 140,
                          left: 20,
                          right: 20,
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0F172A).withValues(alpha: 0.9),
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(color: const Color(0xFF00E5FF), width: 1.5),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.4),
                                  blurRadius: 16,
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF00E5FF).withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(Icons.picture_as_pdf_rounded, color: Color(0xFF00E5FF), size: 28),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        _pickedFileName!,
                                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13.5),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        _pickedFileSize != null
                                            ? '${(_pickedFileSize! / 1024).toStringAsFixed(1)} KB • ملف جاهز للمعاينة والتحميل'
                                            : 'ملف جاهز للتحميل',
                                        style: const TextStyle(color: Colors.white60, fontSize: 11),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                      // Real Instagram Link Sticker (🔗)
                      if (_customLinkUrl != null)
                        Positioned(
                          top: _pickedFileName != null ? 220 : 150,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: GestureDetector(
                              onTap: _openAddLinkDialog,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(22),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.4),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.link_rounded, color: Color(0xFF0F172A), size: 18),
                                    const SizedBox(width: 6),
                                    Text(
                                      _customLinkTitle ?? 'رابط خارجي',
                                      style: const TextStyle(
                                        color: Color(0xFF0F172A),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    const Icon(Icons.arrow_outward_rounded, color: Color(0xFF0F172A), size: 14),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),

                      // Dimming gradient for text legibility
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.black.withValues(alpha: 0.5),
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.65),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            stops: const [0.0, 0.5, 1.0],
                          ),
                        ),
                      ),

                      // Text on Canvas
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
                                    hintText: 'اكتب على الصورة أو الملف...\n(انقر في أي مكان للكتابة)',
                                    hintStyle: TextStyle(color: Colors.white54, fontSize: 18),
                                    border: InputBorder.none,
                                  ),
                                )
                              : Text(
                                  _textController.text.isNotEmpty
                                      ? _textController.text
                                      : 'انقر للكتابة أو أرفق صورة/فيديو/رابط ✨',
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
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded, color: Colors.white, size: 28),
                  ),
                  const Spacer(),

                  // Real Link Sticker Tool 🔗
                  IconButton(
                    onPressed: _openAddLinkDialog,
                    tooltip: 'إضافة ستيكر رابط حقيقي',
                    icon: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: _customLinkUrl != null ? const Color(0xFF00E5FF) : Colors.white24,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.link_rounded,
                        color: _customLinkUrl != null ? Colors.black : Colors.white,
                        size: 18,
                      ),
                    ),
                  ),

                  // Real Document Picker Button 📄
                  IconButton(
                    onPressed: _pickRealDocument,
                    tooltip: 'إرفاق ملف حقيقي (PDF / سلاسل)',
                    icon: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: _pickedFileName != null ? const Color(0xFF00E5FF) : Colors.white24,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.attach_file_rounded,
                        color: _pickedFileName != null ? Colors.black : Colors.white,
                        size: 18,
                      ),
                    ),
                  ),

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

                  // Background Gradient Palette Tool
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
                    itemBuilder: (_) => _quickStickers
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

            // 4. Bottom Controls: Real Pickers + Mode Selector + Instagram Share Footer
            Positioned(
              bottom: 16 + bottomInset,
              left: 0,
              right: 0,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Real Media Action Buttons
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // Pick Real Image from Device Gallery
                        _buildActionPill(
                          icon: Icons.photo_library_rounded,
                          label: 'صورة من المعرض',
                          onTap: _pickRealImageFromGallery,
                        ),

                        // Take Real Photo with Camera
                        _buildActionPill(
                          icon: Icons.camera_alt_rounded,
                          label: 'التقاط صورة',
                          onTap: _takeRealPhotoWithCamera,
                        ),

                        // Pick Real Video from Device
                        _buildActionPill(
                          icon: Icons.video_library_rounded,
                          label: 'فيديو من جهازك',
                          onTap: _pickRealVideo,
                        ),

                        // Add Real Link
                        _buildActionPill(
                          icon: Icons.add_link_rounded,
                          label: 'رابط خارجي',
                          onTap: _openAddLinkDialog,
                          isHighlight: _customLinkUrl != null,
                        ),
                      ],
                    ),
                  ),

                  // Bottom Mode Selector: [ ✍️ كتابة | 📸 صورة | 🎥 فيديو | 🖼️ المعرض ]
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
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

                  // Instagram Bottom Footer: "قصتك" + "مشاركة في الستوري"
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
                    child: Row(
                      children: [
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

  Widget _buildActionPill({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isHighlight = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: isHighlight
              ? const Color(0xFF00E5FF).withValues(alpha: 0.25)
              : Colors.black54,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isHighlight ? const Color(0xFF00E5FF) : Colors.white24,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: isHighlight ? const Color(0xFF00E5FF) : Colors.white, size: 15),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: isHighlight ? const Color(0xFF00E5FF) : Colors.white,
                fontSize: 10.5,
                fontWeight: FontWeight.bold,
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
          if (mode == _StoryMode.gallery) {
            _pickRealImageFromGallery();
          } else if (mode == _StoryMode.camera) {
            _takeRealPhotoWithCamera();
          } else if (mode == _StoryMode.video) {
            _pickRealVideo();
          } else if (mode == _StoryMode.text) {
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
