import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import '../../domain/entities/cohort_chat_message.dart';
import '../../services/cohort_chat_service.dart';
import '../../../teachers/presentation/widgets/modals/live_camera_capture_modal.dart';

class CohortChatRoomModal extends StatefulWidget {
  final String cohortId;
  final String cohortName;
  final String? academicLevel;
  final String currentUserName;
  final String currentUserRole; // 'teacher' or 'student'

  const CohortChatRoomModal({
    super.key,
    required this.cohortId,
    required this.cohortName,
    this.academicLevel,
    this.currentUserName = 'الأستاذ محمد أمين بن عيسى',
    this.currentUserRole = 'teacher',
  });

  static Future<void> show(
    BuildContext context, {
    required String cohortId,
    required String cohortName,
    String? academicLevel,
    String currentUserName = 'الأستاذ محمد أمين بن عيسى',
    String currentUserRole = 'teacher',
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CohortChatRoomModal(
        cohortId: cohortId,
        cohortName: cohortName,
        academicLevel: academicLevel,
        currentUserName: currentUserName,
        currentUserRole: currentUserRole,
      ),
    );
  }

  @override
  State<CohortChatRoomModal> createState() => _CohortChatRoomModalState();
}

class _CohortChatRoomModalState extends State<CohortChatRoomModal> {
  final CohortChatService _chatService = CohortChatService();
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  static const Color _brightCyan = Color(0xFF00E5FF);
  static const Color _electricPurple = Color(0xFF7C4DFF);
  static const Color _deepIndigo = Color(0xFF311B92);
  static const Color _gold = Color(0xFFFFD700);

  late List<CohortChatMessage> _messages;

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  void _loadMessages() {
    setState(() {
      _messages = List.from(_chatService.getMessages(widget.cohortId, cohortName: widget.cohortName));
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendTextMessage() {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    final newMsg = CohortChatMessage(
      id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
      cohortId: widget.cohortId,
      cohortName: widget.cohortName,
      senderId: widget.currentUserRole == 'teacher' ? 'TCH_01' : 'STU_ME',
      senderName: widget.currentUserName,
      senderRole: widget.currentUserRole,
      text: text,
      messageType: 'text',
      timestamp: DateTime.now(),
      isMine: true,
    );

    _chatService.sendMessage(newMsg);
    _textController.clear();
    _loadMessages();
  }

  Future<void> _captureLivePhoto() async {
    final result = await LiveCameraCaptureModal.show(context);
    if (result != null) {
      final newMsg = CohortChatMessage(
        id: 'msg_img_${DateTime.now().millisecondsSinceEpoch}',
        cohortId: widget.cohortId,
        cohortName: widget.cohortName,
        senderId: widget.currentUserRole == 'teacher' ? 'TCH_01' : 'STU_ME',
        senderName: widget.currentUserName,
        senderRole: widget.currentUserRole,
        text: '📷 صورة ملتقطة بالكاميرا الحية',
        messageType: 'image',
        imageBytes: result.bytes,
        fileName: result.name,
        timestamp: DateTime.now(),
        isMine: true,
      );

      _chatService.sendMessage(newMsg);
      _loadMessages();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم إرسال الصورة الحية إلى محادثة الفوج بنجاح! 📸'),
            backgroundColor: Color(0xFF10B981),
          ),
        );
      }
    }
  }

  Future<void> _pickGalleryImage() async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(source: ImageSource.gallery);
      if (picked != null) {
        final bytes = await picked.readAsBytes();
        final newMsg = CohortChatMessage(
          id: 'msg_gal_${DateTime.now().millisecondsSinceEpoch}',
          cohortId: widget.cohortId,
          cohortName: widget.cohortName,
          senderId: widget.currentUserRole == 'teacher' ? 'TCH_01' : 'STU_ME',
          senderName: widget.currentUserName,
          senderRole: widget.currentUserRole,
          text: '🖼️ صورة من المعرض',
          messageType: 'image',
          imageBytes: bytes,
          fileName: picked.name,
          timestamp: DateTime.now(),
          isMine: true,
        );

        _chatService.sendMessage(newMsg);
        _loadMessages();
        return;
      }
    } catch (_) {
      final res = await FilePicker.platform.pickFiles(type: FileType.image, withData: true);
      if (res != null && res.files.isNotEmpty && res.files.first.bytes != null) {
        final newMsg = CohortChatMessage(
          id: 'msg_gal_${DateTime.now().millisecondsSinceEpoch}',
          cohortId: widget.cohortId,
          cohortName: widget.cohortName,
          senderId: widget.currentUserRole == 'teacher' ? 'TCH_01' : 'STU_ME',
          senderName: widget.currentUserName,
          senderRole: widget.currentUserRole,
          text: '🖼️ صورة من الملفات',
          messageType: 'image',
          imageBytes: res.files.first.bytes,
          fileName: res.files.first.name,
          timestamp: DateTime.now(),
          isMine: true,
        );
        _chatService.sendMessage(newMsg);
        _loadMessages();
      }
    }
  }

  void _showAddLinkDialog() {
    final titleCtrl = TextEditingController();
    final urlCtrl = TextEditingController(text: 'https://');

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: const Color(0xFF0F172A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: _brightCyan, width: 1.2),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('مشاركة رابط مع الفوج 🔗', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  IconButton(icon: const Icon(Icons.close_rounded, color: Colors.white60), onPressed: () => Navigator.of(ctx).pop()),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: titleCtrl,
                style: const TextStyle(color: Colors.white, fontSize: 13),
                decoration: InputDecoration(
                  labelText: 'عنوان الرابط أو موضوعه',
                  labelStyle: const TextStyle(color: Colors.white60, fontSize: 12),
                  filled: true,
                  fillColor: Colors.white.withValues(alpha: 0.05),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: urlCtrl,
                style: const TextStyle(color: _brightCyan, fontSize: 13),
                decoration: InputDecoration(
                  labelText: 'الرابط (URL)',
                  labelStyle: const TextStyle(color: Colors.white60, fontSize: 12),
                  filled: true,
                  fillColor: Colors.white.withValues(alpha: 0.05),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    final url = urlCtrl.text.trim();
                    if (url.isNotEmpty && url != 'https://') {
                      final newMsg = CohortChatMessage(
                        id: 'msg_lnk_${DateTime.now().millisecondsSinceEpoch}',
                        cohortId: widget.cohortId,
                        cohortName: widget.cohortName,
                        senderId: widget.currentUserRole == 'teacher' ? 'TCH_01' : 'STU_ME',
                        senderName: widget.currentUserName,
                        senderRole: widget.currentUserRole,
                        text: titleCtrl.text.trim().isNotEmpty ? titleCtrl.text.trim() : 'رابط مشارك مع الفوج:',
                        messageType: 'link',
                        linkUrl: url,
                        linkTitle: titleCtrl.text.trim().isNotEmpty ? titleCtrl.text.trim() : url,
                        timestamp: DateTime.now(),
                        isMine: true,
                      );
                      _chatService.sendMessage(newMsg);
                      _loadMessages();
                      Navigator.of(ctx).pop();
                    }
                  },
                  icon: const Icon(Icons.send_rounded, size: 16),
                  label: const Text('إرسال الرابط للفوج', style: TextStyle(fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(backgroundColor: _brightCyan, foregroundColor: Colors.black, padding: const EdgeInsets.symmetric(vertical: 12)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddFileDialog() {
    final nameCtrl = TextEditingController(text: 'ملخص_شامل_لدروس_الفوج.pdf');
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: const Color(0xFF0F172A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: _electricPurple, width: 1.2),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('إرفاق ملف / ملخص دراسي 📄', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  IconButton(icon: const Icon(Icons.close_rounded, color: Colors.white60), onPressed: () => Navigator.of(ctx).pop()),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: nameCtrl,
                style: const TextStyle(color: Colors.white, fontSize: 13),
                decoration: InputDecoration(
                  labelText: 'اسم الملف المرفق',
                  labelStyle: const TextStyle(color: Colors.white60, fontSize: 12),
                  filled: true,
                  fillColor: Colors.white.withValues(alpha: 0.05),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    final name = nameCtrl.text.trim();
                    if (name.isNotEmpty) {
                      final newMsg = CohortChatMessage(
                        id: 'msg_fil_${DateTime.now().millisecondsSinceEpoch}',
                        cohortId: widget.cohortId,
                        cohortName: widget.cohortName,
                        senderId: widget.currentUserRole == 'teacher' ? 'TCH_01' : 'STU_ME',
                        senderName: widget.currentUserName,
                        senderRole: widget.currentUserRole,
                        text: 'ملف تعليمي مرفق للفوج:',
                        messageType: 'file',
                        fileName: name,
                        fileSizeBytes: 2150000,
                        timestamp: DateTime.now(),
                        isMine: true,
                      );
                      _chatService.sendMessage(newMsg);
                      _loadMessages();
                      Navigator.of(ctx).pop();
                    }
                  },
                  icon: const Icon(Icons.upload_file_rounded, size: 16),
                  label: const Text('إرسال الملف للفوج', style: TextStyle(fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(backgroundColor: _electricPurple, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 12)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAttachmentMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0F172A),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('خيارات الإرفاق للفوج 📎', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 14),
            ListTile(
              leading: const Icon(Icons.camera_alt_rounded, color: _brightCyan),
              title: const Text('التقاط صورة بالكاميرا الحية 📷', style: TextStyle(color: Colors.white, fontSize: 13.5)),
              subtitle: const Text('فتح الكاميرا المباشرة والتقاط صورة للسبورة أو الورقة', style: TextStyle(color: Colors.white60, fontSize: 11)),
              onTap: () {
                Navigator.of(context).pop();
                _captureLivePhoto();
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_rounded, color: _electricPurple),
              title: const Text('صورة من المعرض أو الجهاز 🖼️', style: TextStyle(color: Colors.white, fontSize: 13.5)),
              subtitle: const Text('رفع مخطط، تمرين، أو رسم بياني', style: TextStyle(color: Colors.white60, fontSize: 11)),
              onTap: () {
                Navigator.of(context).pop();
                _pickGalleryImage();
              },
            ),
            ListTile(
              leading: const Icon(Icons.link_rounded, color: Colors.amber),
              title: const Text('مشاركة رابط إنترنت 🔗', style: TextStyle(color: Colors.white, fontSize: 13.5)),
              subtitle: const Text('رابط فيديو يوتيوب، مرجع، أو غرفة مباشرة', style: TextStyle(color: Colors.white60, fontSize: 11)),
              onTap: () {
                Navigator.of(context).pop();
                _showAddLinkDialog();
              },
            ),
            ListTile(
              leading: const Icon(Icons.attach_file_rounded, color: Color(0xFF10B981)),
              title: const Text('إرفاق ملف / ملخص (PDF) 📄', style: TextStyle(color: Colors.white, fontSize: 13.5)),
              subtitle: const Text('سلسلة تمارين، فروض واختبارات مع الحلول', style: TextStyle(color: Colors.white60, fontSize: 11)),
              onTap: () {
                Navigator.of(context).pop();
                _showAddFileDialog();
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final pinned = _messages.where((m) => m.isPinned).toList();

    return Container(
      height: MediaQuery.of(context).size.height * 0.90,
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border.all(color: _brightCyan.withValues(alpha: 0.35), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.7),
            blurRadius: 30,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: Column(
        children: [
          // Handle
          const SizedBox(height: 10),
          Center(
            child: Container(
              width: 44,
              height: 4.5,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: _brightCyan.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                    border: Border.all(color: _brightCyan.withValues(alpha: 0.4)),
                  ),
                  child: const Icon(Icons.forum_rounded, color: _brightCyan, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              widget.cohortName,
                              style: const TextStyle(color: Colors.white, fontSize: 14.5, fontWeight: FontWeight.bold),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981).withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text('🟢 متصل', style: TextStyle(color: Color(0xFF34D399), fontSize: 10, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        widget.academicLevel != null
                            ? '${widget.academicLevel!} • غرفة المحادثة الرسمية للفوج • مرتبطة بالحصص المباشرة'
                            : 'غرفة المحادثة الرسمية للفوج • مرتبطة بالحصص المباشرة والدروس',
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.55), fontSize: 11),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: Colors.white70),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          const Divider(color: Colors.white12, height: 1),

          // Pinned Message (if any)
          if (pinned.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              color: Colors.amber.withValues(alpha: 0.12),
              child: Row(
                children: [
                  const Icon(Icons.push_pin_rounded, color: Colors.amber, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'مثبت: ${pinned.last.text}',
                      style: const TextStyle(color: Colors.white, fontSize: 11.5),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),

          // Messages View
          Expanded(
            child: _messages.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.chat_bubble_outline_rounded, color: Colors.white.withValues(alpha: 0.3), size: 48),
                        const SizedBox(height: 10),
                        const Text(
                          'لا توجد رسائل بعد في غرفة محادثة هذا الفوج.\nكن أول من يبدأ النقاش ويرحب بالطلاب!',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white54, fontSize: 12.5),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final msg = _messages[index];
                      return _buildMessageItem(msg);
                    },
                  ),
          ),

          // Input Bar
          Container(
            padding: EdgeInsets.fromLTRB(10, 8, 10, 12 + bottomInset),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.12))),
            ),
            child: Row(
              children: [
                // Live camera button
                IconButton(
                  onPressed: _captureLivePhoto,
                  icon: const Icon(Icons.camera_alt_rounded),
                  color: _brightCyan,
                  tooltip: 'التقاط صورة بالكاميرا الحية',
                ),
                // Attachment menu
                IconButton(
                  onPressed: _showAttachmentMenu,
                  icon: const Icon(Icons.attach_file_rounded),
                  color: Colors.white70,
                  tooltip: 'إرفاق ملفات، روابط، أو صور',
                ),
                // Text Field
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: TextField(
                      controller: _textController,
                      style: const TextStyle(color: Colors.white, fontSize: 13.5),
                      decoration: const InputDecoration(
                        hintText: 'اكتب رسالة إلى الفوج...',
                        hintStyle: TextStyle(color: Colors.white38, fontSize: 12.5),
                        border: InputBorder.none,
                      ),
                      onSubmitted: (_) => _sendTextMessage(),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                // Send button
                Container(
                  decoration: const BoxDecoration(
                    color: _brightCyan,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    onPressed: _sendTextMessage,
                    icon: const Icon(Icons.send_rounded, color: Colors.black, size: 18),
                    tooltip: 'إرسال',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageItem(CohortChatMessage msg) {
    final isMe = msg.isMine || msg.senderName == widget.currentUserName;
    final isTeacher = msg.isTeacher;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isMe) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: isTeacher ? _deepIndigo : Colors.white12,
              child: Text(
                msg.senderName.isNotEmpty ? msg.senderName[0] : 'أ',
                style: TextStyle(
                  color: isTeacher ? _gold : Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 420),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isMe
                    ? const Color(0xFF1E3A8A).withValues(alpha: 0.85)
                    : (isTeacher
                        ? const Color(0xFF2E1065).withValues(alpha: 0.85)
                        : const Color(0xFF1E293B)),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: isMe ? const Radius.circular(16) : const Radius.circular(4),
                  bottomRight: isMe ? const Radius.circular(4) : const Radius.circular(16),
                ),
                border: Border.all(
                  color: isMe
                      ? _brightCyan.withValues(alpha: 0.4)
                      : (isTeacher ? _gold.withValues(alpha: 0.35) : Colors.white12),
                  width: 1.1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Sender name & role badge
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 6,
                    runSpacing: 2,
                    children: [
                      Text(
                        msg.senderName,
                        style: TextStyle(
                          color: isTeacher ? _gold : _brightCyan,
                          fontSize: 11.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                        decoration: BoxDecoration(
                          color: isTeacher
                              ? _gold.withValues(alpha: 0.18)
                              : Colors.white.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          isTeacher ? 'أستاذ 👨‍🏫' : 'تلميذ 🎓',
                          style: TextStyle(
                            color: isTeacher ? _gold : Colors.white70,
                            fontSize: 9.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Text(
                        '${msg.timestamp.hour.toString().padLeft(2, '0')}:${msg.timestamp.minute.toString().padLeft(2, '0')}',
                        style: const TextStyle(color: Colors.white38, fontSize: 10),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  // Image Content (if any)
                  if (msg.hasImage) ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: msg.imageBytes != null
                          ? Image.memory(
                              msg.imageBytes!,
                              height: 180,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            )
                          : (msg.imageUrl != null
                              ? Image.network(
                                  msg.imageUrl!,
                                  height: 180,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => const SizedBox(),
                                )
                              : const SizedBox()),
                    ),
                    const SizedBox(height: 6),
                  ],

                  // Link Content (if any)
                  if (msg.hasLink) ...[
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: _brightCyan.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.link_rounded, color: _brightCyan, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  msg.linkTitle ?? msg.linkUrl!,
                                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  msg.linkUrl!,
                                  style: const TextStyle(color: _brightCyan, fontSize: 10.5),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),
                  ],

                  // File / Document Content (if any)
                  if (msg.hasFile) ...[
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.4)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.picture_as_pdf_rounded, color: Colors.redAccent, size: 22),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  msg.fileName!,
                                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'ملف PDF • ${((msg.fileSizeBytes ?? 2000000) / 1000000).toStringAsFixed(1)} MB',
                                  style: const TextStyle(color: Colors.white54, fontSize: 10),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.download_rounded, color: Color(0xFF10B981), size: 18),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),
                  ],

                  // Text content
                  if (msg.text.isNotEmpty)
                    Text(
                      msg.text,
                      style: const TextStyle(color: Colors.white, fontSize: 13, height: 1.4),
                    ),

                  // Reactions Bar
                  if (msg.reactions.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 4,
                      children: msg.reactions.map((r) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.white12),
                          ),
                          child: Text(r, style: const TextStyle(fontSize: 11)),
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ),
            ),
          ),
          if (isMe) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundColor: isTeacher ? _deepIndigo : _brightCyan.withValues(alpha: 0.3),
              child: Text(
                msg.senderName.isNotEmpty ? msg.senderName[0] : 'أ',
                style: TextStyle(
                  color: isTeacher ? _gold : _brightCyan,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
