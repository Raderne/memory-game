import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memory_app/screens/game.dart';
import 'package:memory_app/theme.dart';
import 'package:memory_app/widgets.dart';

void main() {
  testWidgets('game over saves once before delivering the result', (
    tester,
  ) async {
    final order = <String>[];

    await tester.pumpWidget(
      MaterialApp(
        theme: appTheme,
        home: GameScreen(
          settings: const Settings(speed: Speed.fast),
          loadBest: () async {
            order.add('best');
            return 70;
          },
          saveScore:
              ({
                required score,
                required round,
                required tiles,
                required speed,
                required theme,
              }) async {
                order.add('save');
              },
        ),
      ),
    );

    expect(find.text('Round 1'), findsOneWidget);
    expect(find.text('0'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 600));
    await tester.pump();
    final shownTile = tester
        .widget<SimonCircle>(find.byType(SimonCircle))
        .activeTile!;
    await tester.pump(const Duration(microseconds: 192500));
    await tester.pump(const Duration(microseconds: 122500));

    final circle = tester.widget<SimonCircle>(find.byType(SimonCircle));
    expect(circle.disabled, isFalse);
    circle.onTileTap!((shownTile + 1) % 4);
    await tester.pump();

    expect(find.text('Game Over'), findsOneWidget);
    expect(order, ['best', 'save']);

    await tester.pump(const Duration(milliseconds: 1200));
    await tester.pump();

    expect(find.text('GAME OVER'), findsOneWidget);
    expect(find.text('70'), findsOneWidget);
    expect(find.text('★ NEW HIGH SCORE'), findsNothing);
    expect(order, ['best', 'save']);

    await tester.tap(find.text('Play Again'));
    await tester.pumpAndSettle();
    expect(find.text('Round 1'), findsOneWidget);
    expect(find.text('GAME OVER'), findsNothing);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('progress dots do not move the board', (tester) async {
    tester.view.physicalSize = const Size(360, 720);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      MaterialApp(
        theme: appTheme,
        home: GameScreen(
          settings: const Settings(speed: Speed.fast),
          loadBest: () async => 0,
          saveScore:
              ({
                required score,
                required round,
                required tiles,
                required speed,
                required theme,
              }) async {},
        ),
      ),
    );

    await tester.pump(const Duration(milliseconds: 600));
    final before = tester.getTopLeft(find.byType(SimonCircle));

    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('Your turn!'), findsOneWidget);
    expect(tester.getTopLeft(find.byType(SimonCircle)), before);
    expect(tester.getSize(find.byKey(const Key('progress-dots'))).height, 18);
  });
}
