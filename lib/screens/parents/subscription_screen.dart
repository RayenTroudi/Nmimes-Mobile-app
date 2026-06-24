import 'package:flutter/material.dart';
import '../../theme/colors.dart';
import '../../theme/text_styles.dart';
import '../../theme/spacing.dart';
import '../../widgets/primary_button.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  int _selected = 1;

  static const _plans = [
    _Plan('Basic', 'Free', ['5 snaps/month', '10 challenges', 'Basic AI chat']),
    _Plan('Pro', '\$4.99/mo', ['Unlimited snaps', 'All challenges', 'Full AI chat', 'Rewards']),
    _Plan('Family', '\$9.99/mo', ['Up to 3 children', 'All Pro features', 'Parent dashboard']),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Subscription', style: AppTextStyles.h3),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Column(
            children: [
              const SizedBox(height: AppSpacing.xl),
              Text('Choose a Plan', style: AppTextStyles.h2),
              const SizedBox(height: AppSpacing.xxl),
              Expanded(
                child: ListView.separated(
                  itemCount: _plans.length,
                  separatorBuilder: (_, i) => const SizedBox(height: 12),
                  itemBuilder: (_, i) {
                    final active = _selected == i;
                    return GestureDetector(
                      onTap: () => setState(() => _selected = i),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        decoration: BoxDecoration(
                          color: active
                              ? AppColors.primary.withValues(alpha: 0.06)
                              : AppColors.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: active ? AppColors.primary : AppColors.cardBorder,
                            width: active ? 2 : 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(_plans[i].name,
                                    style: AppTextStyles.h3.copyWith(
                                        color: active ? AppColors.primary : null)),
                                const Spacer(),
                                Text(_plans[i].price,
                                    style: AppTextStyles.h3.copyWith(
                                        color: active ? AppColors.primary : AppColors.textSecondary)),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            ..._plans[i].features.map((f) => Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Row(
                                    children: [
                                      Icon(Icons.check_circle_outline,
                                          size: 16,
                                          color: active ? AppColors.primary : AppColors.textSecondary),
                                      const SizedBox(width: 6),
                                      Text(f, style: AppTextStyles.bodySmall),
                                    ],
                                  ),
                                )),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              PrimaryButton(
                label: _plans[_selected].price == 'Free'
                    ? 'Continue with Free'
                    : 'Subscribe — ${_plans[_selected].price}',
                onTap: () => Navigator.pushNamed(context, '/payment'),
              ),
              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }
}

class _Plan {
  final String name;
  final String price;
  final List<String> features;
  const _Plan(this.name, this.price, this.features);
}
