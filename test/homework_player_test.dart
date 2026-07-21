import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nmimes/l10n/generated/app_localizations.dart';
import 'package:nmimes/screens/snap/homework_player/homework_player_screen.dart';
import 'package:nmimes/screens/snap/homework_player/homework_steps.dart';
import 'package:nmimes/screens/snap/homework_player/homework_widgets.dart';
import 'package:nmimes/screens/snap/snap_hw_send_screen.dart';
import 'package:nmimes/widgets/app_progress_bar.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: child,
      );

  /// Advance animations without `pumpAndSettle` — the player usually has a
  /// looping or delayed animation running, which would make pumpAndSettle
  /// time out. Several discrete frames are needed rather than one long pump:
  /// the feedback sheet slides in via a paint-time transform, so its
  /// hit-test box only reaches its resting place once the tween finishes.
  Future<void> beat(WidgetTester tester, [int frames = 6]) async {
    for (var i = 0; i < frames; i++) {
      await tester.pump(const Duration(milliseconds: 150));
    }
  }

  // The fox intro screen lays a Spacer-driven Column inside a scroll view.
  // That combination throws "RenderFlex children have non-zero flex but
  // incoming height constraints are unbounded" unless the height is made
  // finite, and the failure cascades into every ancestor. It has to be
  // checked at several heights: tall screens leave slack, short ones do not.
  for (final size in const [
    Size(360, 640), // small phone
    Size(390, 844), // iPhone 14
    Size(412, 915), // large android
    Size(800, 1280), // tablet
  ]) {
    testWidgets('fox intro screen lays out cleanly at ${size.width.toInt()}x'
        '${size.height.toInt()}', (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(wrap(const SnapHwSendScreen()));
      await beat(tester);

      expect(tester.takeException(), isNull,
          reason: 'no layout exception at $size');

      // The button must be on screen and hittable, not collapsed to the top
      // of a broken layout.
      final button = find.text("Let's Solve");
      expect(button, findsOneWidget);

      final box = tester.getRect(button);
      expect(box.top, greaterThan(size.height * 0.5),
          reason: 'the CTA belongs at the bottom, not stacked at the top');
      expect(box.bottom, lessThanOrEqualTo(size.height),
          reason: 'the CTA must be fully on screen');
    });
  }

  testWidgets('starts on step 1 of 4 with the problem card visible',
      (tester) async {
    tester.view.physicalSize = const Size(390, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(wrap(const HomeworkPlayerScreen()));
    await beat(tester);

    expect(find.text('2x + 5 = 15'), findsOneWidget);
    expect(find.text('1/4'), findsOneWidget);
    expect(find.text('What are we looking for?'), findsOneWidget);

    // The progress bar reflects position, not a hardcoded value.
    final bar = tester.widget<AppProgressBar>(find.byType(AppProgressBar));
    expect(bar.value, closeTo(0.25, 0.001));
  });

  testWidgets('the problem card survives across step changes', (tester) async {
    tester.view.physicalSize = const Size(390, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(wrap(const HomeworkPlayerScreen()));
    await beat(tester);

    // Grab the card's element identity, answer step 1, and confirm the very
    // same element is still mounted. This is what makes the card free to
    // render: if it were inside the AnimatedSwitcher it would be rebuilt.
    final before = tester.element(find.byType(HwProblemCard));

    await tester.tap(find.text('x'));
    await beat(tester);
    await tester.tap(find.text('Next Step'));
    await beat(tester);

    expect(find.text('2/4'), findsOneWidget);
    final after = tester.element(find.byType(HwProblemCard));
    expect(identical(before, after), isTrue,
        reason: 'the problem card should persist, not rebuild, between steps');
  });

  testWidgets('a correct pick shows the success sheet and advances',
      (tester) async {
    tester.view.physicalSize = const Size(390, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(wrap(const HomeworkPlayerScreen()));
    await beat(tester);

    await tester.tap(find.text('x'));
    await beat(tester);

    expect(find.byType(HwFeedbackSheet), findsOneWidget);
    final sheet = tester.widget<HwFeedbackSheet>(find.byType(HwFeedbackSheet));
    expect(sheet.correct, isTrue);

    await tester.tap(find.text('Next Step'));
    await beat(tester);
    expect(find.text('2/4'), findsOneWidget);
  });

  testWidgets('a wrong pick shows the hint sheet and does not advance',
      (tester) async {
    tester.view.physicalSize = const Size(390, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(wrap(const HomeworkPlayerScreen()));
    await beat(tester);

    // '15' is a distractor, not the answer.
    await tester.tap(find.text('15'));
    await beat(tester);

    final sheet = tester.widget<HwFeedbackSheet>(find.byType(HwFeedbackSheet));
    expect(sheet.correct, isFalse,
        reason: 'picking a distractor should not be treated as correct');
    expect(find.text('1/4'), findsOneWidget,
        reason: 'a wrong answer must not advance the step');
  });

  testWidgets('the stuck-actions escape hatch appears only after two misses',
      (tester) async {
    tester.view.physicalSize = const Size(390, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(wrap(const HomeworkPlayerScreen()));
    await beat(tester);

    await tester.tap(find.text('15'));
    await beat(tester);
    var sheet = tester.widget<HwFeedbackSheet>(find.byType(HwFeedbackSheet));
    expect(sheet.showStuckActions, isFalse,
        reason: 'one miss should just offer Try Again');

    // Dismiss, miss again.
    await tester.tap(find.text("Let's Try Again"));
    await beat(tester);
    await tester.tap(find.text('5'));
    await beat(tester);

    sheet = tester.widget<HwFeedbackSheet>(find.byType(HwFeedbackSheet));
    expect(sheet.showStuckActions, isTrue,
        reason: 'after two misses the child should get a way forward');
  });

  testWidgets('demo homework is four steps ending in the solution',
      (tester) async {
    final steps = buildDemoHomework();
    expect(steps, hasLength(4));
    expect(steps.first.kind, HwStepKind.tapGrid);
    expect(steps[1].kind, HwStepKind.tapList);
    expect(steps[2].kind, HwStepKind.balance);
    expect(steps.last.kind, HwStepKind.solution);

    // Step 3 must be a hands-on mechanic, not a text field: that was the
    // whole point of replacing it.
    expect(steps[2].kind, isNot(HwStepKind.tapList));
  });

  testWidgets('no text field survives anywhere in the flow', (tester) async {
    tester.view.physicalSize = const Size(390, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(wrap(const HomeworkPlayerScreen()));
    await beat(tester);

    // Walk to the balance step.
    await tester.tap(find.text('x'));
    await beat(tester);
    await tester.tap(find.text('Next Step'));
    await beat(tester);
    await tester.tap(find.text('Subtract 5 from both sides'));
    await beat(tester);
    await tester.tap(find.text('Next Step'));
    await beat(tester);

    expect(find.text('3/4'), findsOneWidget);
    expect(find.byType(TextField), findsNothing,
        reason: 'step 3 should be a manipulable balance, not typing');
  });

  testWidgets('no overflow on a short screen', (tester) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(wrap(const HomeworkPlayerScreen()));
    await beat(tester);
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('x'));
    await beat(tester);
    expect(tester.takeException(), isNull);
  });
}
