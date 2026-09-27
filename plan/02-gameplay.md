# 02 — Gameplay (`game.dart` + `screens/game.dart`)

## Engine: `SimonGame extends ChangeNotifier`
Port of `useSimonGame`. It depends on neither Flutter widgets nor the db, which keeps it testable.

State: `seq`, `inputIdx`, `phase` (idle | showing | input | success | gameover), `score`, `round`, `activeTile`, `pressedTile`, `msg`.
Constructor takes `tileCount`, `stepMs` (from speed) and an optional `Random` for tests.

- `start()`: seq = [rand], score 0, round 1, msg ''. After 600 ms → `_show(seq)`.
- `_show(s)`: phase showing, msg "Watch carefully…". For each index i, at `i*d`: light tile `s[i]` for `0.55*d`, then turn it off. After the last tile, wait a further `0.35*d`, then set phase input, inputIdx 0, msg "Your turn!".
- `tap(t)`: ignore unless phase is input. Set pressedTile for 180 ms.
  - Correct and not last: `score += 10*round`, then `inputIdx++`.
  - Correct and last: `score += 10*round + 25*round`, phase success, msg "Correct!", append a random tile, `round++`. After 1100 ms → `_show`.
  - Wrong: phase gameover, msg "Game Over".
- All timers live in a list and are cancelled in `dispose()` and on `start()`.

## Screen
- **Header row**: height 48, 8 px horizontal padding.
  - Back icon: `dispose` the game and pop to Home. No score is saved (same as the design).
  - "Round {round}" at 15/600, textSec, then a spacer.
  - Score pill: card bg, radius 10, 1px border, padding 6×14, text 18/700 in the accent color.
- **Body**: centered, 28 px padding, gap 20.
  - SimonCircle at 85% width, max 280. Pass `activeTile`, `pressedTile`, `onTileTap: game.tap`, and `disabled: phase != input`.
  - Center text: the round number (28/800, accent), or `✕` in the danger color on game over.
  - Message: 16/600. Color is danger on gameover, accent on input, textSec otherwise. Animate the color over 300 ms.
  - Progress dots (only during input): one dot per seq item, 8×8, gap 6, 10 px top margin. Done dots use the accent with a glow (`accent@38%` blur 6); the rest use cardBorder.
- **On gameover**: `insertScore(score, round, tiles, speed, theme)` once. Record `prevBest = bestScore()` *before* inserting. After 1200 ms, `pushReplacement` Game Over with `(score, round, prevBest)`.

## Checks: `test/game_test.dart` (use `fakeAsync` or a seeded `Random`)
- A full correct round-1 input gives score `10 + 25 = 35` and round 2.
- Round 2: the first correct tap adds 20, and the second (last) adds 20 + 50.
- A wrong tap → gameover, and later taps are ignored.
- Taps during `showing` are ignored.
