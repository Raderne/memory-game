import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memory_app/screens/game_over.dart';
import 'package:memory_app/theme.dart';

void main() {
  Future<void> pumpResult(
    WidgetTester tester, {
    required int score,
    required int round,
    required int prevBest,
    bool reduceMotion = false,
    void Function(BuildContext context)? onPlayAgain,
    void Function(BuildContext context)? onHome,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: appTheme,
        home: MediaQuery(
          data: MediaQueryData(disableAnimations: reduceMotion),
          child: GameOverScreen(
            score: score,
            round: round,
            prevBest: prevBest,
            settings: const Settings(),
            onPlayAgain: onPlayAgain ?? (_) {},
            onHome: onHome ?? (_) {},
          ),
        ),
      ),
    );
    await tester.pump();
  }

  testWidgets('a positive score above the old best shows a new record', (
    tester,
  ) async {
    await pumpResult(tester, score: 35, round: 2, prevBest: 0);

    expect(find.text('35'), findsNWidgets(2));
    expect(find.text('2'), findsOneWidget);
    expect(find.text('★ NEW HIGH SCORE'), findsOneWidget);
    expect(find.text('Best'), findsOneWidget);
  });

  testWidgets('a lower score keeps the old best and hides the badge', (
    tester,
  ) async {
    await pumpResult(tester, score: 10, round: 3, prevBest: 40);

    expect(find.text('10'), findsOneWidget);
    expect(find.text('40'), findsOneWidget);
    expect(find.text('★ NEW HIGH SCORE'), findsNothing);
  });

  testWidgets('a tie or a zero score is not a new record', (tester) async {
    await pumpResult(tester, score: 40, round: 4, prevBest: 40);
    expect(find.text('★ NEW HIGH SCORE'), findsNothing);

    await pumpResult(tester, score: 0, round: 1, prevBest: 0);
    expect(find.text('★ NEW HIGH SCORE'), findsNothing);
    expect(find.text('0'), findsNWidgets(2));
  });

  testWidgets('play again, home, and android back use their own actions', (
    tester,
  ) async {
    final actions = <String>[];
    await pumpResult(
      tester,
      score: 35,
      round: 2,
      prevBest: 0,
      onPlayAgain: (_) => actions.add('again'),
      onHome: (_) => actions.add('home'),
    );

    await tester.tap(find.text('Play Again'));
    await tester.tap(find.text('Home'));
    await tester.binding.handlePopRoute();
    await tester.pump();

    expect(actions, ['again', 'home', 'home']);
  });

  testWidgets('reduced motion shows the result immediately', (tester) async {
    await pumpResult(
      tester,
      score: 35,
      round: 2,
      prevBest: 0,
      reduceMotion: true,
    );

    expect(
      tester.widget<Opacity>(find.byKey(const Key('game-over-reveal'))).opacity,
      1,
    );
  });

  testWidgets('the result fades in after a short delay', (tester) async {
    await pumpResult(tester, score: 35, round: 2, prevBest: 10);

    expect(
      tester.widget<Opacity>(find.byKey(const Key('game-over-reveal'))).opacity,
      0,
    );

    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 500));

    expect(
      tester.widget<Opacity>(find.byKey(const Key('game-over-reveal'))).opacity,
      1,
    );
  });
}
