import 'package:flutter/material.dart';
import '../../theme/colors.dart';
import '../../theme/text_styles.dart';
import '../../theme/spacing.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notifications = true;
  bool _sound = true;
  bool _vibration = false;
  bool _parentalControls = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Settings', style: AppTextStyles.h3),
      ),
      body: ListView(
        children: [
          _SectionHeader('Notifications'),
          _ToggleTile('Push Notifications', _notifications,
              (v) => setState(() => _notifications = v)),
          _ToggleTile('Sound Effects', _sound,
              (v) => setState(() => _sound = v)),
          _ToggleTile('Vibration', _vibration,
              (v) => setState(() => _vibration = v)),
          _SectionHeader('Parental Controls'),
          _ToggleTile('Parental Controls', _parentalControls,
              (v) => setState(() => _parentalControls = v)),
          _SectionHeader('Account'),
          ListTile(
            title: Text('Change Password', style: AppTextStyles.body),
            trailing: const Icon(Icons.chevron_right, color: AppColors.textHint),
            onTap: () {},
          ),
          ListTile(
            title: Text('Privacy Policy', style: AppTextStyles.body),
            trailing: const Icon(Icons.chevron_right, color: AppColors.textHint),
            onTap: () {},
          ),
          ListTile(
            title: Text('Terms of Service', style: AppTextStyles.body),
            trailing: const Icon(Icons.chevron_right, color: AppColors.textHint),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg, AppSpacing.xl, AppSpacing.lg, AppSpacing.sm),
      child: Text(title, style: AppTextStyles.bodySmall),
    );
  }
}

class _ToggleTile extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleTile(this.label, this.value, this.onChanged);

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      title: Text(label, style: AppTextStyles.body),
      value: value,
      activeThumbColor: AppColors.primary,
      activeTrackColor: AppColors.primary.withValues(alpha: 0.5),
      onChanged: onChanged,
    );
  }
}
