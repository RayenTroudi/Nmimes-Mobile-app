import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/colors.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  static const _items = [
    _Notif(
      title: 'Snap & Send',
      body: "Let's solve a quick problem and earn points!",
      time: '12:30 pm',
      isRead: false,
    ),
    _Notif(
      title: 'New Challenge Unlocked!',
      body: 'Test yourself and win cool rewards.',
      time: '8:30 am',
      isRead: false,
    ),
    _Notif(
      title: 'Awesome Job!',
      body: 'You completed a challenge and earned a badge!',
      time: 'Yesterday',
      isRead: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
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
                        'Notifications',
                        style: GoogleFonts.poppins(
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
                itemCount: _items.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (_, i) => _NotifCard(item: _items[i]),
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
                        style: GoogleFonts.poppins(
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
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: AppColors.textHint,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  item.body,
                  style: GoogleFonts.poppins(
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
