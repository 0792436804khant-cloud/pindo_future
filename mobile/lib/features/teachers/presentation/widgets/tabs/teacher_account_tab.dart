import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pindo_future_mobile/features/teachers/data/models/teacher_dashboard_model.dart';
import '../modals/teacher_support_modal.dart';

class TeacherAccountTab extends StatelessWidget {
  final TeacherDashboardModel dashboard;
  final VoidCallback onEditProfile;
  final VoidCallback onOpenAccountSettings;
  final VoidCallback onSignOut;
  final VoidCallback onPreviewShowcase;

  const TeacherAccountTab({
    super.key,
    required this.dashboard,
    required this.onEditProfile,
    required this.onOpenAccountSettings,
    required this.onSignOut,
    required this.onPreviewShowcase,
  });

  static const Color _brightCyan = Color(0xFF00E5FF);
  static const Color _electricPurple = Color(0xFF7C4DFF);
  static const Color _deepIndigo = Color(0xFF311B92);

  @override
  Widget build(BuildContext context) {
    final profile = dashboard.teacherProfile;
    final deepLink = 'https://pindofuture.com/teacher/${profile.teacherId}';

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          const Text(
            '👤 حساب الأستاذ والمنصات',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 2),
          const Text(
            'الملف الشخصي الاحترافي، الروابط العميقة، والإعدادات',
            style: TextStyle(fontSize: 12, color: Colors.white60),
          ),

          const SizedBox(height: 20),

          // Profile Card
          _buildProfileCard(context, profile),

          const SizedBox(height: 20),

          // External Platforms & Deep Link (Section 12 in specifications)
          _buildDeepLinkSection(context, deepLink),

          const SizedBox(height: 20),

          // Reports & Analytics Preview (Section 14 in specifications)
          _buildAnalyticsPreviewCard(context),

          const SizedBox(height: 20),

          // Settings & Support Tiles (Section 15 & 16 in specifications)
          _buildActionsMenu(context),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildProfileCard(BuildContext context, TeacherProfileInfo profile) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A).withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _electricPurple.withValues(alpha: 0.4), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(2.5),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: _brightCyan, width: 2),
                ),
                child: CircleAvatar(
                  radius: 30,
                  backgroundColor: _deepIndigo,
                  backgroundImage: profile.avatarUrl != null ? NetworkImage(profile.avatarUrl!) : null,
                  child: profile.avatarUrl == null
                      ? Text(profile.name.isNotEmpty ? profile.name[0] : 'أ', style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold))
                      : null,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            profile.name,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (profile.isVerified) ...[
                          const SizedBox(width: 6),
                          const Icon(Icons.verified_rounded, color: _brightCyan, size: 18),
                        ],
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(profile.email, style: const TextStyle(color: Colors.white60, fontSize: 12)),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.amber.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'خبرة ${profile.yearsOfExperience} سنوات',
                        style: const TextStyle(color: Colors.amber, fontSize: 10.5, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Subjects & Levels chips
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              ...profile.subjects.map((s) => _buildChip(s, _brightCyan)),
              ...profile.levels.map((l) => _buildChip(l, _electricPurple)),
            ],
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onEditProfile,
                  icon: const Icon(Icons.edit_rounded, size: 16, color: _brightCyan),
                  label: const Text('تعديل الملف والشهادات', style: TextStyle(color: Colors.white, fontSize: 12)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: _brightCyan),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onPreviewShowcase,
                  icon: const Icon(Icons.preview_rounded, size: 16),
                  label: const Text('معاينة الواجهة العامة', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _electricPurple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildDeepLinkSection(BuildContext context, String deepLink) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white12),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.link_rounded, color: _brightCyan, size: 20),
              SizedBox(width: 8),
              Text(
                'الرابط الذكي لموقعك وعروضك الخارجية',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'شارك هذا الرابط في صفحتك على الفيسبوك أو الإنستغرام أو موقعك الخاص؛ سيفتح التطبيق مباشرة للطلاب وينقلهم لدروسك.',
            style: TextStyle(color: Colors.white60, fontSize: 11.5, height: 1.4),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    deepLink,
                    style: const TextStyle(color: _brightCyan, fontSize: 12, fontFamily: 'monospace'),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: deepLink));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('تم نسخ رابط الأستاذ الذكي للحافظة بنجاح!'),
                        backgroundColor: Color(0xFF10B981),
                      ),
                    );
                  },
                  tooltip: 'نسخ الرابط',
                  icon: const Icon(Icons.copy_rounded, color: Colors.white70, size: 18),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsPreviewCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.insights_rounded, color: Colors.orangeAccent, size: 20),
              SizedBox(width: 8),
              Text(
                'تقارير الأداء ومعدل الحضور',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildReportMetric('متوسط الحضور', '91%', const Color(0xFF10B981)),
              _buildReportMetric('إتمام المنهاج', '68%', _brightCyan),
              _buildReportMetric('تجديد الاشتراكات', '85%', _electricPurple),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReportMetric(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(color: Colors.white60, fontSize: 11)),
      ],
    );
  }

  Widget _buildActionsMenu(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.support_agent_rounded, color: _brightCyan),
            title: const Text('الدعم الفني والمشكلات التقنية', style: TextStyle(color: Colors.white, fontSize: 13.5)),
            subtitle: const Text('الإبلاغ عن انقطاع البث أو استفسار مالي', style: TextStyle(color: Colors.white54, fontSize: 11)),
            trailing: const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white30, size: 14),
            onTap: () => TeacherSupportModal.show(context),
          ),
          const Divider(color: Colors.white10, height: 1),
          ListTile(
            leading: const Icon(Icons.settings_outlined, color: Colors.white70),
            title: const Text('إعدادات الحساب والأمان', style: TextStyle(color: Colors.white, fontSize: 13.5)),
            trailing: const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white30, size: 14),
            onTap: onOpenAccountSettings,
          ),
          const Divider(color: Colors.white10, height: 1),
          ListTile(
            leading: const Icon(Icons.logout_rounded, color: Colors.redAccent),
            title: const Text('تسجيل الخروج', style: TextStyle(color: Colors.redAccent, fontSize: 13.5, fontWeight: FontWeight.bold)),
            onTap: onSignOut,
          ),
        ],
      ),
    );
  }
}
