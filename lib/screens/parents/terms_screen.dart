import 'package:flutter/material.dart';
import '../../theme/colors.dart';
import '../../theme/text_styles.dart';
import '../../l10n/l10n_extension.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
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
                    l10n.terms_title,
                    style: AppTextStyles.font(context,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),

            // Body
            Expanded(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: _buildContent(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    final l10n = context.l10n;
    final sections = [
      _Section(l10n.terms_section1_title, l10n.terms_section1_body),
      _Section(l10n.terms_section2_title, l10n.terms_section2_body),
      _Section(l10n.terms_section3_title, l10n.terms_section3_body),
      _Section(l10n.terms_section4_title, l10n.terms_section4_body),
      _Section(l10n.terms_section5_title, l10n.terms_section5_body),
      _Section(l10n.terms_section6_title, l10n.terms_section6_body),
      _Section(l10n.terms_section7_title, l10n.terms_section7_body),
      _Section(l10n.terms_section8_title, l10n.terms_section8_body),
      _Section(l10n.terms_section9_title, l10n.terms_section9_body),
      _Section(l10n.terms_section10_title, l10n.terms_section10_body),
      _Section(l10n.terms_section11_title, l10n.terms_section11_body),
      _Section(l10n.terms_section12_title, l10n.terms_section12_body),
      _Section(l10n.terms_section13_title, l10n.terms_section13_body),
      _Section(l10n.terms_section14_title, l10n.terms_section14_body),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...sections.map((s) => _SectionWidget(section: s)),
        const SizedBox(height: 8),
        Text(
          l10n.terms_finalMessage,
          style: AppTextStyles.font(context,
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
            height: 1.6,
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

class _Section {
  final String title;
  final String body;
  const _Section(this.title, this.body);
}

class _SectionWidget extends StatelessWidget {
  final _Section section;
  const _SectionWidget({required this.section});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            section.title,
            style: AppTextStyles.font(context,
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            section.body,
            style: AppTextStyles.font(context,
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: AppColors.textPrimary,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
