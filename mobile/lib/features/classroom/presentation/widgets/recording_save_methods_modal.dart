import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../../../../core/network/api_client.dart';
import '../../../auth/data/datasources/auth_local_datasource.dart';
import '../../../library/presentation/screens/protected_recording_player_screen.dart';
import '../../services/live_session_recorder.dart';

class RecordingSaveMethodsModal extends StatefulWidget {
  final String sessionId;
  final String sessionTitle;
  final LiveSessionRecorder recorder;
  final bool isRecording;
  final VoidCallback onRecordingStateChanged;

  const RecordingSaveMethodsModal({
    super.key,
    required this.sessionId,
    required this.sessionTitle,
    required this.recorder,
    required this.isRecording,
    required this.onRecordingStateChanged,
  });

  static Future<void> show(
    BuildContext context, {
    required String sessionId,
    required String sessionTitle,
    required LiveSessionRecorder recorder,
    required bool isRecording,
    required VoidCallback onRecordingStateChanged,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => RecordingSaveMethodsModal(
        sessionId: sessionId,
        sessionTitle: sessionTitle,
        recorder: recorder,
        isRecording: isRecording,
        onRecordingStateChanged: onRecordingStateChanged,
      ),
    );
  }

  @override
  State<RecordingSaveMethodsModal> createState() => _RecordingSaveMethodsModalState();
}

class _RecordingSaveMethodsModalState extends State<RecordingSaveMethodsModal> {
  final _titleController = TextEditingController();
  final _externalUrlController = TextEditingController();

  bool _isLoadingData = true;
  bool _isUploading = false;
  bool _captureScreenForRec = true;
  String? _statusMessage;

  List<Map<String, dynamic>> _cohorts = [];
  List<Map<String, dynamic>> _savedRecordings = [];
  int? _selectedCohortId;

  LiveRecordingResult? _pendingCapturedResult;

  static const Color _brightCyan = Color(0xFF00E5FF);
  static const Color _electricPurple = Color(0xFF7C4DFF);

  @override
  void initState() {
    super.initState();
    _titleController.text = 'تسجيل ${widget.sessionTitle}';
    _loadCohortsAndRecordings();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _externalUrlController.dispose();
    super.dispose();
  }

  Future<void> _loadCohortsAndRecordings() async {
    setState(() => _isLoadingData = true);
    try {
      final token = await AuthLocalDataSourceImpl().getToken();
      if (token == null || token.isEmpty) return;

      final api = ApiClient();
      final cohortsRes = await api.get('/teacher/cohorts', token: token);
      final recRes = await api.get('/teacher/recordings', token: token);

      if (!mounted) return;
      final cohortsList = (cohortsRes['data'] as List<dynamic>? ?? [])
          .whereType<Map<String, dynamic>>()
          .toList();
      final recList = (recRes['recordings'] as List<dynamic>? ?? [])
          .whereType<Map<String, dynamic>>()
          .toList();

      setState(() {
        _cohorts = cohortsList;
        _savedRecordings = recList;
        _selectedCohortId ??= cohortsList.isNotEmpty ? (cohortsList.first['id'] as num?)?.toInt() : null;
        _isLoadingData = false;
      });
    } catch (_) {
      if (mounted) setState(() => _isLoadingData = false);
    }
  }

  Future<void> _startCapture() async {
    try {
      await widget.recorder.start(
        preferScreenCapture: _captureScreenForRec,
        includeMicAudio: true,
      );
      widget.onRecordingStateChanged();
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('بدأ التسجيل المباشر بجودة عالية (REC 🔴) — اضغط زر التسجيل عند الانتهاء لحفظه.'),
            backgroundColor: Color(0xFFEF4444),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _statusMessage = e.toString().replaceFirst('UnsupportedError: ', '').replaceFirst('Exception: ', '');
        });
      }
    }
  }

  Future<void> _stopCaptureAndPrepareSave() async {
    final result = await widget.recorder.stop(sessionId: widget.sessionId);
    widget.onRecordingStateChanged();
    if (!mounted) return;

    if (result == null) {
      setState(() => _statusMessage = 'لم يتم التقاط أي بيانات فيديو أثناء التسجيل.');
      return;
    }

    setState(() {
      _pendingCapturedResult = result;
      _statusMessage = 'تم إيقاف التسجيل (${(result.sizeBytes / (1024 * 1024)).toStringAsFixed(2)} MB) — اختر طريقة الحفظ أدناه.';
    });
  }

  Future<void> _uploadBytesToCloud({
    required Uint8List bytes,
    required String filename,
    required int durationSeconds,
    required String saveMode,
  }) async {
    setState(() {
      _isUploading = true;
      _statusMessage = 'جارٍ رفع وحفظ الفيديو في المكتبة السحابية...';
    });

    try {
      final token = await AuthLocalDataSourceImpl().getToken();
      if (token == null || token.isEmpty) {
        throw Exception('يجب تسجيل الدخول كأستاذ لرفع التسجيلات.');
      }

      final title = _titleController.text.trim().isNotEmpty
          ? _titleController.text.trim()
          : 'تسجيل ${widget.sessionTitle}';

      final fields = <String, String>{
        'title': title,
        'duration_seconds': durationSeconds.toString(),
        'save_mode': saveMode,
        'is_published': '1',
      };
      if (_selectedCohortId != null) {
        fields['cohort_id'] = _selectedCohortId.toString();
      }

      await ApiClient().postMultipartBytes(
        '/teacher/sessions/${widget.sessionId}/recordings/upload',
        fileField: 'video_file',
        bytes: bytes,
        filename: filename,
        fields: fields,
        token: token,
      );

      if (!mounted) return;
      setState(() {
        _isUploading = false;
        _pendingCapturedResult = null;
        _statusMessage = 'تم حفظ التسجيل في مكتبة الفوج السحابية بنجاح وأصبح متاحاً للتلاميذ.';
      });
      await _loadCohortsAndRecordings();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isUploading = false;
        _statusMessage = 'فشل رفع التسجيل: ${e.toString().replaceFirst("Exception: ", "")}';
      });
    }
  }

  Future<void> _pickAndUploadExistingVideo() async {
    try {
      final picked = await FilePicker.platform.pickFiles(
        type: FileType.video,
        withData: true,
      );
      if (picked == null || picked.files.isEmpty) return;

      final file = picked.files.first;
      final bytes = file.bytes;
      if (bytes == null || bytes.isEmpty) {
        setState(() => _statusMessage = 'تعذر قراءة محتوى ملف الفيديو المختار.');
        return;
      }

      await _uploadBytesToCloud(
        bytes: bytes,
        filename: file.name,
        durationSeconds: 0,
        saveMode: 'uploaded_file',
      );
    } catch (e) {
      if (mounted) {
        setState(() => _statusMessage = 'خطأ أثناء اختيار الفيديو: $e');
      }
    }
  }

  Future<void> _saveExternalLinkRecording() async {
    final url = _externalUrlController.text.trim();
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      setState(() => _statusMessage = 'يرجى إدخال رابط فيديو صحيح يبدأ بـ https://');
      return;
    }
    if (_selectedCohortId == null) {
      setState(() => _statusMessage = 'يرجى اختيار الفوج الدراسي المرتبط أولاً.');
      return;
    }

    setState(() => _isUploading = true);
    try {
      final token = await AuthLocalDataSourceImpl().getToken();
      final api = ApiClient();
      final sessionRes = await api.get('/sessions/${widget.sessionId}', token: token);
      final numericSessionId = (sessionRes['data']?['id'] ?? sessionRes['session']?['id'] ?? 1) as num;

      await api.post(
        '/teacher/cohorts/$_selectedCohortId/recordings',
        body: {
          'classroom_session_id': numericSessionId.toInt(),
          'title': _titleController.text.trim().isNotEmpty ? _titleController.text.trim() : widget.sessionTitle,
          'video_storage_path': url,
          'is_published': true,
        },
        token: token,
      );

      _externalUrlController.clear();
      if (mounted) {
        setState(() {
          _isUploading = false;
          _statusMessage = 'تم ربط رابط التسجيل الخارجي بمكتبة الفوج بنجاح.';
        });
        await _loadCohortsAndRecordings();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isUploading = false;
          _statusMessage = 'تعذر ربط الرابط الخارجي: $e';
        });
      }
    }
  }

  Future<void> _deleteRecording(int recordingId) async {
    try {
      final token = await AuthLocalDataSourceImpl().getToken();
      await ApiClient().delete('/teacher/recordings/$recordingId', token: token);
      await _loadCohortsAndRecordings();
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final isRecordingNow = widget.recorder.isRecording || widget.isRecording;

    return Container(
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.88),
      padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.of(context).viewInsets.bottom + 24),
      decoration: const BoxDecoration(
        color: Color(0xFF0F172A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
        border: Border(top: BorderSide(color: Colors.white24, width: 1.2)),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(color: Colors.white30, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 16),
            const Row(
              children: [
                Icon(Icons.video_library_rounded, color: _brightCyan, size: 22),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'إدارة التسجيلات وطرق حفظ البث المباشر',
                    style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            const Text(
              'التخزين السحابي الدائم (Railway Volume: /storage/app/public/recordings) أو الحفظ المحلي على الجهاز',
              style: TextStyle(color: Colors.white54, fontSize: 11.5),
            ),
            const SizedBox(height: 14),

            if (_statusMessage != null)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _brightCyan.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _brightCyan.withValues(alpha: 0.4)),
                ),
                child: Text(
                  _statusMessage!,
                  style: const TextStyle(color: Colors.white, fontSize: 12.5),
                ),
              ),

            // Cohort & Title Selector
            TextField(
              controller: _titleController,
              style: const TextStyle(color: Colors.white, fontSize: 13.5),
              decoration: InputDecoration(
                labelText: 'عنوان التسجيل المحفوظ',
                labelStyle: const TextStyle(color: Colors.white70, fontSize: 12),
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.06),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 10),
            if (_cohorts.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white12),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    value: _selectedCohortId,
                    isExpanded: true,
                    dropdownColor: const Color(0xFF0F172A),
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                    items: _cohorts
                        .map(
                          (c) => DropdownMenuItem<int>(
                            value: (c['id'] as num).toInt(),
                            child: Text('حفظ في مكتبة: ${c['name']}'),
                          ),
                        )
                        .toList(),
                    onChanged: (val) => setState(() => _selectedCohortId = val),
                  ),
                ),
              ),
            const SizedBox(height: 14),

            // Method 1: Live Capture (Start/Stop/Save)
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isRecordingNow
                    ? const Color(0xFFEF4444).withValues(alpha: 0.12)
                    : Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isRecordingNow ? const Color(0xFFEF4444) : Colors.white12,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        isRecordingNow ? Icons.fiber_manual_record_rounded : Icons.videocam_rounded,
                        color: isRecordingNow ? const Color(0xFFEF4444) : _brightCyan,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          '1. تسجيل البث المباشر (سحابي أو محلي)',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13.5),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (!isRecordingNow && _pendingCapturedResult == null) ...[
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      activeColor: _brightCyan,
                      title: const Text('تسجيل الشاشة + الصوت (بدل الكاميرا فقط)', style: TextStyle(color: Colors.white70, fontSize: 12)),
                      value: _captureScreenForRec,
                      onChanged: (v) => setState(() => _captureScreenForRec = v),
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _isUploading ? null : _startCapture,
                        icon: const Icon(Icons.fiber_manual_record_rounded, size: 18),
                        label: const Text('بدء تسجيل الحصة الآن', style: TextStyle(fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFEF4444),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  ] else if (isRecordingNow) ...[
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _stopCaptureAndPrepareSave,
                        icon: const Icon(Icons.stop_circle_outlined, size: 18),
                        label: const Text('إيقاف التسجيل واختيار مكان الحفظ', style: TextStyle(fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFEF4444),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  ] else if (_pendingCapturedResult != null) ...[
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _isUploading
                                ? null
                                : () => _uploadBytesToCloud(
                                      bytes: _pendingCapturedResult!.bytes,
                                      filename: _pendingCapturedResult!.filename,
                                      durationSeconds: _pendingCapturedResult!.durationSeconds,
                                      saveMode: 'live_capture',
                                    ),
                            icon: const Icon(Icons.cloud_upload_rounded, size: 18),
                            label: const Text('حفظ في مكتبة الفوج', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF10B981),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => widget.recorder.triggerLocalDownload(_pendingCapturedResult!),
                            icon: const Icon(Icons.download_rounded, size: 18, color: _brightCyan),
                            label: const Text('تنزيل على جهازي', style: TextStyle(color: _brightCyan, fontWeight: FontWeight.bold, fontSize: 12)),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: _brightCyan),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Method 2: Upload Pre-recorded File
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _isUploading ? null : _pickAndUploadExistingVideo,
                icon: const Icon(Icons.upload_file_rounded, color: _electricPurple),
                label: Text(
                  _isUploading ? 'جارٍ الرفع للسحابة...' : '2. رفع ملف فيديو من جهازك إلى مكتبة الفوج (.mp4 / .webm)',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12.5),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                  side: const BorderSide(color: _electricPurple),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Method 3: External URL
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _externalUrlController,
                    style: const TextStyle(color: Colors.white, fontSize: 12.5),
                    decoration: InputDecoration(
                      hintText: '3. أو لصق رابط تسجيل خارجي (https://...)',
                      hintStyle: const TextStyle(color: Colors.white38, fontSize: 11.5),
                      filled: true,
                      fillColor: Colors.white.withValues(alpha: 0.05),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _isUploading ? null : _saveExternalLinkRecording,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _electricPurple,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('ربط', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 18),

            // Existing Saved Recordings Archive
            const Text(
              'التسجيلات المحفوظة في السحابة:',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 8),
            if (_isLoadingData)
              const Center(child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator()))
            else if (_savedRecordings.isEmpty)
              const Text(
                'لا توجد تسجيلات محفوظة بعد.',
                style: TextStyle(color: Colors.white54, fontSize: 12),
              )
            else
              ..._savedRecordings.map((r) {
                final sizeBytes = (r['file_size_bytes'] as num?)?.toInt() ?? 0;
                final sizeMb = sizeBytes > 0 ? '${(sizeBytes / (1024 * 1024)).toStringAsFixed(1)} MB' : '';
                final mode = r['save_mode']?.toString() ?? 'cloud_library';
                final modeLabel = mode == 'live_capture'
                    ? 'تسجيل مباشر'
                    : mode == 'uploaded_file'
                        ? 'ملف مرفوع'
                        : 'رابط/سحابة';
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.04),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.play_circle_filled_rounded, color: _brightCyan, size: 28),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              r['title']?.toString() ?? 'تسجيل',
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                            Text(
                              '${r['cohort_name'] ?? ''} • $modeLabel${sizeMb.isNotEmpty ? ' • $sizeMb' : ''}',
                              style: const TextStyle(color: Colors.white54, fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        tooltip: 'تشغيل ومعاينة',
                        icon: const Icon(Icons.open_in_new_rounded, color: _brightCyan, size: 19),
                        onPressed: () {
                          final url = r['stream_url']?.toString() ?? '';
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => ProtectedRecordingPlayerScreen(
                                title: r['title']?.toString() ?? 'تسجيل الحصة',
                                description: r['description']?.toString(),
                                streamUrl: url,
                                watermarkText: 'Teacher Preview',
                              ),
                            ),
                          );
                        },
                      ),
                      IconButton(
                        tooltip: 'حذف التسجيل',
                        icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 19),
                        onPressed: () => _deleteRecording((r['id'] as num).toInt()),
                      ),
                    ],
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}
