import 'package:flutter/material.dart';
import '../../l10n/l10n_extension.dart';
import '../../theme/colors.dart';
import '../../theme/text_styles.dart';

class FormulaDetailScreen extends StatelessWidget {
  const FormulaDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    final sections = [
      _Section(l10n.formulaDetail_section_addition, [
        _Rule('a + 0 = a', l10n.formulaDetail_note_addZero),
        _Rule('a + b = b + a', l10n.formulaDetail_note_switchPlaces),
      ]),
      _Section(l10n.formulaDetail_section_subtraction, [
        _Rule('a - 0 = a', null),
        _Rule('a - a = 0', null),
      ]),
      _Section(l10n.formulaDetail_section_basicUnknown, [
        _Rule('x + a = b', null),
        _Rule('x - a = b', null),
        _Rule('a × x = b', null),
        _Rule('x ÷ a = b', null),
      ]),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 12, 16, 8),
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
                        l10n.savedFormulas_title,
                        style: AppTextStyles.font(context,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {},
                    child: const Padding(
                      padding: EdgeInsets.all(8),
                      child: Icon(Icons.search_rounded,
                          color: AppColors.textPrimary, size: 24),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                itemCount: sections.length,
                separatorBuilder: (_, _) => const SizedBox(height: 14),
                itemBuilder: (_, i) => _SectionCard(section: sections[i]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Data models ──────────────────────────────────────────────────────────────

class _Section {
  final String title;
  final List<_Rule> rules;
  const _Section(this.title, this.rules);
}

class _Rule {
  final String formula;
  final String? note;
  const _Rule(this.formula, this.note);
}

// ─── Section card ─────────────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  final _Section section;
  const _SectionCard({required this.section});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            section.title,
            style: AppTextStyles.font(context,
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.blue,
            ),
          ),
          const SizedBox(height: 12),
          ...section.rules.asMap().entries.map((entry) {
            final idx = entry.key + 1;
            final rule = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$idx. ${rule.formula}',
                    style: AppTextStyles.font(context,
                      fontSize: 14,
                      color: AppColors.textPrimary,
                      height: 1.4,
                    ),
                  ),
                  if (rule.note != null)
                    Padding(
                      padding: const EdgeInsetsDirectional.only(start: 16, top: 2),
                      child: Text(
                        rule.note!,
                        style: AppTextStyles.font(context,
                          fontSize: 13,
                          color: AppColors.textSecondary,
                          height: 1.4,
                        ),
                      ),
                    ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
