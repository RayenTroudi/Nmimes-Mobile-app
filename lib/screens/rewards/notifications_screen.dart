import 'package:flutter/material.dart';
import '../../l10n/l10n_extension.dart';
import '../../theme/colors.dart';
import '../../theme/text_styles.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    final items = [
      _Notif(
        title: l10n.notifications_item1_title,
        body: l10n.notifications_item1_body,
        time: '12:30 pm',
        isRead: false,
      ),
      _Notif(
        title: l10n.notifications_item2_title,
        body: l10n.notifications_item2_body,
        time: '8:30 am',
        isRead: false,
      ),
      _Notif(
        title: l10n.notifications_item3_title,
        body: l10n.notifications_item3_body,
        time: l10n.notifications_time_yesterday,
        isRead: true,
      ),
    ];

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
                        l10n.notifications_title,
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
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                itemCount: items.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (_, i) => _NotifCard(item: items[i]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Notif {
  final String title;
  final String body;
  final String time;
  final bool isRead;
  const _Notif(
      {required this.title,
      required this.body,
      required this.time,
      required this.isRead});
}

class _NotifCard extends StatelessWidget {
  final _Notif item;
  const _NotifCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final iconColor =
        item.isRead ? AppColors.textHint : AppColors.primary;
    final iconBg = item.isRead
        ? const Color(0xFFEEEEEE)
        : AppColors.primary.withValues(alpha: 0.12);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.notifications_rounded,
                color: iconColor, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        item.title,
                        style: AppTextStyles.font(context,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: item.isRead
                              ? AppColors.textSecondary
                              : AppColors.textPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      item.time,
                      style: AppTextStyles.font(context,
                        fontSize: 12,
                        color: AppColors.textHint,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  item.body,
                  style: AppTextStyles.font(context,
                    fontSize: 13,
                    color: item.isRead
                        ? AppColors.textHint
                        : AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
