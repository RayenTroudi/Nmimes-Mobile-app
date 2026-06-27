import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/colors.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  // 0 = My Plan, 1 = Select Plan
  int _tab = 0;
  // false = Monthly, true = Yearly
  bool _yearly = false;

  static const _features = [
    'Unlimited Snap & Send',
    'Unlimited AI Chat',
    'Unlimited Challenges',
    'Unlimited Rewards',
    'Teach Back to AI',
  ];

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
                    'Subscription',
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                _tab == 0 ? 'My Plan' : 'Select Plan',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ),

            const SizedBox(height: 16),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _tab == 0 ? _buildMyPlan() : _buildSelectPlan(),
            ),

            const Spacer(),

            // Bottom button
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              child: SizedBox(
                width: double.infinity,
                height: 70,
                child: ElevatedButton(
                  onPressed: () {
                    if (_tab == 0) {
                      setState(() => _tab = 1);
                    } else {
                      Navigator.pushNamed(context, '/payment');
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                      side: const BorderSide(color: AppColors.white, width: 2),
                    ),
                  ),
                  child: Text(
                    _tab == 0 ? 'Update Subscription' : 'Select Plan',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── My Plan ──────────────────────────────────────────────────────────────
  Widget _buildMyPlan() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: _PriceDisplay(
                amount: '39.99', color: AppColors.textPrimary),
          ),
          const SizedBox(height: 20),
          ..._features.map((f) => _FeatureRow(
                label: f,
                checkColor: AppColors.textPrimary,
                textColor: AppColors.textPrimary,
              )),
          const SizedBox(height: 16),
          Text(
            'Valid till: 24 Feb 2026',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  // ── Select Plan ──────────────────────────────────────────────────────────
  Widget _buildSelectPlan() {
    // Monthly → full orange card; Yearly → white card with orange accents
    final isMonthly = !_yearly;
    final cardBg = isMonthly ? AppColors.primary : AppColors.white;
    final priceColor = isMonthly ? AppColors.white : AppColors.primary;
    final checkColor = isMonthly ? AppColors.white : AppColors.primary;
    final textColor = isMonthly ? AppColors.white : AppColors.textPrimary;
    final price = _yearly ? '449.99' : '39.99';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Toggle pills
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _PlanPill(
                label: 'Monthly',
                selected: !_yearly,
                isOnOrange: isMonthly,
                onTap: () => setState(() => _yearly = false),
              ),
              const SizedBox(width: 12),
              _PlanPill(
                label: 'Yearly',
                selected: _yearly,
                isOnOrange: isMonthly,
                onTap: () => setState(() => _yearly = true),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Price
          Center(child: _PriceDisplay(amount: price, color: priceColor)),
          const SizedBox(height: 20),

          // Features
          ..._features.map((f) => _FeatureRow(
                label: f,
                checkColor: checkColor,
                textColor: textColor,
              )),
        ],
      ),
    );
  }
}

// ── Shared widgets ────────────────────────────────────────────────────────────

class _PriceDisplay extends StatelessWidget {
  final String amount;
  final Color color;

  const _PriceDisplay({required this.amount, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Text(
            '\$',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w400,
              color: color,
            ),
          ),
        ),
        Text(
          amount,
          style: TextStyle(
            fontSize: 52,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _FeatureRow extends StatelessWidget {
  final String label;
  final Color checkColor;
  final Color textColor;

  const _FeatureRow({
    required this.label,
    required this.checkColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Icon(Icons.check, color: checkColor, size: 16),
          const SizedBox(width: 12),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _PlanPill extends StatelessWidget {
  final String label;
  final bool selected;
  final bool isOnOrange;
  final VoidCallback onTap;

  const _PlanPill({
    required this.label,
    required this.selected,
    required this.isOnOrange,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // On orange card: selected pill is white-tinted; on white card: selected pill is orange-tinted
    final bg = selected
        ? (isOnOrange
            ? AppColors.white.withValues(alpha: 0.25)
            : AppColors.primary.withValues(alpha: 0.12))
        : Colors.transparent;
    final borderColor = isOnOrange
        ? AppColors.white.withValues(alpha: selected ? 0.7 : 0.35)
        : AppColors.primary.withValues(alpha: selected ? 1.0 : 0.35);
    final textColor =
        isOnOrange ? AppColors.white : AppColors.primary;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding:
            const EdgeInsets.symmetric(horizontal: 28, vertical: 13),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(50),
          border: Border.all(color: borderColor),
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
      ),
    );
  }
}
