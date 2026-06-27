import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/colors.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(Icons.arrow_back_ios,
                          color: AppColors.textPrimary, size: 22),
                    ),
                  ),
                  Text(
                    'Privacy Policy',
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),

            // Body
            Expanded(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: _buildContent(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    const sections = [
      _Section('1. Welcome',
          'We respect your privacy. This page explains what information we collect and how we use it.'),
      _Section('2. What Information We Collect', '''We may collect:

✔ Account Information
• Name or nickname
• Email or phone number
• Profile picture (avatar)

✔ Learning Information
• Your progress
• Points and badges
• Challenges completed
• Topics you study

✔ Device Information
• Device type (phone/tablet)
• App version'''),
      _Section('3. Why We Collect This Information',
          'We use this information to:\n• Help you learn better\n• Save your progress\n• Improve the app\n• Show your points and badges\n• Provide support if you need help'),
      _Section('4. Do We Share Your Information?',
          'No, we do not sell your information.\n\nWe may share data only in these cases:\n• If the law requires it\n• To protect users from harm\n• To keep the app safe'),
      _Section('5. Parents & Safety',
          'Parents can use Parent Mode to view learning progress.\nStudents should not share personal details with strangers.'),
      _Section('6. Study Rooms',
          'Study rooms are for friendly learning.\nPlease don\'t share personal information in chat rooms.'),
      _Section('7. Cookies & Tracking',
          'We may use small tools to improve the app (like performance tracking). These tools do not collect personal data like your name or email.'),
      _Section('8. Your Rights', 'You can:\n• Ask us to delete your account\n• Ask us what data we have\n• Request changes to your information'),
      _Section('9. Security',
          'We use strong security to protect your data. But please remember:\n• Keep your password safe\n• Don\'t share your account'),
      _Section('10. Changes to This Policy',
          'We may update this policy sometimes. If we do, we will let you know in the app.'),
      _Section('11. Contact',
          'If you have questions, you can contact us through In-App Support Chat.'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...sections.map((s) => _SectionWidget(section: s)),
        const SizedBox(height: 8),
        Text(
          'Final Message\nWe are committed to keeping your information safe and secure.',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
            height: 1.6,
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

class _Section {
  final String title;
  final String body;
  const _Section(this.title, this.body);
}

class _SectionWidget extends StatelessWidget {
  final _Section section;
  const _SectionWidget({required this.section});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            section.title,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            section.body,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: AppColors.textPrimary,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
