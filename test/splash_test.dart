import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memory_app/screens/splash.dart';
import 'package:memory_app/theme.dart';

void main() {
  Future<List<int>> pumpSplash(
    WidgetTester tester, {
    bool reduceMotion = false,
  }) async {
    final done = <int>[];
    await tester.pumpWidget(
      MaterialApp(
        theme: appTheme,
        home: MediaQuery(
          data: MediaQueryData(disableAnimations: reduceMotion),
          child: SplashScreen(onDone: () => done.add(1)),
        ),
      ),
    );
    return done;
  }

  testWidgets('plays the full 5 s timeline once, then calls onDone', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(375, 780);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final done = await pumpSplash(tester);
    for (final label in ['MEMORY', 'How far can you go?']) {
      expect(tester.getCenter(find.text(label)).dx, closeTo(375 / 2, 5));
    }

    await tester.pump(const Duration(milliseconds: 4990));
    expect(done, isEmpty);
    await tester.pump(const Duration(milliseconds: 20));
    await tester.pump();
    expect(done, [1]);
  });

  testWidgets('reduced motion skips straight to onDone', (tester) async {
    final done = await pumpSplash(tester, reduceMotion: true);
    await tester.pump();
    expect(done, [1]);
  });

  testWidgets('disposing mid-animation never calls onDone', (tester) async {
    final done = await pumpSplash(tester);
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 10));
    expect(done, isEmpty);
  });
}
