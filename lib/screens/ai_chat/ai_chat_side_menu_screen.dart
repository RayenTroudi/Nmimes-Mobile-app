import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/colors.dart';

class AIChatSideMenuScreen extends StatelessWidget {
  const AIChatSideMenuScreen({super.key});

  static const _history = [
    _HistoryItem('solve 2x+5=13', true),
    _HistoryItem('solve 2x+3=7', false),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withValues(alpha: 0.3),
      body: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          color: Colors.transparent,
          child: Align(
            alignment: Alignment.centerLeft,
            child: GestureDetector(
              onTap: () {}, // absorb taps inside menu
              child: Container(
                width: MediaQuery.of(context).size.width * 0.82,
                height: double.infinity,
                decoration: const BoxDecoration(
                  color: AppColors.background,
                  borderRadius:
                      BorderRadius.horizontal(right: Radius.circular(24)),
                ),
                child: SafeArea(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Close button
                      Align(
                        alignment: Alignment.topRight,
                        child: GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: const Padding(
                            padding: EdgeInsets.fromLTRB(0, 16, 20, 8),
                            child: Icon(Icons.close,
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
                              Text(
                                '+  ',
                                style: GoogleFonts.poppins(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              Text(
                                'New Chat',
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const Divider(
                          color: AppColors.cardBorder, height: 1),
                      const SizedBox(height: 20),

                      // History title
                      Padding(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 24),
                        child: Text(
                          'History',
                          style: GoogleFonts.poppins(
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
                                    Expanded(
                                      child: Text(
                                        item.title,
                                        style: GoogleFonts.poppins(
                                          fontSize: 14,
                                          color: item.isActive
                                              ? AppColors.textPrimary
                                              : AppColors.textSecondary,
                                        ),
                                      ),
                                    ),
                                    if (item.isActive)
                                      Container(
                                        width: 10,
                                        height: 10,
                                        decoration: const BoxDecoration(
                                          color: AppColors.primary,
                                          shape: BoxShape.circle,
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
    );
  }
}

class _HistoryItem {
  final String title;
  final bool isActive;
  const _HistoryItem(this.title, this.isActive);
}
