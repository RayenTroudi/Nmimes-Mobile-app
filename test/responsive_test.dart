// test/responsive_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nmimes/theme/responsive.dart';

/// Pumps a widget under a MediaQuery of the given size and hands the
/// captured BuildContext to [body] for assertions.
Future<void> _withSize(
  WidgetTester tester,
  Size size,
  void Function(BuildContext context) body,
) async {
  await tester.pumpWidget(
    MediaQuery(
      data: MediaQueryData(size: size),
      child: Builder(
        builder: (context) {
          body(context);
          return const SizedBox();
        },
      ),
    ),
  );
}

void main() {
  testWidgets('isTablet true at >=600 shortest side', (tester) async {
    await _withSize(tester, const Size(800, 1200), (c) {
      expect(c.isTablet, isTrue);
    });
    await _withSize(tester, const Size(1200, 800), (c) {
      expect(c.isTablet, isTrue); // landscape tablet, shortest side 800
    });
  });

  testWidgets('phone is not a tablet; small phone flagged', (tester) async {
    await _withSize(tester, const Size(390, 844), (c) {
      expect(c.isTablet, isFalse);
      expect(c.isSmallPhone, isFalse);
    });
    await _withSize(tester, const Size(320, 568), (c) {
      expect(c.isSmallPhone, isTrue);
    });
  });

  testWidgets('rs scales down on phones, ~1.0 on tablet, capped on huge',
      (tester) async {
    await _withSize(tester, const Size(600, 900), (c) {
      // At the reference shortest side (600) the ratio is 1.0.
      expect(c.rs(100), closeTo(100, 0.001));
    });
    await _withSize(tester, const Size(360, 640), (c) {
      // Phone scales down but never below the 0.82 floor.
      final v = c.rs(100);
      expect(v, lessThan(100));
      expect(v, greaterThanOrEqualTo(82));
    });
    await _withSize(tester, const Size(2000, 2600), (c) {
      // Huge tablet is capped at the 1.15 ceiling.
      expect(c.rs(100), closeTo(115, 0.001));
    });
  });

  testWidgets('wp and hp are fractions of size', (tester) async {
    await _withSize(tester, const Size(400, 800), (c) {
      expect(c.wp(0.5), closeTo(200, 0.001));
      expect(c.hp(0.25), closeTo(200, 0.001));
    });
  });
}
