import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memory_app/screens/home.dart';
import 'package:memory_app/theme.dart';
import 'package:memory_app/widgets.dart';

void main() {
  Future<void> pumpHome(
    WidgetTester tester, {
    Settings settings = const Settings(),
    Future<void> Function()? onStartGame,
    Future<int> Function()? loadBest,
    bool reduceMotion = false,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: appTheme,
        home: MediaQuery(
          data: MediaQueryData(disableAnimations: reduceMotion),
          child: HomeScreen(
            settings: settings,
            onSettingsChanged: (_) {},
            onStartGame: onStartGame ?? () async {},
            onOpenSettings: () async {},
            onOpenScores: () async {},
            onOpenAbout: () async {},
            loadBest: loadBest ?? () async => 0,
          ),
        ),
      ),
    );
    await tester.pump();
  }

  testWidgets('fresh home shows its actions without an empty best-score line', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(375, 667);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await pumpHome(tester);

    expect(find.text('MEMORY'), findsOneWidget);
    expect(find.text('How far can you go?'), findsOneWidget);
    expect(find.text('Start Game'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('Scores'), findsOneWidget);
    expect(find.text('About'), findsOneWidget);
    expect(find.textContaining('Best:'), findsNothing);
    expect(tester.widget<SimonCircle>(find.byType(SimonCircle)).tileCount, 4);

    for (final label in ['Settings', 'Scores', 'About']) {
      final button = find.ancestor(
        of: find.text(label),
        matching: find.byType(InkWell),
      );
      expect(tester.getSize(button).height, greaterThanOrEqualTo(48));
    }

    await tester.pumpWidget(const SizedBox.shrink());
  });

  for (final count in [4, 6, 8]) {
    testWidgets('idle animation cycles through all $count tiles', (
      tester,
    ) async {
      await pumpHome(tester, settings: Settings(tileCount: count));

      for (var tile = 0; tile < count; tile++) {
        await tester.pump(Duration(milliseconds: tile == 0 ? 1200 : 700));
        expect(
          tester.widget<SimonCircle>(find.byType(SimonCircle)).activeTile,
          tile,
        );
        await tester.pump(const Duration(milliseconds: 500));
        expect(
          tester.widget<SimonCircle>(find.byType(SimonCircle)).activeTile,
          isNull,
        );
      }

      await tester.pumpWidget(const SizedBox.shrink());
    });
  }

  testWidgets('reduced motion keeps the idle board still', (tester) async {
    await pumpHome(tester, reduceMotion: true);

    await tester.pump(const Duration(milliseconds: 2400));

    expect(
      tester.widget<SimonCircle>(find.byType(SimonCircle)).activeTile,
      isNull,
    );
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('best score reloads after a destination returns', (tester) async {
    var best = 35;
    await pumpHome(
      tester,
      loadBest: () async => best,
      onStartGame: () async => best = 99,
    );
    expect(find.text('Best: 35'), findsOneWidget);

    await tester.tap(find.text('Start Game'));
    await tester.pump();
    await tester.pump();

    expect(find.text('Best: 99'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('best reloads when a later game returns home', (tester) async {
    var best = 10;
    await tester.pumpWidget(
      MaterialApp(
        theme: appTheme,
        navigatorObservers: [homeRouteObserver],
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(disableAnimations: true),
          child: child!,
        ),
        home: HomeScreen(
          settings: const Settings(),
          onSettingsChanged: (_) {},
          onStartGame: () async {},
          onOpenSettings: () async {},
          onOpenScores: () async {},
          onOpenAbout: () async {},
          loadBest: () async => best,
        ),
      ),
    );
    await tester.pump();
    expect(find.text('Best: 10'), findsOneWidget);

    final context = tester.element(find.text('MEMORY'));
    Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const Text('cover')));
    await tester.pumpAndSettle();
    best = 80;
    Navigator.of(context).pop();
    await tester.pumpAndSettle();

    expect(find.text('Best: 80'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
