# Build Plan

The app is built **one screen per step**. Specs live in `plan/` (repo root). Each step ends runnable
and must meet the definition of done in [[CLAUDE.md Rules]].

| # | Plan file | Scope | Status |
|---|---|---|---|
| 0 | `plan/00-foundation.md` | project, [[Theme and Colors]], [[Database]], [[Shared Widgets]], [[Simon Circle]] | **done** 2026-09-27 |
| 1 | `plan/01-home.md` | Home ([[Screens]]) | **done** 2026-09-27 |
| 2 | `plan/02-gameplay.md` | [[Game Engine]] + Game screen | **done** 2026-09-27 |
| 3 | `plan/03-game-over.md` | Game Over | **done** 2026-09-27 |
| 4 | `plan/04-settings.md` | Settings | **done** 2026-09-27 |
| 5 | `plan/05-leaderboard.md` | Leaderboard | **done** 2026-09-27 |
| — | (no plan file; design `launch.jsx`) | [[Launch Screen and Icon]] | **done** 2026-09-27 |

Order rationale: the design's order. Gameplay comes early so the play → save → result loop works
by step 3.

**Update the Status column when a step finishes.**

## Step notes
- **0 (done):** `flutter analyze` clean, 8 tests pass (`test/db_test.dart`, `test/simon_circle_test.dart`), checked by
  hand on the Pixel 10 emulator (tap → glow, 4/6/8 tiles, theme switch, settings survive a cold restart).
  Step 1 replaced the temporary `_FoundationPreview` with Home. The `Chip` → `ChoiceChipX` naming question is
  recorded in [[Shared Widgets]].
- **1 (done):** `screens/home.dart` is the start route. Widget tests cover the fresh state, best-score reload,
  complete 4/6/8-tile idle cycles, reduced motion, and 48dp secondary targets. Checked on the Pixel 10 emulator
  at normal and 2× text scale. Future-screen callbacks remain no-ops until their own build steps.
- **2 (done):** `game.dart` implements the timed state machine and scoring; `screens/game.dart` is wired from
  Home and saves once at game over. Engine and screen tests cover scoring, input lockout, read-before-insert,
  and the 1200 ms handoff. Checked on the Pixel 10 emulator at normal and 2× text scale.
- **3 (done):** `screens/game_over.dart` replaces Game after the save. Tests cover a new record, a lower
  score, a tie, a zero score, Play Again, Home, Android back, the delayed fade, and reduced motion.
  Home reloads its best score when it is revealed again. Checked on the Pixel 10 emulator at normal and
  2× text scale; an existing best of 700 correctly hid the badge for a score of 35.
- **4 (done):** `screens/settings.dart` saves tiles, speed, and theme immediately and previews them on a
  disabled circle. Reset asks inline, then `clearScores()`. Home opens it; coming back reloads Best, so
  a confirmed reset hides that line. `flutter analyze` clean, full suite passed. Checked on the Pixel 10
  emulator at normal and 2× text: 8 / Fast / Ocean survived a cold restart, and reset hid Best. Accent
  button labels now use `foregroundOn` (see [[Theme and Colors]]).
- **5 (done):** `screens/leaderboard.dart` lists `topScores(10)`. Empty state is the trophy and the two
  lines from the plan. Rows keep the query order; ranks 1–3 use the medal characters and the first row
  uses the current accent. `timeAgo` is pure and tested at 59s, 60s, 3599s, 3600s, and 86400s. `Score`
  has a public constructor so the widget test can inject rows. Home's Scores button opens the screen.
  Checked on the Pixel 10 emulator at normal and 2× text: three games showed as 35, 35, 0 with gold,
  silver, and bronze, newest tie first.

Links: [[Memory Game]], [[Design Source]]
