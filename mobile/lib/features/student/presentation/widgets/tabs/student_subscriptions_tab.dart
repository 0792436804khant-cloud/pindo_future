import 'package:flutter/material.dart';
import 'package:pindo_future_mobile/features/student/data/models/student_dashboard_model.dart';
import 'package:pindo_future_mobile/features/monetization/services/subscription_payment_service.dart';
import 'package:pindo_future_mobile/features/monetization/domain/entities/subscription_payment_receipt.dart';
import '../modals/subscription_package_modal.dart';
import '../modals/algerian_payment_sheet_modal.dart';

class StudentSubscriptionsTab extends StatelessWidget {
  final StudentDashboardData dashboardData;
  final VoidCallback onOpenCohortsExplorer;

  const StudentSubscriptionsTab({
    super.key,
    required this.dashboardData,
    required this.onOpenCohortsExplorer,
  });

  static const Color _brightCyan = Color(0xFF00E5FF);
  static const Color _electricPurple = Color(0xFF7C4DFF);
  static const Color _deepIndigo = Color(0xFF311B92);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<SubscriptionPaymentReceipt>>(
      valueListenable: SubscriptionPaymentService.instance.receiptsListenable,
      builder: (context, receipts, _) {
        final pendingReceipts = receipts.where((r) => r.isPending).toList();

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 90),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              const Text(
                'اشتراكاتي وباقات الدفع 💳',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'إدارة انخراطاتك مع الأساتذة، تجديد الباقات، ودفع الاشتراكات بالدينار الجزائري.',
                style: TextStyle(color: Colors.white60, fontSize: 12, height: 1.4),
              ),
              const SizedBox(height: 16),

              // Pending Subscriptions Banner (Live Reactive Sync)
              if (pendingReceipts.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFFD97706).withValues(alpha: 0.30),
                        const Color(0xFFB45309).withValues(alpha: 0.20),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFF59E0B)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.hourglass_top_rounded, color: Color(0xFFFBBF24), size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'طلب اشتراك قيد المراجعة ⏱️ (${pendingReceipts.length})',
                            style: const TextStyle(color: Color(0xFFFDE68A), fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'تم استلام وصل الدفع بنجاح (${pendingReceipts.first.referenceNumber} - ${pendingReceipts.first.packageName}). سيتم تفعيل الحصص تلقائياً فور مصادقة الأستاذ على التحويل.',
                        style: const TextStyle(color: Colors.white70, fontSize: 11.5, height: 1.4),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Informational Tip
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _deepIndigo.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: _brightCyan.withValues(alpha: 0.25)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.lightbulb_outline, color: _brightCyan, size: 20),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'تجديد الاشتراك يقوم بتجديد باقتك الحالية مباشرة. لتغيير نوع الباقة (من حصص فقط إلى حصص ومكتبة)، اضغط على "دفع الاشتراك / تغيير الباقة".',
                        style: TextStyle(color: Colors.white70, fontSize: 11, height: 1.35),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Enrolled Subscriptions
              const Text(
                'الأفواج والاشتراكات المنخرط بها:',
                style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              if (dashboardData.subscriptions.activeCohortsCount == 0 && dashboardData.nextSession == null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.04),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.credit_card_off_rounded, color: Colors.white.withValues(alpha: 0.35), size: 36),
                      const SizedBox(height: 12),
                      const Text(
                        'لا توجد اشتراكات نشطة حالياً',
                        style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'تصفح قائمة الأساتذة والأفواج النموذجية المعتمدة للاشتراك في باقات الحصص المباشرة والمكتبة التعليمية.',
                        style: TextStyle(color: Colors.white60, fontSize: 12, height: 1.4),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 18),
                      ElevatedButton.icon(
                        onPressed: onOpenCohortsExplorer,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _brightCyan,
                          foregroundColor: const Color(0xFF070B14),
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        icon: const Icon(Icons.explore_outlined, size: 16),
                        label: const Text('استكشاف الأفواج والاشتراك الآن', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5)),
                      ),
                    ],
                  ),
                )
              else if (dashboardData.nextSession != null)
                _subscriptionCard(
                  context,
                  cohortName: dashboardData.nextSession!.cohortName,
                  teacherName: dashboardData.nextSession!.teacherName,
                  subject: dashboardData.nextSession!.subject,
                  packageName: dashboardData.subscriptions.packageName,
                  priceDzd: 2500,
                  remainingCredits: dashboardData.subscriptions.remainingCredits,
                  totalCredits: 8,
                  expiresAt: dashboardData.subscriptions.expiresAt.isNotEmpty ? dashboardData.subscriptions.expiresAt : 'اشتراك مفعل',
                  status: 'فعال ومفعل ✓',
                  statusColor: const Color(0xFF10B981),
                ),
              const SizedBox(height: 20),

              // Explore Additional Cohorts
              Center(
                child: OutlinedButton.icon(
                  onPressed: onOpenCohortsExplorer,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _brightCyan,
                    side: const BorderSide(color: _brightCyan),
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.person_add_alt_1_outlined, size: 18),
                  label: const Text('الانخراط والاشتراك مع أستاذ جديد'),
                ),
              ),
              const SizedBox(height: 24),

              // Payment History
              const Text(
                'سجل عمليات الدفع والاشتراك السابقة:',
                style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),

              if (receipts.isEmpty) ...[
                _paymentHistoryItem(
                  date: '2026-10-20',
                  cohort: 'فوج التفوق في العلوم الفيزيائية',
                  package: 'باقة الحصص والمكتبة',
                  amount: '3,800 دج',
                  method: 'بريدي موب (BaridiMob)',
                  status: 'مقبول ومفعل',
                  refNumber: 'REF-ALG-8891',
                  statusColor: const Color(0xFF10B981),
                ),
                _paymentHistoryItem(
                  date: '2026-10-15',
                  cohort: 'فوج النخبة للبكالوريا — الرياضيات',
                  package: 'باقة الحصص فقط',
                  amount: '2,500 دج',
                  method: 'البطاقة الذهبية CIB',
                  status: 'مقبول ومفعل',
                  refNumber: 'REF-ALG-7420',
                  statusColor: const Color(0xFF10B981),
                ),
              ] else ...[
                for (final r in receipts)
                  _paymentHistoryItem(
                    date: '${r.submittedAt.year}-${r.submittedAt.month.toString().padLeft(2, '0')}-${r.submittedAt.day.toString().padLeft(2, '0')}',
                    cohort: r.cohortName,
                    package: r.packageName,
                    amount: '${r.priceDzd} دج',
                    method: r.paymentMethod,
                    status: r.isApproved
                        ? 'مقبول ومفعل ✓'
                        : (r.isRejected ? 'مرفوض ❌' : 'قيد المراجعة ⏱️'),
                    refNumber: r.referenceNumber,
                    statusColor: r.isApproved
                        ? const Color(0xFF10B981)
                        : (r.isRejected ? const Color(0xFFEF4444) : const Color(0xFFF59E0B)),
                  ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _subscriptionCard(
    BuildContext context, {
    required String cohortName,
    required String teacherName,
    required String subject,
    required String packageName,
    required int priceDzd,
    required int remainingCredits,
    required int totalCredits,
    required String expiresAt,
    required String status,
    required Color statusColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A).withValues(alpha: 0.80),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: Status & Credits
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: statusColor),
                ),
                child: Text(
                  status,
                  style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
              Text(
                'الرصيد المتبقي: $remainingCredits / $totalCredits حصص',
                style: const TextStyle(color: _brightCyan, fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Cohort Title & Details
          Text(
            cohortName,
            style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 3),
          Text(
            'المادة: $subject • الأستاذ: $teacherName',
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
          const SizedBox(height: 8),

          // Current Package Info Pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(Icons.inventory_2_outlined, color: Color(0xFFFBBF24), size: 14),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'الباقة الحالية: $packageName ($priceDzd دج)',
                    style: const TextStyle(color: Color(0xFFFDE68A), fontSize: 11.5, fontWeight: FontWeight.w600),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'تاريخ انتهاء الصلاحية: $expiresAt',
            style: const TextStyle(color: Colors.white54, fontSize: 11),
          ),
          const SizedBox(height: 14),

          // The Two Essential Action Buttons
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              // Action 1: دفع الاشتراك / تغيير الباقة
              SizedBox(
                width: 175,
                child: OutlinedButton.icon(
                  onPressed: () => SubscriptionPackageModal.show(
                    context,
                    cohortName: cohortName,
                    teacherName: teacherName,
                    subject: subject,
                    currentPackageName: packageName,
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: _brightCyan, width: 1.2),
                    backgroundColor: _brightCyan.withValues(alpha: 0.08),
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  icon: const Icon(Icons.credit_card_outlined, size: 15, color: _brightCyan),
                  label: const Text(
                    'دفع الاشتراك / تغيير الباقة',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
              ),

              // Action 2: تجديد الاشتراك
              SizedBox(
                width: 140,
                child: ElevatedButton.icon(
                  onPressed: () => AlgerianPaymentSheetModal.show(
                    context,
                    cohortName: cohortName,
                    teacherName: teacherName,
                    subject: subject,
                    packageName: packageName,
                    priceDzd: priceDzd,
                    isQuickRenewal: true,
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _electricPurple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    elevation: 3,
                  ),
                  icon: const Icon(Icons.bolt, size: 16),
                  label: const Text(
                    'تجديد الاشتراك ⚡',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _paymentHistoryItem({
    required String date,
    required String cohort,
    required String package,
    required String amount,
    required String method,
    required String status,
    required String refNumber,
    Color statusColor = const Color(0xFF10B981),
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(cohort, style: const TextStyle(color: Colors.white, fontSize: 12.5, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Text('$package • $method • $date', style: const TextStyle(color: Colors.white60, fontSize: 10.5)),
                Text('المرجع: $refNumber', style: const TextStyle(color: Colors.white38, fontSize: 9.5)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(amount, style: const TextStyle(color: _brightCyan, fontSize: 12.5, fontWeight: FontWeight.bold)),
              const SizedBox(height: 2),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: statusColor == const Color(0xFF10B981) ? const Color(0xFF34D399) : statusColor,
                    fontSize: 9.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
