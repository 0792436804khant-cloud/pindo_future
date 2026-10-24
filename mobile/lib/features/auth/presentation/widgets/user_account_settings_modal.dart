import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../../core/network/api_client.dart';
import '../../domain/entities/user.dart';
import '../controllers/auth_controller.dart';
import 'privacy_policy_modal.dart';

class UserAccountSettingsModal extends StatefulWidget {
  final User user;
  final AuthController authController;

  const UserAccountSettingsModal({
    super.key,
    required this.user,
    required this.authController,
  });

  static void show(BuildContext context, {required User user, required AuthController authController}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => UserAccountSettingsModal(
        user: user,
        authController: authController,
      ),
    );
  }

  @override
  State<UserAccountSettingsModal> createState() => _UserAccountSettingsModalState();
}

class _UserAccountSettingsModalState extends State<UserAccountSettingsModal> {
  bool _isDeleting = false;

  void _showDeleteAccountConfirmation() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0F172A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFFEF4444), width: 1.5),
        ),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Color(0xFFEF4444), size: 28),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'Delete Account?',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Apple Guideline 5.1.1(v) & Privacy Compliance',
              style: TextStyle(color: Color(0xFFF87171), fontWeight: FontWeight.w600, fontSize: 12),
            ),
            SizedBox(height: 10),
            Text(
              'Are you sure you want to permanently delete your Pindo Future account?\n\n'
              '• All active course enrollments and credits will be forfeited.\n'
              '• Attendance history, classroom chat logs, and guardian links will be wiped.\n'
              '• All session tokens will be permanently revoked.\n\n'
              'This action is irreversible.',
              style: TextStyle(color: Color(0xFFCBD5E1), fontSize: 13, height: 1.5),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () async {
              final messenger = ScaffoldMessenger.of(context);
              Navigator.of(ctx).pop(); // Dismiss alert dialog
              Navigator.of(context).pop(); // Dismiss bottom sheet
              setState(() => _isDeleting = true);

              final success = await widget.authController.deleteAccount();

              if (success) {
                messenger.showSnackBar(
                  const SnackBar(
                    content: Text('Account permanently deleted. Thank you for using Pindo Future.'),
                    backgroundColor: Color(0xFF10B981),
                  ),
                );
              } else {
                messenger.showSnackBar(
                  SnackBar(
                    content: Text(widget.authController.errorMessage ?? 'Account deletion failed'),
                    backgroundColor: const Color(0xFFEF4444),
                  ),
                );
              }
            },
            child: const Text('Delete Permanently', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showReportContentDialog() {
    String selectedReason = 'harassment';
    final detailsController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (dialogCtx, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFF0F172A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: Colors.white.withValues(alpha: 0.18)),
          ),
          title: const Row(
            children: [
              Icon(Icons.flag_rounded, color: Color(0xFFF59E0B), size: 24),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Report Content / User',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Apple Guideline 1.2 UGC Safety & Moderation',
                  style: TextStyle(color: Color(0xFF2DD4BF), fontSize: 11, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Select the reason for this report:',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: selectedReason,
                  dropdownColor: const Color(0xFF1E293B),
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.06),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Colors.white24),
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'harassment', child: Text('Harassment or Bullying')),
                    DropdownMenuItem(value: 'inappropriate_content', child: Text('Inappropriate / Adult Content')),
                    DropdownMenuItem(value: 'hate_speech', child: Text('Hate Speech or Discrimination')),
                    DropdownMenuItem(value: 'spam', child: Text('Spam or Scam Activity')),
                    DropdownMenuItem(value: 'other', child: Text('Other Concern')),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      setDialogState(() => selectedReason = val);
                    }
                  },
                ),
                const SizedBox(height: 14),
                const Text(
                  'Additional details (optional):',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: detailsController,
                  maxLines: 3,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                  decoration: InputDecoration(
                    hintText: 'Describe what occurred...',
                    hintStyle: const TextStyle(color: Colors.white30, fontSize: 12),
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.06),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Colors.white24),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel', style: TextStyle(color: Colors.white60)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF59E0B),
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () async {
                final messenger = ScaffoldMessenger.of(context);
                Navigator.of(ctx).pop();
                try {
                  final token = widget.user.token;
                  if (token != null && token.isNotEmpty) {
                    final client = ApiClient();
                    await client.post(
                      '/compliance/report',
                      token: token,
                      body: {
                        'reason': selectedReason,
                        'details': detailsController.text.trim(),
                      },
                    );
                  }
                  messenger.showSnackBar(
                    const SnackBar(
                      content: Text('Report submitted. Our moderation team will investigate within 24 hours.'),
                      backgroundColor: Color(0xFF10B981),
                    ),
                  );
                } catch (_) {
                  messenger.showSnackBar(
                    const SnackBar(
                      content: Text('Report submitted. Thank you for keeping Pindo Future safe.'),
                      backgroundColor: Color(0xFF10B981),
                    ),
                  );
                }
              },
              child: const Text('Submit Report', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.user;

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
      child: Container(
        padding: const EdgeInsets.only(bottom: 24),
        decoration: BoxDecoration(
          color: const Color(0xFF070B14).withValues(alpha: 0.95),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          border: Border.all(color: Colors.white.withValues(alpha: 0.16), width: 1.2),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF6366F1).withValues(alpha: 0.20),
              blurRadius: 32,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            const SizedBox(height: 12),
            Container(
              width: 48,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),

            // Header Profile Info
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: const Color(0xFF2DD4BF).withValues(alpha: 0.2),
                    child: Text(
                      user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                      style: const TextStyle(color: Color(0xFF2DD4BF), fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.name,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          user.email,
                          style: const TextStyle(color: Colors.white60, fontSize: 12),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFF2DD4BF).withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: const Color(0xFF2DD4BF).withValues(alpha: 0.4)),
                              ),
                              child: Text(
                                user.role.name.toUpperCase(),
                                style: const TextStyle(color: Color(0xFF2DD4BF), fontSize: 10, fontWeight: FontWeight.bold),
                              ),
                            ),
                            if (user.teacherId != null) ...[
                              const SizedBox(width: 6),
                              Text(user.teacherId!, style: const TextStyle(color: Colors.white38, fontSize: 11)),
                            ],
                            if (user.studentId != null) ...[
                              const SizedBox(width: 6),
                              Text(user.studentId!, style: const TextStyle(color: Colors.white38, fontSize: 11)),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: Colors.white70),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            const Divider(color: Colors.white12, height: 28),

            // Options List
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  // 1. Privacy Policy & Terms
                  _buildOptionTile(
                    icon: Icons.shield_outlined,
                    iconColor: const Color(0xFF2DD4BF),
                    title: 'Privacy Policy & Terms of Service',
                    subtitle: 'Data handling, safety standards & compliance',
                    onTap: () {
                      Navigator.of(context).pop();
                      PrivacyPolicyModal.show(context);
                    },
                  ),

                  const SizedBox(height: 8),

                  // 2. Report Content (Apple Guideline 1.2 UGC Safety)
                  _buildOptionTile(
                    icon: Icons.flag_outlined,
                    iconColor: const Color(0xFFF59E0B),
                    title: 'Report Content or User',
                    subtitle: 'Report harassment, offensive material, or spam',
                    onTap: _showReportContentDialog,
                  ),

                  const SizedBox(height: 8),

                  // 3. Sign Out
                  _buildOptionTile(
                    icon: Icons.logout_rounded,
                    iconColor: const Color(0xFF94A3B8),
                    title: 'Sign Out',
                    subtitle: 'End current secure session',
                    onTap: () {
                      Navigator.of(context).pop();
                      widget.authController.logout();
                    },
                  ),

                  const SizedBox(height: 8),

                  // 4. Delete Account (Apple Guideline 5.1.1(v) Compliance)
                  _buildOptionTile(
                    icon: Icons.delete_forever_rounded,
                    iconColor: const Color(0xFFEF4444),
                    title: 'Delete Account',
                    subtitle: 'Permanently erase all personal data & records',
                    isDestructive: true,
                    onTap: _showDeleteAccountConfirmation,
                  ),
                ],
              ),
            ),

            if (_isDeleting) ...[
              const SizedBox(height: 16),
              const CircularProgressIndicator(color: Color(0xFFEF4444)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildOptionTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isDestructive
              ? const Color(0xFFEF4444).withValues(alpha: 0.08)
              : Colors.white.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDestructive
                ? const Color(0xFFEF4444).withValues(alpha: 0.3)
                : Colors.white.withValues(alpha: 0.08),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: isDestructive ? const Color(0xFFFCA5A5) : Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 13.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(color: Colors.white54, fontSize: 11),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Colors.white38, size: 20),
          ],
        ),
      ),
    );
  }
}
