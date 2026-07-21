import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;
import 'package:nmimes/l10n/generated/app_localizations.dart';
import 'package:nmimes/providers/auth_state.dart';
import 'package:nmimes/theme/app_theme.dart';
import 'package:nmimes/theme/colors.dart';
import 'package:nmimes/theme/spacing.dart';
import 'package:nmimes/widgets/chunky_button.dart';
import 'package:nmimes/widgets/fox_mascot.dart';
import 'package:nmimes/screens/challenges/challenges_screen.dart';

Widget _wrap(Widget child) => ChangeNotifierProvider(
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
);

void main() {
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await Supabase.initialize(
      url: 'http://localhost:54321',
      anonKey: 'test-anon-key',
    );
  });

  testWidgets('exactly one champion marks the current stage', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(_wrap(const ChallengesScreen()));
    await tester.pump(const Duration(milliseconds: 500));

    // The header has its own fox avatar; the path should add exactly one
    // more — the champion on the active node.
    final foxes = find.byType(FoxMascot);
    // ignore: avoid_print
    print('FoxMascot count on screen: ${foxes.evaluate().length}');

    // Find the champion (the 'happy' variant used by the marker).
    final champion = find.byWidgetPredicate(
      (w) => w is FoxMascot && w.variant == 'happy',
    );
    expect(
      champion,
      findsOneWidget,
      reason: 'exactly one champion should mark the current stage',
    );

    // The champion sits on top of the node for the user's current stage —
    // the first unlocked, incomplete challenge. With the sample data that
    // is "Puzzle Pro"; asserting against the label of whichever node it
    // belongs to keeps this valid once progress is wired to real data.
    final championY = tester.getCenter(champion).dy;
    final stageLabel = find.text('Puzzle Pro');
    final labelY = tester.getCenter(stageLabel).dy;
    // ignore: avoid_print
    print('champion dy=$championY   current-stage label dy=$labelY');

    // Measure the champion against the node circle it should be sitting on.
    final championBox = tester.getRect(champion);
    final nodeBox = tester.getRect(
      find.ancestor(of: find.text('🧩'), matching: find.byType(ChunkyButton)),
    );
    // ignore: avoid_print
    print('champion rect: $championBox');
    // ignore: avoid_print
    print('node rect:     $nodeBox');
    // ignore: avoid_print
    print(
      'OVERLAP (champion bottom - node top) = '
      '${championBox.bottom - nodeBox.top}',
    );
    // ignore: avoid_print
    print(
      'horizontal centre delta = '
      '${(championBox.center.dx - nodeBox.center.dx).abs()}',
    );

    // The champion must sit ON the node, not float above it: its feet
    // should reach past the rim into the upper part of the circle.
    final overlap = championBox.bottom - nodeBox.top;
    expect(
      overlap,
      greaterThan(nodeBox.height * 0.35),
      reason:
          'champion should visibly rest on the node, not hover above '
          '(overlap ${overlap.toStringAsFixed(1)} of '
          '${nodeBox.height} node)',
    );
    // …but not swallow the node's icon entirely.
    expect(
      overlap,
      lessThan(nodeBox.height * 0.75),
      reason: 'champion should not cover the whole node',
    );

    // Centred on the node it marks.
    expect(
      (championBox.center.dx - nodeBox.center.dx).abs(),
      lessThan(2),
      reason: 'champion should be centred on its node',
    );

    // Above the label (it sits on top of the node, not beside or below it)…
    expect(
      championY,
      lessThan(labelY),
      reason: 'champion should sit on top of its node, above the label',
    );
    // …and close enough to read as belonging to that node rather than
    // floating over an unrelated part of the path.
    expect(
      labelY - championY,
      lessThan(160),
      reason: 'champion should hug the node it marks',
    );

    // The taller champion slot must not push the path rows into overflow.
    final ex = tester.takeException();
    expect(
      ex?.toString().contains('overflowed') ?? false,
      isFalse,
      reason: 'champion slot should not overflow its row: $ex',
    );
  });

  testWidgets('the content sheet has rounded top corners over the header', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(_wrap(const ChallengesScreen()));
    await tester.pump(const Duration(milliseconds: 500));
    tester.takeException();

    // The cream sheet: a Container decorated with the background colour and
    // a vertical-top radius, the same shape the home screen uses.
    final sheet = find.byWidgetPredicate((w) {
      if (w is! Container) return false;
      final d = w.decoration;
      if (d is! BoxDecoration) return false;
      return d.color == AppColors.background &&
          d.borderRadius ==
              BorderRadius.vertical(
                top: const Radius.circular(AppRadius.sheet),
              );
    });

    expect(
      sheet,
      findsOneWidget,
      reason: 'the challenges body should sit on a rounded cream sheet',
    );

    // It must be clipped, or the radius is decoration only and children
    // paint over the corners.
    final container = tester.widget<Container>(sheet);
    expect(
      container.clipBehavior,
      isNot(Clip.none),
      reason: 'the sheet must clip its children to the rounded corners',
    );

    // The orange must actually be behind it, otherwise the rounded corners
    // reveal a seam instead of the header colour.
    final colored = find.ancestor(
      of: sheet,
      matching: find.byWidgetPredicate(
        (w) => w is ColoredBox && w.color == AppColors.primary,
      ),
    );
    expect(
      colored,
      findsWidgets,
      reason: 'brand orange should show through the sheet corners',
    );
  });

  // Scrolling the map used to run the unit banners right up under the tab
  // pills. The gap has to live outside the ListView: list padding scrolls
  // away with the content, so it cannot hold anything back.
  for (final tab in const ['challenges', 'pvp']) {
    testWidgets('the $tab list viewport starts below the tab pills',
        (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(_wrap(const ChallengesScreen()));
      await tester.pump(const Duration(milliseconds: 500));
      tester.takeException();

      if (tab == 'pvp') {
        await tester.tap(find.text('⚔️  PVP'));
        for (var i = 0; i < 8; i++) {
          await tester.pump(const Duration(milliseconds: 120));
        }
      }

      // The pills are private to the screen, so anchor on the label text.
      final pills = tester.getRect(find.text('🎯  Challenges'));
      final viewport = tester.getRect(find.byType(Viewport).first);

      // The clipping viewport itself must begin below the pills. Because it
      // clips, nothing inside it can ever paint into that gap no matter how
      // far the user scrolls.
      expect(
        viewport.top,
        greaterThanOrEqualTo(pills.bottom + 8),
        reason: 'the scroll viewport must start clear of the tab pills',
      );
    });
  }

  testWidgets('scrolling the map does not push content up under the pills',
      (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(_wrap(const ChallengesScreen()));
    await tester.pump(const Duration(milliseconds: 500));
    tester.takeException();

    final pillBottom = tester.getRect(find.text('🎯  Challenges')).bottom;

    await tester.drag(find.byType(ListView), const Offset(0, -400));
    for (var i = 0; i < 8; i++) {
      await tester.pump(const Duration(milliseconds: 120));
    }
    tester.takeException();

    // After scrolling, the unit banner titles still on screen must sit below
    // the pills — this is the exact symptom that was reported.
    final banner = find.text('Unit 2 · Master League');
    expect(banner, findsOneWidget, reason: 'the second unit should be visible');

    final rect = tester.getRect(banner);
    expect(
      rect.top,
      greaterThanOrEqualTo(pillBottom),
      reason: 'a unit banner slid up under the tab pills',
    );
  });

  testWidgets('switching to the PVP tab keeps the sheet and does not overflow',
      (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(_wrap(const ChallengesScreen()));
    await tester.pump(const Duration(milliseconds: 500));
    tester.takeException();

    await tester.tap(find.text('⚔️  PVP'));
    // Several frames rather than pumpAndSettle: the champion marker bobs
    // forever, so settling would time out.
    for (var i = 0; i < 8; i++) {
      await tester.pump(const Duration(milliseconds: 120));
    }

    expect(
      find.text('Leaderboard'),
      findsOneWidget,
      reason: 'the PVP tab should be showing',
    );

    final ex = tester.takeException();
    expect(
      ex?.toString().contains('overflowed') ?? false,
      isFalse,
      reason: 'the PVP tab must not overflow inside the sheet: $ex',
    );
  });
}
