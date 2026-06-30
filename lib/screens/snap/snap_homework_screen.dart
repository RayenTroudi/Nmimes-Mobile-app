import 'package:flutter/material.dart';
import '../../l10n/l10n_extension.dart';
import '../../theme/text_styles.dart';
import 'snap_widgets.dart';

class SnapHomeworkScreen extends StatelessWidget {
  const SnapHomeworkScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Scaffold(
      backgroundColor: Colors.black,
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SnapQuickTipsCard(),
            ),
            const SizedBox(height: 12),
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
