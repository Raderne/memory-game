# Screens

Five screens under `lib/screens/` (planned). Per-screen specs live in `plan/0N-*.md` ([[Build Plan]]).

```
Home ──Start──▶ Game ──(gameover, 1.2s, replace)──▶ Game Over ──Play Again (replace)──▶ Game
 │  ◀──Back (no save)──┘                                 └──Home──▶ Home
 ├──Settings──▶ Settings ──Back──▶ Home
 └──Scores────▶ Leaderboard ──Back──▶ Home
```

- **Home**: an idle-animated [[Simon Circle]], a gradient "MEMORY" title, "Best: N" from [[Database]], and
  Start / Settings / Scores. Best is reloaded when returning to Home.
- **Game**: Round N, a score pill, the interactive circle and progress dots. Driven by [[Game Engine]].
- **Game Over**: score, a ★ NEW HIGH SCORE badge, Round/Best stats, Play Again / Home.
- **Settings**: Tiles 4/6/8, Speed, Color Theme ([[Theme and Colors]]) and a preview circle. Changes save
  immediately. Reset All Scores uses an inline confirm, not a dialog.
- **Leaderboard**: top 10 with 🥇🥈🥉, round, time-ago, and an empty state.

Settings are held in the root widget state and passed down (no state library, see [[Tech Stack]]).
Screens compose the [[Shared Widgets]] (`Btn`, `TopBar`, `OptionRow`, `ChoiceChipX`) and the [[Simon Circle]].
Until step 1, `main.dart`'s start route is a temporary foundation preview, not Home ([[Build Plan]] § Step notes).
Links: [[Memory Game]], [[Design Source]]
