# Game Engine

`SimonGame extends ChangeNotifier` in `lib/game.dart` (built in step 2). It is a port of the prototype's
`useSimonGame` hook. It imports only `dart:async`, `dart:math`, and Flutter foundation for
`ChangeNotifier`—no widgets or database—so it remains unit-testable.

Phases: `idle → showing → input → (success → showing …) | gameover`.

Constructor: `SimonGame({required tileCount, required stepMs, Random? random})`. The optional seeded
`Random` is used by `test/game_test.dart`. Public state is `seq, inputIdx, phase, score, round,
activeTile, pressedTile, msg`.

## Timing (step `d`: slow 900 / normal 550 / fast 350 ms)
- 600 ms delay after `start()`, then the sequence shows. Tile `i` lights at `i·d` for `0.55·d`.
- Input opens `0.35·d` after the last tile goes dark. Message changes from "Watch carefully…" to "Your turn!".
- A pressed tile flashes for 180 ms. After a completed round, there is 1100 ms ("Correct!") before the next showing.
- Fractional step durations use microseconds, so normal speed preserves `0.55 × 550 = 302.5 ms` rather
  than rounding early.

## Scoring
- A correct tap adds `10 × round`. The last tap of a sequence also adds a `25 × round` bonus.
- Example: round 1 perfect = 35. Round 2 perfect = 20 + (20 + 50) = 90.
- A wrong tap means game over. Taps are ignored outside the `input` phase.

## Gotchas
- **High-score check order:** read `bestScore()` *before* `insertScore()`. The badge shows when
  `score > 0 && score > prevBest`. The prototype used `>=` after saving, and we deliberately
  don't count a tie as a new record.
- **Timers:** keep every timer in a list and cancel it in `dispose()` and on `start()`. Back mid-game
  must not leave timers firing.
- Back mid-game does **not** save a score. Game over saves exactly once.

## Screen integration
`lib/screens/game.dart` owns one engine instance and listens only for the transition to `gameover`.
It immediately starts `bestScore()` followed by `insertScore()`, and independently starts the 1200 ms
result delay. The injected defaults (`loadBest`, `saveScore`) are the real database functions; injection
keeps the widget test fast and verifies read-before-insert ordering. `_saved` prevents duplicate rows when
the engine later clears `pressedTile`.

The screen replaces itself with Game Over after the save and the 1200 ms delay. It does not expose a
result callback. Home → Game uses `Navigator.push`. Back before game over disposes the engine and does
not save.

Tests:
- `test/game_test.dart`: round-1/round-2 scoring, wrong-tap lockout, showing-phase lockout.
- `test/game_screen_test.dart`: previous best → one insert → Game Over after 1200 ms → Play Again
  starts round 1.

Links: [[Simon Circle]], [[Database]], [[Screens]], [[Theme and Colors]]
