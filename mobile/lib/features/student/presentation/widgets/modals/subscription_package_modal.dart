import 'package:flutter/material.dart';
import '../../../../../core/config/platform_payment_config.dart';
import 'algerian_payment_sheet_modal.dart';

class SubscriptionPackageModal extends StatefulWidget {
  final String cohortName;
  final String teacherName;
  final String subject;
  final String currentPackageName;
  final int liveSessionsPriceDzd;
  final int libraryPriceDzd;
  final int fullBundlePriceDzd;
  final bool hasLibrary;
  final Future<void> Function(String packageType, String packageName, int priceDzd)? onPackageConfirmed;

  const SubscriptionPackageModal({
    super.key,
    required this.cohortName,
    required this.teacherName,
    required this.subject,
    required this.currentPackageName,
    this.liveSessionsPriceDzd = 2500,
    this.libraryPriceDzd = 1500,
    this.fullBundlePriceDzd = 3500,
    this.hasLibrary = true,
    this.onPackageConfirmed,
  });

  static Future<void> show(
    BuildContext context, {
    required String cohortName,
    required String teacherName,
    required String subject,
    required String currentPackageName,
    int liveSessionsPriceDzd = 2500,
    int libraryPriceDzd = 1500,
    int fullBundlePriceDzd = 3500,
    bool hasLibrary = true,
    Future<void> Function(String packageType, String packageName, int priceDzd)? onPackageConfirmed,
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
        liveSessionsPriceDzd: liveSessionsPriceDzd,
        libraryPriceDzd: libraryPriceDzd,
        fullBundlePriceDzd: fullBundlePriceDzd,
        hasLibrary: hasLibrary,
        onPackageConfirmed: onPackageConfirmed,
      ),
    );
  }

  @override
  State<SubscriptionPackageModal> createState() => _SubscriptionPackageModalState();
}

class _SubscriptionPackageModalState extends State<SubscriptionPackageModal> {
  // 0: الحصص المباشرة فقط (live_only)
  // 1: المكتبة الرقمية فقط (library_only)
  // 2: الباقة المتكاملة - الكل في واحد (full_bundle)
  int _selectedPackage = 0;

  static const Color _brightCyan = Color(0xFF00E5FF);
  static const Color _electricPurple = Color(0xFF7C4DFF);
  static const Color _deepIndigo = Color(0xFF0F172A);

  @override
  void initState() {
    super.initState();
    final lower = widget.currentPackageName.toLowerCase();
    if (widget.hasLibrary &&
        (widget.currentPackageName.contains('متكاملة') ||
            (widget.currentPackageName.contains('المكتبة') && widget.currentPackageName.contains('الحصص')) ||
            lower.contains('bundle'))) {
      _selectedPackage = 2;
    } else if (widget.hasLibrary && widget.currentPackageName.contains('المكتبة')) {
      _selectedPackage = 1;
    } else {
      _selectedPackage = 0;
    }
  }

  int get _selectedPrice {
    if (_selectedPackage == 1 && widget.hasLibrary) return widget.libraryPriceDzd;
    if (_selectedPackage == 2 && widget.hasLibrary) return widget.fullBundlePriceDzd;
    return widget.liveSessionsPriceDzd;
  }

  String get _selectedPackageType {
    if (_selectedPackage == 1 && widget.hasLibrary) return PlatformPaymentConfig.packageLibraryOnly;
    if (_selectedPackage == 2 && widget.hasLibrary) return PlatformPaymentConfig.packageFullBundle;
    return PlatformPaymentConfig.packageLiveOnly;
  }

  String get _selectedPackageTitle {
    if (_selectedPackage == 1 && widget.hasLibrary) return 'باقة المكتبة الرقمية فقط';
    if (_selectedPackage == 2 && widget.hasLibrary) return 'الباقة المتكاملة (الحصص + المكتبة الشاملة)';
    return 'باقة الحصص المباشرة والحضورية فقط';
  }

  Future<void> _proceedToPayment() async {
    final chosenPackage = _selectedPackageTitle;
    final packageType = _selectedPackageType;
    final price = _selectedPrice;

    if (widget.onPackageConfirmed != null) {
      await widget.onPackageConfirmed!(packageType, chosenPackage, price);
    }

    if (!mounted) return;
    Navigator.of(context).pop();

    AlgerianPaymentSheetModal.show(
      context,
      cohortName: widget.cohortName,
      teacherName: widget.teacherName,
      subject: widget.subject,
      packageName: chosenPackage,
      priceDzd: price,
      packageType: packageType,
      livePriceDzd: widget.liveSessionsPriceDzd,
      libraryPriceDzd: widget.libraryPriceDzd,
      isQuickRenewal: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.90,
      ),
      decoration: const BoxDecoration(
        color: _deepIndigo,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(color: Colors.black54, blurRadius: 25, offset: Offset(0, -6)),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      child: SingleChildScrollView(
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
                Expanded(
                  child: Row(
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
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'اختر باقة الاشتراك المناسبة 🎯',
                              style: TextStyle(color: Colors.white, fontSize: 16.5, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'الفوج: ${widget.cohortName}',
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(color: Colors.white60, fontSize: 11.5),
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

            // Option 0: باقة الحصص المباشرة / الحضورية فقط
            _packageCard(
              index: 0,
              title: 'باقة الحصص فقط (Live Only)',
              price: '${widget.liveSessionsPriceDzd} دج / شهرياً',
              badge: 'الحصص المباشرة',
              badgeColor: _brightCyan,
              features: const [
                'حضور الحصص التفاعلية المباشرة أو الحضورية كاملة',
                'سبورة تفاعلية ذكية ومشاركة حلول التمارين',
                'المشاركة في محادثة ودردشة الفوج الرسمية 💬',
              ],
            ),

            if (widget.hasLibrary) ...[
              const SizedBox(height: 12),
              // Option 1: باقة المكتبة الرقمية فقط
              _packageCard(
                index: 1,
                title: 'باقة المكتبة الرقمية فقط (Library Only)',
                price: '${widget.libraryPriceDzd} دج / شهرياً',
                badge: 'التسجيلات والملفات',
                badgeColor: const Color(0xFF10B981),
                features: const [
                  'وصول كامل لمكتبة الفيديوهات والتسجيلات المحمية 🎬',
                  'تحميل الملخصات، السلاسل والحلول النموذجية 📚',
                  'مثالية للمراجعة الحرة في أي وقت بدون التزام بمواعيد البث',
                ],
              ),
              const SizedBox(height: 12),
              // Option 2: الباقة المتكاملة (كل شيء في واحد)
              _packageCard(
                index: 2,
                title: 'الباقة المتكاملة — الكل في واحد (Full Bundle)',
                price: '${widget.fullBundlePriceDzd} دج / شهرياً',
                badge: 'شامل الكل • الأفضل توفيراً ⭐',
                badgeColor: const Color(0xFFF59E0B),
                features: const [
                  'كل مميزات باقة الحصص التفاعلية المباشرة كاملة',
                  'وصول غير محدود لمكتبة التسجيلات المحمية والملخصات 🎬📚',
                  'بنك الفروض والامتحانات + خصم مدمج مقارنة بالشراء المنفصل ⭐',
                ],
              ),
            ],
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
                  'المتابعة إلى الدفع ($_selectedPrice دج) 💳',
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
                ),
              ),
            ),
          ],
        ),
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
