# Game Engine

`SimonGame extends ChangeNotifier` in `lib/game.dart` (planned). It is a port of the prototype's
`useSimonGame` hook. It has **no widget or db imports**, so it can be unit-tested.

Phases: `idle → showing → input → (success → showing …) | gameover`.

## Timing (step `d`: slow 900 / normal 550 / fast 350 ms)
- 600 ms delay after `start()`, then the sequence shows. Tile `i` lights at `i·d` for `0.55·d`.
- Input opens `0.35·d` after the last tile goes dark. Message changes from "Watch carefully…" to "Your turn!".
- A pressed tile flashes for 180 ms. After a completed round, there is 1100 ms ("Correct!") before the next showing.

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

Links: [[Simon Circle]], [[Database]], [[Screens]], [[Theme and Colors]]
