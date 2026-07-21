import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nmimes/l10n/generated/app_localizations.dart';
import 'package:nmimes/screens/rewards/saved_formulas_screen.dart';
import 'package:nmimes/screens/study_room/peer_learning_screen.dart';

void main() {
  /// A route table so `pushNamed` in the screens under test resolves to
  /// something instead of throwing. The destinations are stubs — this suite
  /// asserts *whether* navigation happened, not what it landed on.
  final pushed = <String>[];

  Widget wrap(Widget child) => MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: child,
        onGenerateRoute: (settings) {
          pushed.add(settings.name!);
          return MaterialPageRoute(
            builder: (_) => Scaffold(body: Text('route:${settings.name}')),
            settings: settings,
          );
        },
      );

  setUp(pushed.clear);

  /// Advance the entrance cascade without `pumpAndSettle` — the code field's
  /// cursor repeats forever once focused, which would make settling time out.
  Future<void> beat(WidgetTester tester, [int frames = 8]) async {
    for (var i = 0; i < frames; i++) {
      await tester.pump(const Duration(milliseconds: 120));
    }
  }

  void sized(WidgetTester tester, Size size) {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
  }

  // ── Layout ───────────────────────────────────────────────────────────────
  // Both screens grew animated wrappers and, in the grid's case, a Stack with
  // a positioned slab. Neither may overflow, at any of the sizes the app
  // actually ships on.
  for (final size in const [
    Size(360, 640), // small phone
    Size(390, 844), // iPhone 14
    Size(412, 915), // large android
    Size(800, 1280), // tablet
  ]) {
    final label = '${size.width.toInt()}x${size.height.toInt()}';

    testWidgets('peer learning lays out cleanly at $label', (tester) async {
      sized(tester, size);
      await tester.pumpWidget(wrap(const PeerLearningScreen()));
      await beat(tester);
      expect(tester.takeException(), isNull);
    });

    testWidgets('saved formulas lays out cleanly at $label', (tester) async {
      sized(tester, size);
      await tester.pumpWidget(wrap(const SavedFormulasScreen()));
      await beat(tester);
      expect(tester.takeException(), isNull);

      // All four cards must be on screen and non-empty — a zero-height cell
      // from the new Stack/Positioned layout would still "lay out cleanly".
      for (final name in const [
        'Algebra',
        'Statistics',
        'Geometry',
        'Calculus',
      ]) {
        final rect = tester.getRect(find.text(name));
        expect(rect.width, greaterThan(0), reason: '$name has no width');
        expect(rect.height, greaterThan(0), reason: '$name has no height');
      }
    });
  }

  // ── Entrance animation ───────────────────────────────────────────────────

  testWidgets('formula cards cascade in rather than appearing at once',
      (tester) async {
    sized(tester, const Size(390, 844));
    await tester.pumpWidget(wrap(const SavedFormulasScreen()));

    // One frame in, the cascade has barely started: the first card must be
    // further along than the last, which is what "staggered" means.
    await tester.pump(const Duration(milliseconds: 120));

    double opacityOf(String label) {
      final finder = find.ancestor(
        of: find.text(label),
        matching: find.byType(Opacity),
      );
      return tester.widgetList<Opacity>(finder).first.opacity;
    }

    expect(opacityOf('Algebra'), greaterThan(opacityOf('Calculus')),
        reason: 'the first card should lead the last one in');

    // And everything must finish — a cascade that strands a card at partial
    // opacity is worse than no animation.
    await beat(tester);
    for (final name in const [
      'Algebra',
      'Statistics',
      'Geometry',
      'Calculus',
    ]) {
      expect(opacityOf(name), 1.0, reason: '$name never finished entering');
    }
  });

  // ── Code entry ───────────────────────────────────────────────────────────

  testWidgets('an incomplete code does not join a room', (tester) async {
    sized(tester, const Size(390, 844));
    await tester.pumpWidget(wrap(const PeerLearningScreen()));
    await beat(tester);

    await tester.enterText(find.byType(TextField).last, '12');
    await beat(tester);

    await tester.tap(find.text('Team Up!'));
    await beat(tester);

    expect(pushed, isEmpty,
        reason: 'a 2-digit code must not be accepted as a room code');
  });

  testWidgets('a complete 4-digit code joins the room', (tester) async {
    sized(tester, const Size(390, 844));
    await tester.pumpWidget(wrap(const PeerLearningScreen()));
    await beat(tester);

    await tester.enterText(find.byType(TextField).last, '1234');
    await beat(tester);

    // Each digit renders in its own circle.
    for (final d in const ['1', '2', '3', '4']) {
      expect(find.text(d), findsOneWidget);
    }

    await tester.tap(find.text('Team Up!'));
    await beat(tester);

    expect(pushed, contains('/joined-room'));
  });

  testWidgets('non-digits are rejected by the code field', (tester) async {
    sized(tester, const Size(390, 844));
    await tester.pumpWidget(wrap(const PeerLearningScreen()));
    await beat(tester);

    await tester.enterText(find.byType(TextField).last, 'ab12');
    await beat(tester);

    // Only the digits survive, so the circles never show a stray letter.
    expect(find.text('a'), findsNothing);
    expect(find.text('b'), findsNothing);
    expect(find.text('1'), findsOneWidget);
    expect(find.text('2'), findsOneWidget);
  });

  testWidgets('a wrong-length code buzzes instead of failing silently',
      (tester) async {
    sized(tester, const Size(390, 844));
    await tester.pumpWidget(wrap(const PeerLearningScreen()));
    await beat(tester);

    final haptics = <String>[];
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'HapticFeedback.vibrate') {
          haptics.add(call.arguments as String? ?? '');
        }
        return null;
      },
    );
    addTearDown(() => tester.binding.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null));

    await tester.tap(find.text('Team Up!'));
    await beat(tester);

    expect(haptics, isNotEmpty,
        reason: 'rejecting the tap should be felt, not just ignored');
  });

  testWidgets('the create-room button still navigates', (tester) async {
    sized(tester, const Size(390, 844));
    await tester.pumpWidget(wrap(const PeerLearningScreen()));
    await beat(tester);

    await tester.tap(find.text('Create My Room'));
    await beat(tester);

    expect(pushed, contains('/my-room'));
  });

  testWidgets('tapping a formula category opens the detail screen',
      (tester) async {
    sized(tester, const Size(390, 844));
    await tester.pumpWidget(wrap(const SavedFormulasScreen()));
    await beat(tester);

    await tester.tap(find.text('Geometry'));
    await beat(tester);

    expect(pushed, contains('/formula-detail'));
  });

  // ── Press feedback ───────────────────────────────────────────────────────

  testWidgets('a formula card presses down and springs back', (tester) async {
    sized(tester, const Size(390, 844));
    await tester.pumpWidget(wrap(const SavedFormulasScreen()));
    await beat(tester);

    final card = find.text('Algebra');
    final resting = tester.getRect(card);

    final gesture = await tester.startGesture(tester.getCenter(card));
    // Two pumps, not one: the first delivers the pointer-down, and only then
    // does the press animation have a frame to run on.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 150));

    final pressedRect = tester.getRect(card);
    expect(pressedRect.top, greaterThan(resting.top),
        reason: 'the card should sink onto its 3D edge while held');

    // Cancel rather than lift: releasing fires onTap and navigates away, so
    // the card would be gone before it could be measured. Cancelling is also
    // the case that matters — a drag off the card must not leave it stuck
    // down.
    await gesture.cancel();
    await beat(tester);
    expect(tester.getRect(card).top, closeTo(resting.top, 0.5),
        reason: 'and return to rest when the press is cancelled');
  });
}
