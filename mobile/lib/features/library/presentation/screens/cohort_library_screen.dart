import 'package:flutter/material.dart';
import '../../../../core/widgets/glassmorphism.dart';
import '../controllers/library_controller.dart';
import 'protected_recording_player_screen.dart';

class CohortLibraryScreen extends StatefulWidget {
  final int cohortId;
  final String cohortName;
  final LibraryController controller;
  final String? token;

  const CohortLibraryScreen({
    super.key,
    required this.cohortId,
    required this.cohortName,
    required this.controller,
    this.token,
  });

  @override
  State<CohortLibraryScreen> createState() => _CohortLibraryScreenState();
}

class _CohortLibraryScreenState extends State<CohortLibraryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadLibrary();
  }

  void _loadLibrary() {
    final token = widget.token;
    if (token != null) {
      widget.controller.loadCohortLibrary(token: token, cohortId: widget.cohortId);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, _) {
        final data = widget.controller.libraryData;
        final isSubscribed = data?.isSubscribed ?? false;

        return Scaffold(
          backgroundColor: const Color(0xFF0A0F1D),
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Text(
              'المكتبة التعليمية: ${widget.cohortName}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
            bottom: TabBar(
              controller: _tabController,
              indicatorColor: const Color(0xFF00D26A),
              labelColor: const Color(0xFF00D26A),
              unselectedLabelColor: Colors.white60,
              tabs: const [
                Tab(icon: Icon(Icons.video_library_outlined), text: 'تسجيلات الحصص'),
                Tab(icon: Icon(Icons.menu_book_outlined), text: 'الملخصات والتمارين'),
              ],
            ),
          ),
          body: SafeArea(
            child: widget.controller.isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF00D26A)))
                : widget.controller.state == LibraryState.error
                    ? _buildErrorView()
                    : TabBarView(
                        controller: _tabController,
                        children: [
                          _buildRecordingsTab(isSubscribed),
                          _buildMaterialsTab(isSubscribed),
                        ],
                      ),
          ),
        );
      },
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
          const SizedBox(height: 12),
          Text(
            widget.controller.errorMessage ?? 'تعذر تحميل المكتبة',
            style: const TextStyle(color: Colors.white70),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadLibrary,
            child: const Text('إعادة المحاولة'),
          ),
        ],
      ),
    );
  }

  Widget _buildRecordingsTab(bool isSubscribed) {
    final recordings = widget.controller.libraryData?.recordings ?? [];

    if (recordings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.video_camera_back_outlined, size: 48, color: Colors.white.withValues(alpha: 0.3)),
            const SizedBox(height: 12),
            const Text('لا توجد تسجيلات منشورة حتى الآن', style: TextStyle(color: Colors.white60)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: recordings.length,
      itemBuilder: (context, index) {
        final rec = recordings[index];
        final canAccess = isSubscribed && rec.isAccessible;

        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: GlassmorphicContainer(
            borderRadius: BorderRadius.circular(14),
            padding: const EdgeInsets.all(14),
            backgroundColor: Colors.white.withValues(alpha: 0.04),
            borderColor: Colors.white.withValues(alpha: 0.1),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: canAccess
                        ? const Color(0xFF00D26A).withValues(alpha: 0.15)
                        : Colors.white.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    canAccess ? Icons.play_circle_fill : Icons.lock_outline,
                    color: canAccess ? const Color(0xFF00D26A) : Colors.white38,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        rec.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.schedule, size: 12, color: Colors.white.withValues(alpha: 0.5)),
                          const SizedBox(width: 4),
                          Text(
                            rec.formattedDuration,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.5),
                              fontSize: 11,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Icon(Icons.remove_red_eye_outlined, size: 12, color: Colors.white.withValues(alpha: 0.5)),
                          const SizedBox(width: 4),
                          Text(
                            '${rec.viewsCount} مشاهدة',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.5),
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: canAccess ? const Color(0xFF00D26A) : Colors.white12,
                    foregroundColor: canAccess ? Colors.black : Colors.white60,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () async {
                    if (!canAccess) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('الاشتراك في الفوج مطلوب لمشاهدة التسجيلات المحمية.'),
                          backgroundColor: Colors.amber,
                        ),
                      );
                      return;
                    }

                    final token = widget.token;
                    if (token == null) return;

                    final streamData = await widget.controller.requestStream(
                      token: token,
                      recordingId: rec.id,
                    );

                    if (streamData != null && context.mounted) {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ProtectedRecordingPlayerScreen(
                            title: rec.title,
                            description: rec.description,
                            streamUrl: streamData.streamUrl,
                            watermarkText: streamData.watermarkText,
                          ),
                        ),
                      );
                    }
                  },
                  child: Text(canAccess ? 'مشاهدة' : 'مقفل'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMaterialsTab(bool isSubscribed) {
    final materials = widget.controller.libraryData?.materials ?? [];

    if (materials.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.folder_open_outlined, size: 48, color: Colors.white.withValues(alpha: 0.3)),
            const SizedBox(height: 12),
            const Text('لا توجد ملفات أو ملخصات حتى الآن', style: TextStyle(color: Colors.white60)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: materials.length,
      itemBuilder: (context, index) {
        final mat = materials[index];
        final canAccess = isSubscribed && mat.isAccessible;

        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: GlassmorphicContainer(
            borderRadius: BorderRadius.circular(14),
            padding: const EdgeInsets.all(14),
            backgroundColor: Colors.white.withValues(alpha: 0.04),
            borderColor: Colors.white.withValues(alpha: 0.1),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: const Color(0xFF6C5CE7).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.picture_as_pdf, color: Color(0xFF6C5CE7), size: 28),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        mat.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${mat.fileType.toUpperCase()} • ${mat.formattedFileSize}',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.5),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(
                    canAccess ? Icons.download_rounded : Icons.lock_outline,
                    color: canAccess ? const Color(0xFF00D26A) : Colors.white38,
                  ),
                  onPressed: () async {
                    if (!canAccess) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('الاشتراك في الفوج مطلوب لتحميل الملفات والملخصات.'),
                          backgroundColor: Colors.amber,
                        ),
                      );
                      return;
                    }

                    final token = widget.token;
                    if (token == null) return;

                    final downloadUrl = await widget.controller.requestMaterialDownload(
                      token: token,
                      materialId: mat.id,
                    );

                    if (downloadUrl != null && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('تم إنشاء رابط التحميل المباشر الآمن: ${mat.title}'),
                          backgroundColor: const Color(0xFF00D26A),
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
