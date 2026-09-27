import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memory_app/db.dart';
import 'package:memory_app/screens/leaderboard.dart';
import 'package:memory_app/theme.dart';

void main() {
  test('timeAgo switches at each boundary', () {
    final now = DateTime(2026, 9, 27, 15);
    String ago(int seconds) =>
        timeAgo(now.subtract(Duration(seconds: seconds)), now);

    expect(ago(59), 'just now');
    expect(ago(60), '1m ago');
    expect(ago(3599), '59m ago');
    expect(ago(3600), '1h ago');
    expect(ago(86400), '1d ago');
  });

  Future<void> pumpBoard(
    WidgetTester tester, {
    required Future<List<Score>> Function() loadScores,
    bool largeText = false,
  }) async {
    tester.view.physicalSize = const Size(360, 720);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    await tester.pumpWidget(
      MaterialApp(
        theme: appTheme,
        home: MediaQuery(
          data: MediaQueryData(
            textScaler: TextScaler.linear(largeText ? 2 : 1),
          ),
          child: LeaderboardScreen(
            accent: ColorTheme.classic.accent,
            loadScores: loadScores,
          ),
        ),
      ),
    );
    await tester.pump();
  }

  Score row(int score, int round) => Score(
    score: score,
    round: round,
    tiles: 4,
    speed: Speed.normal,
    theme: ColorTheme.classic,
    createdAt: DateTime.now(),
  );

  testWidgets('an empty board shows the empty state and not a flash of it', (
    tester,
  ) async {
    final pending = Completer<List<Score>>();
    await pumpBoard(tester, loadScores: () => pending.future);
    expect(find.text('No scores yet'), findsNothing);

    pending.complete(<Score>[]);
    await tester.pump();
    await tester.pump();
    expect(find.text('No scores yet'), findsOneWidget);
    expect(find.text('Play a game to set your first record!'), findsOneWidget);
    expect(find.byIcon(Icons.emoji_events_outlined), findsOneWidget);
  });

  testWidgets('rows keep the given order, with medals on the top three', (
    tester,
  ) async {
    await pumpBoard(
      tester,
      loadScores: () async => [row(80, 4), row(50, 3), row(35, 2), row(10, 1)],
    );
    await tester.pump();

    expect(find.text('🥇'), findsOneWidget);
    expect(find.text('🥈'), findsOneWidget);
    expect(find.text('🥉'), findsOneWidget);
    expect(find.text('4'), findsOneWidget);
    expect(find.text('80'), findsOneWidget);
    expect(find.text('Round 4'), findsOneWidget);
    expect(find.text('just now'), findsNWidgets(4));

    BoxDecoration decoration(int index) {
      final box = tester.widget<DecoratedBox>(find.byKey(Key('score-$index')));
      return box.decoration as BoxDecoration;
    }

    final accent = ColorTheme.classic.accent;
    expect(decoration(0).color, accent.withValues(alpha: 0x10 / 255));
    expect(
      decoration(0).border,
      Border.all(color: accent.withValues(alpha: 0x30 / 255)),
    );
    expect(decoration(1).color, card);
    expect(decoration(1).border, Border.all(color: cardBorder));
  });

  testWidgets('a narrow board at large text does not overflow', (tester) async {
    await pumpBoard(
      tester,
      largeText: true,
      loadScores: () async => [row(80, 4)],
    );
    await tester.pump();

    expect(find.text('80'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
