import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/colors.dart';
import 'snap_widgets.dart';

class SnapHomeworkCameraScreen extends StatefulWidget {
  const SnapHomeworkCameraScreen({super.key});

  @override
  State<SnapHomeworkCameraScreen> createState() =>
      _SnapHomeworkCameraScreenState();
}

class _SnapHomeworkCameraScreenState extends State<SnapHomeworkCameraScreen> {
  bool _flashOn = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_back,
                        color: AppColors.textPrimary, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Snap a Homework',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  // Flash toggle button
                  GestureDetector(
                    onTap: () => setState(() => _flashOn = !_flashOn),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: AppColors.cardBorder,
                          width: 1.5,
                        ),
                      ),
                      child: Icon(
                        _flashOn ? Icons.flash_on : Icons.flash_off,
                        color: _flashOn
                            ? AppColors.primary
                            : AppColors.textSecondary,
                        size: 22,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Camera viewfinder — expands to fill space
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SnapCameraViewfinder(hint: ''),
              ),
            ),

            // Bottom camera controls
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 28),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Gallery button
                  GestureDetector(
                    onTap: () =>
                        Navigator.pushNamed(context, '/snap-hw-captured'),
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.cardBorder,
                          width: 1.5,
                        ),
                      ),
                      child: const Icon(
                        Icons.photo_library_outlined,
                        color: AppColors.textPrimary,
                        size: 24,
                      ),
                    ),
                  ),

                  // Shutter button
                  GestureDetector(
                    onTap: () =>
                        Navigator.pushNamed(context, '/snap-hw-captured'),
                    child: Container(
                      width: 72,
                      height: 72,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),

                  // Flip camera button
                  GestureDetector(
                    onTap: () {},
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.cardBorder,
                          width: 1.5,
                        ),
                      ),
                      child: const Icon(
                        Icons.flip_camera_ios_outlined,
                        color: AppColors.textPrimary,
                        size: 24,
                      ),
                    ),
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
