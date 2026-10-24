import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/widgets/bento_card.dart';
import '../../../../core/widgets/glassmorphism.dart';
import '../../../../core/widgets/pindo_brand_logo.dart';
import '../controllers/monetization_controller.dart';

class TeacherEarningsScreen extends StatefulWidget {
  final MonetizationController monetizationController;

  const TeacherEarningsScreen({
    super.key,
    required this.monetizationController,
  });

  @override
  State<TeacherEarningsScreen> createState() => _TeacherEarningsScreenState();
}

class _TeacherEarningsScreenState extends State<TeacherEarningsScreen> {
  int _activeTabIndex = 0; // 0: Transactions, 1: Payouts

  static const Color _bgDark = Color(0xFF070B14);
  static const Color _deepIndigo = Color(0xFF311B92);
  static const Color _electricPurple = Color(0xFF7C4DFF);
  static const Color _brightCyan = Color(0xFF00E5FF);
  static const Color _neonGreen = Color(0xFF10B981);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.monetizationController.loadTeacherEarnings();
    });
  }

  void _showRequestPayoutDialog(double availableBalance) {
    final amountController = TextEditingController(text: availableBalance.toStringAsFixed(0));
    final accountController = TextEditingController(text: 'DZ00 0002 9881 1224 5');
    String payoutMethod = 'bank_transfer';
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.75),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: GlassmorphicContainer(
              borderRadius: BorderRadius.circular(24),
              borderColor: _brightCyan.withValues(alpha: 0.35),
              padding: const EdgeInsets.all(24),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const BentoIconAura(
                          icon: Icons.account_balance_wallet,
                          color: _brightCyan,
                          size: 24,
                          padding: 10,
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'Request Payout Disbursement',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.white54, size: 20),
                          onPressed: () => Navigator.of(ctx).pop(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: _neonGreen.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: _neonGreen.withValues(alpha: 0.35)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle_outline, color: _neonGreen, size: 18),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Available for withdrawal: ${availableBalance.toStringAsFixed(0)} DZD',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: _neonGreen,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    // Payout method dropdown
                    Text(
                      'Disbursement Channel',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white.withValues(alpha: 0.8)),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: payoutMethod,
                          dropdownColor: const Color(0xFF0F172A),
                          isExpanded: true,
                          style: const TextStyle(color: Colors.white, fontSize: 13),
                          icon: const Icon(Icons.keyboard_arrow_down, color: _brightCyan),
                          items: const [
                            DropdownMenuItem(value: 'bank_transfer', child: Text('Bank Wire / Direct Deposit (RIB)')),
                            DropdownMenuItem(value: 'stripe_connect', child: Text('BaridiMob / CCP Express Payout')),
                            DropdownMenuItem(value: 'paypal', child: Text('International Wire (SWIFT)')),
                          ],
                          onChanged: (val) {
                            if (val != null) setDialogState(() => payoutMethod = val);
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    // Amount field
                    Text(
                      'Payout Amount (DZD)',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white.withValues(alpha: 0.8)),
                    ),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: amountController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white.withValues(alpha: 0.06),
                        prefixIcon: const Icon(Icons.payments_outlined, color: _brightCyan, size: 20),
                        hintText: 'Enter amount',
                        hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.4)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.18)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.18)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(color: _brightCyan, width: 1.5),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      ),
                      validator: (v) {
                        final amt = double.tryParse(v ?? '');
                        if (amt == null || amt < 1000) return 'Minimum payout amount is 1,000 DZD';
                        if (amt > availableBalance) return 'Exceeds available balance of ${availableBalance.toStringAsFixed(0)} DZD';
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),
                    // Destination account
                    Text(
                      'Destination Bank Account / CCP / IBAN',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white.withValues(alpha: 0.8)),
                    ),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: accountController,
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white.withValues(alpha: 0.06),
                        prefixIcon: const Icon(Icons.credit_card, color: _electricPurple, size: 20),
                        hintText: 'e.g. DZ00 0002 9881 1224 5 or CCP 0029881122 Clé 45',
                        hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.18)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.18)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(color: _electricPurple, width: 1.5),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Account details required' : null,
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: FuturisticCapsuleButton(
                            text: 'Cancel',
                            isPrimary: false,
                            height: 44,
                            onPressed: () => Navigator.of(ctx).pop(),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FuturisticCapsuleButton(
                            text: 'Submit Payout',
                            icon: Icons.send_rounded,
                            height: 44,
                            accentColor: _brightCyan,
                            secondaryColor: _electricPurple,
                            onPressed: () async {
                              if (formKey.currentState?.validate() ?? false) {
                                Navigator.of(ctx).pop();
                                await widget.monetizationController.submitPayoutRequest(
                                  amount: double.parse(amountController.text.trim()),
                                  destinationAccount: accountController.text.trim(),
                                  payoutMethod: payoutMethod,
                                );
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.monetizationController,
      builder: (context, _) {
        final ctrl = widget.monetizationController;
        final summary = ctrl.earningsSummary;

        return Scaffold(
          backgroundColor: _bgDark,
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            flexibleSpace: ClipRRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                child: Container(
                  color: _bgDark.withValues(alpha: 0.70),
                ),
              ),
            ),
            title: const Row(
              children: [
                PindoBrandLogo(size: 26, showText: false, withGlow: true),
                SizedBox(width: 10),
                Text(
                  'Revenue & Monetization',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh, color: _brightCyan),
                tooltip: 'Refresh Financials',
                onPressed: () => ctrl.loadTeacherEarnings(),
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: Stack(
            children: [
              // Ambient futuristic glowing orbs
              Positioned(
                top: -60,
                right: -60,
                child: Container(
                  width: 260,
                  height: 260,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        _deepIndigo.withValues(alpha: 0.45),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 100,
                left: -80,
                child: Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        _electricPurple.withValues(alpha: 0.25),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),

              // Main Scrollable Content
              SafeArea(
                child: ctrl.isLoadingEarnings
                    ? const Center(child: CircularProgressIndicator(color: _brightCyan))
                    : SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 1. Revenue Share Hero Banner
                            _buildHeaderBanner(summary)
                                .animate()
                                .fadeIn(duration: 400.ms)
                                .slideY(begin: -0.1, end: 0, duration: 400.ms, curve: Curves.easeOutCubic),
                            const SizedBox(height: 20),

                            // Notification banners
                            if (ctrl.earningsError != null) ...[
                              _buildAlert(ctrl.earningsError!, isError: true),
                              const SizedBox(height: 14),
                            ],
                            if (ctrl.payoutSuccessMessage != null) ...[
                              _buildAlert(ctrl.payoutSuccessMessage!, isError: false),
                              const SizedBox(height: 14),
                            ],

                            // 2. Bento Box KPI Grid
                            _buildBentoKpiGrid(summary)
                                .animate()
                                .fadeIn(duration: 450.ms, delay: 100.ms)
                                .slideY(begin: 0.05, end: 0, duration: 450.ms, curve: Curves.easeOutCubic),
                            const SizedBox(height: 26),

                            // 3. Tab Navigation Pills
                            _buildTabSelector()
                                .animate()
                                .fadeIn(duration: 350.ms, delay: 180.ms),
                            const SizedBox(height: 18),

                            // 4. Tab Content (Transactions or Payouts)
                            if (_activeTabIndex == 0)
                              _buildTransactionsTab(ctrl)
                            else
                              _buildPayoutsTab(ctrl),

                            const SizedBox(height: 40),
                          ],
                        ),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeaderBanner(dynamic summary) {
    final available = summary?.availableBalance ?? 0.0;

    return GlassmorphicContainer(
      borderRadius: BorderRadius.circular(24),
      padding: const EdgeInsets.all(22),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          _deepIndigo.withValues(alpha: 0.70),
          _electricPurple.withValues(alpha: 0.40),
          const Color(0xFF0F172A).withValues(alpha: 0.85),
        ],
      ),
      borderColor: _brightCyan.withValues(alpha: 0.35),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isNarrow = constraints.maxWidth < 620;

          final infoSection = Row(
            children: [
              const BentoIconAura(
                icon: Icons.monetization_on_rounded,
                color: _brightCyan,
                size: 32,
                padding: 14,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Text(
                          '80% Instructor Split',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.2,
                          ),
                        ),
                        FuturisticGlowBadge(
                          label: 'ACTIVE',
                          color: _neonGreen,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '20% Platform Hosting & WebRTC SFU • Instant Settlements',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.75),
                        fontSize: 12.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );

          final payoutButton = FuturisticCapsuleButton(
            text: 'Request Payout',
            icon: Icons.account_balance_wallet_outlined,
            height: 44,
            accentColor: _brightCyan,
            secondaryColor: _electricPurple,
            onPressed: available >= 1000 ? () => _showRequestPayoutDialog(available) : null,
          );

          if (isNarrow) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                infoSection,
                const SizedBox(height: 16),
                payoutButton,
              ],
            );
          }

          return Row(
            children: [
              Expanded(child: infoSection),
              const SizedBox(width: 16),
              payoutButton,
            ],
          );
        },
      ),
    );
  }

  Widget _buildBentoKpiGrid(dynamic summary) {
    final available = (summary?.availableBalance ?? 0.0).toStringAsFixed(0);
    final gross = (summary?.grossSales ?? 0.0).toStringAsFixed(0);
    final salesCount = summary?.totalSalesCount ?? 0;
    final fees = (summary?.platformFees ?? 0.0).toStringAsFixed(0);
    final pending = (summary?.pendingPayout ?? 0.0).toStringAsFixed(0);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 720;

        final heroCard = BentoCard(
          isHero: true,
          title: '$available DZD',
          subtitle: 'Available Balance (80% net earnings ready for transfer)',
          icon: Icons.account_balance_wallet_rounded,
          accentColor: _brightCyan,
          secondaryAccent: _neonGreen,
          badgeText: 'WITHDRAWABLE',
          badgeColor: _brightCyan,
          onTap: () {
            final avail = summary?.availableBalance ?? 0.0;
            if (avail >= 1000) _showRequestPayoutDialog(avail);
          },
        );

        final grossCard = BentoCard(
          title: '$gross DZD',
          subtitle: 'Gross Masterclass Sales ($salesCount enrollments)',
          icon: Icons.trending_up_rounded,
          accentColor: _electricPurple,
          secondaryAccent: _brightCyan,
          badgeText: 'SALES',
          badgeColor: _electricPurple,
        );

        final pendingCard = BentoCard(
          title: '$pending DZD',
          subtitle: 'Pending Payout Disbursements processing via CCP/RIB',
          icon: Icons.hourglass_top_rounded,
          accentColor: const Color(0xFFF59E0B),
          secondaryAccent: const Color(0xFFEF4444),
          badgeText: 'IN TRANSIT',
          badgeColor: const Color(0xFFF59E0B),
        );

        final feesCard = BentoCard(
          title: '$fees DZD',
          subtitle: 'Platform WebRTC infrastructure & hosting fees (20%)',
          icon: Icons.cloud_done_rounded,
          accentColor: const Color(0xFF94A3B8),
          secondaryAccent: _deepIndigo,
          badgeText: 'INFRA',
          badgeColor: const Color(0xFF94A3B8),
        );

        if (isWide) {
          return Column(
            children: [
              heroCard,
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(child: grossCard),
                  const SizedBox(width: 14),
                  Expanded(child: pendingCard),
                  const SizedBox(width: 14),
                  Expanded(child: feesCard),
                ],
              ),
            ],
          );
        }

        return Column(
          children: [
            heroCard,
            const SizedBox(height: 14),
            grossCard,
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(child: pendingCard),
                const SizedBox(width: 12),
                Expanded(child: feesCard),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildTabSelector() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildTabPill(
              title: 'Sales Transactions',
              icon: Icons.receipt_long_rounded,
              isSelected: _activeTabIndex == 0,
              onTap: () => setState(() => _activeTabIndex = 0),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: _buildTabPill(
              title: 'Disbursement Payouts',
              icon: Icons.account_balance_rounded,
              isSelected: _activeTabIndex == 1,
              onTap: () => setState(() => _activeTabIndex = 1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabPill({
    required String title,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GlassmorphicScaleButton(
      onPressed: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: isSelected
              ? LinearGradient(
                  colors: [
                    _brightCyan.withValues(alpha: 0.25),
                    _electricPurple.withValues(alpha: 0.25),
                  ],
                )
              : null,
          border: isSelected
              ? Border.all(color: _brightCyan.withValues(alpha: 0.60), width: 1.2)
              : Border.all(color: Colors.transparent),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: _brightCyan.withValues(alpha: 0.20),
                    blurRadius: 12,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 17,
              color: isSelected ? _brightCyan : Colors.white60,
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? Colors.white : Colors.white60,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionsTab(MonetizationController ctrl) {
    if (ctrl.transactions.isEmpty) {
      return _buildEmptyState(
        'No course sales transactions recorded yet.',
        Icons.receipt_outlined,
      );
    }

    return Column(
      children: ctrl.transactions.asMap().entries.map((entry) {
        final idx = entry.key;
        final t = entry.value;

        return GlassmorphicContainer(
          borderRadius: BorderRadius.circular(18),
          borderColor: Colors.white.withValues(alpha: 0.12),
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const BentoIconAura(
                icon: Icons.arrow_downward_rounded,
                color: _neonGreen,
                size: 20,
                padding: 10,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t.courseTitle,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${t.orderNumber} • Student: ${t.studentName}',
                      style: TextStyle(fontSize: 11.5, color: Colors.white.withValues(alpha: 0.65)),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      t.createdAt.split('T').first,
                      style: TextStyle(fontSize: 10.5, color: Colors.white.withValues(alpha: 0.45)),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '+${t.netAmount.toStringAsFixed(0)} DZD',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: _neonGreen,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Gross ${t.grossAmount.toStringAsFixed(0)} DZD',
                    style: TextStyle(fontSize: 10.5, color: Colors.white.withValues(alpha: 0.5)),
                  ),
                ],
              ),
            ],
          ),
        )
            .animate()
            .fadeIn(duration: 300.ms, delay: (idx * 50).ms)
            .slideY(begin: 0.05, end: 0, duration: 300.ms, delay: (idx * 50).ms);
      }).toList(),
    );
  }

  Widget _buildPayoutsTab(MonetizationController ctrl) {
    if (ctrl.payouts.isEmpty) {
      return _buildEmptyState(
        'No payout disbursement requests yet.',
        Icons.account_balance_wallet_outlined,
      );
    }

    return Column(
      children: ctrl.payouts.asMap().entries.map((entry) {
        final idx = entry.key;
        final p = entry.value;
        final isCompleted = p.status == 'completed';
        final statusColor = isCompleted ? _neonGreen : const Color(0xFFF59E0B);

        return GlassmorphicContainer(
          borderRadius: BorderRadius.circular(18),
          borderColor: statusColor.withValues(alpha: 0.25),
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              BentoIconAura(
                icon: isCompleted ? Icons.check_circle_outline_rounded : Icons.hourglass_top_rounded,
                color: statusColor,
                size: 20,
                padding: 10,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      p.payoutReference,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Channel: ${p.payoutMethod.toUpperCase()} • ${p.destinationAccount ?? "Account on file"}',
                      style: TextStyle(fontSize: 11.5, color: Colors.white.withValues(alpha: 0.65)),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      p.createdAt.split('T').first,
                      style: TextStyle(fontSize: 10.5, color: Colors.white.withValues(alpha: 0.45)),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '-${p.amount.toStringAsFixed(0)} DZD',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFEF4444),
                    ),
                  ),
                  const SizedBox(height: 4),
                  FuturisticGlowBadge(
                    label: p.status.toUpperCase(),
                    color: statusColor,
                  ),
                ],
              ),
            ],
          ),
        )
            .animate()
            .fadeIn(duration: 300.ms, delay: (idx * 50).ms)
            .slideY(begin: 0.05, end: 0, duration: 300.ms, delay: (idx * 50).ms);
      }).toList(),
    );
  }

  Widget _buildEmptyState(String msg, IconData icon) {
    return GlassmorphicContainer(
      borderRadius: BorderRadius.circular(20),
      padding: const EdgeInsets.all(36),
      borderColor: Colors.white.withValues(alpha: 0.12),
      child: Center(
        child: Column(
          children: [
            BentoIconAura(
              icon: icon,
              color: Colors.white38,
              size: 32,
              padding: 16,
            ),
            const SizedBox(height: 16),
            Text(
              msg,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.white.withValues(alpha: 0.70)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlert(String message, {required bool isError}) {
    final alertColor = isError ? const Color(0xFFEF4444) : _neonGreen;

    return GlassmorphicContainer(
      borderRadius: BorderRadius.circular(14),
      borderColor: alertColor.withValues(alpha: 0.4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      gradient: LinearGradient(
        colors: [
          alertColor.withValues(alpha: 0.20),
          alertColor.withValues(alpha: 0.08),
        ],
      ),
      child: Row(
        children: [
          Icon(
            isError ? Icons.error_outline : Icons.check_circle_outline,
            color: alertColor,
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize: 12.5,
                color: Colors.white.withValues(alpha: 0.95),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
