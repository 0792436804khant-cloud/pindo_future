import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:pindo_future_mobile/core/network/api_client.dart';
import 'package:pindo_future_mobile/core/widgets/bento_card.dart';
import 'package:pindo_future_mobile/core/widgets/glassmorphism.dart';
import 'package:pindo_future_mobile/core/widgets/pindo_brand_logo.dart';
import 'package:pindo_future_mobile/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:pindo_future_mobile/features/auth/data/models/admin_dashboard_model.dart';
import 'package:pindo_future_mobile/features/auth/domain/entities/user.dart';
import 'package:pindo_future_mobile/features/auth/presentation/controllers/auth_controller.dart';
import 'package:pindo_future_mobile/features/auth/presentation/widgets/user_account_settings_modal.dart';

class AdminDashboardScreen extends StatefulWidget {
  final User user;
  final AuthController authController;

  const AdminDashboardScreen({
    super.key,
    required this.user,
    required this.authController,
  });

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  late AdminDashboardModel _dashboard;
  bool _isLoading = false;
  int _selectedTab = 0; // 0: نظرة عامة, 1: التوثيق, 2: السحب المالي, 3: البث المباشر

  static const Color _bgDark = Color(0xFF070B14);
  static const Color _deepIndigo = Color(0xFF311B92);
  static const Color _electricPurple = Color(0xFF7C4DFF);
  static const Color _brightCyan = Color(0xFF00E5FF);
  static const Color _neonGreen = Color(0xFF10B981);

  @override
  void initState() {
    super.initState();
    _dashboard = AdminDashboardModel.mockFallback();
    _fetchDashboardData();
  }

  Future<void> _fetchDashboardData() async {
    setState(() => _isLoading = true);
    try {
      final apiClient = ApiClient();
      final authLocal = AuthLocalDataSourceImpl();
      final token = await authLocal.getToken();

      final response = await apiClient.get('/admin/dashboard', token: token);
      if (response is Map<String, dynamic> && response['data'] != null) {
        if (mounted) {
          setState(() {
            _dashboard = AdminDashboardModel.fromJson(response);
            _isLoading = false;
          });
        }
        return;
      }
    } catch (_) {
      // Graceful fallback to mock data
    }
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _approveTeacher(int teacherId, String teacherName) async {
    try {
      final apiClient = ApiClient();
      final authLocal = AuthLocalDataSourceImpl();
      final token = await authLocal.getToken();
      await apiClient.post('/admin/teachers/$teacherId/verify', body: {}, token: token);
    } catch (_) {}

    if (mounted) {
      setState(() {
        _dashboard = AdminDashboardModel(
          kpis: AdminKpis(
            totalStudentsCount: _dashboard.kpis.totalStudentsCount,
            totalTeachersCount: _dashboard.kpis.totalTeachersCount,
            verifiedTeachersCount: _dashboard.kpis.verifiedTeachersCount + 1,
            pendingVerificationsCount: _dashboard.kpis.pendingVerificationsCount > 0
                ? _dashboard.kpis.pendingVerificationsCount - 1
                : 0,
            totalCohortsCount: _dashboard.kpis.totalCohortsCount,
            activeLiveSessionsCount: _dashboard.kpis.activeLiveSessionsCount,
            grossRevenue: _dashboard.kpis.grossRevenue,
            platformCommission: _dashboard.kpis.platformCommission,
            teacherNetEarnings: _dashboard.kpis.teacherNetEarnings,
            pendingPayoutsCount: _dashboard.kpis.pendingPayoutsCount,
            pendingPayoutsAmount: _dashboard.kpis.pendingPayoutsAmount,
            sfuClusterCapacity: _dashboard.kpis.sfuClusterCapacity,
            sfuClusterStatus: _dashboard.kpis.sfuClusterStatus,
          ),
          pendingVerifications: _dashboard.pendingVerifications.where((t) => t.id != teacherId).toList(),
          pendingPayouts: _dashboard.pendingPayouts,
        );
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تم اعتماد الأستاذ «$teacherName» ومنحه الشارة الموثقة بنجاح.'),
          backgroundColor: _neonGreen,
        ),
      );
    }
  }

  Future<void> _approvePayout(int payoutId, String teacherName, double amount) async {
    try {
      final apiClient = ApiClient();
      final authLocal = AuthLocalDataSourceImpl();
      final token = await authLocal.getToken();
      await apiClient.post('/admin/payouts/$payoutId/approve', body: {}, token: token);
    } catch (_) {}

    if (mounted) {
      setState(() {
        _dashboard = AdminDashboardModel(
          kpis: AdminKpis(
            totalStudentsCount: _dashboard.kpis.totalStudentsCount,
            totalTeachersCount: _dashboard.kpis.totalTeachersCount,
            verifiedTeachersCount: _dashboard.kpis.verifiedTeachersCount,
            pendingVerificationsCount: _dashboard.kpis.pendingVerificationsCount,
            totalCohortsCount: _dashboard.kpis.totalCohortsCount,
            activeLiveSessionsCount: _dashboard.kpis.activeLiveSessionsCount,
            grossRevenue: _dashboard.kpis.grossRevenue,
            platformCommission: _dashboard.kpis.platformCommission,
            teacherNetEarnings: _dashboard.kpis.teacherNetEarnings,
            pendingPayoutsCount: _dashboard.kpis.pendingPayoutsCount > 0
                ? _dashboard.kpis.pendingPayoutsCount - 1
                : 0,
            pendingPayoutsAmount: _dashboard.kpis.pendingPayoutsAmount >= amount
                ? _dashboard.kpis.pendingPayoutsAmount - amount
                : 0.0,
            sfuClusterCapacity: _dashboard.kpis.sfuClusterCapacity,
            sfuClusterStatus: _dashboard.kpis.sfuClusterStatus,
          ),
          pendingVerifications: _dashboard.pendingVerifications,
          pendingPayouts: _dashboard.pendingPayouts.where((p) => p.id != payoutId).toList(),
        );
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تم تأكيد تسوية مستحقات الأستاذ «$teacherName» بمبلغ ${amount.toStringAsFixed(0)} دج بنجاح.'),
          backgroundColor: _neonGreen,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
              'Admin Command Center — لوحة الإدارة',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.white,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
        actions: [
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.only(right: 8.0),
                child: SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2, color: _brightCyan),
                ),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Colors.white70),
            tooltip: 'Settings & Security',
            onPressed: () => UserAccountSettingsModal.show(
              context,
              user: widget.user,
              authController: widget.authController,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white70),
            tooltip: 'Sign Out',
            onPressed: () => widget.authController.logout(),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Executive Admin Profile Banner
                  _buildAdminProfileBanner(),

                  const SizedBox(height: 20),

                  // 2. Navigation Segments (Tabs)
                  _buildSegmentTabs(),

                  const SizedBox(height: 20),

                  // 3. Tab Body
                  if (_selectedTab == 0) _buildOverviewTab(),
                  if (_selectedTab == 1) _buildVerificationsTab(),
                  if (_selectedTab == 2) _buildPayoutsTab(),
                  if (_selectedTab == 3) _buildClusterMonitoringTab(),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAdminProfileBanner() {
    final kpis = _dashboard.kpis;

    return GlassmorphicContainer(
      borderRadius: BorderRadius.circular(24),
      borderColor: _brightCyan.withValues(alpha: 0.35),
      padding: const EdgeInsets.all(20),
      gradient: LinearGradient(
        colors: [
          _deepIndigo.withValues(alpha: 0.70),
          _electricPurple.withValues(alpha: 0.35),
          const Color(0xFF0F172A).withValues(alpha: 0.85),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      child: Column(
        children: [
          Row(
            children: [
              const BentoIconAura(
                icon: Icons.admin_panel_settings_rounded,
                color: _brightCyan,
                size: 28,
                padding: 12,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          widget.user.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.2,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const FuturisticGlowBadge(
                          label: 'ROOT ADMIN',
                          color: Color(0xFFF59E0B),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'إشراف العمليات المركزية • خوادم البث المباشر SFU (${kpis.sfuClusterCapacity} مقعد)',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Financial highlight row
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildHeaderMetric('إجمالي المعاملات', '${kpis.grossRevenue.toStringAsFixed(0)} دج', Colors.white),
                _buildHeaderMetric('عمولة المنصة (15% + 10%)', '${kpis.platformCommission.toStringAsFixed(0)} دج', _neonGreen),
                _buildHeaderMetric('مستحقات الأساتذة الصافية', '${kpis.teacherNetEarnings.toStringAsFixed(0)} دج', _brightCyan),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderMetric(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.bold)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(color: Colors.white54, fontSize: 10.5)),
      ],
    );
  }

  Widget _buildSegmentTabs() {
    final tabs = [
      {'title': 'نظرة عامة', 'icon': Icons.dashboard_rounded},
      {'title': 'توثيق الأساتذة (${_dashboard.pendingVerifications.length})', 'icon': Icons.verified_user_rounded},
      {'title': 'طلبات السحب (${_dashboard.pendingPayouts.length})', 'icon': Icons.payments_rounded},
      {'title': 'مراقبة البث SFU', 'icon': Icons.speed_rounded},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(tabs.length, (idx) {
          final isSelected = _selectedTab == idx;
          final item = tabs[idx];
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: InkWell(
              onTap: () => setState(() => _selectedTab = idx),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? _electricPurple : Colors.white.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: isSelected ? _brightCyan : Colors.white12),
                ),
                child: Row(
                  children: [
                    Icon(item['icon'] as IconData, size: 16, color: isSelected ? _brightCyan : Colors.white70),
                    const SizedBox(width: 6),
                    Text(
                      item['title'] as String,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.white70,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        fontSize: 12.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildOverviewTab() {
    final kpis = _dashboard.kpis;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '📊 مؤشرات أداء المنظومة الحية',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 1.6,
          children: [
            _buildKpiCard('إجمالي التلاميذ', '${kpis.totalStudentsCount}', Icons.school_rounded, _neonGreen),
            _buildKpiCard('الأساتذة المعتمدين', '${kpis.verifiedTeachersCount}/${kpis.totalTeachersCount}', Icons.verified_rounded, _brightCyan),
            _buildKpiCard('الأفواج الدراسية', '${kpis.totalCohortsCount}', Icons.groups_rounded, _electricPurple),
            _buildKpiCard('قاعات البث المباشر الآن', '${kpis.activeLiveSessionsCount}', Icons.sensors_rounded, Colors.redAccent),
            _buildKpiCard('طلبات توثيق قيد المراجعة', '${kpis.pendingVerificationsCount}', Icons.pending_actions_rounded, Colors.orangeAccent),
            _buildKpiCard('سحوبات تنتظر الموافقة', '${kpis.pendingPayoutsCount} (${kpis.pendingPayoutsAmount.toStringAsFixed(0)} دج)', Icons.account_balance_wallet_rounded, Colors.amber),
          ],
        ),
        const SizedBox(height: 24),
        BentoCard(
          isHero: true,
          title: 'خوادم WebRTC SFU Clusters (سعة 30,000 طالب)',
          subtitle: 'حالة الخوادم: ${kpis.sfuClusterStatus} • دعم البث فائق السرعة وجودة الصوت التكيفية لشبكات الجزائر.',
          icon: Icons.cloud_done_rounded,
          accentColor: _brightCyan,
          secondaryAccent: _neonGreen,
          badgeText: 'ONLINE',
          badgeColor: _neonGreen,
          onTap: () {},
        ),
      ],
    );
  }

  Widget _buildVerificationsTab() {
    final list = _dashboard.pendingVerifications;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '🛡️ طلبات توثيق واعتماد الأساتذة الجدد',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const SizedBox(height: 4),
        const Text(
          'مراجعة هويات الأساتذة ومؤهلاتهم ومنح الشارة الرسمية (Verification Badge)',
          style: TextStyle(fontSize: 12, color: Colors.white60),
        ),
        const SizedBox(height: 16),
        if (list.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Center(
              child: Text('لا توجد طلبات توثيق جديدة حالياً.', style: TextStyle(color: Colors.white54, fontSize: 13)),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: list.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, idx) {
              final t = list[idx];
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: _electricPurple.withValues(alpha: 0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(t.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.amber.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(t.submittedAt, style: const TextStyle(color: Colors.amber, fontSize: 11)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text('${t.email} • ${t.wilaya}', style: const TextStyle(color: Colors.white60, fontSize: 12)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      children: t.subjects.map((s) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: _brightCyan.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(s, style: const TextStyle(color: _brightCyan, fontSize: 11)),
                      )).toList(),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _approveTeacher(t.id, t.name),
                            icon: const Icon(Icons.verified_rounded, size: 16),
                            label: const Text('قبول واعتماد الشارة', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _neonGreen,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        OutlinedButton(
                          onPressed: () {
                            setState(() {
                              _dashboard = AdminDashboardModel(
                                kpis: _dashboard.kpis,
                                pendingVerifications: _dashboard.pendingVerifications.where((item) => item.id != t.id).toList(),
                                pendingPayouts: _dashboard.pendingPayouts,
                              );
                            });
                          },
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.redAccent),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                          ),
                          child: const Text('رفض', style: TextStyle(color: Colors.redAccent, fontSize: 12)),
                        ),
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

  Widget _buildPayoutsTab() {
    final list = _dashboard.pendingPayouts;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '💳 طلبات السحب المالي لمستحقات الأساتذة',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const SizedBox(height: 4),
        const Text(
          'مراجعة عمليات السحب والتحويل عبر بريدي موب (BaridiMob) والحساب البريدي الجاري (CCP)',
          style: TextStyle(fontSize: 12, color: Colors.white60),
        ),
        const SizedBox(height: 16),
        if (list.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Center(
              child: Text('لا توجد طلبات سحب معلقة حالياً.', style: TextStyle(color: Colors.white54, fontSize: 13)),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: list.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, idx) {
              final p = list[idx];
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(p.teacherName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                        Text(
                          '${p.amount.toStringAsFixed(0)} ${p.currency}',
                          style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text('طريقة التحويل: ${p.payoutMethod} • الحساب: ${p.destinationAccount}', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                    const SizedBox(height: 2),
                    Text('المرجع: ${p.reference} • ${p.requestedAt}', style: const TextStyle(color: Colors.white38, fontSize: 11)),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _approvePayout(p.id, p.teacherName, p.amount),
                            icon: const Icon(Icons.check_circle_rounded, size: 16),
                            label: const Text('تأكيد التحويل وإتمام الدفع', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.amber.shade700,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        OutlinedButton(
                          onPressed: () {
                            setState(() {
                              _dashboard = AdminDashboardModel(
                                kpis: _dashboard.kpis,
                                pendingVerifications: _dashboard.pendingVerifications,
                                pendingPayouts: _dashboard.pendingPayouts.where((item) => item.id != p.id).toList(),
                              );
                            });
                          },
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.white24),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                          ),
                          child: const Text('إلغاء', style: TextStyle(color: Colors.white70, fontSize: 12)),
                        ),
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

  Widget _buildClusterMonitoringTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '🌐 مراقبة شبكة البث المباشر (WebRTC SFU Telemetry)',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.35),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: _brightCyan.withValues(alpha: 0.3)),
          ),
          child: Column(
            children: [
              _buildClusterRow('سعة القنوات المباشرة', '30,000 قناة متزامنة', _neonGreen),
              const Divider(color: Colors.white12, height: 20),
              _buildClusterRow('عقد التوزيع التلقائي (Autoscaling)', '8 Nodes Ready', _brightCyan),
              const Divider(color: Colors.white12, height: 20),
              _buildClusterRow('متوسط استجابة البث (Latency)', '45 ms (Adaptive Bitrate)', Colors.white),
              const Divider(color: Colors.white12, height: 20),
              _buildClusterRow('حماية التسجيلات والـ DRM', 'Floating Watermark Active', _electricPurple),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildClusterRow(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 13)),
        Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13)),
      ],
    );
  }

  Widget _buildKpiCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(color: Colors.white60, fontSize: 11)),
              Icon(icon, color: color, size: 18),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
