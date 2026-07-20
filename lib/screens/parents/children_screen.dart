import 'package:flutter/material.dart';
import '../../theme/colors.dart';
import '../../theme/text_styles.dart';
import '../../theme/spacing.dart';
import '../../widgets/avatar_widget.dart';
import '../../l10n/l10n_extension.dart';

class ChildrenScreen extends StatelessWidget {
  const ChildrenScreen({super.key});

  static const _children = [
    ('Alex', 'Grade 5', '320 pts'),
    ('Sam', 'Grade 3', '180 pts'),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(l10n.children_title, style: AppTextStyles.font(context, fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: AppColors.primary),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(AppSpacing.lg),
        itemCount: _children.length,
        separatorBuilder: (_, i) => const SizedBox(height: 8),
        itemBuilder: (ctx, i) => Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border, width: 2),
          ),
          child: Row(
            children: [
              AvatarWidget(
                  initials: _children[i].$1[0], radius: 28),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_children[i].$1,
                        style: AppTextStyles.font(ctx, fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                    Text(_children[i].$2,
                        style: AppTextStyles.font(ctx, fontSize: 12, color: AppColors.textSecondary)),
                    Text(_children[i].$3,
                        style: AppTextStyles.font(ctx, fontSize: 12, color: AppColors.primary)),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit_outlined,
                    color: AppColors.textSecondary),
                onPressed: () =>
                    Navigator.pushNamed(ctx, '/edit-child'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
