import 'package:flutter/material.dart';
import '../../l10n/l10n_extension.dart';
import '../../theme/colors.dart';
import '../../theme/text_styles.dart';
import 'snap_widgets.dart';

class SnapLessonScreen extends StatelessWidget {
  const SnapLessonScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_back,
                        color: AppColors.textPrimary, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    l.snap_title_lesson,
                    style: AppTextStyles.font(context,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    const SnapQuickTipsCard(),
                    const SizedBox(height: 20),
                    Expanded(
                      child: SnapCameraViewfinder(
                          hint: l.snap_hint_lesson),
                    ),
                    const SizedBox(height: 24),
                    SnapActionButton(
                      label: l.snap_button_takePhoto,
                      filled: true,
                      icon: Icons.camera_alt_rounded,
                      onTap: () =>
                          Navigator.pushNamed(context, '/snap-captured'),
                    ),
                    const SizedBox(height: 12),
                    SnapActionButton(
                      label: l.snap_button_uploadPhoto,
                      filled: false,
                      icon: Icons.upload_rounded,
                      onTap: () =>
                          Navigator.pushNamed(context, '/snap-captured'),
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
}
