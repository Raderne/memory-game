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
    ({int score, int round, int previousBest})? result;

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
          onGameOver:
              ({required score, required round, required previousBest}) async {
                result = (
                  score: score,
                  round: round,
                  previousBest: previousBest,
                );
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

    expect(result, (score: 0, round: 1, previousBest: 70));
    expect(order, ['best', 'save']);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
