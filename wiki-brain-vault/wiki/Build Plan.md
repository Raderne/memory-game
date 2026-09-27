# Build Plan

The app is built **one screen per step**. Specs live in `plan/` (repo root). Each step ends runnable
and must meet the definition of done in [[CLAUDE.md Rules]].

| # | Plan file | Scope | Status |
|---|---|---|---|
| 0 | `plan/00-foundation.md` | project, [[Theme and Colors]], [[Database]], [[Shared Widgets]], [[Simon Circle]] | **done** 2026-09-27 |
| 1 | `plan/01-home.md` | Home ([[Screens]]) | **done** 2026-09-27 |
| 2 | `plan/02-gameplay.md` | [[Game Engine]] + Game screen | todo |
| 3 | `plan/03-game-over.md` | Game Over | todo |
| 4 | `plan/04-settings.md` | Settings | todo |
| 5 | `plan/05-leaderboard.md` | Leaderboard | todo |

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

Links: [[Memory Game]], [[Design Source]]
