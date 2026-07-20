import 'package:flutter/material.dart';
import '../../l10n/l10n_extension.dart';
import '../../theme/colors.dart';
import '../../theme/text_styles.dart';
import '../../widgets/bounce_in.dart';

class ClaimRewardScreen extends StatelessWidget {
  const ClaimRewardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 12, 20, 8),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Padding(
                      padding: EdgeInsets.all(8),
                      child: Icon(Icons.arrow_back,
                          color: AppColors.textPrimary, size: 22),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        l10n.claimReward_title,
                        style: AppTextStyles.font(context,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 38),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Fox image
                    Center(
                      child: BounceIn(
                        child: Image.asset(
                          'assets/images/fox_sunglasses.png',
                          width: 140,
                          height: 140,
                          fit: BoxFit.contain,
                          errorBuilder: (_, _, _) => const Icon(
                            Icons.pets_rounded,
                            color: AppColors.primary,
                            size: 100,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Title
                    Text(
                      l10n.claimReward_rewardTitle,
                      style: AppTextStyles.font(context,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Partner row
                    Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: const BoxDecoration(
                            color: Color(0xFF4A4A4A),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.store_rounded,
                              color: Colors.white, size: 20),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          l10n.claimReward_partner,
                          style: AppTextStyles.font(context,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Description
                    Text(
                      l10n.claimReward_description,
                      style: AppTextStyles.font(context,
                        fontSize: 14,
                        color: AppColors.textSecondary,
                        height: 1.55,
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Validity
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: l10n.claimReward_validUntil,
                            style: AppTextStyles.font(context,
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          TextSpan(
                            text: l10n.claimReward_validDate,
                            style: AppTextStyles.font(context,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // How to use
                    Text(
                      l10n.claimReward_howToUse,
                      style: AppTextStyles.font(context,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ...[
                      l10n.claimReward_step1,
                      l10n.claimReward_step2,
                      l10n.claimReward_step3,
                    ].map((step) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                margin: const EdgeInsetsDirectional.only(top: 7, end: 10),
                                decoration: const BoxDecoration(
                                  color: AppColors.textSecondary,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  step,
                                  style: AppTextStyles.font(context,
                                    fontSize: 14,
                                    color: AppColors.textSecondary,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )),
                    const SizedBox(height: 24),

                    // Coupon ticket
                    _CouponTicket(),
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

// ─── Coupon ticket ────────────────────────────────────────────────────────────

class _CouponTicket extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        height: 110,
        child: Row(
          children: [
            // Left orange half
            Expanded(
              flex: 2,
              child: Container(
                color: AppColors.primary,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '20%',
                      style: AppTextStyles.font(context,
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      l10n.claimReward_coupon_discount,
                      style: AppTextStyles.font(context,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Notch divider
            CustomPaint(
              size: const Size(16, 110),
              painter: _NotchPainter(),
            ),

            // Right cream half
            Expanded(
              flex: 3,
              child: Container(
                color: const Color(0xFFFAEDD5),
                padding: const EdgeInsets.fromLTRB(12, 0, 16, 0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.claimReward_coupon_label,
                      style: AppTextStyles.font(context,
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      'NMIMES20',
                      style: AppTextStyles.font(context,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(l10n.claimReward_snackbar),
                          duration: const Duration(seconds: 2),
                        ),
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          l10n.claimReward_coupon_button,
                          style: AppTextStyles.font(context,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
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

class _NotchPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = AppColors.background;
    final orange = Paint()..color = AppColors.primary;
    final cream = Paint()..color = const Color(0xFFFAEDD5);

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width / 2, size.height), orange);
    canvas.drawRect(
        Rect.fromLTWH(size.width / 2, 0, size.width / 2, size.height), cream);

    // Top notch
    canvas.drawCircle(Offset(size.width / 2, 0), size.width * 0.7, paint);
    // Bottom notch
    canvas.drawCircle(
        Offset(size.width / 2, size.height), size.width * 0.7, paint);

    // Dashed line
    final dashPaint = Paint()
      ..color = AppColors.background
      ..strokeWidth = 1.5;
    double y = size.width;
    while (y < size.height - size.width) {
      canvas.drawLine(
          Offset(size.width / 2, y), Offset(size.width / 2, y + 5), dashPaint);
      y += 9;
    }
  }

  @override
  bool shouldRepaint(_) => false;
}
