import 'package:flutter/material.dart';
import '../../theme/colors.dart';
import '../../theme/text_styles.dart';
import '../../l10n/l10n_extension.dart';

class ParentsViewScreen extends StatelessWidget {
  const ParentsViewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Stack(
        children: [
          Column(
            children: [
              // Orange top bar
              SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                  child: Row(
                    children: [
                      // Mascot avatar circle
                      Container(
                        width: 40,
                        height: 40,
                        decoration: const BoxDecoration(
                          color: Color(0xFFFFFDFC),
                          shape: BoxShape.circle,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(4),
                          child: Image.asset(
                            'assets/images/foxWithSunGlass.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      const Spacer(),
                      // Language toggle
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.16),
                          borderRadius: BorderRadius.circular(45),
                        ),
                        child: Row(
                          children: [
                            const SizedBox(width: 4),
                            Text(
                              l10n.parentsView_label_eng,
                              style: AppTextStyles.font(context,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.white,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(Icons.keyboard_arrow_down,
                                color: AppColors.white, size: 14),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Settings icon
                      GestureDetector(
                        onTap: () =>
                            Navigator.pushNamed(context, '/settings'),
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.16),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.settings_outlined,
                              color: AppColors.white, size: 20),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Cream scrollable content card
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFF7E8),
                    borderRadius: BorderRadius.vertical(
                        top: Radius.circular(30)),
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Child selector card
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF4E4C3),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.primary),
                          ),
                          child: Row(
                            children: [
                              // Avatar
                              Container(
                                width: 46,
                                height: 46,
                                decoration: const BoxDecoration(
                                  color: AppColors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: ClipOval(
                                  child: Image.asset(
                                    'assets/images/nmimes_celebrate.png',
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                l10n.parentsView_childName,
                                style: AppTextStyles.font(context,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(width: 8),
                              // Edit button
                              GestureDetector(
                                onTap: () => Navigator.pushNamed(
                                    context, '/edit-child'),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: AppColors.white,
                                    borderRadius:
                                        BorderRadius.circular(25),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.edit_outlined,
                                          color: AppColors.primary,
                                          size: 14),
                                      const SizedBox(width: 4),
                                      Text(
                                        l10n.parentsView_button_edit,
                                        style: AppTextStyles.font(context,
                                          fontSize: 10,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const Spacer(),
                              // Chevron
                              const Icon(Icons.keyboard_arrow_down,
                                  color: Color(0xFF5A6677)),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Progress title
                        Text(
                          l10n.parentsView_title_progress(l10n.parentsView_childName),
                          style: AppTextStyles.font(context,
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Weekly Summary card (orange)
                        _InfoCard(
                          color: const Color(0xFFF79C09),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      color: Colors.white
                                          .withValues(alpha: 0.3),
                                      borderRadius:
                                          BorderRadius.circular(13),
                                    ),
                                    child: const Icon(
                                        Icons.bar_chart_rounded,
                                        color: AppColors.white,
                                        size: 26),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    l10n.parentsView_card_weeklySummary,
                                    style: AppTextStyles.font(context,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.white,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              _BulletItem(
                                  l10n.parentsView_bullet_greatProgress,
                                  AppColors.white),
                              _BulletItem(
                                  l10n.parentsView_bullet_completed15,
                                  AppColors.white),
                              _BulletItem(
                                  l10n.parentsView_bullet_practiced4days,
                                  AppColors.white),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Learning Progress chart card (yellow)
                        _InfoCard(
                          color: const Color(0xFFFEF5C4),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.parentsView_card_learningProgress,
                                style: AppTextStyles.font(context,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 16),
                              _SimpleLineChart(legendLabel: l10n.parentsView_chart_legendLabel),
                              const SizedBox(height: 12),
                              _BulletItem(
                                  l10n.parentsView_bullet_accuracy78,
                                  AppColors.textPrimary),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Strength card (green)
                        _InfoCard(
                          color: const Color(0xFFBDEEC6),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 30,
                                    height: 30,
                                    decoration: BoxDecoration(
                                      color: Colors.white
                                          .withValues(alpha: 0.3),
                                      borderRadius:
                                          BorderRadius.circular(7),
                                    ),
                                    child: const Icon(Icons.check_circle,
                                        color: Color(0xFF35A468),
                                        size: 18),
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    l10n.parentsView_card_strength,
                                    style: AppTextStyles.font(context,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              _BulletItem(l10n.parentsView_bullet_strongMultiplication,
                                  AppColors.textPrimary),
                              _BulletItem(l10n.parentsView_bullet_quickEquations,
                                  AppColors.textPrimary),
                              _BulletItem(
                                  l10n.parentsView_bullet_algebraBasics,
                                  AppColors.textPrimary),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Needs More Practice card (pale yellow)
                        _InfoCard(
                          color: const Color(0xFFFDEBBE),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 30,
                                    height: 30,
                                    decoration: BoxDecoration(
                                      color: Colors.white
                                          .withValues(alpha: 0.3),
                                      borderRadius:
                                          BorderRadius.circular(7),
                                    ),
                                    child: const Icon(Icons.warning_amber,
                                        color: Color(0xFFECB213),
                                        size: 18),
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    l10n.parentsView_card_needsMorePractice,
                                    style: AppTextStyles.font(context,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              _BulletItem(l10n.parentsView_bullet_fractions,
                                  AppColors.textPrimary),
                              _BulletItem(l10n.parentsView_bullet_wordProblems,
                                  AppColors.textPrimary),
                              _BulletItem(
                                  l10n.parentsView_bullet_division,
                                  AppColors.textPrimary),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Progress card (cyan)
                        _InfoCard(
                          color: const Color(0xFFC1F3F2),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 30,
                                    height: 30,
                                    decoration: BoxDecoration(
                                      color: Colors.white
                                          .withValues(alpha: 0.3),
                                      borderRadius:
                                          BorderRadius.circular(7),
                                    ),
                                    child: const Icon(Icons.trending_up,
                                        color: Color(0xFF1DBFD4),
                                        size: 18),
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    l10n.parentsView_card_progress,
                                    style: AppTextStyles.font(context,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              _BulletItem(
                                  l10n.parentsView_bullet_consistency,
                                  AppColors.textPrimary),
                              _BulletItem(
                                  l10n.parentsView_bullet_practiced35mins,
                                  AppColors.textPrimary),
                              _BulletItem(
                                  l10n.parentsView_bullet_accuracy62to74,
                                  AppColors.textPrimary),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Suggested Action card (orange)
                        _InfoCard(
                          color: AppColors.primary,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 30,
                                    height: 30,
                                    decoration: BoxDecoration(
                                      color: Colors.white
                                          .withValues(alpha: 0.3),
                                      borderRadius:
                                          BorderRadius.circular(7),
                                    ),
                                    child: const Icon(Icons.lightbulb_outline,
                                        color: AppColors.white, size: 18),
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    l10n.parentsView_card_suggestedAction,
                                    style: AppTextStyles.font(context,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.white,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              _BulletItem(l10n.parentsView_bullet_practiceFractions,
                                  AppColors.white),
                              _BulletItem(
                                  l10n.parentsView_bullet_try2challenges,
                                  AppColors.white),
                              _BulletItem(
                                  l10n.parentsView_bullet_reviewLesson,
                                  AppColors.white),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Add child FAB
          Positioned(
            right: 20,
            bottom: 32,
            child: GestureDetector(
              onTap: () => Navigator.pushNamed(context, '/parent-setup'),
              child: Container(
                width: 60,
                height: 60,
                decoration: const BoxDecoration(
                  color: AppColors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x33000000),
                      blurRadius: 12,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(Icons.add,
                    color: AppColors.primary, size: 28),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final Color color;
  final Widget child;

  const _InfoCard({required this.color, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: child,
    );
  }
}

class _BulletItem extends StatelessWidget {
  final String text;
  final Color color;

  const _BulletItem(this.text, this.color);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Icon(Icons.check, size: 16, color: color),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.font(context,
                fontSize: 14,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SimpleLineChart extends StatelessWidget {
  final String legendLabel;
  const _SimpleLineChart({required this.legendLabel});

  @override
  Widget build(BuildContext context) {
    // Data points as fractions (0.0–1.0)
    const points = [0.56, 0.76, 0.78];
    const dataLabels = ['56%', '76%', '78%'];
    const weeks = ['Week 1', 'Week 2', 'Week 3'];
    const yLabels = ['100%', '80%', '60%', '40%', '20%', '0%'];

    // Layout constants matching Figma
    const yAxisW = 48.0;
    const chartH = 200.0;
    const legendH = 28.0;
    const xAxisH = 24.0;
    const totalHeight = chartH + xAxisH + legendH + 8;

    return SizedBox(
      height: totalHeight,
      width: double.infinity,
      child: CustomPaint(
        painter: _LineChartPainter(
          points: points,
          dataLabels: dataLabels,
          yLabels: yLabels,
          weeks: weeks,
          yAxisW: yAxisW,
          chartH: chartH,
          xAxisH: xAxisH,
          legendH: legendH,
          legendLabel: legendLabel,
        ),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _LineChartPainter extends CustomPainter {
  final List<double> points;
  final List<String> dataLabels;
  final List<String> yLabels;
  final List<String> weeks;
  final double yAxisW;
  final double chartH;
  final double xAxisH;
  final double legendH;
  final String legendLabel;

  const _LineChartPainter({
    required this.points,
    required this.dataLabels,
    required this.yLabels,
    required this.weeks,
    required this.yAxisW,
    required this.chartH,
    required this.xAxisH,
    required this.legendH,
    required this.legendLabel,
  });

  void _drawText(
    Canvas canvas,
    String text,
    Offset offset, {
    double fontSize = 11,
    Color color = const Color(0xB3000000),
    TextAlign align = TextAlign.left,
    double maxWidth = 60,
  }) {
    final tp = TextPainter(
      text: TextSpan(
          text: text,
          style: TextStyle(
              fontSize: fontSize,
              color: color,
              fontFamily: 'Inter',
              height: 1.2)),
      textDirection: TextDirection.ltr,
      textAlign: align,
    )..layout(maxWidth: maxWidth);
    double dx = offset.dx;
    if (align == TextAlign.center) dx -= tp.width / 2;
    if (align == TextAlign.right) dx -= tp.width;
    tp.paint(canvas, Offset(dx, offset.dy));
  }

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    final areaPaint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.12)
      ..style = PaintingStyle.fill;

    // Dotted grid paint
    final dotGridPaint = Paint()
      ..color = const Color(0x55000000)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    const dashLen = 4.0;
    const gapLen = 4.0;

    void drawDottedLine(Offset start, Offset end) {
      final dx = end.dx - start.dx;
      final dy = end.dy - start.dy;
      final dist = (end - start).distance;
      final steps = (dist / (dashLen + gapLen)).floor();
      for (int s = 0; s < steps; s++) {
        final t0 = s * (dashLen + gapLen) / dist;
        final t1 = (s * (dashLen + gapLen) + dashLen) / dist;
        canvas.drawLine(
          Offset(start.dx + dx * t0, start.dy + dy * t0),
          Offset(start.dx + dx * t1.clamp(0.0, 1.0),
              start.dy + dy * t1.clamp(0.0, 1.0)),
          dotGridPaint,
        );
      }
    }

    final chartW = size.width - yAxisW;
    // inner horizontal padding so dots don't sit on the grid edges
    const plotPad = 24.0;
    final plotW = chartW - plotPad * 2;

    // ── Y-axis labels & horizontal dotted grid lines ──
    for (int i = 0; i < yLabels.length; i++) {
      final y = (chartH / (yLabels.length - 1)) * i;
      drawDottedLine(Offset(yAxisW, y), Offset(yAxisW + chartW, y));
      // label left-aligned inside the y-axis column
      _drawText(canvas, yLabels[i], Offset(0, y - 7),
          align: TextAlign.left, maxWidth: yAxisW - 4);
    }

    // ── Compute data point coordinates (with inner padding) ──
    final xStep = plotW / (points.length - 1);
    final coords = List.generate(points.length, (i) {
      return Offset(yAxisW + plotPad + i * xStep, chartH * (1 - points[i]));
    });

    // ── Vertical dotted grid lines (one per data point) ──
    for (final c in coords) {
      drawDottedLine(Offset(c.dx, 0), Offset(c.dx, chartH));
    }

    // Build a smooth cubic-bezier path through the data points
    Path smoothPath(List<Offset> pts) {
      final path = Path()..moveTo(pts[0].dx, pts[0].dy);
      for (int i = 0; i < pts.length - 1; i++) {
        final cp1x = pts[i].dx + (pts[i + 1].dx - pts[i].dx) * 0.5;
        final cp1y = pts[i].dy;
        final cp2x = pts[i].dx + (pts[i + 1].dx - pts[i].dx) * 0.5;
        final cp2y = pts[i + 1].dy;
        path.cubicTo(cp1x, cp1y, cp2x, cp2y, pts[i + 1].dx, pts[i + 1].dy);
      }
      return path;
    }

    // ── Filled area under the curve ──
    final smoothLine = smoothPath(coords);
    final areaPath = Path.from(smoothLine)
      ..lineTo(coords.last.dx, chartH)
      ..lineTo(coords.first.dx, chartH)
      ..close();
    canvas.drawPath(areaPath, areaPaint);

    // ── Curved line ──
    canvas.drawPath(smoothLine, linePaint);

    // ── Dots + data labels ──
    for (int i = 0; i < coords.length; i++) {
      final c = coords[i];
      // orange shadow
      canvas.drawCircle(
          c,
          9,
          Paint()
            ..color = AppColors.primary.withValues(alpha: 0.35)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6));
      // ripple
      canvas.drawCircle(
          c, 8, Paint()..color = AppColors.primary.withValues(alpha: 0.18));
      // fill
      canvas.drawCircle(c, 5, Paint()..color = AppColors.primary);
      // white border
      canvas.drawCircle(
          c,
          5,
          Paint()
            ..color = Colors.white
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2);
      // data label above dot
      _drawText(canvas, dataLabels[i], Offset(c.dx, c.dy - 22),
          align: TextAlign.center, maxWidth: 40);
    }

    // ── X-axis week labels (aligned under each dot) ──
    final xLabelY = chartH + 6;
    for (int i = 0; i < weeks.length; i++) {
      _drawText(canvas, weeks[i], Offset(coords[i].dx, xLabelY),
          align: TextAlign.center, maxWidth: 60);
    }

    // ── Legend ──
    final legendY = chartH + xAxisH + 8;
    final legendCenterX = size.width / 2;
    const lineHalfW = 12.0;
    // legend line
    canvas.drawLine(
        Offset(legendCenterX - lineHalfW, legendY + 8),
        Offset(legendCenterX + lineHalfW, legendY + 8),
        linePaint);
    // legend dot
    canvas.drawCircle(
        Offset(legendCenterX, legendY + 8), 4, Paint()..color = AppColors.primary);
    canvas.drawCircle(
        Offset(legendCenterX, legendY + 8),
        4,
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5);
    // legend label
    _drawText(canvas, legendLabel,
        Offset(legendCenterX + lineHalfW + 4, legendY + 2));
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}
