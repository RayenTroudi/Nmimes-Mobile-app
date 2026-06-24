import 'package:flutter/material.dart';
import '../../theme/colors.dart';
import '../../theme/text_styles.dart';
import '../../theme/spacing.dart';
import '../../widgets/avatar_widget.dart';

class ParentsViewScreen extends StatelessWidget {
  const ParentsViewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Header(),
              _ProgressCard(),
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg, vertical: AppSpacing.md),
                child: Text('Manage', style: AppTextStyles.h3),
              ),
              _NavTile(Icons.people_outline, 'Children',
                  () => Navigator.pushNamed(context, '/children')),
              _NavTile(Icons.card_membership_outlined, 'Subscription',
                  () => Navigator.pushNamed(context, '/subscription')),
              _NavTile(Icons.settings_outlined, 'Settings',
                  () => Navigator.pushNamed(context, '/settings')),
              _NavTile(Icons.help_outline, 'Help & Support',
                  () => Navigator.pushNamed(context, '/help')),
              const Divider(
                  indent: AppSpacing.lg,
                  endIndent: AppSpacing.lg,
                  color: AppColors.cardBorder),
              _NavTile(
                Icons.logout,
                'Log Out',
                () => Navigator.pushNamed(context, '/parent-logout'),
                color: Colors.red,
              ),
              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        children: [
          const AvatarWidget(initials: 'P', radius: 28),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Parent Dashboard", style: AppTextStyles.h2),
                Text('Welcome back!',
                    style: AppTextStyles.bodySmall
                        .copyWith(color: AppColors.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Child's Progress",
              style: AppTextStyles.h3.copyWith(color: AppColors.white)),
          const SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _Stat('320', 'Points', AppColors.white),
              _Stat('12', 'Challenges', AppColors.white),
              _Stat('5', 'Day Streak', AppColors.white),
            ],
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String value;
  final String label;
  final Color color;

  const _Stat(this.value, this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
            style: AppTextStyles.h2.copyWith(color: color)),
        Text(label,
            style: AppTextStyles.bodySmall
                .copyWith(color: color.withValues(alpha: 0.8))),
      ],
    );
  }
}

class _NavTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;

  const _NavTile(this.icon, this.label, this.onTap,
      {this.color = AppColors.textPrimary});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(label, style: AppTextStyles.body.copyWith(color: color)),
      trailing: Icon(Icons.chevron_right, color: AppColors.textHint),
      onTap: onTap,
    );
  }
}
