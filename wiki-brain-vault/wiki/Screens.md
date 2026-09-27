# Screens

Five screens under `lib/screens/`. Home, Game, and Game Over are built; Settings and Leaderboard remain
planned. Per-screen specs live in `plan/0N-*.md` ([[Build Plan]]).

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
  - Navigation is exposed as `onStartGame`, `onOpenSettings`, and `onOpenScores` callbacks. Settings and
    Scores remain no-ops until their build steps.
  - `homeRouteObserver` reloads the best score in `didPopNext`, so returning from Play Again still
    updates "Best".
- **Game** (`screens/game.dart`, built in step 2): 48px Round/score header, interactive [[Simon Circle]],
  animated phase message, and progress dots. Driven by [[Game Engine]].
  - The circle is 85% of screen width capped at 280 (and constrained to the available width). Input is
    disabled outside the engine's input phase. The center shows the round or a danger-colored `✕`.
  - Completed 8px progress dots use the current accent and 38%-alpha glow; dots wrap only if a very long
    sequence cannot fit one row.
  - On game over, previous best is read before the score is inserted, exactly once. After 1200 ms the
    Game route is replaced by Game Over. Back before game over disposes the engine and saves nothing.
  - Message color animation becomes instantaneous when reduced motion is enabled. The layout was
    checked at normal and 2× text scale.
- **Game Over** (`screens/game_over.dart`, built in step 3): trophy badge, score, optional new-record
  pill, Round/Best, Play Again, and Home.
  - `best = max(prevBest, score)`. The pill shows only when `score > 0 && score > prevBest`, so a tie
    is not a new record.
  - The result fades and slides 20px over 500ms ease, starting 100ms after the route builds. Reduced
    motion shows it immediately. Android back uses the same action as Home.
  - Play Again replaces this route with a fresh Game using the current settings. Home pops back to Home.
- **Settings**: Tiles 4/6/8, Speed, Color Theme ([[Theme and Colors]]) and a preview circle. Changes save
  immediately. Reset All Scores uses an inline confirm, not a dialog.
- **Leaderboard**: top 10 with 🥇🥈🥉, round, time-ago, and an empty state.

Settings are held in the root widget state and passed down (no state library, see [[Tech Stack]]).
Screens compose the [[Shared Widgets]] (`Btn`, `TopBar`, `OptionRow`, `ChoiceChipX`) and the [[Simon Circle]].
Links: [[Memory Game]], [[Design Source]]
