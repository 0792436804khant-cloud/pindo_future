import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../../core/widgets/pindo_brand_logo.dart';

class PrivacyPolicyModal extends StatelessWidget {
  const PrivacyPolicyModal({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const PrivacyPolicyModal(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.88,
        decoration: BoxDecoration(
          color: const Color(0xFF070B14).withValues(alpha: 0.94),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          border: Border.all(color: Colors.white.withValues(alpha: 0.16), width: 1.2),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF2DD4BF).withValues(alpha: 0.18),
              blurRadius: 32,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
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
            const SizedBox(height: 14),

            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  const PindoBrandLogo(size: 28, showText: false, withGlow: true),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Privacy Policy & Terms',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.2,
                          ),
                        ),
                        Text(
                          'Pindo Future Education Platform • Compliance & Standards',
                          style: TextStyle(
                            color: Color(0xFF2DD4BF),
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
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

            const Divider(color: Colors.white12, height: 24),

            // Content body
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionCard(
                      icon: Icons.shield_rounded,
                      title: '1. Personal Data & Privacy Protection',
                      accentColor: const Color(0xFF2DD4BF),
                      content:
                          'Pindo Future respects your privacy and adheres to international privacy standards and Algerian Law 18-07 on personal data protection. '
                          'We collect only information required to provide distance learning services: user name, email, chosen academic level, attendance history, and course enrollments. '
                          'We never sell, rent, or trade student or teacher personal data to third parties for advertising or commercial marketing.',
                    ),
                    const SizedBox(height: 16),

                    _buildSectionCard(
                      icon: Icons.family_restroom_rounded,
                      title: '2. Child Safety & Parental Oversight',
                      accentColor: const Color(0xFF38BDF8),
                      content:
                          'For minor students, Pindo Future includes a dedicated Parent Portal allowing guardians to link with their children’s accounts, monitor attendance in real time, review teacher notes, and inspect academic progress. '
                          'Communication inside classrooms is restricted to authorized group educational sessions.',
                    ),
                    const SizedBox(height: 16),

                    _buildSectionCard(
                      icon: Icons.videocam_rounded,
                      title: '3. Video & Audio SFU Streaming Security',
                      accentColor: const Color(0xFF818CF8),
                      content:
                          'All real-time audio, video, interactive whiteboard strokes, and in-class chat streams are transmitted securely through LiveKit SFU WebRTC infrastructure with transport encryption (DTLS/SRTP). '
                          'Access to dynamic classroom rooms requires an authenticated, cryptographically signed session token issued strictly to registered participants.',
                    ),
                    const SizedBox(height: 16),

                    _buildSectionCard(
                      icon: Icons.policy_rounded,
                      title: '4. Zero Tolerance for Objectionable Content (Apple Guideline 1.2)',
                      accentColor: const Color(0xFFF59E0B),
                      content:
                          'Pindo Future enforces a strict zero-tolerance policy against objectionable content, cyberbullying, harassment, hate speech, or offensive material. '
                          'Users can instantly report any message or participant using the in-app "Report" mechanism. '
                          'Our moderation and safety team investigates all reported incidents within 24 hours. Offending users face immediate suspension or permanent expulsion.',
                    ),
                    const SizedBox(height: 16),

                    _buildSectionCard(
                      icon: Icons.delete_forever_rounded,
                      title: '5. Account Deletion & Right to be Forgotten (Apple Guideline 5.1.1(v))',
                      accentColor: const Color(0xFFF43F5E),
                      content:
                          'You have the full right to delete your Pindo Future account and erase all associated data at any time directly from the app (Settings → Delete Account) or by emailing support@pindofuture.com. '
                          'Upon deletion, all authentication tokens, personal details, enrollments, and communication logs are permanently deleted from our servers.',
                    ),
                    const SizedBox(height: 16),

                    _buildSectionCard(
                      icon: Icons.payments_rounded,
                      title: '6. Monetization & Currency',
                      accentColor: const Color(0xFF10B981),
                      content:
                          'Course prices and teacher subscriptions are displayed in Algerian Dinars (DZD). '
                          'Transactions are protected with end-to-end receipt validation. Teachers receive transparent revenue splits and can request disbursements according to platform guidelines.',
                    ),
                    const SizedBox(height: 24),

                    // Support info
                    Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.white12),
                        ),
                        child: const Column(
                          children: [
                            Text(
                              'Questions or Safety Inquiries?',
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Email: support@pindofuture.com • Algiers, Algeria',
                              style: TextStyle(color: Colors.white60, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required IconData icon,
    required String title,
    required Color accentColor,
    required String content,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.09)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                  border: Border.all(color: accentColor.withValues(alpha: 0.35)),
                ),
                child: Icon(icon, color: accentColor, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: const TextStyle(
              color: Color(0xFFCBD5E1),
              fontSize: 12.5,
              height: 1.55,
            ),
          ),
        ],
      ),
    );
  }
}
