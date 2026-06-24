import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/colors.dart';

class SavedFormulasScreen extends StatelessWidget {
  const SavedFormulasScreen({super.key});

  static const _categories = [
    _Category('Algebra', Color(0xFF35A468), Icons.calculate_outlined),
    _Category('Statistics', Color(0xFF058BC4), Icons.bar_chart_rounded),
    _Category('Geometry', Color(0xFFE97D9C), Icons.category_outlined),
    _Category('Calculus', Color(0xFFF59E0B), Icons.auto_graph_rounded),
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
                        'Saved Formulas',
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
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                child: GridView.builder(
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                    childAspectRatio: 1.0,
                  ),
                  itemCount: _categories.length,
                  itemBuilder: (_, i) => _CategoryCard(
                    cat: _categories[i],
                    onTap: () =>
                        Navigator.pushNamed(context, '/formula-detail'),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Category {
  final String label;
  final Color color;
  final IconData icon;
  const _Category(this.label, this.color, this.icon);
}

class _CategoryCard extends StatelessWidget {
  final _Category cat;
  final VoidCallback onTap;
  const _CategoryCard({required this.cat, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: cat.color,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(cat.icon, color: Colors.white, size: 52),
            const SizedBox(height: 14),
            Text(
              cat.label,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
