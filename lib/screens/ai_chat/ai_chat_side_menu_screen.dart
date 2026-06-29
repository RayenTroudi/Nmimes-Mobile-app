import 'package:flutter/material.dart';
import '../../l10n/l10n_extension.dart';
import '../../theme/colors.dart';
import '../../theme/text_styles.dart';

class AIChatSideMenuScreen extends StatelessWidget {
  const AIChatSideMenuScreen({super.key});

  static const _history = [
    _HistoryItem('solve 2x+5=13', true),
    _HistoryItem('solve 2x+3=7', false),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return Material(
      color: Colors.transparent,
      child: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          color: Colors.black.withValues(alpha: 0.3),
          child: Align(
            // In RTL the menu slides in from the right
            alignment: isRtl ? Alignment.centerRight : Alignment.centerLeft,
            child: GestureDetector(
              onTap: () {},
              child: Container(
                width: MediaQuery.of(context).size.width * 0.82,
                height: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: isRtl
                      ? const BorderRadius.horizontal(left: Radius.circular(24))
                      : const BorderRadius.horizontal(right: Radius.circular(24)),
                ),
                child: SafeArea(
                  child: Directionality(
                    textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Close button — left in RTL (x:20 in Figma), right in LTR
                        Align(
                          alignment: isRtl ? Alignment.topLeft : Alignment.topRight,
                          child: GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Padding(
                              padding: isRtl
                                  ? const EdgeInsets.fromLTRB(20, 16, 0, 8)
                                  : const EdgeInsets.fromLTRB(0, 16, 20, 8),
                              child: const Icon(Icons.close,
                                  color: AppColors.textSecondary, size: 22),
                            ),
                          ),
                        ),

                        // + New Chat
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
                            child: Row(
                              children: [
                                const Icon(Icons.add,
                                    color: AppColors.textPrimary, size: 22),
                                const SizedBox(width: 8),
                                Text(
                                  l10n.aiChat_menu_newChat,
                                  style: AppTextStyles.font(context,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const Divider(color: AppColors.cardBorder, height: 1),
                        const SizedBox(height: 20),

                        // History title
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Text(
                            l10n.aiChat_menu_history,
                            style: AppTextStyles.font(context,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // History items
                        ...List.generate(_history.length, (i) {
                          final item = _history[i];
                          return Column(
                            children: [
                              GestureDetector(
                                onTap: () => Navigator.pop(context),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 24, vertical: 14),
                                  child: Row(
                                    children: [
                                      // Orange dot on the left (start) — Figma x:20
                                      if (item.isActive) ...[
                                        Container(
                                          width: 8,
                                          height: 8,
                                          decoration: const BoxDecoration(
                                            color: AppColors.primary,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                      ],
                                      Expanded(
                                        child: Text(
                                          item.title,
                                          style: AppTextStyles.font(context,
                                            fontSize: 14,
                                            color: item.isActive
                                                ? AppColors.textPrimary
                                                : AppColors.textSecondary,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const Divider(
                                  color: AppColors.cardBorder,
                                  height: 1,
                                  indent: 24,
                                  endIndent: 24),
                            ],
                          );
                        }),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}


class _HistoryItem {
  final String title;
  final bool isActive;
  const _HistoryItem(this.title, this.isActive);
}
