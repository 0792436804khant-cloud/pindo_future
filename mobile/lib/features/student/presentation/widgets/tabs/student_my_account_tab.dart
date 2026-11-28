import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pindo_future_mobile/features/student/data/models/student_dashboard_model.dart';
import 'package:pindo_future_mobile/features/student/presentation/widgets/modals/support_ticket_modal.dart';
import '../modals/subscription_package_modal.dart';
import '../modals/algerian_payment_sheet_modal.dart';

class StudentMyAccountTab extends StatefulWidget {
  final StudentDashboardData dashboardData;
  final VoidCallback onOpenAccountSettings;
  final VoidCallback onLogout;
  final ValueChanged<int>? onNavigateToTab;

  const StudentMyAccountTab({
    super.key,
    required this.dashboardData,
    required this.onOpenAccountSettings,
    required this.onLogout,
    this.onNavigateToTab,
  });

  @override
  State<StudentMyAccountTab> createState() => _StudentMyAccountTabState();
}

class _StudentMyAccountTabState extends State<StudentMyAccountTab> {
  static const Color _brightCyan = Color(0xFF00E5FF);
  static const Color _electricPurple = Color(0xFF7C4DFF);
  static const Color _deepIndigo = Color(0xFF311B92);

  // Profile photo state (supports in-memory bytes and optional URL)
  Uint8List? _avatarBytes;
  String? _customProfilePhotoUrl;

  // Notification toggles
  bool _liveReminderEnabled = true;
  bool _chatNotificationsEnabled = true;
  bool _teacherStoriesEnabled = true;
  bool _parentSyncEnabled = true;

  // Valid 1x1 sample avatar PNG bytes to guarantee immediate render across tests & offline
  static final Uint8List _sampleAvatarBytes = Uint8List.fromList([
    0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D,
    0x49, 0x48, 0x44, 0x52, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01,
    0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4, 0x89, 0x00, 0x00, 0x00,
    0x0A, 0x49, 0x44, 0x41, 0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00,
    0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4, 0x00, 0x00, 0x00, 0x00, 0x49,
    0x45, 0x4E, 0x44, 0xAE, 0x42, 0x60, 0x82
  ]);

  void _showProfilePhotoOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0F172A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'صورة الملف الشخصي (Photo de profil) 📸',
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            const Text(
              'اختر كيفية تحديث صورتك الشخصية على المنصة:',
              style: TextStyle(color: Colors.white60, fontSize: 12),
            ),
            const SizedBox(height: 18),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _brightCyan.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.camera_alt_outlined, color: _brightCyan, size: 20),
              ),
              title: const Text('التقاط صورة جديدة بالكاميرا 📷', style: TextStyle(color: Colors.white, fontSize: 13.5)),
              onTap: () {
                Navigator.of(ctx).pop();
                setState(() {
                  _avatarBytes = _sampleAvatarBytes;
                  _customProfilePhotoUrl = null;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('تم التقاط وتحديث صورة الملف الشخصي بنجاح!'),
                    backgroundColor: Color(0xFF10B981),
                  ),
                );
              },
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _electricPurple.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.photo_library_outlined, color: _electricPurple, size: 20),
              ),
              title: const Text('اختيار صورة من معرض الصور 🖼️', style: TextStyle(color: Colors.white, fontSize: 13.5)),
              onTap: () {
                Navigator.of(ctx).pop();
                setState(() {
                  _avatarBytes = _sampleAvatarBytes;
                  _customProfilePhotoUrl = null;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('تم اختيار وتحديث صورة الملف الشخصي بنجاح!'),
                    backgroundColor: Color(0xFF10B981),
                  ),
                );
              },
            ),
            if (_avatarBytes != null || _customProfilePhotoUrl != null)
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF4444).withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.delete_outline, color: Color(0xFFEF4444), size: 20),
                ),
                title: const Text('إزالة الصورة والعودة للحرف الافتراضي', style: TextStyle(color: Color(0xFFFCA5A5), fontSize: 13.5)),
                onTap: () {
                  Navigator.of(ctx).pop();
                  setState(() {
                    _avatarBytes = null;
                    _customProfilePhotoUrl = null;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('تمت إزالة صورة الملف الشخصي.'),
                      backgroundColor: Color(0xFF0F172A),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  void _showParentSyncInfo() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0F172A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFF10B981), width: 1.2),
        ),
        title: const Row(
          children: [
            Icon(Icons.family_restroom, color: Color(0xFF34D399), size: 24),
            SizedBox(width: 8),
            Text('ربط حساب ولي الأمر 👨‍👦', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'الحساب المرتبط حالياً:',
              style: TextStyle(color: Colors.white70, fontSize: 12),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('الاسم: محمد قادري (الأب)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                  SizedBox(height: 2),
                  Text('البريد: parent@pindofuture.com', style: TextStyle(color: Colors.white60, fontSize: 11)),
                  SizedBox(height: 2),
                  Text('حالة المزامنة: مفعّل ويتلقى تقارير الحضور الأسبوعية ✓', style: TextStyle(color: Color(0xFF34D399), fontSize: 11)),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'يتلقى الولي تلقائياً إشعارات حضور الحصص، تقارير الواجبات، ومواعيد تجديد الاشتراكات لدعم مسيرتك الدراسية.',
              style: TextStyle(color: Colors.white60, fontSize: 11.5, height: 1.4),
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
            child: const Text('حسناً', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final student = widget.dashboardData.student;
    final subs = widget.dashboardData.subscriptions;
    final attendance = widget.dashboardData.attendance;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 95),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          const Text(
            'الملف الشخصي وحسابي 👤',
            style: TextStyle(
              color: Colors.white,
              fontSize: 19,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'بياناتك الأكاديمية، جواز التعلّم والمواظبة، أمان الأجهزة، وإعدادات الحساب.',
            style: TextStyle(color: Colors.white60, fontSize: 12, height: 1.4),
          ),
          const SizedBox(height: 18),

          // 1. Digital Student Passport Card
          _buildStudentPassportCard(student),
          const SizedBox(height: 18),

          // 2. Learning Passport & Overall Academic Metrics
          _buildLearningPassportMetrics(subs, attendance),
          const SizedBox(height: 20),

          // 3. Quick Navigation Hub to the 3 Pillars
          _buildPillarsQuickHub(subs),
          const SizedBox(height: 20),

          // 4. Digital Watermark & Device Protection
          _buildSecurityAndWatermarkCard(student),
          const SizedBox(height: 20),

          // 5. Smart Notifications & Alarm Preferences
          _buildNotificationPreferencesCard(),
          const SizedBox(height: 20),

          // 6. Support & Settings Buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => SupportTicketModal.show(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E293B),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: Colors.white.withValues(alpha: 0.15)),
                    ),
                  ),
                  icon: const Icon(Icons.help_outline_rounded, color: _brightCyan, size: 18),
                  label: const Text('طلب مساعدة ودعم', style: TextStyle(fontSize: 12)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: widget.onOpenAccountSettings,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E293B),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: Colors.white.withValues(alpha: 0.15)),
                    ),
                  ),
                  icon: const Icon(Icons.security_rounded, color: Color(0xFF10B981), size: 18),
                  label: const Text('الأمان وكلمة المرور', style: TextStyle(fontSize: 12)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // 7. Sign Out Button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: widget.onLogout,
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFEF4444),
                side: const BorderSide(color: Color(0xFFEF4444)),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(Icons.logout, size: 18),
              label: const Text('تسجيل الخروج من الحساب', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            ),
          ),
        ],
      ),
    );
  }

  // 1. Student Passport Card with Photo de Profil
  Widget _buildStudentPassportCard(StudentProfile student) {
    ImageProvider? avatarImage;
    if (_avatarBytes != null) {
      avatarImage = MemoryImage(_avatarBytes!);
    } else if (_customProfilePhotoUrl != null) {
      avatarImage = NetworkImage(_customProfilePhotoUrl!);
    }

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_deepIndigo, Color(0xFF1E1B4B), Color(0xFF0F172A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _brightCyan.withValues(alpha: 0.40), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: _brightCyan.withValues(alpha: 0.15),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Avatar with camera change button
              Stack(
                children: [
                  Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [_brightCyan, _electricPurple],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: _brightCyan.withValues(alpha: 0.3),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 32,
                      backgroundColor: const Color(0xFF0F172A),
                      backgroundImage: avatarImage,
                      child: avatarImage == null
                          ? Text(
                              student.name.isNotEmpty ? student.name[0].toUpperCase() : 'S',
                              style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold),
                            )
                          : null,
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: InkWell(
                      onTap: () => _showProfilePhotoOptions(context),
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: _brightCyan,
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFF0F172A), width: 2),
                        ),
                        child: const Icon(Icons.camera_alt, color: Color(0xFF070B14), size: 13),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            student.name,
                            style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981).withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFF10B981), width: 0.8),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.verified, color: Color(0xFF34D399), size: 12),
                              SizedBox(width: 4),
                              Text('تلميذ موثّق ✓', style: TextStyle(color: Color(0xFF34D399), fontSize: 10, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      student.email,
                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'الطور الثانوي • شعبة علوم تجريبية / رياضي (BAC 2025)',
                      style: const TextStyle(color: Color(0xFFFDE68A), fontSize: 11, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(color: Colors.white12, height: 1),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              _passportInfoPill(Icons.fingerprint, 'معرف التلميذ:', 'STU_${student.id.toString().padLeft(4, '0')}_2026'),
              _passportInfoPill(Icons.location_on_outlined, 'الولاية:', 'الجزائر العاصمة (القبة)'),
              _passportInfoPill(Icons.school_outlined, 'المؤسسة:', 'ثانوية الرياضيات بالقبة'),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _brightCyan.withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.family_restroom, color: _brightCyan, size: 16),
                    const SizedBox(width: 8),
                    const Text('كود ربط ولي الأمر:', style: TextStyle(color: Colors.white70, fontSize: 11)),
                    const SizedBox(width: 6),
                    Text(
                      'PINDO-FAM-${student.id.toString().padLeft(4, '0')}',
                      style: const TextStyle(color: _brightCyan, fontSize: 12, fontWeight: FontWeight.bold, fontFamily: 'monospace'),
                    ),
                  ],
                ),
                InkWell(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: 'PINDO-FAM-${student.id.toString().padLeft(4, '0')}'));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('تم نسخ كود ربط ولي الأمر لمشاركته مع الوالد.'),
                        backgroundColor: const Color(0xFF0F172A),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _brightCyan.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.copy, color: _brightCyan, size: 12),
                        SizedBox(width: 4),
                        Text('نسخ', style: TextStyle(color: _brightCyan, fontSize: 10.5, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _passportInfoPill(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: _brightCyan, size: 13),
          const SizedBox(width: 5),
          Text(label, style: const TextStyle(color: Colors.white54, fontSize: 10.5)),
          const SizedBox(width: 4),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 10.5, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  // 2. Learning Passport Metrics (جواز التعلّم والمواظبة)
  Widget _buildLearningPassportMetrics(StudentSubscriptionSummary subs, StudentAttendanceSummary attendance) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.workspace_premium_rounded, color: Color(0xFFF59E0B), size: 18),
            SizedBox(width: 8),
            Text(
              'جواز التعلّم وإحصائيات المواظبة 📊',
              style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            _metricBox(
              icon: Icons.groups_rounded,
              color: _brightCyan,
              title: 'الأفواج المنخرط بها',
              value: '${subs.activeCohortsCount} أفواج',
              subtitle: 'مع نخبة الأساتذة',
            ),
            const SizedBox(width: 10),
            _metricBox(
              icon: Icons.fact_check_rounded,
              color: const Color(0xFF10B981),
              title: 'نسبة المواظبة',
              value: '${attendance.attendanceRate}%',
              subtitle: '${attendance.attendedSessions} من ${attendance.totalSessions} حصة',
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            _metricBox(
              icon: Icons.history_edu_rounded,
              color: const Color(0xFFF59E0B),
              title: 'امتحانات تم حلها',
              value: '8 مواضيع',
              subtitle: 'بنك البكالوريا الرسمي',
            ),
            const SizedBox(width: 10),
            _metricBox(
              icon: Icons.timer_outlined,
              color: _electricPurple,
              title: 'ساعات المراجعة',
              value: '24.5 ساعة',
              subtitle: 'تسجيلات وحصص تفاعلية',
            ),
          ],
        ),
      ],
    );
  }

  Widget _metricBox({
    required IconData icon,
    required Color color,
    required String title,
    required String value,
    required String subtitle,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF0F172A).withValues(alpha: 0.75),
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
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 15),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(color: Colors.white60, fontSize: 11),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: const TextStyle(color: Colors.white38, fontSize: 10),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  // 3. Quick Navigation Hub to the 3 Pillars
  Widget _buildPillarsQuickHub(StudentSubscriptionSummary subs) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A).withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'روابط الوصول السريع لأركان الحساب:',
            style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _hubRow(
            icon: Icons.credit_card_rounded,
            color: _brightCyan,
            title: 'اشتراكاتي وباقات الدفع 💳',
            description: 'الرصيد: ${subs.remainingCredits} حصص متبقية • ينتهي: ${subs.expiresAt.isNotEmpty ? subs.expiresAt : '2026-11-20'}',
            actionText: 'إدارة الباقات والتجديد',
            onTap: () {
              if (widget.onNavigateToTab != null) {
                widget.onNavigateToTab!(2); // Switch to Tab 2: الاشتراكات
              } else {
                SubscriptionPackageModal.show(
                  context,
                  cohortName: 'فوج النخبة للبكالوريا — الرياضيات',
                  teacherName: 'الأستاذ محمد أمين بن عيسى',
                  subject: 'الرياضيات',
                  currentPackageName: subs.packageName,
                  studentName: widget.dashboardData.student.name,
                  studentEmail: widget.dashboardData.student.email,
                );
              }
            },
          ),
          const Divider(color: Colors.white10, height: 18),
          _hubRow(
            icon: Icons.calendar_month_rounded,
            color: _electricPurple,
            title: 'حصصي وجدول الدروس التاريخي 🎓',
            description: 'سجل جميع حصصك من أول يوم اشتراك مع روابط التسجيل والبث',
            actionText: 'الانتقال لخانة الحصص',
            onTap: () {
              if (widget.onNavigateToTab != null) {
                widget.onNavigateToTab!(1); // Switch to Tab 1: حصصي
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _hubRow({
    required IconData icon,
    required Color color,
    required String title,
    required String description,
    required String actionText,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 2),
                  Text(description, style: const TextStyle(color: Colors.white60, fontSize: 11)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.white38, size: 12),
          ],
        ),
      ),
    );
  }

  // 4. Security, Watermark & Device Protection
  Widget _buildSecurityAndWatermarkCard(StudentProfile student) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A).withValues(alpha: 0.75),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.shield_outlined, color: Color(0xFF10B981), size: 18),
                  SizedBox(width: 8),
                  Text(
                    'أمان الحساب وحماية المحتوى الرقمي 🛡️',
                    style: TextStyle(color: Colors.white, fontSize: 13.5, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text('آمن 100%', style: TextStyle(color: Color(0xFF34D399), fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _securityItem(
            icon: Icons.devices_rounded,
            title: 'الجهاز المسجل النشط:',
            detail: 'الهاتف الحالي (Samsung Galaxy / Chrome) • نشط الآن ✓',
          ),
          const SizedBox(height: 8),
          _securityItem(
            icon: Icons.branding_watermark_rounded,
            title: 'العلامة المائية المخصصة:',
            detail: '${student.name} • ${student.email} (مشفرة لمنع التسريب)',
          ),
          const SizedBox(height: 8),
          _securityItem(
            icon: Icons.family_restroom_rounded,
            title: 'ربط حساب ولي الأمر:',
            detail: 'محمد قادري (مفعّل للمتابعة الأبوية والإشعارات)',
            action: TextButton(
              onPressed: _showParentSyncInfo,
              style: TextButton.styleFrom(
                foregroundColor: _brightCyan,
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text('عرض التفاصيل ←', style: TextStyle(fontSize: 10.5)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _securityItem({
    required IconData icon,
    required String title,
    required String detail,
    Widget? action,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white60, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(title, style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold)),
                    if (action != null) action,
                  ],
                ),
                const SizedBox(height: 2),
                Text(detail, style: const TextStyle(color: Colors.white54, fontSize: 10.5)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 5. Smart Notification & Alarm Preferences
  Widget _buildNotificationPreferencesCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A).withValues(alpha: 0.75),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.tune_rounded, color: _electricPurple, size: 18),
              SizedBox(width: 8),
              Text(
                'تفضيلات التنبيهات والإشعارات الذكية ⚙️',
                style: TextStyle(color: Colors.white, fontSize: 13.5, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _switchRow(
            title: 'تنبيهات الحصص المباشرة قبل 15 دقيقة ⏰',
            subtitle: 'إشعار فوري مع نغمة هادئة قبل انطلاق البث',
            value: _liveReminderEnabled,
            onChanged: (v) => setState(() => _liveReminderEnabled = v),
          ),
          const Divider(color: Colors.white10, height: 12),
          _switchRow(
            title: 'إشعارات محادثات وغرف الأفواج 💬',
            subtitle: 'تنبيه بالرسائل والتمارين الجديدة من الأستاذ',
            value: _chatNotificationsEnabled,
            onChanged: (v) => setState(() => _chatNotificationsEnabled = v),
          ),
          const Divider(color: Colors.white10, height: 12),
          _switchRow(
            title: 'قصص ومستجدات الأساتذة 📸',
            subtitle: 'إشعار عند نشر الأستاذ لقصة جديدة أو نصيحة تفوق',
            value: _teacherStoriesEnabled,
            onChanged: (v) => setState(() => _teacherStoriesEnabled = v),
          ),
          const Divider(color: Colors.white10, height: 12),
          _switchRow(
            title: 'مزامنة تقارير الحضور مع ولي الأمر 👨‍👦',
            subtitle: 'إرسال إشعار حضور الحصة تلقائياً لحساب الولي',
            value: _parentSyncEnabled,
            onChanged: (v) => setState(() => _parentSyncEnabled = v),
          ),
        ],
      ),
    );
  }

  Widget _switchRow({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
              const SizedBox(height: 2),
              Text(subtitle, style: const TextStyle(color: Colors.white54, fontSize: 10.5)),
            ],
          ),
        ),
        Switch.adaptive(
          value: value,
          onChanged: onChanged,
          activeColor: _brightCyan,
          activeTrackColor: _brightCyan.withValues(alpha: 0.35),
        ),
      ],
    );
  }
}
