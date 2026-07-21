import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../l10n/l10n_extension.dart';
import '../../theme/colors.dart';
import '../../theme/text_styles.dart';
import '../../widgets/stagger_in.dart';

/// Saved formulas — the 2x2 category grid.
///
/// Same four cards as before. What changed is that they now arrive in a
/// cascade, press down on a 3D edge like the rest of the app's chunky
/// controls, and carry a soft glow in their own colour instead of sitting as
/// flat blocks.
class SavedFormulasScreen extends StatelessWidget {
  const SavedFormulasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    final categories = [
      _Category(l10n.savedFormulas_cat_algebra, const Color(0xFF35A468),
          Icons.calculate_outlined),
      _Category(l10n.savedFormulas_cat_statistics, const Color(0xFF058BC4),
          Icons.bar_chart_rounded),
      _Category(l10n.savedFormulas_cat_geometry, const Color(0xFFE97D9C),
          Icons.category_outlined),
      _Category(l10n.savedFormulas_cat_calculus, const Color(0xFFF59E0B),
          Icons.auto_graph_rounded),
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
                  _TapIcon(
                    onTap: () => Navigator.pop(context),
                    icon: Icons.arrow_back,
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        l10n.savedFormulas_title,
                        style: AppTextStyles.font(
                          context,
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
                  // Four fixed cards that always fit: nothing scrolls, and a
                  // bouncing scroll physics on a non-scrolling grid just
                  // makes the cascade feel loose.
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                    childAspectRatio: 1.0,
                  ),
                  itemCount: categories.length,
                  itemBuilder: (_, i) => StaggerIn(
                    index: i,
                    // Slightly longer travel than the default so a grid of
                    // large blocks reads as dealing cards rather than a
                    // twitch.
                    offset: 24,
                    step: const Duration(milliseconds: 80),
                    child: _CategoryCard(
                      cat: categories[i],
                      onTap: () {
                        HapticFeedback.mediumImpact();
                        Navigator.pushNamed(context, '/formula-detail');
                      },
                    ),
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

/// A category tile with the app's chunky 3D press.
///
/// The card sits [_edge] pixels above a darker slab of its own colour; on
/// press it drops onto that slab, which is the same affordance
/// [ChunkyButton] gives buttons elsewhere. Reimplemented rather than reused
/// because ChunkyButton is fixed-height and this must fill a square grid cell.
class _CategoryCard extends StatefulWidget {
  final _Category cat;
  final VoidCallback onTap;
  const _CategoryCard({required this.cat, required this.onTap});

  @override
  State<_CategoryCard> createState() => _CategoryCardState();
}

class _CategoryCardState extends State<_CategoryCard> {
  static const _edge = 5.0;

  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final color = widget.cat.color;
    final edge = AppColors.edgeFor(color);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: RepaintBoundary(
        child: Stack(
          children: [
            // The 3D slab. Painted as a full-size sibling underneath rather
            // than a boxShadow so it keeps a crisp rounded edge at any size.
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: edge,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
            AnimatedPositioned(
              duration: const Duration(milliseconds: 90),
              curve: Curves.easeOut,
              left: 0,
              right: 0,
              top: _pressed ? _edge : 0,
              bottom: _pressed ? 0 : _edge,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOut,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: _pressed ? 0.15 : 0.32),
                      blurRadius: _pressed ? 4 : 12,
                      offset: Offset(0, _pressed ? 1 : 5),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // The icon leads the press by shrinking a touch further
                    // than the card, which sells the depth.
                    AnimatedScale(
                      scale: _pressed ? 0.92 : 1.0,
                      duration: const Duration(milliseconds: 140),
                      curve: Curves.easeOut,
                      child: Icon(
                        widget.cat.icon,
                        color: Colors.white,
                        size: 52,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        widget.cat.label,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.font(
                          context,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Back icon with a press response, matching the peer learning header.
class _TapIcon extends StatefulWidget {
  final VoidCallback onTap;
  final IconData icon;
  const _TapIcon({required this.onTap, required this.icon});

  @override
  State<_TapIcon> createState() => _TapIconState();
}

class _TapIconState extends State<_TapIcon> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: () {
        HapticFeedback.lightImpact();
        widget.onTap();
      },
      child: AnimatedScale(
        scale: _pressed ? 0.85 : 1.0,
        duration: const Duration(milliseconds: 90),
        curve: Curves.easeOut,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(widget.icon, color: AppColors.textPrimary, size: 22),
        ),
      ),
    );
  }
}
