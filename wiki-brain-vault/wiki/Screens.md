# Screens

Five screens under `lib/screens/`. Home is built; the other four remain planned. Per-screen specs live
in `plan/0N-*.md` ([[Build Plan]]).

```
Home ──Start──▶ Game ──(gameover, 1.2s, replace)──▶ Game Over ──Play Again (replace)──▶ Game
 │  ◀──Back (no save)──┘                                 └──Home──▶ Home
 ├──Settings──▶ Settings ──Back──▶ Home
 └──Scores────▶ Leaderboard ──Back──▶ Home
```

- **Home** (`screens/home.dart`, built in step 1): a centered, idle-animated [[Simon Circle]], gradient
  "MEMORY" title, "Best: N" from [[Database]], and Start / Settings / Scores. It is now the start route.
  - The board lights tile `i % tileCount` every 1200 ms for 500 ms. Both timers are cancelled in
    `dispose`; `MediaQuery.disableAnimations` keeps it still when reduced motion is enabled.
  - `loadBest` defaults to `bestScore` and is injectable only to keep the widget test independent from
    SQLite. The score loads on entry and after any destination callback returns; zero is hidden.
  - Circle width is 70% of the screen capped at 220. The page uses `SafeArea`, 32px horizontal padding,
    48dp secondary touch targets, semantic button labels, and `Flexible` labels at large text scales.
  - Navigation is exposed as `onStartGame`, `onOpenSettings`, and `onOpenScores` callbacks. `main.dart`
    intentionally passes no-ops until each target screen's build step; no future-screen stubs were added.
- **Game**: Round N, a score pill, the interactive circle and progress dots. Driven by [[Game Engine]].
- **Game Over**: score, a ★ NEW HIGH SCORE badge, Round/Best stats, Play Again / Home.
- **Settings**: Tiles 4/6/8, Speed, Color Theme ([[Theme and Colors]]) and a preview circle. Changes save
  immediately. Reset All Scores uses an inline confirm, not a dialog.
- **Leaderboard**: top 10 with 🥇🥈🥉, round, time-ago, and an empty state.

Settings are held in the root widget state and passed down (no state library, see [[Tech Stack]]).
Screens compose the [[Shared Widgets]] (`Btn`, `TopBar`, `OptionRow`, `ChoiceChipX`) and the [[Simon Circle]].
Links: [[Memory Game]], [[Design Source]]
