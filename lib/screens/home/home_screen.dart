import 'package:flutter/material.dart';
import '../../theme/colors.dart';
import '../../theme/text_styles.dart';
import '../../widgets/fox_mascot.dart';
import '../../widgets/language_picker_sheet.dart';
import '../../providers/locale_provider.dart';
import '../../l10n/l10n_extension.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.background,
      child: Column(
        children: [
          // Orange header
          _HomeHeader(
            onNotificationTap: () =>
                Navigator.pushNamed(context, '/notifications'),
          ),

          // Scrollable body
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Snap a Homework card
                  _ActionCard(
                    title: context.l10n.home_card_snapHomework_title,
                    subtitle: context.l10n.home_card_snapHomework_subtitle,
                    imagePath: 'assets/images/icon_snap_homework.png',
                    onTap: () =>
                        Navigator.pushNamed(context, '/snap-homework'),
                  ),
                  const SizedBox(height: 14),

                  // Snap a Lesson card
                  _ActionCard(
                    title: context.l10n.home_card_snapLesson_title,
                    subtitle: context.l10n.home_card_snapLesson_subtitle,
                    imagePath: 'assets/images/icon_snap_lesson.png',
                    onTap: () =>
                        Navigator.pushNamed(context, '/snap-lesson'),
                  ),
                  const SizedBox(height: 24),

                  // Study Rooms title
                  Text(
                    context.l10n.home_label_studyRooms,
                    style: AppTextStyles.font(context,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 12),

                  // Peer Learning row
                  _StudyRoomRow(
                    title: context.l10n.home_row_peerLearning_title,
                    subtitle: context.l10n.home_row_peerLearning_subtitle,
                    imagePath: 'assets/images/icon_peer_learning.png',
                    onTap: () =>
                        Navigator.pushNamed(context, '/peer-learning'),
                  ),
                  const SizedBox(height: 12),

                  // Saved Formulas row
                  _StudyRoomRow(
                    title: context.l10n.home_row_savedFormulas_title,
                    subtitle: '',
                    imagePath: 'assets/images/icon_saved_formulas.png',
                    onTap: () =>
                        Navigator.pushNamed(context, '/saved-formulas'),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),

        ],
      ),
    );
  }
}

class _HomeHeader extends StatelessWidget {
  final VoidCallback onNotificationTap;
  const _HomeHeader({required this.onNotificationTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.primary,
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Top row: avatar + name + lang + bell
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              child: Row(
                children: [
                  // Avatar
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: Colors.white.withValues(alpha: 0.6), width: 2),
                    ),
                    child: ClipOval(
                      child: SizedBox(
                        width: 44,
                        height: 44,
                        child: FoxMascot(size: 44),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),

                  // Hi, name
                  Expanded(
                    child: Text(
                      context.l10n.home_greeting('John Deo'),
                      style: AppTextStyles.font(context,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.white),
                    ),
                  ),

                  // Language pill
                  ValueListenableBuilder<Locale>(
                    valueListenable: LocaleProvider.of(context),
                    builder: (context, locale, _) {
                      final (flag, label) = switch (locale.languageCode) {
                        'fr' => ('🇫🇷', 'FR'),
                        'ar' => ('🇸🇦', 'عربية'),
                        _ =>  ('🇬🇧', 'ENG'),
                      };
                      return GestureDetector(
                        onTap: () => showLanguagePicker(context),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(flag,
                                  style: const TextStyle(fontSize: 14)),
                              const SizedBox(width: 4),
                              Text(
                                label,
                                style: AppTextStyles.font(context,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.white),
                              ),
                              const SizedBox(width: 2),
                              const Icon(Icons.keyboard_arrow_down,
                                  color: AppColors.white, size: 14),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 10),

                  // Bell
                  GestureDetector(
                    onTap: onNotificationTap,
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.notifications_outlined,
                          color: AppColors.white, size: 20),
                    ),
                  ),
                ],
              ),
            ),

            // Points bar
            Padding(
              padding:
                  const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.emoji_events_rounded,
                          color: AppColors.white, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.l10n.home_label_yourPoints,
                          style: AppTextStyles.font(context,
                              fontSize: 12,
                              color: Colors.white.withValues(alpha: 0.85)),
                        ),
                        Text(
                          '150',
                          style: AppTextStyles.font(context,
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: AppColors.white),
                        ),
                      ],
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => Navigator.pushNamed(context, '/rewards'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            const Text('🏆',
                                style: TextStyle(fontSize: 16)),
                            const SizedBox(width: 6),
                            Text(
                              context.l10n.home_button_rewards,
                              style: AppTextStyles.font(context,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String imagePath;
  final VoidCallback onTap;

  const _ActionCard({
    required this.title,
    required this.subtitle,
    required this.imagePath,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.primary, width: 1.5),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.font(context,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: AppTextStyles.font(context,
                        fontSize: 13,
                        color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(6),
                child: Image.asset(imagePath, fit: BoxFit.contain),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StudyRoomRow extends StatelessWidget {
  final String title;
  final String subtitle;
  final String imagePath;
  final VoidCallback onTap;

  const _StudyRoomRow({
    required this.title,
    required this.subtitle,
    required this.imagePath,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.all(6),
                child: Image.asset(imagePath, fit: BoxFit.contain),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.font(context,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary),
                  ),
                  if (subtitle.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: AppTextStyles.font(context,
                          fontSize: 12,
                          color: AppColors.textSecondary),
                    ),
                  ],
                ],
              ),
            ),
            const Icon(Icons.chevron_right,
                color: AppColors.textSecondary, size: 22),
          ],
        ),
      ),
    );
  }
}
