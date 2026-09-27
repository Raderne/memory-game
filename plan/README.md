# Memory — Flutter build plan

Simon-style memory game. Source design: claude.ai/design project `71c53062-9db7-4423-8239-dbf6989af89f`
(`Memory Game.html`, `memory-app.jsx`, `memory-screens.jsx`, `simon-circle.jsx`).
`design-canvas.jsx` and the `Phone` shell are presentation-only and are **not** ported, and neither are the fake status bar and home indicator in `PhoneFrame`. Flutter uses `SafeArea` for that space.

## Stack
- Flutter 3.44 / Dart 3.12 (installed). Android is the target platform, because the design uses an Android frame.
- `sqflite` + `path`: scores **and** settings in one SQLite db. That avoids adding `shared_preferences` as a second storage dependency.
- Dev: `sqflite_common_ffi` so db tests run on the Windows host.
- No state-management package. Use `setState`, plus one `ChangeNotifier` for the game loop.
- Navigation: plain `Navigator.push` / `pushReplacement`.
- Icons: built-in Material icons (the design's SVG strokes map 1:1, see `00-foundation.md`).

## Build order (one screen per step, each ends runnable)
| # | File | Delivers |
|---|------|----------|
| 0 | [00-foundation.md](00-foundation.md) | project, theme tokens, db, shared widgets, `SimonCircle` |
| 1 | [01-home.md](01-home.md) | Home screen, idle tile animation, best score |
| 2 | [02-gameplay.md](02-gameplay.md) | game engine + Game screen, writes score to db |
| 3 | [03-game-over.md](03-game-over.md) | result, new-high-score badge, replay/home |
| 4 | [04-settings.md](04-settings.md) | tiles / speed / theme, reset scores |
| 5 | [05-leaderboard.md](05-leaderboard.md) | top 10 from db, empty state |

## Target layout (fewest files)
```
lib/
  main.dart                 app root, loads settings, routes
  theme.dart                colors, accents, COLOR_THEMES, speeds
  db.dart                   sqflite: scores + settings
  game.dart                 SimonGame (ChangeNotifier), pure logic
  widgets.dart              Btn, TopBar, OptionRow, ChoiceChipX, SimonCircle
  screens/home.dart
  screens/game.dart
  screens/game_over.dart
  screens/settings.dart
  screens/leaderboard.dart
test/
  game_test.dart            scoring + sequence rules
  db_test.dart              insert / top / best / clear (ffi)
```

## Definition of done per screen
1. Matches the design values listed in its plan file (sizes, colors, copy).
2. `flutter analyze` is clean.
3. Tests listed in the file pass (`flutter test`).
4. Run on an emulator or device and check the flow by hand.
