import 'package:flutter/material.dart';
import '../../theme/colors.dart';
import '../../theme/text_styles.dart';
import '../../l10n/l10n_extension.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  int _tab = 0; // 0 = My Plan, 1 = Select Plan

  final _pageCtrl = PageController();
  int _planPage = 0; // 0 = monthly, 1 = yearly

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is int && args == 1 && _tab == 0) {
      _tab = 1;
    }
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  void _goToPage(int page) {
    _pageCtrl.animateToPage(
      page,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final features = [
      l10n.subscription_feature_snapSend,
      l10n.subscription_feature_aiChat,
      l10n.subscription_feature_challenges,
      l10n.subscription_feature_rewards,
      l10n.subscription_feature_teachBack,
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ────────────────────────────────────────────────
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
                    l10n.subscription_title,
                    style: AppTextStyles.font(context,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
              child: Text(
                _tab == 0
                    ? l10n.subscription_tab_myPlan
                    : l10n.subscription_tab_selectPlan,
                style: AppTextStyles.font(context,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ),

            // ── Body (Expanded so button stays at bottom) ─────────────
            Expanded(
              child: _tab == 0
                  ? _MyPlanBody(features: features)
                  : _SelectPlanBody(
                      pageCtrl: _pageCtrl,
                      planPage: _planPage,
                      onPageChanged: (p) => setState(() => _planPage = p),
                      onPillTap: _goToPage,
                      features: features,
                    ),
            ),

            // ── Bottom button ─────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
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
                    _tab == 0
                        ? l10n.subscription_button_updatePlan
                        : l10n.subscription_button_selectPlan,
                    style: AppTextStyles.font(context,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.white,
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
}

// ── My Plan body ──────────────────────────────────────────────────────────────

class _MyPlanBody extends StatelessWidget {
  final List<String> features;
  const _MyPlanBody({required this.features});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.primary),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: _PriceDisplay(
                amount: '39.99',
                color: AppColors.textPrimary,
                badgeLabel: l10n.subscription_badge_perMonth,
                badgeOnOrange: false,
              ),
            ),
            const SizedBox(height: 20),
            ...features.map((f) => _FeatureRow(
                  label: f,
                  checkColor: AppColors.textPrimary,
                  textColor: AppColors.textPrimary,
                )),
            const SizedBox(height: 16),
            Text(
              l10n.subscription_validTill,
              style: AppTextStyles.font(context,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Select Plan body (swipeable) ──────────────────────────────────────────────

class _SelectPlanBody extends StatelessWidget {
  final PageController pageCtrl;
  final int planPage;
  final ValueChanged<int> onPageChanged;
  final ValueChanged<int> onPillTap;
  final List<String> features;

  const _SelectPlanBody({
    required this.pageCtrl,
    required this.planPage,
    required this.onPageChanged,
    required this.onPillTap,
    required this.features,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Column(
      children: [
        // Pill switcher
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _PlanPill(
                label: l10n.subscription_pill_monthly,
                selected: planPage == 0,
                onTap: () => onPillTap(0),
              ),
              const SizedBox(width: 12),
              _PlanPill(
                label: l10n.subscription_pill_yearly,
                selected: planPage == 1,
                onTap: () => onPillTap(1),
                saveBadge: l10n.subscription_save,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // PageView — takes all remaining space
        Expanded(
          child: PageView(
            controller: pageCtrl,
            onPageChanged: onPageChanged,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                child: SingleChildScrollView(
                  child: _PlanCard(
                    isMonthly: true,
                    price: '39.99',
                    badgeLabel: l10n.subscription_badge_perMonth,
                    features: features,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                child: SingleChildScrollView(
                  child: _PlanCard(
                    isMonthly: false,
                    price: '449.99',
                    badgeLabel: l10n.subscription_badge_perYear,
                    features: features,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Dot indicators
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(2, (i) {
              final active = planPage == i;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: active ? 20 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: active
                      ? AppColors.primary
                      : AppColors.primary.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(4),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}

// ── Plan card ─────────────────────────────────────────────────────────────────

class _PlanCard extends StatelessWidget {
  final bool isMonthly;
  final String price;
  final String badgeLabel;
  final List<String> features;

  const _PlanCard({
    required this.isMonthly,
    required this.price,
    required this.badgeLabel,
    required this.features,
  });

  @override
  Widget build(BuildContext context) {
    final cardBg = isMonthly ? AppColors.primary : AppColors.white;
    final checkColor = isMonthly ? AppColors.white : AppColors.primary;
    final textColor = isMonthly ? AppColors.white : AppColors.textPrimary;
    final priceColor = isMonthly ? AppColors.white : AppColors.primary;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: _PriceDisplay(
              amount: price,
              color: priceColor,
              badgeLabel: badgeLabel,
              badgeOnOrange: isMonthly,
            ),
          ),
          const SizedBox(height: 20),
          ...features.map((f) => _FeatureRow(
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
  final String badgeLabel;
  final bool badgeOnOrange;

  const _PriceDisplay({
    required this.amount,
    required this.color,
    required this.badgeLabel,
    required this.badgeOnOrange,
  });

  @override
  Widget build(BuildContext context) {
    final badgeBg = badgeOnOrange
        ? Colors.white.withValues(alpha: 0.25)
        : AppColors.primary.withValues(alpha: 0.12);
    final badgeText = badgeOnOrange ? Colors.white : AppColors.primary;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
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
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
          decoration: BoxDecoration(
            color: badgeBg,
            borderRadius: BorderRadius.circular(50),
          ),
          child: Text(
            badgeLabel,
            style: AppTextStyles.font(context,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: badgeText,
            ),
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
            style: AppTextStyles.font(context,
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
  final VoidCallback onTap;
  final String? saveBadge;

  const _PlanPill({
    required this.label,
    required this.selected,
    required this.onTap,
    this.saveBadge,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 11),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary.withValues(alpha: 0.10)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(50),
          border: Border.all(
            color: selected
                ? AppColors.primary
                : AppColors.primary.withValues(alpha: 0.35),
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: AppTextStyles.font(context,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
            if (saveBadge != null) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  saveBadge!,
                  style: AppTextStyles.font(context,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
