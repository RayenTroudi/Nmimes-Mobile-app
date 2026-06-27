import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/colors.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notifications = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
                    'Settings',
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  // Subscription
                  _SettingsRow(
                    label: 'Subscription',
                    onTap: () => Navigator.pushNamed(context, '/subscription'),
                  ),
                  const SizedBox(height: 16),

                  // Notifications (with toggle)
                  _SettingsRow(
                    label: 'Notifications',
                    trailing: _Toggle(
                      value: _notifications,
                      onChanged: (v) => setState(() => _notifications = v),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Terms & Conditions
                  _SettingsRow(
                    label: 'Terms & Conditions',
                    onTap: () => Navigator.pushNamed(context, '/terms'),
                  ),
                  const SizedBox(height: 16),

                  // Privacy Policy
                  _SettingsRow(
                    label: 'Privacy Policy',
                    onTap: () => Navigator.pushNamed(context, '/privacy'),
                  ),
                  const SizedBox(height: 16),

                  // Log Out
                  _SettingsRow(
                    label: 'Log Out',
                    labelColor: const Color(0xFFE62929),
                    backgroundColor: const Color(0xFFFBD7C8),
                    borderColor: const Color(0xFFE62929),
                    onTap: () => Navigator.pushNamed(context, '/parent-logout'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  final String label;
  final Color labelColor;
  final Color backgroundColor;
  final Color borderColor;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsRow({
    required this.label,
    this.labelColor = AppColors.textPrimary,
    this.backgroundColor = AppColors.white,
    this.borderColor = const Color(0xFFE0E0E0),
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 60,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: labelColor,
                ),
              ),
            ),
            if (trailing case final t?) t,
          ],
        ),
      ),
    );
  }
}

class _Toggle extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const _Toggle({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 46,
        height: 28,
        decoration: BoxDecoration(
          color: value ? AppColors.primary : const Color(0xFFDEDEDE),
          borderRadius: BorderRadius.circular(50),
        ),
        padding: const EdgeInsets.all(2),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 200),
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 22,
            height: 22,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }
}
