import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/colors.dart';
import 'snap_widgets.dart';

class SnapLessonScreen extends StatelessWidget {
  const SnapLessonScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
                    'Snap a Lesson',
                    style: GoogleFonts.poppins(
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
                    const Expanded(
                      child: SnapCameraViewfinder(
                          hint: 'Point at your lesson'),
                    ),
                    const SizedBox(height: 24),
                    SnapActionButton(
                      label: 'Take Photo',
                      filled: true,
                      icon: Icons.camera_alt_rounded,
                      onTap: () =>
                          Navigator.pushNamed(context, '/snap-captured'),
                    ),
                    const SizedBox(height: 12),
                    SnapActionButton(
                      label: 'Upload Photo',
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
