import 'package:flutter/material.dart';
import 'algerian_payment_sheet_modal.dart';

class SubscriptionPackageModal extends StatefulWidget {
  final String cohortName;
  final String teacherName;
  final String subject;
  final String currentPackageName;

  const SubscriptionPackageModal({
    super.key,
    required this.cohortName,
    required this.teacherName,
    required this.subject,
    required this.currentPackageName,
  });

  static Future<void> show(
    BuildContext context, {
    required String cohortName,
    required String teacherName,
    required String subject,
    required String currentPackageName,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => SubscriptionPackageModal(
        cohortName: cohortName,
        teacherName: teacherName,
        subject: subject,
        currentPackageName: currentPackageName,
      ),
    );
  }

  @override
  State<SubscriptionPackageModal> createState() => _SubscriptionPackageModalState();
}

class _SubscriptionPackageModalState extends State<SubscriptionPackageModal> {
  int _selectedPackage = 0; // 0: باقة الحصص فقط, 1: باقة الحصص والمكتبة

  static const Color _brightCyan = Color(0xFF00E5FF);
  static const Color _electricPurple = Color(0xFF7C4DFF);
  static const Color _deepIndigo = Color(0xFF0F172A);

  @override
  void initState() {
    super.initState();
    if (widget.currentPackageName.contains('المكتبة')) {
      _selectedPackage = 1;
    }
  }

  void _proceedToPayment() {
    final chosenPackage = _selectedPackage == 0 ? 'باقة الحصص فقط' : 'باقة الحصص والمكتبة الرقمية';
    final price = _selectedPackage == 0 ? 2500 : 3800;

    Navigator.of(context).pop();

    AlgerianPaymentSheetModal.show(
      context,
      cohortName: widget.cohortName,
      teacherName: widget.teacherName,
      subject: widget.subject,
      packageName: chosenPackage,
      priceDzd: price,
      isQuickRenewal: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: _deepIndigo,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(color: Colors.black54, blurRadius: 25, offset: Offset(0, -6)),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle Bar
          Container(
            width: 44,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.white30,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 16),

          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _electricPurple.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.style_rounded, color: _electricPurple, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'اختر باقة الاشتراك المناسبة 🎯',
                        style: TextStyle(color: Colors.white, fontSize: 16.5, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'الفوج: ${widget.cohortName}',
                        style: const TextStyle(color: Colors.white60, fontSize: 11.5),
                      ),
                    ],
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white60, size: 20),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Option 1: باقة الحصص فقط
          _packageCard(
            index: 0,
            title: 'باقة الحصص فقط (Live Only)',
            price: '2,500 دج / شهرياً',
            badge: 'الخيار القياسي',
            badgeColor: _brightCyan,
            features: [
              '8 حصص مباشرة شهرياً مع الأستاذ (بث عالي الدقة)',
              'سبورة تفاعلية ذكية ومشاركة حلول التمارين',
              'المشاركة في محادثة ودردشة الفوج الرسمية 💬',
              'تنبيهات وإشعارات دورية قبل انطلاق كل حصة ⏰',
            ],
          ),
          const SizedBox(height: 14),

          // Option 2: باقة الحصص والمكتبة
          _packageCard(
            index: 1,
            title: 'باقة الحصص والمكتبة الرقمية (Live + Library)',
            price: '3,800 دج / شهرياً',
            badge: 'الأكثر طلباً وتفوقاً ⭐',
            badgeColor: const Color(0xFFF59E0B),
            features: [
              'كل مميزات باقة الحصص التفاعلية المباشرة كاملة',
              'وصول غير محدود لمكتبة التسجيلات المحمية بالعلامة المائية 🎬',
              'بنك نماذج فروض وامتحانات البكالوريا مع الحلول النموذجية 📝',
              'ملخصات حصرية وخرائط ذهنية قابلة للتحميل والقراءة 📚',
            ],
          ),
          const SizedBox(height: 20),

          // Continue Button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: _proceedToPayment,
              style: ElevatedButton.styleFrom(
                backgroundColor: _brightCyan,
                foregroundColor: const Color(0xFF070B14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 4,
              ),
              icon: const Icon(Icons.payment, size: 18),
              label: Text(
                'المتابعة إلى الدفع (${_selectedPackage == 0 ? '2,500 دج' : '3,800 دج'}) 💳',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _packageCard({
    required int index,
    required String title,
    required String price,
    required String badge,
    required Color badgeColor,
    required List<String> features,
  }) {
    final isSelected = _selectedPackage == index;

    return InkWell(
      onTap: () => setState(() => _selectedPackage = index),
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected ? _electricPurple.withValues(alpha: 0.15) : Colors.white.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? _brightCyan : Colors.white.withValues(alpha: 0.12),
            width: isSelected ? 1.8 : 1.0,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(color: _brightCyan.withValues(alpha: 0.20), blurRadius: 12, offset: const Offset(0, 3)),
                ]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Icon(
                        isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                        color: isSelected ? _brightCyan : Colors.white54,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          title,
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.white70,
                            fontSize: 13.5,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: badgeColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: badgeColor, width: 0.8),
                  ),
                  child: Text(
                    badge,
                    style: TextStyle(color: badgeColor, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              price,
              style: TextStyle(
                color: isSelected ? _brightCyan : Colors.white,
                fontSize: 14.5,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ...features.map((f) => Padding(
                  padding: const EdgeInsets.only(bottom: 3),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.check, color: Color(0xFF34D399), size: 14),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          f,
                          style: const TextStyle(color: Colors.white70, fontSize: 11),
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }
}
