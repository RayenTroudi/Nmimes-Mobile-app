import 'package:flutter/material.dart';
import '../../theme/colors.dart';
import '../../theme/text_styles.dart';
import '../../theme/spacing.dart';
import '../../widgets/avatar_widget.dart';

class ChildrenScreen extends StatelessWidget {
  const ChildrenScreen({super.key});

  static const _children = [
    ('Alex', 'Grade 5', '320 pts'),
    ('Sam', 'Grade 3', '180 pts'),
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
        title: Text('Children', style: AppTextStyles.h3),
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
            border: Border.all(color: AppColors.cardBorder),
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
                        style: AppTextStyles.body
                            .copyWith(fontWeight: FontWeight.w600)),
                    Text(_children[i].$2,
                        style: AppTextStyles.bodySmall),
                    Text(_children[i].$3,
                        style: AppTextStyles.bodySmall
                            .copyWith(color: AppColors.primary)),
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
