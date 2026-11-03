import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AlgerianPaymentSheetModal extends StatefulWidget {
  final String cohortName;
  final String teacherName;
  final String subject;
  final String packageName;
  final int priceDzd;
  final bool isQuickRenewal;

  const AlgerianPaymentSheetModal({
    super.key,
    required this.cohortName,
    required this.teacherName,
    required this.subject,
    required this.packageName,
    required this.priceDzd,
    this.isQuickRenewal = false,
  });

  static Future<void> show(
    BuildContext context, {
    required String cohortName,
    required String teacherName,
    required String subject,
    required String packageName,
    required int priceDzd,
    bool isQuickRenewal = false,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AlgerianPaymentSheetModal(
        cohortName: cohortName,
        teacherName: teacherName,
        subject: subject,
        packageName: packageName,
        priceDzd: priceDzd,
        isQuickRenewal: isQuickRenewal,
      ),
    );
  }

  @override
  State<AlgerianPaymentSheetModal> createState() => _AlgerianPaymentSheetModalState();
}

class _AlgerianPaymentSheetModalState extends State<AlgerianPaymentSheetModal> {
  int _selectedMethodIndex = 0; // 0: BaridiMob, 1: Edahabia, 2: CCP
  bool _receiptUploaded = false;
  String? _uploadedReceiptName;
  bool _isSubmitting = false;

  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _cardExpiryController = TextEditingController();
  final TextEditingController _cardCvvController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  static const Color _brightCyan = Color(0xFF00E5FF);
  static const Color _electricPurple = Color(0xFF7C4DFF);
  static const Color _deepIndigo = Color(0xFF0F172A);
  static const Color _baridiMobGold = Color(0xFFF59E0B);
  static const Color _edahabiaGold = Color(0xFFEAB308);

  static const String _baridiMobRip = '007 99999 0023456789 42';
  static const String _ccpAccount = '23456789 المفتاح: 42';

  @override
  void dispose() {
    _cardNumberController.dispose();
    _cardExpiryController.dispose();
    _cardCvvController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _copyRip() {
    Clipboard.setData(const ClipboardData(text: '00799999002345678942'));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle, color: Color(0xFF34D399), size: 18),
            SizedBox(width: 8),
            Text('تم نسخ رقم الـ RIP بنجاح لحافظة الهاتف.'),
          ],
        ),
        backgroundColor: const Color(0xFF0F172A),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _simulatePickReceipt(String source) {
    setState(() {
      _receiptUploaded = true;
      _uploadedReceiptName = 'recu_baridimob_${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}.jpg ($source)';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم إرفاق وصل التحويل ($source) بنجاح.'),
        backgroundColor: const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _submitPayment() {
    setState(() => _isSubmitting = true);

    Future.delayed(const Duration(milliseconds: 900), () {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      Navigator.of(context).pop();

      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: const Color(0xFF0F172A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: Color(0xFF10B981), width: 1.5),
          ),
          title: const Row(
            children: [
              Icon(Icons.verified, color: Color(0xFF34D399), size: 28),
              SizedBox(width: 10),
              Text(
                'تم تأكيد طلب الدفع بنجاح',
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'تم تسجيل العملية بنجاح لصالح: ${widget.cohortName}',
                style: const TextStyle(color: Colors.white70, fontSize: 13),
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
                    Text('نوع الباقة: ${widget.packageName}', style: const TextStyle(color: _brightCyan, fontSize: 12, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text('المبلغ: ${widget.priceDzd} دج', style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text('رقم المرجع: REF-ALG-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}', style: const TextStyle(color: Colors.white54, fontSize: 11)),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'سيتم تفعيل الرصيد وحساب الحصص مباشرة بمجرد تأكيد المطابقة البنكية.',
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
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.88,
      minChildSize: 0.50,
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
            // Handle Bar
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
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 30),
                children: [
                  // Title
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
                                    widget.isQuickRenewal ? 'تجديد الاشتراك الفوري ⚡' : 'دفع الاشتراك والتفعيل 💳',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  const Text(
                                    'وسائل الدفع الرقمية في الجزائر 🇩🇿',
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

                  // Order Summary Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF1E1B4B),
                          Colors.white.withValues(alpha: 0.05),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: _electricPurple.withValues(alpha: 0.4)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'المادة: ${widget.subject} • الأستاذ: ${widget.teacherName}',
                          style: const TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(Icons.auto_awesome, color: Color(0xFFFBBF24), size: 14),
                            const SizedBox(width: 6),
                            Text(
                              'الباقة المحددة: ${widget.packageName}',
                              style: const TextStyle(color: Color(0xFFFBBF24), fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        if (widget.isQuickRenewal) ...[
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.04),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.info_outline, color: Colors.white54, size: 14),
                                SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    'ملاحظة: هذا تجديد سريع لنفس باقتك الحالية. لتغيير نوع الباقة اضغط خيار "دفع الاشتراك" في الشاشة السابقة.',
                                    style: TextStyle(color: Colors.white60, fontSize: 10.5, height: 1.3),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Method Switcher Tabs
                  const Text(
                    'اختر طريقة الدفع المفضلة لديك:',
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

                  // Active Method Body
                  if (_selectedMethodIndex == 0) _buildBaridiMobSection(),
                  if (_selectedMethodIndex == 1) _buildEdahabiaSection(),
                  if (_selectedMethodIndex == 2) _buildCcpSection(),

                  const SizedBox(height: 22),

                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: _isSubmitting ? null : _submitPayment,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _brightCyan,
                        foregroundColor: const Color(0xFF070B14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        elevation: 4,
                      ),
                      icon: _isSubmitting
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF070B14)),
                            )
                          : const Icon(Icons.check_circle_outline, size: 20),
                      label: Text(
                        _isSubmitting ? 'جارٍ تسجيل العملية...' : 'تأكيد إرسال طلب الدفع (${widget.priceDzd} دج)',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
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
                  'التحويل عبر تطبيق بريدي موب (BaridiMob RIP):',
                  style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
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
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('رقم الحساب الجاري البريدي RIP:', style: TextStyle(color: Colors.white54, fontSize: 10.5)),
                      SizedBox(height: 3),
                      Text(
                        _baridiMobRip,
                        style: TextStyle(
                          color: _baridiMobGold,
                          fontSize: 13.5,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.8,
                          fontFamily: 'monospace',
                        ),
                        overflow: TextOverflow.ellipsis,
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
          ),
          const SizedBox(height: 14),
          const Text(
            'إرفاق صورة وصل التحويل (Capture / Reçu):',
            style: TextStyle(color: Colors.white70, fontSize: 12),
          ),
          const SizedBox(height: 8),
          if (!_receiptUploaded)
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _simulatePickReceipt('الكاميرا'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: BorderSide(color: Colors.white.withValues(alpha: 0.25)),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    icon: const Icon(Icons.camera_alt_outlined, size: 16, color: _brightCyan),
                    label: const Text('تصوير الوصل 📷', style: TextStyle(fontSize: 11)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _simulatePickReceipt('الملفات'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: BorderSide(color: Colors.white.withValues(alpha: 0.25)),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    icon: const Icon(Icons.photo_library_outlined, size: 16, color: _baridiMobGold),
                    label: const Text('اختيار من الملفات 🖼️', style: TextStyle(fontSize: 11)),
                  ),
                ),
              ],
            )
          else
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFF10B981)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, color: Color(0xFF34D399), size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _uploadedReceiptName ?? 'تم إرفاق الوصل بنجاح',
                      style: const TextStyle(color: Colors.white, fontSize: 11),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.cancel, color: Colors.white60, size: 16),
                    onPressed: () => setState(() {
                      _receiptUploaded = false;
                      _uploadedReceiptName = null;
                    }),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEdahabiaSection() {
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
              Icon(Icons.security, color: _edahabiaGold, size: 18),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'الدفع الفوري الآمن بالبطاقة الذهبية / CIB:',
                  style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _cardNumberController,
            keyboardType: TextInputType.number,
            style: const TextStyle(color: Colors.white, letterSpacing: 1.5),
            decoration: InputDecoration(
              labelText: 'رقم البطاقة الذهبية (16 رقماً)',
              labelStyle: const TextStyle(color: Colors.white60, fontSize: 12),
              prefixIcon: const Icon(Icons.credit_card, color: _edahabiaGold, size: 20),
              filled: true,
              fillColor: const Color(0xFF070B14),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _cardExpiryController,
                  keyboardType: TextInputType.datetime,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'تاريخ الانتهاء (MM/YY)',
                    labelStyle: const TextStyle(color: Colors.white60, fontSize: 11),
                    filled: true,
                    fillColor: const Color(0xFF070B14),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: _cardCvvController,
                  keyboardType: TextInputType.number,
                  obscureText: true,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'رمز CVV2 (3 أرقام)',
                    labelStyle: const TextStyle(color: Colors.white60, fontSize: 11),
                    filled: true,
                    fillColor: const Color(0xFF070B14),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ],
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
                  'الدفع عبر الحوالة البريدية (مكتب البريد Algérie Poste):',
                  style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
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
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('الحساب الجاري CCP:', style: TextStyle(color: Colors.white54, fontSize: 11)),
                SizedBox(height: 2),
                Text(_ccpAccount, style: TextStyle(color: _brightCyan, fontSize: 13, fontWeight: FontWeight.bold)),
                SizedBox(height: 4),
                Text('باسم: مؤسسة بيندو فيوتشر للتعليم التفاعلي عن بعد', style: TextStyle(color: Colors.white70, fontSize: 11)),
              ],
            ),
          ),
          const SizedBox(height: 12),
          if (!_receiptUploaded)
            OutlinedButton.icon(
              onPressed: () => _simulatePickReceipt('حوالة CCP'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: BorderSide(color: Colors.white.withValues(alpha: 0.25)),
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              icon: const Icon(Icons.upload_file, size: 16, color: _brightCyan),
              label: const Text('إرفاق صورة وصل الحوالة البريدية 📄', style: TextStyle(fontSize: 11.5)),
            )
          else
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(Icons.check, color: Color(0xFF34D399), size: 16),
                  SizedBox(width: 6),
                  Text('تم إرفاق وصل الحوالة CCP بنجاح', style: TextStyle(color: Colors.white, fontSize: 11)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
