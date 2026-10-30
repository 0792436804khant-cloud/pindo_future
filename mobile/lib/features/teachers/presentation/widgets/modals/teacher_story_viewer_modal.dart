import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pindo_future_mobile/features/teachers/data/models/teacher_dashboard_model.dart';

class TeacherStoryViewerModal extends StatefulWidget {
  final List<TeacherStoryItem> stories;
  final TeacherProfileInfo teacherProfile;
  final int initialIndex;

  const TeacherStoryViewerModal({
    super.key,
    required this.stories,
    required this.teacherProfile,
    this.initialIndex = 0,
  });

  static Future<void> show(
    BuildContext context, {
    required List<TeacherStoryItem> stories,
    required TeacherProfileInfo teacherProfile,
    int initialIndex = 0,
  }) {
    if (stories.isEmpty) return Future.value();
    return showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.92),
      barrierDismissible: true,
      useSafeArea: false,
      builder: (_) => TeacherStoryViewerModal(
        stories: stories,
        teacherProfile: teacherProfile,
        initialIndex: initialIndex,
      ),
    );
  }

  @override
  State<TeacherStoryViewerModal> createState() => _TeacherStoryViewerModalState();
}

class _TeacherStoryViewerModalState extends State<TeacherStoryViewerModal>
    with SingleTickerProviderStateMixin {
  late int _currentIndex;
  late AnimationController _progressController;
  Timer? _timer;
  String? _recentReaction;

  static const Color _brightCyan = Color(0xFF00E5FF);
  static const Color _electricPurple = Color(0xFF7C4DFF);

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _nextStory();
        }
      });

    _startCurrentStory();
  }

  void _startCurrentStory() {
    _progressController.reset();
    _progressController.forward();
  }

  void _nextStory() {
    if (_currentIndex < widget.stories.length - 1) {
      setState(() {
        _currentIndex++;
        _recentReaction = null;
      });
      _startCurrentStory();
    } else {
      Navigator.of(context).pop();
    }
  }

  void _prevStory() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
        _recentReaction = null;
      });
      _startCurrentStory();
    } else {
      _startCurrentStory();
    }
  }

  void _handleReaction(String emoji) {
    setState(() {
      _recentReaction = emoji;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'أرسلت تفاعلاً $emoji للأستاذ ${widget.teacherProfile.name}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        duration: const Duration(seconds: 2),
        backgroundColor: const Color(0xFF1E293B),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final story = widget.stories[_currentIndex];

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: GestureDetector(
          onTapDown: (_) => _progressController.stop(),
          onTapUp: (_) => _progressController.forward(),
          onTapCancel: () => _progressController.forward(),
          child: Stack(
            children: [
              // Background Card
              Positioned.fill(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    gradient: LinearGradient(
                      colors: story.isLiveAlert
                          ? [const Color(0xFF881337), const Color(0xFF1E1B4B), const Color(0xFF0F172A)]
                          : [const Color(0xFF1E1B4B), const Color(0xFF0F172A), const Color(0xFF030712)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    border: Border.all(
                      color: story.isLiveAlert
                          ? Colors.redAccent.withValues(alpha: 0.6)
                          : _brightCyan.withValues(alpha: 0.3),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: (story.isLiveAlert ? Colors.redAccent : _electricPurple).withValues(alpha: 0.25),
                        blurRadius: 30,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Full Story Image if present
                      if (story.imageUrl != null) ...[
                        Image.network(
                          story.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const SizedBox(),
                        ),
                        // Dark overlay gradient for contrast
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.black.withValues(alpha: 0.65),
                                Colors.black.withValues(alpha: 0.25),
                                Colors.black.withValues(alpha: 0.75),
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                        ),
                      ],

                      // Video indicator badge if story is video
                      if (story.mediaType == 'video')
                        Positioned(
                          top: 70,
                          right: 20,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.redAccent.withValues(alpha: 0.85),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.videocam_rounded, color: Colors.white, size: 14),
                                SizedBox(width: 4),
                                Text(
                                  'فيديو مسجل',
                                  style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ),

                      // Tap Areas: Left for previous, Right for next
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              behavior: HitTestBehavior.translucent,
                              onTap: _prevStory,
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              behavior: HitTestBehavior.translucent,
                              onTap: _nextStory,
                            ),
                          ),
                        ],
                      ),

                      // Content Body
                      Center(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 80),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (story.tag != null) ...[
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: story.isLiveAlert
                                        ? Colors.red.withValues(alpha: 0.25)
                                        : _brightCyan.withValues(alpha: 0.18),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: story.isLiveAlert ? Colors.redAccent : _brightCyan,
                                      width: 1.2,
                                    ),
                                  ),
                                  child: Text(
                                    story.tag!,
                                    style: TextStyle(
                                      color: story.isLiveAlert ? Colors.redAccent : _brightCyan,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 24),
                              ],

                              Text(
                                story.text,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  height: 1.6,
                                  letterSpacing: 0.2,
                                ),
                              ),

                              if (story.actionButtonText != null) ...[
                                const SizedBox(height: 28),
                                ElevatedButton.icon(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('جارٍ الانتقال: ${story.actionButtonText}'),
                                        backgroundColor: _electricPurple,
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                                  label: Text(
                                    story.actionButtonText!,
                                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: story.isLiveAlert ? Colors.redAccent : _brightCyan,
                                    foregroundColor: Colors.black,
                                    padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Header Bar: Progress Bars + Teacher Info + Close Button
              Positioned(
                top: 16,
                left: 20,
                right: 20,
                child: Column(
                  children: [
                    // Segmented Progress Bar
                    Row(
                      children: List.generate(widget.stories.length, (idx) {
                        return Expanded(
                          child: Container(
                            height: 3,
                            margin: const EdgeInsets.symmetric(horizontal: 2),
                            decoration: BoxDecoration(
                              color: Colors.white24,
                              borderRadius: BorderRadius.circular(2),
                            ),
                            child: idx < _currentIndex
                                ? Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  )
                                : idx == _currentIndex
                                    ? AnimatedBuilder(
                                        animation: _progressController,
                                        builder: (context, child) {
                                          return FractionallySizedBox(
                                            alignment: Alignment.centerLeft,
                                            widthFactor: _progressController.value,
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius: BorderRadius.circular(2),
                                              ),
                                            ),
                                          );
                                        },
                                      )
                                    : const SizedBox(),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 12),

                    // Teacher Header
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 18,
                          backgroundColor: _electricPurple,
                          backgroundImage: widget.teacherProfile.avatarUrl != null
                              ? NetworkImage(widget.teacherProfile.avatarUrl!)
                              : null,
                          child: widget.teacherProfile.avatarUrl == null
                              ? Text(
                                  widget.teacherProfile.name.isNotEmpty
                                      ? widget.teacherProfile.name[0]
                                      : 'أ',
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                )
                              : null,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      widget.teacherProfile.name,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13.5,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                  const Icon(Icons.verified_rounded, color: _brightCyan, size: 15),
                                ],
                              ),
                              Row(
                                children: [
                                  Text(
                                    story.timeAgo,
                                    style: const TextStyle(color: Colors.white60, fontSize: 11),
                                  ),
                                  const SizedBox(width: 8),
                                  const Text('•', style: TextStyle(color: Colors.white38, fontSize: 11)),
                                  const SizedBox(width: 8),
                                  Icon(Icons.visibility_outlined, size: 12, color: Colors.white60),
                                  const SizedBox(width: 3),
                                  Text(
                                    '${story.viewsCount}',
                                    style: const TextStyle(color: Colors.white60, fontSize: 11),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.close_rounded, color: Colors.white, size: 24),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Bottom Reactions Bar
              Positioned(
                bottom: 24,
                left: 20,
                right: 20,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.65),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildReactionButton('❤️'),
                      _buildReactionButton('🔥'),
                      _buildReactionButton('👏'),
                      _buildReactionButton('🎯'),
                      _buildReactionButton('💡'),
                      if (_recentReaction != null)
                        Text(
                          _recentReaction!,
                          style: const TextStyle(fontSize: 22),
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

  Widget _buildReactionButton(String emoji) {
    return InkWell(
      onTap: () => _handleReaction(emoji),
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        child: Text(
          emoji,
          style: const TextStyle(fontSize: 22),
        ),
      ),
    );
  }
}
