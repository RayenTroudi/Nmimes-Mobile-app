import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/colors.dart';

class FormulaDetailScreen extends StatelessWidget {
  const FormulaDetailScreen({super.key});

  static const _sections = [
    _Section('Addition Rules', [
      _Rule('a + 0 = a', '(Add zero, number stays same)'),
      _Rule('a + b = b + a', '(You can switch places)'),
    ]),
    _Section('Subtraction Rules', [
      _Rule('a - 0 = a', null),
      _Rule('a - a = 0', null),
    ]),
    _Section('Basic Unknown Number Formulas', [
      _Rule('x + a = b', null),
      _Rule('x - a = b', null),
      _Rule('a × x = b', null),
      _Rule('x ÷ a = b', null),
    ]),
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
                        'Saved Formulas',
                        style: GoogleFonts.poppins(
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
                itemCount: _sections.length,
                separatorBuilder: (_, _) => const SizedBox(height: 14),
                itemBuilder: (_, i) => _SectionCard(section: _sections[i]),
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
            style: GoogleFonts.poppins(
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
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: AppColors.textPrimary,
                      height: 1.4,
                    ),
                  ),
                  if (rule.note != null)
                    Padding(
                      padding: const EdgeInsets.only(left: 16, top: 2),
                      child: Text(
                        rule.note!,
                        style: GoogleFonts.poppins(
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
