import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pindo_future_mobile/core/config/platform_payment_config.dart';
import 'package:pindo_future_mobile/features/monetization/services/subscription_payment_service.dart';
import 'package:pindo_future_mobile/features/teachers/presentation/widgets/modals/live_camera_capture_modal.dart';

class AlgerianPaymentSheetModal extends StatefulWidget {
  final int? cohortId;
  final String cohortName;
  final String teacherName;
  final String subject;
  final String packageName;
  final int priceDzd;
  final String? packageType;
  final int? livePriceDzd;
  final int? libraryPriceDzd;
  final bool isQuickRenewal;
  final String? studentToken;
  final String? studentName;
  final String? studentEmail;
  final String? studentCode;
  final int? includedSessionsCount;
  final VoidCallback? onReceiptSubmitted;

  const AlgerianPaymentSheetModal({
    super.key,
    this.cohortId,
    required this.cohortName,
    required this.teacherName,
    required this.subject,
    required this.packageName,
    required this.priceDzd,
    this.packageType,
    this.livePriceDzd,
    this.libraryPriceDzd,
    this.isQuickRenewal = false,
    this.studentToken,
    this.studentName,
    this.studentEmail,
    this.studentCode,
    this.includedSessionsCount,
    this.onReceiptSubmitted,
  });

  static Future<void> show(
    BuildContext context, {
    int? cohortId,
    required String cohortName,
    required String teacherName,
    required String subject,
    required String packageName,
    required int priceDzd,
    String? packageType,
    int? livePriceDzd,
    int? libraryPriceDzd,
    bool isQuickRenewal = false,
    String? studentToken,
    String? studentName,
    String? studentEmail,
    String? studentCode,
    int? includedSessionsCount,
    VoidCallback? onReceiptSubmitted,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AlgerianPaymentSheetModal(
        cohortId: cohortId,
        cohortName: cohortName,
        teacherName: teacherName,
        subject: subject,
        packageName: packageName,
        priceDzd: priceDzd,
        packageType: packageType,
        livePriceDzd: livePriceDzd,
        libraryPriceDzd: libraryPriceDzd,
        isQuickRenewal: isQuickRenewal,
        studentToken: studentToken,
        studentName: studentName,
        studentEmail: studentEmail,
        studentCode: studentCode,
        includedSessionsCount: includedSessionsCount,
        onReceiptSubmitted: onReceiptSubmitted,
      ),
    );
  }

  @override
  State<AlgerianPaymentSheetModal> createState() => _AlgerianPaymentSheetModalState();
}

class _AlgerianPaymentSheetModalState extends State<AlgerianPaymentSheetModal> {
  int _selectedMethodIndex = 0; // 0: BaridiMob, 1: CIB/Edahabia, 2: CCP
  Uint8List? _receiptBytes;
  String? _uploadedReceiptName;
  bool _isPdfReceipt = false;
  bool _isSubmitting = false;

  final TextEditingController _txReferenceController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  static const Color _brightCyan = Color(0xFF00E5FF);
  static const Color _electricPurple = Color(0xFF7C4DFF);
  static const Color _deepIndigo = Color(0xFF0F172A);
  static const Color _baridiMobGold = Color(0xFFF59E0B);
  static const Color _edahabiaGold = Color(0xFFEAB308);

  static const String _baridiMobRip = PlatformPaymentConfig.formattedRip;
  static const String _ccpNumber = PlatformPaymentConfig.ccpAccountNumber;
  static const String _ccpKey = PlatformPaymentConfig.ccpKey;

  bool get _hasValidReceipt => _receiptBytes != null && _receiptBytes!.isNotEmpty;

  @override
  void dispose() {
    _txReferenceController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _showSnack(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, textDirection: TextDirection.rtl),
        backgroundColor: isError ? const Color(0xFFEF4444) : const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _copyRip() {
    Clipboard.setData(const ClipboardData(text: PlatformPaymentConfig.rip));
    _showSnack('تم نسخ رقم الحساب البريدي RIP بنجاح (${PlatformPaymentConfig.formattedRip}).');
  }

  void _applyPickedFile({
    required Uint8List bytes,
    required String filename,
  }) {
    if (bytes.isEmpty) {
      _showSnack('الملف المختار فارغ ولا يحتوي على بيانات صالحة.', isError: true);
      return;
    }

    final lowerName = filename.toLowerCase();
    final isPdf = lowerName.endsWith('.pdf');
    setState(() {
      _receiptBytes = bytes;
      _uploadedReceiptName = filename;
      _isPdfReceipt = isPdf;
    });
    _showSnack('تم إرفاق الوصل الحقيقي ($filename) بنجاح. يمكنك الآن إرسال الطلب.');
  }

  Future<void> _pickReceiptFromCamera() async {
    try {
      if (kIsWeb) {
        final result = await LiveCameraCaptureModal.show(context);
        if (result != null && result.bytes.isNotEmpty) {
          _applyPickedFile(bytes: result.bytes, filename: result.name);
          return;
        }
      }

      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
        maxWidth: 1600,
      );
      if (picked == null) {
        _showSnack('لم يتم التقاط أي صورة للوصل.', isError: true);
        return;
      }

      final bytes = await picked.readAsBytes();
      _applyPickedFile(
        bytes: bytes,
        filename: picked.name.isNotEmpty ? picked.name : 'receipt_camera_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );
    } catch (e) {
      _showSnack('تعذر فتح الكاميرا: تأكد من منح صلاحية الكاميرا في إعدادات الجهاز أو المتصفح.', isError: true);
    }
  }

  Future<void> _pickReceiptFromGallery() async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 88,
        maxWidth: 1600,
      );
      if (picked != null) {
        final bytes = await picked.readAsBytes();
        _applyPickedFile(
          bytes: bytes,
          filename: picked.name.isNotEmpty ? picked.name : 'receipt_gallery_${DateTime.now().millisecondsSinceEpoch}.jpg',
        );
        return;
      }
    } catch (_) {
      // Fallback cleanly to FilePicker below on platforms without native gallery bridge
    }

    await _pickReceiptFromFiles();
  }

  Future<void> _pickReceiptFromFiles() async {
    try {
      final res = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: const ['jpg', 'jpeg', 'png', 'webp', 'pdf'],
        withData: true,
      );

      if (res == null || res.files.isEmpty) {
        _showSnack('لم يتم اختيار أي ملف وصل.', isError: true);
        return;
      }

      final file = res.files.first;
      final bytes = file.bytes;
      if (bytes == null || bytes.isEmpty) {
        _showSnack('تعذر قراءة محتوى الملف المحدد. يرجى اختيار صورة JPG/PNG أو PDF صالحة.', isError: true);
        return;
      }

      _applyPickedFile(
        bytes: bytes,
        filename: file.name.isNotEmpty ? file.name : 'receipt_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );
    } catch (e) {
      _showSnack('تعذر فتح مستعرض الملفات أو المعرض. تأكد من منح صلاحية الوصول للصور.', isError: true);
    }
  }

  void _clearReceipt() {
    setState(() {
      _receiptBytes = null;
      _uploadedReceiptName = null;
      _isPdfReceipt = false;
    });
  }

  Future<void> _submitPayment() async {
    if (_selectedMethodIndex == 1) {
      _showSnack(
        'الدفع الآلي عبر CIB / الذهبية يتطلب ربط بوابة SATIM / Chargily. يرجى الدفع عبر BaridiMob أو CCP وإرفاق الوصل.',
        isError: true,
      );
      return;
    }

    if (!_hasValidReceipt) {
      _showSnack(
        'يرجى تصوير أو اختيار ملف وصل الدفع الحقيقي أولاً قبل تأكيد الإرسال.',
        isError: true,
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final methodNames = ['BaridiMob', 'Edahabia', 'CCP'];
    final selectedMethod = methodNames[_selectedMethodIndex];

    try {
      final serverData = await SubscriptionPaymentService.instance.uploadCohortReceipt(
        cohortId: widget.cohortId,
        receiptBytes: _receiptBytes,
        receiptFilename: _uploadedReceiptName,
        paymentMethod: selectedMethod,
        cohortName: widget.cohortName,
        teacherName: widget.teacherName,
        subject: widget.subject,
        packageName: widget.packageName,
        priceDzd: widget.priceDzd,
        packageType: widget.packageType,
        livePriceDzd: widget.livePriceDzd,
        libraryPriceDzd: widget.libraryPriceDzd,
        txReference: _txReferenceController.text.trim(),
        notes: _notesController.text.trim(),
        token: widget.studentToken,
        studentName: widget.studentName,
        studentEmail: widget.studentEmail,
        studentCode: widget.studentCode,
      );

      if (!mounted) return;
      setState(() => _isSubmitting = false);
      widget.onReceiptSubmitted?.call();
      Navigator.of(context).pop();

      final orderNumber = serverData['order_number']?.toString() ?? serverData['local_reference']?.toString() ?? '-';

      showDialog(
        context: context,
        builder: (ctx) => Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            backgroundColor: const Color(0xFF0F172A),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: const BorderSide(color: Color(0xFF10B981), width: 1.5),
            ),
            title: const Row(
              children: [
                Icon(Icons.verified, color: Color(0xFF34D399), size: 28),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'تم رفع الوصل وإرسال الطلب بنجاح',
                    style: TextStyle(color: Colors.white, fontSize: 15.5, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'تم استلام ملف الوصل (${_uploadedReceiptName ?? ''}) وحفظه في نظام المراجعة والتحكم.',
                  style: const TextStyle(color: Colors.white70, fontSize: 12.5, height: 1.4),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('الفوج: ${widget.cohortName}', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text('نوع الباقة: ${widget.packageName}', style: const TextStyle(color: _brightCyan, fontSize: 12, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text('المبلغ: ${widget.priceDzd} دج', style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text('رقم الطلب: $orderNumber', style: const TextStyle(color: Colors.white60, fontSize: 11)),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'سيتم تفعيل اشتراكك وحساب الحصص والمكتبة فور مطابقة الوصل وتأكيده من الإدارة.',
                  style: TextStyle(color: Color(0xFF34D399), fontSize: 11.5, height: 1.4),
                ),
              ],
            ),
            actions: [
              ElevatedButton(
                onPressed: () => Navigator.of(ctx).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _brightCyan,
                  foregroundColor: const Color(0xFF070B14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('حسناً، تم الحفظ', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      _showSnack(e.toString().replaceFirst('Exception: ', ''), isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final canSubmit = _selectedMethodIndex != 1 && _hasValidReceipt && !_isSubmitting;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: DraggableScrollableSheet(
        initialChildSize: 0.90,
        minChildSize: 0.55,
        maxChildSize: 0.95,
        builder: (_, scrollController) => Container(
          decoration: const BoxDecoration(
            color: _deepIndigo,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            boxShadow: [
              BoxShadow(color: Colors.black54, blurRadius: 25, offset: Offset(0, -6)),
            ],
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.white30,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: _brightCyan.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: _brightCyan.withValues(alpha: 0.35)),
                                ),
                                child: const Icon(Icons.payment_rounded, color: _brightCyan, size: 22),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget.isQuickRenewal ? 'تجديد الاشتراك الفوري ⚡' : 'دفع الاشتراك وتفعيل الحساب 💳',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 15.5,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 2),
                                    const Text(
                                      'وسائل الدفع المعتمدة في الجزائر 🇩🇿',
                                      style: TextStyle(color: Colors.white60, fontSize: 11),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.white60, size: 20),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Order Summary Card (isolated RTL/LTR safe)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFF1E1B4B),
                            Colors.white.withValues(alpha: 0.05),
                          ],
                          begin: Alignment.topRight,
                          end: Alignment.bottomLeft,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: _electricPurple.withValues(alpha: 0.4)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  widget.cohortName,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: _brightCyan.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: _brightCyan),
                                ),
                                child: Text(
                                  '${widget.priceDzd} دج',
                                  style: const TextStyle(
                                    color: _brightCyan,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 12,
                            runSpacing: 4,
                            children: [
                              Text('المادة: ${widget.subject}', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                              Text('الأستاذ: ${widget.teacherName}', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                            ],
                          ),
                          if (widget.includedSessionsCount != null) ...[
                            const SizedBox(height: 6),
                            Text(
                              'عدد الحصص المشمولة: من الحصة 1 إلى الحصة ${widget.includedSessionsCount}',
                              style: const TextStyle(color: Color(0xFF34D399), fontSize: 11.5, fontWeight: FontWeight.w600),
                            ),
                          ],
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(Icons.auto_awesome, color: Color(0xFFFBBF24), size: 14),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  'الباقة المحددة: ${widget.packageName}',
                                  style: const TextStyle(color: Color(0xFFFBBF24), fontSize: 12, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),

                    const Text(
                      'اختر طريقة الدفع:',
                      style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        _methodPill(0, 'بريدي موب (BaridiMob)', Icons.phone_android, _baridiMobGold),
                        const SizedBox(width: 8),
                        _methodPill(1, 'البطاقة الذهبية / CIB', Icons.credit_card, _edahabiaGold),
                        const SizedBox(width: 8),
                        _methodPill(2, 'حوالة CCP', Icons.account_balance, _brightCyan),
                      ],
                    ),
                    const SizedBox(height: 18),

                    if (_selectedMethodIndex == 0) _buildBaridiMobSection(),
                    if (_selectedMethodIndex == 1) _buildEdahabiaSection(),
                    if (_selectedMethodIndex == 2) _buildCcpSection(),

                    if (_selectedMethodIndex != 1) ...[
                      const SizedBox(height: 14),
                      TextField(
                        controller: _txReferenceController,
                        style: const TextStyle(color: Colors.white, fontSize: 13),
                        decoration: InputDecoration(
                          labelText: 'رقم المرجع / العملية على الوصل (اختياري)',
                          labelStyle: const TextStyle(color: Colors.white60, fontSize: 11.5),
                          prefixIcon: const Icon(Icons.tag, color: _brightCyan, size: 18),
                          filled: true,
                          fillColor: Colors.white.withValues(alpha: 0.05),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.14)),
                          ),
                        ),
                      ),
                    ],

                    const SizedBox(height: 20),

                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: _isSubmitting ? null : _submitPayment,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: canSubmit ? _brightCyan : Colors.white12,
                          foregroundColor: canSubmit ? const Color(0xFF070B14) : Colors.white54,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          elevation: canSubmit ? 4 : 0,
                        ),
                        icon: _isSubmitting
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF070B14)),
                              )
                            : Icon(
                                canSubmit ? Icons.cloud_upload_rounded : Icons.lock_outline_rounded,
                                size: 20,
                              ),
                        label: Text(
                          _isSubmitting
                              ? 'جارٍ رفع الوصل إلى الخادم...'
                              : (_selectedMethodIndex == 1
                                  ? 'يرجى اختيار BaridiMob أو CCP للدفع'
                                  : (_hasValidReceipt
                                      ? 'إرسال الوصل وتأكيد الطلب (${widget.priceDzd} دج)'
                                      : 'أرفق صورة الوصل الحقيقي أولاً')),
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _methodPill(int index, String title, IconData icon, Color activeColor) {
    final isSelected = _selectedMethodIndex == index;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _selectedMethodIndex = index),
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
          decoration: BoxDecoration(
            color: isSelected ? activeColor.withValues(alpha: 0.16) : Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? activeColor : Colors.white.withValues(alpha: 0.12),
              width: isSelected ? 1.5 : 1.0,
            ),
          ),
          child: Column(
            children: [
              Icon(icon, size: 18, color: isSelected ? activeColor : Colors.white70),
              const SizedBox(height: 4),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.white70,
                  fontSize: 10.5,
                  height: 1.25,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReceiptUploadArea({required String titleLabel}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          titleLabel,
          style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        if (!_hasValidReceipt) ...[
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _pickReceiptFromCamera,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: BorderSide(color: _brightCyan.withValues(alpha: 0.45)),
                    padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 6),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  icon: const Icon(Icons.camera_alt_outlined, size: 17, color: _brightCyan),
                  label: const Text('تصوير بالكاميرا 📷', style: TextStyle(fontSize: 11.5)),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _pickReceiptFromGallery,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: BorderSide(color: _baridiMobGold.withValues(alpha: 0.5)),
                    padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 6),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  icon: const Icon(Icons.photo_library_outlined, size: 17, color: _baridiMobGold),
                  label: const Text('من المعرض 🖼️', style: TextStyle(fontSize: 11.5)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _pickReceiptFromFiles,
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white70,
                side: BorderSide(color: Colors.white.withValues(alpha: 0.22)),
                padding: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              icon: const Icon(Icons.attach_file_rounded, size: 16, color: Colors.white70),
              label: const Text('أو اختيار ملف / PDF من الجهاز 📄', style: TextStyle(fontSize: 11.5)),
            ),
          ),
        ] else
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF10B981)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!_isPdfReceipt && _receiptBytes != null) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.memory(
                      _receiptBytes!,
                      width: double.infinity,
                      height: 140,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
                Row(
                  children: [
                    Icon(
                      _isPdfReceipt ? Icons.picture_as_pdf_rounded : Icons.check_circle,
                      color: const Color(0xFF34D399),
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _uploadedReceiptName ?? 'receipt',
                            style: const TextStyle(color: Colors.white, fontSize: 11.5, fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            'الحجم: ${((_receiptBytes?.length ?? 0) / 1024).toStringAsFixed(1)} KB • جاهز للرفع والتحقق',
                            style: const TextStyle(color: Color(0xFF6EE7B7), fontSize: 10.5),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFFFCA5A5), size: 20),
                      tooltip: 'حذف الوصل',
                      onPressed: _clearReceipt,
                    ),
                  ],
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildBaridiMobSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: _baridiMobGold.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.send_to_mobile, color: _baridiMobGold, size: 18),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'التحويل عبر تطبيق بريدي موب (BaridiMob)',
                  style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF070B14),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _baridiMobGold.withValues(alpha: 0.35)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.account_balance, color: _baridiMobGold, size: 14),
                    SizedBox(width: 6),
                    Text('الحساب المستلم: ', style: TextStyle(color: Colors.white54, fontSize: 11)),
                    Expanded(
                      child: Text(
                        PlatformPaymentConfig.accountHolderName,
                        style: TextStyle(color: Colors.white, fontSize: 11.5, fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const Divider(color: Colors.white12, height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('رقم الحساب البريدي (RIP):', style: TextStyle(color: Colors.white54, fontSize: 10.5)),
                          SizedBox(height: 4),
                          Directionality(
                            textDirection: TextDirection.ltr,
                            child: SelectableText(
                              _baridiMobRip,
                              style: TextStyle(
                                color: _baridiMobGold,
                                fontSize: 13.5,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.8,
                                fontFamily: 'monospace',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: _copyRip,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _baridiMobGold,
                        foregroundColor: const Color(0xFF070B14),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      icon: const Icon(Icons.copy, size: 14),
                      label: const Text('نسخ', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.03),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.info_outline, color: _brightCyan, size: 15),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'قم بتحويل مبلغ ${widget.priceDzd} دج عبر تطبيق بريدي موب إلى الرقم أعلاه، ثم صوّر أو ارفع لقطة شاشة لوصل التحويل لتفعيل اشتراكك.',
                    style: const TextStyle(color: Colors.white70, fontSize: 11, height: 1.4),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _buildReceiptUploadArea(titleLabel: 'إرفاق صورة أو ملف وصل التحويل (إجباري):'),
        ],
      ),
    );
  }

  Widget _buildEdahabiaSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _edahabiaGold.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _edahabiaGold.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.verified_user_outlined, color: _edahabiaGold, size: 20),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'بوابة الدفع الإلكتروني بالبطاقة (CIB / الذهبية)',
                  style: TextStyle(color: Colors.white, fontSize: 13.5, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            'لا يتم خصم أي مبلغ مباشرة عبر كتابة أرقام البطاقة داخل التطبيق. الخصم الآلي الحقيقي من بطاقة CIB أو الذهبية وتحويله إلى حساب CCP يتم حصرياً عبر صفحة التشفير الآمنة لبوابة الدفع المعتمدة (SATIM / بريد الجزائر أو وسيط مثل Chargily) مع رمز تأكيد SMS (3D-Secure).',
            style: TextStyle(color: Colors.white70, fontSize: 11.5, height: 1.5),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF070B14),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.white12),
            ),
            child: const Row(
              children: [
                Icon(Icons.info, color: _brightCyan, size: 16),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'الحالة الحالية: بانتظار تفعيل مفتاح التاجر للخصم الفوري. للدفع الآن وتفعيل حسابك، استخدم التحويل المباشر عبر بريدي موب (BaridiMob) أو حوالة CCP.',
                    style: TextStyle(color: Color(0xFFBAE6FD), fontSize: 11, height: 1.4),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => setState(() => _selectedMethodIndex = 0),
              style: ElevatedButton.styleFrom(
                backgroundColor: _baridiMobGold,
                foregroundColor: const Color(0xFF070B14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              icon: const Icon(Icons.phone_android, size: 17),
              label: const Text('التحويل الآن عبر بريدي موب (BaridiMob)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCcpSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.account_balance, color: _brightCyan, size: 18),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'الدفع عبر الحوالة البريدية (مكتب البريد Algérie Poste)',
                  style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF070B14),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: _brightCyan.withValues(alpha: 0.3)),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('الحساب الجاري البريدي CCP:', style: TextStyle(color: Colors.white54, fontSize: 11)),
                SizedBox(height: 4),
                Row(
                  children: [
                    Directionality(
                      textDirection: TextDirection.ltr,
                      child: SelectableText(
                        '$_ccpNumber  Clé $_ccpKey',
                        style: TextStyle(color: _brightCyan, fontSize: 14, fontWeight: FontWeight.bold, fontFamily: 'monospace'),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 6),
                Text('باسم: ${PlatformPaymentConfig.accountHolderName}', style: TextStyle(color: Colors.white70, fontSize: 11)),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _buildReceiptUploadArea(titleLabel: 'إرفاق صورة أو ملف وصل الحوالة البريدية (إجباري):'),
        ],
      ),
    );
  }
}
