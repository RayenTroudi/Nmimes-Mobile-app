import 'package:flutter/material.dart';
import '../../l10n/l10n_extension.dart';
import '../../theme/text_styles.dart';
import 'snap_widgets.dart';

class SnapHomeworkCameraScreen extends StatelessWidget {
  const SnapHomeworkCameraScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_back,
                        color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    l.snap_title_homework,
                    style: AppTextStyles.font(context,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            // Live camera preview + controls
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SnapCameraPreview(
                  onCapture: (_) =>
                      Navigator.pushNamed(context, '/snap-hw-captured'),
                  nextRoute: '/snap-hw-captured',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
