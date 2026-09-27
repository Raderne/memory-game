import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memory_app/theme.dart';
import 'package:memory_app/widgets.dart';

void main() {
  const size = 200.0;

  Future<List<int>> pump(WidgetTester tester, int n, {bool disabled = false}) {
    final taps = <int>[];
    return tester
        .pumpWidget(
          MaterialApp(
            home: Center(
              child: SizedBox.square(
                dimension: size,
                child: SimonCircle(
                  tileCount: n,
                  theme: ColorTheme.classic,
                  disabled: disabled,
                  onTileTap: taps.add,
                ),
              ),
            ),
          ),
        )
        .then((_) => taps);
  }

  /// Point at [deg] (0 = up, clockwise) and distance [dist] from the center.
  Offset at(WidgetTester tester, double deg, double dist) {
    final c = tester.getCenter(find.byType(SimonCircle));
    final rad = deg * math.pi / 180;
    return c + Offset(math.sin(rad) * dist, -math.cos(rad) * dist);
  }

  for (final n in [4, 6, 8]) {
    testWidgets('tapping the middle of each of $n sectors reports its index',
        (tester) async {
      final taps = await pump(tester, n);
      final arc = 360 / n;
      final mid = (size / 2 - 8 + 0.2 * size) / 2; // between R and r
      for (var i = 0; i < n; i++) {
        await tester.tapAt(at(tester, i * arc + arc / 2, mid));
      }
      expect(taps, List.generate(n, (i) => i));
    });
  }

  testWidgets('taps in the center disc or outside the ring are ignored',
      (tester) async {
    final taps = await pump(tester, 4);
    await tester.tapAt(at(tester, 45, 0.2 * size - 5));
    await tester.tapAt(at(tester, 45, size / 2 - 3));
    expect(taps, isEmpty);
  });

  testWidgets('disabled circle ignores taps', (tester) async {
    final taps = await pump(tester, 4, disabled: true);
    await tester.tapAt(at(tester, 45, size / 3));
    expect(taps, isEmpty);
  });
}
