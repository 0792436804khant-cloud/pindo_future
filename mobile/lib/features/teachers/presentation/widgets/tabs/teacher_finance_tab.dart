import 'package:flutter/material.dart';
import 'package:pindo_future_mobile/features/teachers/data/models/teacher_dashboard_model.dart';

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
                  'نسبة الأستاذ 80%',
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

              return Container(
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
                  ],
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
