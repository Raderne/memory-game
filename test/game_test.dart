import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:memory_app/game.dart';

void main() {
  const stepMs = 100;

  Future<void> showSequence(
    WidgetTester tester,
    SimonGame game, {
    bool firstRound = false,
  }) async {
    if (firstRound) {
      game.start();
      await tester.pump(const Duration(milliseconds: 600));
    } else {
      await tester.pump(const Duration(milliseconds: 1100));
    }
    await tester.pump();

    for (var i = 0; i < game.seq.length; i++) {
      if (i > 0) {
        await tester.pump(const Duration(milliseconds: 45));
      }
      await tester.pump(const Duration(milliseconds: 55));
    }
    await tester.pump(const Duration(milliseconds: 35));
    expect(game.phase, GamePhase.input);
  }

  testWidgets('a correct round 1 scores 35 and starts round 2', (tester) async {
    final game = SimonGame(tileCount: 4, stepMs: stepMs, random: Random(1));
    await showSequence(tester, game, firstRound: true);

    game.tap(game.seq.single);

    expect(game.score, 35);
    expect(game.round, 2);
    expect(game.seq, hasLength(2));
    expect(game.phase, GamePhase.success);
    game.dispose();
  });

  testWidgets('round 2 adds 20 per tap and a 50 completion bonus', (
    tester,
  ) async {
    final game = SimonGame(tileCount: 4, stepMs: stepMs, random: Random(2));
    await showSequence(tester, game, firstRound: true);
    game.tap(game.seq.single);
    await showSequence(tester, game);
    final roundTwo = List<int>.of(game.seq);

    game.tap(roundTwo.first);
    expect(game.score, 55);
    expect(game.inputIdx, 1);

    game.tap(roundTwo.last);
    expect(game.score, 125);
    expect(game.round, 3);
    expect(game.phase, GamePhase.success);
    game.dispose();
  });

  testWidgets('a wrong tap ends the game and later taps are ignored', (
    tester,
  ) async {
    final game = SimonGame(tileCount: 4, stepMs: stepMs, random: Random(3));
    await showSequence(tester, game, firstRound: true);
    final correct = game.seq.single;

    game.tap((correct + 1) % 4);
    expect(game.phase, GamePhase.gameover);
    expect(game.msg, 'Game Over');

    game.tap(correct);
    expect(game.score, 0);
    expect(game.phase, GamePhase.gameover);
    game.dispose();
  });

  testWidgets('taps during sequence playback are ignored', (tester) async {
    final game = SimonGame(tileCount: 4, stepMs: stepMs, random: Random(4));
    game.start();
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pump();
    expect(game.phase, GamePhase.showing);

    game.tap(game.seq.single);

    expect(game.score, 0);
    expect(game.inputIdx, 0);
    expect(game.pressedTile, isNull);
    game.dispose();
  });
}
