import 'package:flutter/material.dart';
import '../../../../monetization/domain/entities/subscription_payment_receipt.dart';
import '../../../../monetization/services/subscription_payment_service.dart';

class VerifyPaymentReceiptModal extends StatefulWidget {
  final SubscriptionPaymentReceipt receipt;
  final VoidCallback? onStatusChanged;

  const VerifyPaymentReceiptModal({
    super.key,
    required this.receipt,
    this.onStatusChanged,
  });

  static Future<void> show(
    BuildContext context, {
    required SubscriptionPaymentReceipt receipt,
    VoidCallback? onStatusChanged,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => VerifyPaymentReceiptModal(
        receipt: receipt,
        onStatusChanged: onStatusChanged,
      ),
    );
  }

  @override
  State<VerifyPaymentReceiptModal> createState() => _VerifyPaymentReceiptModalState();
}

class _VerifyPaymentReceiptModalState extends State<VerifyPaymentReceiptModal> {
  static const Color _brightCyan = Color(0xFF00E5FF);
  static const Color _electricPurple = Color(0xFF7C4DFF);
  static const Color _darkSurface = Color(0xFF0F172A);

  late SubscriptionPaymentReceipt _currentReceipt;
  bool _showRejectInput = false;
  final TextEditingController _rejectionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _currentReceipt = widget.receipt;
  }

  @override
  void dispose() {
    _rejectionController.dispose();
    super.dispose();
  }

  void _approveReceipt() {
    final success = SubscriptionPaymentService.instance.approveReceipt(_currentReceipt.id);
    if (success) {
      widget.onStatusChanged?.call();
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Color(0xFF34D399), size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text('تم تأكيد الدفع وتفعيل اشتراك التلميذ (${_currentReceipt.studentName}) بنجاح!'),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF0F172A),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Color(0xFF10B981)),
          ),
        ),
      );
    }
  }

  void _rejectReceipt() {
    final reason = _rejectionController.text.trim();
    final success = SubscriptionPaymentService.instance.rejectReceipt(_currentReceipt.id, reason);
    if (success) {
      widget.onStatusChanged?.call();
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.cancel, color: Color(0xFFEF4444), size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text('تم رفض الوصل وإرسال التنبيه للتلميذ: ${_currentReceipt.studentName}'),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF0F172A),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Color(0xFFEF4444)),
          ),
        ),
      );
    }
  }

  void _openFullReceiptViewer() {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: const Color(0xFF070B14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'معاينة مكبرة للوصل • ${_currentReceipt.referenceNumber}',
                    style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white70),
                    onPressed: () => Navigator.of(ctx).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  height: 380,
                  width: double.infinity,
                  color: const Color(0xFF1E293B),
                  child: _buildReceiptVisual(),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'تأكد من مطابقة رقم العملية: ${_currentReceipt.referenceNumber}',
                style: const TextStyle(color: Colors.white60, fontSize: 11),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReceiptVisual() {
    if (_currentReceipt.receiptBytes != null) {
      return Image.memory(
        _currentReceipt.receiptBytes!,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildSimulatedReceiptCard(),
      );
    }
    return _buildSimulatedReceiptCard();
  }

  Widget _buildSimulatedReceiptCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.amber.withValues(alpha: 0.15),
            ),
            child: const Icon(Icons.receipt_long_rounded, color: Colors.amber, size: 36),
          ),
          const SizedBox(height: 12),
          Text(
            'وصل تحويل ${_currentReceipt.paymentMethod} الرسمي',
            style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(
            'المبلغ المحول: ${_currentReceipt.priceDzd} دج',
            style: const TextStyle(color: Color(0xFF10B981), fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'رقم المرجع: ${_currentReceipt.referenceNumber}',
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
          Text(
            'اسم المحوّل: ${_currentReceipt.studentName}',
            style: const TextStyle(color: Colors.white54, fontSize: 11),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.88,
      decoration: const BoxDecoration(
        color: _darkSurface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Drag Handle
          const SizedBox(height: 12),
          Center(
            child: Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Header Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _brightCyan.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.verified_user_outlined, color: _brightCyan, size: 22),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'فحص وتأكيد وصل الدفع 🧾',
                        style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'مراجعة مستند التحويل وتفعيل اشتراك التلميذ في الفوج',
                        style: TextStyle(color: Colors.white60, fontSize: 11.5),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white54),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          const Divider(color: Colors.white12, height: 24),

          // Scrollable Body
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                // 1. Student Identity Card
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: _electricPurple.withValues(alpha: 0.25),
                        child: Text(
                          _currentReceipt.studentName.isNotEmpty ? _currentReceipt.studentName[0] : 'S',
                          style: const TextStyle(color: _brightCyan, fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  _currentReceipt.studentName,
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                                ),
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: _brightCyan.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    _currentReceipt.studentId,
                                    style: const TextStyle(color: _brightCyan, fontSize: 9.5, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(_currentReceipt.studentEmail, style: const TextStyle(color: Colors.white54, fontSize: 11.5)),
                            const SizedBox(height: 2),
                            Text('الفوج: ${_currentReceipt.cohortName}', style: const TextStyle(color: Colors.white70, fontSize: 11.5)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                // 2. Transaction Details Summary Card
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: Column(
                    children: [
                      _detailRow('الباقة المختارة', _currentReceipt.packageName, textColor: _brightCyan),
                      const Divider(color: Colors.white10, height: 16),
                      _detailRow('سعر الباقة', '${_currentReceipt.priceDzd} دج'),
                      const Divider(color: Colors.white10, height: 16),
                      _detailRow('مستحقاتك المحتسبة', '+${_currentReceipt.teacherPayoutDzd} دج', textColor: const Color(0xFF10B981), isBold: true),
                      const Divider(color: Colors.white10, height: 16),
                      _detailRow('وسيلة الدفع', _currentReceipt.paymentMethod),
                      const Divider(color: Colors.white10, height: 16),
                      _detailRow('رقم المعاملة', _currentReceipt.referenceNumber),
                      const Divider(color: Colors.white10, height: 16),
                      _detailRow('الحالة الحالية', _currentReceipt.status.arabicLabel,
                          textColor: _currentReceipt.isApproved
                              ? const Color(0xFF10B981)
                              : (_currentReceipt.isRejected ? Colors.redAccent : Colors.orangeAccent)),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // 3. Receipt Image Preview (With Zoom Button)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'مستند الوصل المرفق 📷',
                      style: TextStyle(color: Colors.white, fontSize: 13.5, fontWeight: FontWeight.bold),
                    ),
                    TextButton.icon(
                      onPressed: _openFullReceiptViewer,
                      icon: const Icon(Icons.fullscreen, color: _brightCyan, size: 16),
                      label: const Text('تكبير الوصل', style: TextStyle(color: _brightCyan, fontSize: 11.5)),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                InkWell(
                  onTap: _openFullReceiptViewer,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    height: 160,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: _buildReceiptVisual(),
                        ),
                        Positioned(
                          bottom: 8,
                          left: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.6),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.zoom_in, color: Colors.white, size: 14),
                                SizedBox(width: 4),
                                Text('انقر للمعاينة الكاملة', style: TextStyle(color: Colors.white, fontSize: 10)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // 4. Rejection Input (if toggled)
                if (_showRejectInput) ...[
                  TextField(
                    controller: _rejectionController,
                    maxLines: 2,
                    style: const TextStyle(color: Colors.white, fontSize: 12.5),
                    decoration: InputDecoration(
                      hintText: 'اكتب سبب الرفض (مثال: الوصل غير مقروء، المبلغ ناقص...)',
                      hintStyle: const TextStyle(color: Colors.white38, fontSize: 11.5),
                      filled: true,
                      fillColor: const Color(0xFF1E293B),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.redAccent),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.redAccent),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _rejectReceipt,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFEF4444),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: const Text('تأكيد الرفض وإشعار الطالب', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                        ),
                      ),
                      const SizedBox(width: 10),
                      TextButton(
                        onPressed: () => setState(() => _showRejectInput = false),
                        child: const Text('إلغاء', style: TextStyle(color: Colors.white70)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],

                // 5. Actions (if still pending)
                if (_currentReceipt.isPending && !_showRejectInput) ...[
                  ElevatedButton.icon(
                    onPressed: _approveReceipt,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 4,
                    ),
                    icon: const Icon(Icons.check_circle_outline, size: 20),
                    label: const Text(
                      'تأكيد الدفع وتفعيل الاشتراك فوراً ✓',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton.icon(
                    onPressed: () => setState(() => _showRejectInput = true),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFEF4444),
                      side: const BorderSide(color: Color(0xFFEF4444)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(Icons.close_rounded, size: 18),
                    label: const Text(
                      'رفض الوصل مع ذكر السبب ❌',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ),
                ],

                if (_currentReceipt.isApproved)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.4)),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle, color: Color(0xFF34D399), size: 18),
                        SizedBox(width: 8),
                        Text(
                          'هذا الاشتراك مؤكد ومفعل مسبقاً',
                          style: TextStyle(color: Color(0xFF34D399), fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 25),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value, {Color textColor = Colors.white, bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.white60, fontSize: 12)),
        Text(
          value,
          style: TextStyle(color: textColor, fontSize: 12.5, fontWeight: isBold ? FontWeight.bold : FontWeight.w500),
        ),
      ],
    );
  }
}
