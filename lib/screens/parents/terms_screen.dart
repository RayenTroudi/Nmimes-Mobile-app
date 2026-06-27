import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/colors.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

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
                    'Term & Conditions',
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
                child: _buildContent(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    const sections = [
      _Section('1. Welcome!',
          'Nmimes is a fun app to help you learn and practice math. By using this app, you agree to follow these simple rules.'),
      _Section('2. Who Can Use the App?',
          'This app is for students aged 13 and above.\nIf you are under 18, a parent or guardian should know you are using the app.'),
      _Section('3. Your Account',
          'Use your real and correct information.\nKeep your login details safe.\nDon\'t share your account with others.'),
      _Section('4. How to Use Nmimes',
          'You can use the app to:\n• Learn math\n• Ask AI for help\n• Join study rooms\n• Play friendly challenges\n\nPlease don\'t:\n• Be rude or mean to others\n• Share bad or unsafe messages\n• Try to break or misuse the app'),
      _Section('5. About AI Help',
          'AI helps explain math in an easy way.\nSometimes AI can make mistakes.\nUse AI to learn, not just to copy answers.'),
      _Section('6. Study Rooms & Challenges',
          'Be kind and respectful in study rooms.\nChallenges are just for fun and learning.\nPlay fair and support your friends.'),
      _Section('7. Rewards & Points',
          'Points, badges, and rewards are for motivation.\nThey are not school grades.'),
      _Section('8. Parent Mode',
          'Parents can check activity and control settings.\nDon\'t try to change parent controls without permission.'),
      _Section('9. Your Privacy',
          'We keep your information safe.\nWe do not sell your personal data.\nMore details are in our Privacy Policy.'),
      _Section('10. Notifications',
          'You may get reminders and updates.\nYou can turn notifications on or off in settings.'),
      _Section('11. Following the Rules',
          'If rules are broken, your account may be paused or closed.\nYou can delete your account anytime from settings.'),
      _Section('12. App Content',
          'Everything in Nmimes belongs to the app.\nDon\'t copy or share it without permission.'),
      _Section('13. Need Help?',
          'Use the In-App Support Chat if you need help or have questions.'),
      _Section('14. Changes',
          'Rules may change sometimes.\nKeep using the app means you agree to the new rules.'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...sections.map((s) => _SectionWidget(section: s)),
        const SizedBox(height: 8),
        Text(
          '👍 Final Message for Kids\nBe kind. Learn well. Have fun with math! 🎉',
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
