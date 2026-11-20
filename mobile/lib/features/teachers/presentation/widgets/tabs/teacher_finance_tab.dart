import 'package:flutter/material.dart';
import 'package:pindo_future_mobile/features/teachers/data/models/teacher_dashboard_model.dart';
import '../../../../monetization/domain/entities/subscription_payment_receipt.dart';
import '../../../../monetization/services/subscription_payment_service.dart';
import '../modals/verify_payment_receipt_modal.dart';

class TeacherFinanceTab extends StatelessWidget {
  final TeacherDashboardModel dashboard;
  final VoidCallback onOpenDetailedEarnings;

  const TeacherFinanceTab({
    super.key,
    required this.dashboard,
    required this.onOpenDetailedEarnings,
  });

  static const Color _brightCyan = Color(0xFF00E5FF);
  static const Color _electricPurple = Color(0xFF7C4DFF);

  @override
  Widget build(BuildContext context) {
    final stats = dashboard.stats;
    final transactions = dashboard.recentTransactions;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '💰 إدارة المداخيل والاشتراكات',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'متابعة أرباحك الصافية، والمدفوعات المؤكدة بالدينار الجزائري',
                    style: TextStyle(fontSize: 12, color: Colors.white60),
                  ),
                ],
              ),
              IconButton(
                onPressed: onOpenDetailedEarnings,
                tooltip: 'تقرير تفصيلي',
                icon: const Icon(Icons.analytics_rounded, color: _brightCyan),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Pending Receipts Alert Banner
          _buildPendingReceiptsAlert(context),

          // Total Net Earnings Hero Card
          _buildEarningsHeroCard(context, stats),

          const SizedBox(height: 20),

          // Subscription Packages Section (Section 8 in specifications)
          _buildSubscriptionPackagesSection(context),

          const SizedBox(height: 24),

          // Recent Sales & Transactions (Section 9 in specifications)
          _buildRecentTransactionsSection(context, transactions),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildEarningsHeroCard(BuildContext context, TeacherStats stats) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.amber.shade900.withValues(alpha: 0.5),
            const Color(0xFF0F172A),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.amber.withValues(alpha: 0.4), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.amber.withValues(alpha: 0.15),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'صافي المستحقات المتاحة',
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.amber.withValues(alpha: 0.5)),
                ),
                child: const Text(
                  'رصيد أرباح معتمد ✓',
                  style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 11),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            '${stats.totalEarnings.toStringAsFixed(0)} دج',
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.hourglass_top_rounded, color: Colors.orangeAccent, size: 14),
              const SizedBox(width: 4),
              Text(
                'مبالغ تنتظر التأكيد: ${stats.pendingEarnings.toStringAsFixed(0)} دج',
                style: const TextStyle(color: Colors.orangeAccent, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton.icon(
              onPressed: () {
                _showPayoutRequestDialog(context, stats.totalEarnings);
              },
              icon: const Icon(Icons.account_balance_rounded, size: 18),
              label: const Text('طلب سحب الأرباح (بريدي موب / CCP)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber.shade700,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubscriptionPackagesSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '📦 باقات الاشتراك المتاحة للطلاب',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildPackageCard(
                title: 'باقة دروس فقط',
                subtitle: '4 حصص مباشرة شهرياً',
                price: '2,500 دج',
                color: _brightCyan,
                features: ['حضور الحصص المباشرة', 'المحادثة والسبورة'],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildPackageCard(
                title: 'دروس + مكتبة',
                subtitle: 'حصص + تسجيلات محمية',
                price: '3,500 دج',
                color: _electricPurple,
                features: ['حصص مباشرة كاملة', 'مكتبة التسجيلات والملفات'],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPackageCard({
    required String title,
    required String subtitle,
    required String price,
    required Color color,
    required List<String> features,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13.5)),
          const SizedBox(height: 2),
          Text(subtitle, style: const TextStyle(color: Colors.white60, fontSize: 11)),
          const SizedBox(height: 8),
          Text(price, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          ...features.map((f) => Padding(
                padding: const EdgeInsets.only(bottom: 3),
                child: Row(
                  children: [
                    Icon(Icons.check, size: 12, color: color),
                    const SizedBox(width: 4),
                    Text(f, style: const TextStyle(color: Colors.white70, fontSize: 10.5)),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildPendingReceiptsAlert(BuildContext context) {
    return ValueListenableBuilder<List<SubscriptionPaymentReceipt>>(
      valueListenable: SubscriptionPaymentService.instance.receiptsListenable,
      builder: (context, receipts, _) {
        final pending = receipts.where((r) => r.isPending).toList();
        if (pending.isEmpty) return const SizedBox.shrink();

        return Container(
          margin: const EdgeInsets.only(bottom: 20),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.amber.shade900.withValues(alpha: 0.35),
                const Color(0xFF1E1B4B).withValues(alpha: 0.7),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.amber.shade400.withValues(alpha: 0.7), width: 1.2),
            boxShadow: [
              BoxShadow(
                color: Colors.amber.withValues(alpha: 0.15),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.amber.withValues(alpha: 0.2),
                  border: Border.all(color: Colors.amber, width: 1.2),
                ),
                child: const Icon(Icons.mark_email_unread_rounded, color: Colors.amber, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '🔔 وصلات جديدة بانتظار التأكيد (${pending.length})',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13.5),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'وصل من: ${pending.first.studentName} (${pending.first.priceDzd} دج • ${pending.first.paymentMethod})',
                      style: const TextStyle(color: Colors.white70, fontSize: 11),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: () {
                  VerifyPaymentReceiptModal.show(context, receipt: pending.first);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  foregroundColor: const Color(0xFF0F172A),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  elevation: 2,
                ),
                icon: const Icon(Icons.receipt_long, size: 14),
                label: const Text('فحص وتفعيل', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRecentTransactionsSection(BuildContext context, List<TeacherTransactionItem> list) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '📜 سجل العمليات والمدفوعات الأخيرة',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const SizedBox(height: 12),
        if (list.isEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Center(
              child: Text('لا توجد عمليات دفع مسجلة مؤخراً.', style: TextStyle(color: Colors.white54, fontSize: 13)),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: list.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, idx) {
              final tx = list[idx];
              final isConfirmed = tx.status == 'مؤكد';

              return InkWell(
                onTap: () {
                  final all = SubscriptionPaymentService.instance.allReceipts;
                  final match = all.firstWhere(
                    (r) => r.studentName.contains(tx.studentName) || tx.studentName.contains(r.studentName),
                    orElse: () => SubscriptionPaymentReceipt(
                      id: 'TX_${tx.id}',
                      referenceNumber: 'TRX-ALG-2026-${tx.id.toString().padLeft(4, '0')}',
                      studentName: tx.studentName,
                      studentEmail: 'student@pindofuture.com',
                      studentId: 'STU_${tx.id}_2026',
                      cohortName: tx.title,
                      teacherName: dashboard.teacherProfile.name,
                      subject: 'الرياضيات',
                      packageName: 'باقة الحصص',
                      priceDzd: tx.amount.toInt(),
                      paymentMethod: 'BaridiMob',
                      status: isConfirmed ? ReceiptStatus.approved : ReceiptStatus.pending,
                      submittedAt: DateTime.now().subtract(const Duration(hours: 4)),
                    ),
                  );
                  VerifyPaymentReceiptModal.show(context, receipt: match);
                },
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: (isConfirmed ? const Color(0xFF10B981) : Colors.orangeAccent).withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isConfirmed ? Icons.verified_rounded : Icons.pending_rounded,
                          color: isConfirmed ? const Color(0xFF10B981) : Colors.orangeAccent,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(tx.studentName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                            const SizedBox(height: 2),
                            Text(tx.title, style: const TextStyle(color: Colors.white60, fontSize: 11.5)),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '+${tx.amount.toStringAsFixed(0)} دج',
                            style: const TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.bold, fontSize: 13.5),
                          ),
                          const SizedBox(height: 2),
                          Text(tx.date, style: const TextStyle(color: Colors.white38, fontSize: 10.5)),
                        ],
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white24, size: 12),
                    ],
                  ),
                ),
              );
            },
          ),
      ],
    );
  }

  void _showPayoutRequestDialog(BuildContext context, double availableAmount) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF0F172A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: const BorderSide(color: Colors.white24)),
        title: const Text('طلب سحب الأرباح', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'الرصيد المتاح للسحب: ${availableAmount.toStringAsFixed(0)} دج',
              style: const TextStyle(color: _brightCyan, fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 12),
            const Text(
              'سيتم تحويل المستحقات عبر بريدي موب (BaridiMob) أو حسابك البريدي الجاري (CCP) خلال 24 ساعة عمل.',
              style: TextStyle(color: Colors.white70, fontSize: 12, height: 1.4),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('إلغاء', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('تم إرسال طلب السحب بنجاح إلى الإدارة المالية للمنصة.'),
                  backgroundColor: Color(0xFF10B981),
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.amber.shade700),
            child: const Text('تأكيد طلب السحب', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
