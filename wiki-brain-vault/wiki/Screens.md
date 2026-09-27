# Screens

Five screens under `lib/screens/`, plus the splash. Home, Game, Game Over, Settings, and Leaderboard
are built. Per-screen specs live in `plan/0N-*.md` ([[Build Plan]]).

```
Splash ──(5s, fade, replaces as root)──▶ Home
Home ──Start──▶ Game ──(gameover, 1.2s, replace)──▶ Game Over ──Play Again (replace)──▶ Game
 │  ◀──Back (no save)──┘                                 └──Home──▶ Home
 ├──Settings──▶ Settings ──Back──▶ Home
 └──Scores────▶ Leaderboard ──Back──▶ Home
```

- **Splash** (`screens/splash.dart`): the animated launch screen, see [[Launch Screen and Icon]].
- **Home** (`screens/home.dart`, built in step 1): a centered, idle-animated [[Simon Circle]], gradient
  "MEMORY" title, "Best: N" from [[Database]], and Start / Settings / Scores. It is now the start route.
  - The board lights tile `i % tileCount` every 1200 ms for 500 ms. Both timers are cancelled in
    `dispose`; `MediaQuery.disableAnimations` keeps it still when reduced motion is enabled.
  - `loadBest` defaults to `bestScore` and is injectable only to keep the widget test independent from
    SQLite. The score loads on entry and after any destination callback returns; zero is hidden.
  - Circle width is 70% of the screen capped at 220. The page uses `SafeArea`, 32px horizontal padding,
    48dp secondary touch targets, semantic button labels, and `Flexible` labels at large text scales.
  - Navigation is exposed as `onStartGame`, `onOpenSettings`, and `onOpenScores` callbacks. Scores pushes
    the Leaderboard. Settings pushes the Settings screen.
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
- **Settings** (`screens/settings.dart`, built in step 4): TopBar "Settings", then scrollable TILES
  (4/6/8), SPEED (Relaxed/Normal/Fast), and COLOR THEME. Theme buttons are a 2-column wrap (1 column
  when two 120px buttons will not fit), each with the first four lit dots and that theme's own accent
  when selected. A 130px disabled [[Simon Circle]] (`activeTile: 0`) previews the current tiles and theme.
  Every change calls `saveSetting` and `onSettingsChanged` immediately. Reset All Scores is pinned to the
  bottom: an outlined danger button, then inline Cancel / Confirm. Confirm calls `clearScores()` and
  stays on this screen. Home reloads Best when it is revealed, so the Best line disappears after a reset.
  Controls are at least 48dp, labelled for the screen reader, and the page was checked at 2× text.
- **Leaderboard** (`screens/leaderboard.dart`, built in step 5): TopBar "Leaderboard", then the top 10
  scores from [[Database]] `topScores(10)`. The body waits for that future, so the empty state does not
  flash. Empty: a 64px trophy circle, "No scores yet", and "Play a game to set your first record!".
  Otherwise a separated list. Rank 1 uses the current accent at 6% fill and 19% border; other rows use
  the card. Ranks 1–3 are 🥇 🥈 🥉, later ranks are the number. Each row shows the score, "Round N", and
  `timeAgo` ("just now", "{m}m ago", "{h}h ago", "{d}d ago"). Rows are labelled for the screen reader.
  The title, rank glyph, and time shrink instead of overflowing at large text.

Settings are held in the root widget state and passed down (no state library, see [[Tech Stack]]).
Screens compose the [[Shared Widgets]] (`Btn`, `TopBar`, `OptionRow`, `ChoiceChipX`) and the [[Simon Circle]].
Links: [[Memory Game]], [[Design Source]]
