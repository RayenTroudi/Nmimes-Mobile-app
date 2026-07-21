import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;
import 'package:nmimes/l10n/generated/app_localizations.dart';
import 'package:nmimes/providers/auth_state.dart';
import 'package:nmimes/providers/locale_provider.dart';
import 'package:nmimes/theme/app_theme.dart';
import 'package:nmimes/theme/colors.dart';
import 'package:nmimes/theme/spacing.dart';
import 'package:nmimes/screens/home/home_screen.dart';
import 'package:nmimes/screens/rewards/rewards_screen.dart';

/// Figma spec (node 1316:15892 "Snap a Homework", 375:4196 content sheet):
///   card   → cornerRadius 19.46, fill #ffffff, stroke #f05f01
///   row    → cornerRadius 19.51, fill #ffffff, stroke #00000000 (none)
///   sheet  → cornerRadius 30,    fill #fff7e8
const _figmaCardRadius = 19.46;
const _figmaSheetRadius = 30.0;
const _figmaStroke = Color(0xFFF05F01);
const _figmaSheetFill = Color(0xFFFFF7E8);

// HomeScreen's header reads LocaleProvider for the language pill, so the
// harness has to supply one or the whole header fails to build.
Widget _wrap(Widget child) => LocaleProvider(
  notifier: LocaleNotifier(const Locale('en')),
  child: ChangeNotifierProvider(
    create: (_) => AuthState(),
    child: MaterialApp(
      theme: AppTheme.lightForLocale(const Locale('en')),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('en'),
      home: Scaffold(body: child),
    ),
  ),
);

/// Every BoxDecoration rendered on screen, in paint order.
List<BoxDecoration> _decorations(WidgetTester tester) => tester
    .widgetList<DecoratedBox>(find.byType(DecoratedBox))
    .map((d) => d.decoration)
    .whereType<BoxDecoration>()
    .toList();

double? _topLeftRadius(BoxDecoration d) {
  final br = d.borderRadius;
  return br is BorderRadius ? br.topLeft.x : null;
}

void main() {
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await Supabase.initialize(
      url: 'http://localhost:54321',
      anonKey: 'test-anon-key',
    );
  });

  testWidgets('card shadow matches the shadow measured from Figma', (
    tester,
  ) async {
    // The Figma MCP server does not expose `effects`, so these numbers come
    // from sampling the rendered PNG at 4x and least-squares fitting the
    // alpha falloff below a card edge to a gaussian:
    //   peak alpha 31%, offsetY 1.1pt, sigma 4.1pt  (rms 1.3/255)
    // Flutter's blurRadius is ~2*sigma.
    expect(AppShadows.card, hasLength(1));
    final s = AppShadows.card.single;

    expect(
      s.color.a,
      closeTo(0.31, 0.02),
      reason: 'measured peak alpha was 31%',
    );
    expect(s.blurRadius, closeTo(8.2, 1.0), reason: 'measured sigma 4.1pt');
    expect(s.offset.dy, closeTo(1.1, 0.6), reason: 'measured offset 1.1pt');
    expect(s.offset.dx, 0, reason: 'shadow is straight down, not angled');
  });

  testWidgets('points bar shadow matches the shadow measured from Figma', (
    tester,
  ) async {
    // Node 375:4430 — the translucent points bar on the orange header.
    // Sampled against the known #F05F01 backdrop and fitted using BOTH the
    // bar's top and bottom edges: alpha 19%, offset 5.5pt, sigma 4.5pt.
    // The near-zero alpha above the bar is what pins the offset down.
    expect(AppShadows.onColor, hasLength(1));
    final s = AppShadows.onColor.single;

    expect(s.color.a, closeTo(0.19, 0.02), reason: 'measured peak alpha 19%');
    expect(s.blurRadius, closeTo(9.0, 1.0), reason: 'measured sigma 4.5pt');
    expect(s.offset.dy, closeTo(5.5, 1.0), reason: 'shadow sits well below');
    expect(s.offset.dx, 0);

    // It must be softer and lower than the on-cream card shadow, or the
    // two tokens are interchangeable and one of them is wrong.
    expect(s.color.a, lessThan(AppShadows.card.single.color.a));
    expect(s.offset.dy, greaterThan(AppShadows.card.single.offset.dy));
  });

  testWidgets('the header points bar casts the on-colour shadow', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(_wrap(const HomeScreen()));
    await tester.pump(const Duration(milliseconds: 500));

    // The bar is the translucent-white panel wrapping the points figure.
    final bar = tester.widget<DecoratedBox>(
      find
          .ancestor(of: find.text('150'), matching: find.byType(DecoratedBox))
          .last,
    );
    final d = bar.decoration as BoxDecoration;
    expect(
      d.boxShadow,
      AppShadows.onColor,
      reason: 'the points bar should lift off the orange header',
    );

    // Figma paints the bar as 20% white over #F05F01, which composites to
    // exactly #F37F34. Assert the flat colour so it cannot drift.
    expect(
      d.color,
      const Color(0xFFF37F34),
      reason: 'points bar fill should be #F37F34',
    );

    // The bar is defined by its fill and shadow alone.
    expect(d.border, isNull, reason: 'points bar should have no border');
  });

  testWidgets('primaryPanel is 20% white composited over the brand orange', (
    tester,
  ) async {
    // Guards the derivation, not just the literal: if `primary` ever moves,
    // this fails and flags that primaryPanel has to be recomputed.
    const bg = AppColors.primary;
    const fg = Colors.white;
    const a = 0.20;
    int mix(int f, int b) => (f * a + b * (1 - a)).round();

    final composited = Color.fromARGB(
      255,
      mix((fg.r * 255).round(), (bg.r * 255).round()),
      mix((fg.g * 255).round(), (bg.g * 255).round()),
      mix((fg.b * 255).round(), (bg.b * 255).round()),
    );

    expect(
      AppColors.primaryPanel,
      composited,
      reason:
          'primaryPanel should equal 20% white over primary; if primary '
          'changed, recompute it',
    );
  });

  testWidgets('reward cards cast the shared card shadow', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(_wrap(const RewardsScreen()));
    await tester.pump(const Duration(seconds: 1));

    // The reward/badge cards are white, ~20.72 radius, on the cream sheet.
    final cards = _decorations(tester).where(
      (d) =>
          d.color == Colors.white &&
          (_topLeftRadius(d) ?? 0) > 20 &&
          (_topLeftRadius(d) ?? 0) < 21,
    );
    expect(
      cards,
      isNotEmpty,
      reason: 'rewards screen should render badge cards',
    );
    for (final c in cards) {
      expect(
        c.boxShadow,
        AppShadows.card,
        reason: 'every reward card should cast the measured shadow',
      );
    }
  });

  testWidgets('design tokens match the Figma spec', (tester) async {
    // Radius: Figma's 19.46 is rounded to 20 so it lands on whole pixels.
    expect((AppRadius.card - _figmaCardRadius).abs(), lessThan(0.6));
    expect(AppRadius.sheet, _figmaSheetRadius);
    expect(AppColors.background, _figmaSheetFill);
    expect(AppColors.cardBorderPrimary, _figmaStroke);
    expect(AppColors.cardBorderSecondary, Colors.transparent);
  });

  testWidgets('Snap cards carry the orange border at the card radius', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(_wrap(const HomeScreen()));
    await tester.pump(const Duration(milliseconds: 500));

    // Locate the two Snap cards by their headline, then walk up to the
    // DecoratedBox that actually paints the border.
    for (final label in ['Snap a Homework', 'Snap a Lesson']) {
      expect(find.text(label), findsOneWidget, reason: '$label should render');

      final box = tester.widget<DecoratedBox>(
        find
            .ancestor(of: find.text(label), matching: find.byType(DecoratedBox))
            .first,
      );
      final d = box.decoration as BoxDecoration;

      expect(
        d.border?.top.color,
        _figmaStroke,
        reason: '$label should have the #F05F01 border from Figma',
      );
      expect(
        _topLeftRadius(d),
        AppRadius.card,
        reason: '$label should use the 20px card radius',
      );
      expect(
        d.color,
        AppColors.white,
        reason: '$label should stay white on the cream sheet',
      );
      expect(
        d.boxShadow,
        isNotEmpty,
        reason: '$label should lift off the sheet',
      );
    }
  });

  testWidgets('study-room rows stay borderless, matching Figma', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(_wrap(const HomeScreen()));
    await tester.pump(const Duration(milliseconds: 500));

    for (final label in ['Peer Learning', 'Saved Formulas']) {
      final box = tester.widget<DecoratedBox>(
        find
            .ancestor(of: find.text(label), matching: find.byType(DecoratedBox))
            .first,
      );
      final d = box.decoration as BoxDecoration;

      // Figma stroke is #00000000 — the row is defined by its shadow only.
      expect(
        d.border,
        isNull,
        reason: '$label has a transparent stroke in Figma, so no border',
      );
      expect(_topLeftRadius(d), AppRadius.card);
      expect(d.boxShadow, isNotEmpty, reason: '$label relies on its shadow');
    }
  });

  testWidgets('cream sheet is rounded where it meets the orange header', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(_wrap(const HomeScreen()));
    await tester.pump(const Duration(milliseconds: 500));

    final sheet = _decorations(tester).where(
      (d) =>
          d.color == AppColors.background &&
          _topLeftRadius(d) == AppRadius.sheet,
    );
    expect(
      sheet,
      isNotEmpty,
      reason: 'the cream sheet should have 30px top corners over the orange',
    );

    // Only the top corners are rounded — the sheet runs off the bottom.
    final br = sheet.first.borderRadius as BorderRadius;
    expect(br.bottomLeft.x, 0, reason: 'sheet should be square at the bottom');

    expect(tester.takeException(), isNull);
  });
}
