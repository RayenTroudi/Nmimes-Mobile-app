import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/locale_provider.dart';
import '../theme/colors.dart';

const _languages = [
  (code: 'en', flag: '🇬🇧', label: 'English'),
  (code: 'fr', flag: '🇫🇷', label: 'Français'),
  (code: 'ar', flag: '🇸🇦', label: 'العربية'),
];

void showLanguagePicker(BuildContext context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => _LanguagePickerSheet(
      notifier: LocaleProvider.of(context),
    ),
  );
}

class _LanguagePickerSheet extends StatelessWidget {
  final LocaleNotifier notifier;
  const _LanguagePickerSheet({required this.notifier});

  @override
  Widget build(BuildContext context) {
    final current = notifier.value.languageCode;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFDEDEDE),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            for (final lang in _languages) ...[
              ListTile(
                leading: Text(lang.flag, style: const TextStyle(fontSize: 24)),
                title: Text(
                  lang.label,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                trailing: current == lang.code
                    ? const Icon(Icons.check_rounded, color: AppColors.primary)
                    : null,
                onTap: () {
                  notifier.setLocale(Locale(lang.code));
                  Navigator.pop(context);
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}
