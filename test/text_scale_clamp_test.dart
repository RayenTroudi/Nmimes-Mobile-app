import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Reproduces the exact builder the app installs, so the clamp behavior is
/// verified independently of the full app bootstrap (which needs Supabase).
Widget clampBuilder(BuildContext context, Widget? child) {
  final mq = MediaQuery.of(context);
  final clamped = mq.textScaler.clamp(minScaleFactor: 0.9, maxScaleFactor: 1.3);
  return MediaQuery(data: mq.copyWith(textScaler: clamped), child: child!);
}

void main() {
  testWidgets('clamps an oversized OS text scale to 1.3', (tester) async {
    double? seen;
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(textScaler: TextScaler.linear(2.0)),
        child: MaterialApp(
          builder: clampBuilder,
          home: Builder(
            builder: (context) {
              seen = MediaQuery.of(context).textScaler.scale(10) / 10;
              return const SizedBox();
            },
          ),
        ),
      ),
    );
    expect(seen, closeTo(1.3, 0.001));
  });

  testWidgets('raises a tiny OS text scale to the 0.9 floor', (tester) async {
    double? seen;
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(textScaler: TextScaler.linear(0.5)),
        child: MaterialApp(
          builder: clampBuilder,
          home: Builder(
            builder: (context) {
              seen = MediaQuery.of(context).textScaler.scale(10) / 10;
              return const SizedBox();
            },
          ),
        ),
      ),
    );
    expect(seen, closeTo(0.9, 0.001));
  });
}
