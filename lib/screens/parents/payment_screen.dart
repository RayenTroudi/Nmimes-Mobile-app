import 'package:flutter/material.dart';
import '../../theme/colors.dart';
import '../../theme/text_styles.dart';
import '../../theme/spacing.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/app_text_field.dart';

class PaymentScreen extends StatelessWidget {
  const PaymentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Payment', style: AppTextStyles.h3),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.xl),
              Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.credit_card,
                        color: AppColors.primary, size: 32),
                    const SizedBox(width: AppSpacing.md),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Pro Plan', style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600)),
                        Text('\$4.99 / month', style: AppTextStyles.bodySmall.copyWith(color: AppColors.primary)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
              Text('Card Details', style: AppTextStyles.h3),
              const SizedBox(height: AppSpacing.md),
              const AppTextField(hint: 'Card number'),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: const [
                  Expanded(child: AppTextField(hint: 'MM / YY')),
                  SizedBox(width: AppSpacing.md),
                  Expanded(child: AppTextField(hint: 'CVV', obscure: true)),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              const AppTextField(hint: 'Cardholder name'),
              const SizedBox(height: AppSpacing.xxxl),
              PrimaryButton(
                label: 'Pay \$4.99',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Payment successful!')),
                  );
                  Navigator.pushNamedAndRemoveUntil(
                      context, '/parents-view', (r) => false);
                },
              ),
              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }
}
