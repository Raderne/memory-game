# Build Plan

The app is built **one screen per step**. Specs live in `plan/` (repo root). Each step ends runnable
and must meet the definition of done in [[CLAUDE.md Rules]].

| # | Plan file | Scope | Status |
|---|---|---|---|
| 0 | `plan/00-foundation.md` | project, [[Theme and Colors]], [[Database]], shared widgets, [[Simon Circle]] | todo |
| 1 | `plan/01-home.md` | Home ([[Screens]]) | todo |
| 2 | `plan/02-gameplay.md` | [[Game Engine]] + Game screen | todo |
| 3 | `plan/03-game-over.md` | Game Over | todo |
| 4 | `plan/04-settings.md` | Settings | todo |
| 5 | `plan/05-leaderboard.md` | Leaderboard | todo |

Order rationale: the design's order. Gameplay comes early so the play → save → result loop works
by step 3.

**Update the Status column when a step finishes.**

Links: [[Memory Game]], [[Design Source]]
