# CLAUDE.md — Memory (Simon-style memory game)

Guidance for any AI agent or teammate working in this repo. Read this file fully before
touching code, then read `wiki-brain-vault/wiki/index.md`.

## What this is

A Simon-style memory game for Android, built with **Flutter** + **SQLite (`sqflite`)**.
The player watches a sequence light up on a circular board of 4, 6 or 8 tiles and repeats it.
Every correct round adds one tile to the sequence, and the score is saved to SQLite at game over.

Source design: claude.ai/design project `71c53062-9db7-4423-8239-dbf6989af89f`, file
`Memory Game.html` (React/JSX prototype). The design is the **visual and behavioural spec**.
When in doubt, match it. Its values are already transcribed into `plan/`.

## Current state

Planning is done, and **no Flutter code exists yet**. Work proceeds **screen by screen** in this order:

| Step | Plan file | Scope |
|---|---|---|
| 0 | `plan/00-foundation.md` | project, theme tokens, db, shared widgets, `SimonCircle` |
| 1 | `plan/01-home.md` | Home |
| 2 | `plan/02-gameplay.md` | game engine + Game screen |
| 3 | `plan/03-game-over.md` | Game Over |
| 4 | `plan/04-settings.md` | Settings |
| 5 | `plan/05-leaderboard.md` | Leaderboard |

Do **one step at a time**. Don't start the next step unless the user asks for it. When you
finish a step, mark it done in `wiki-brain-vault/wiki/Build Plan.md` and add a log line.

## Stack & hard decisions (don't change without asking the user)

- **Flutter 3.44 / Dart 3.12**. **Android only** for v1 (portrait, dark theme).
- **`sqflite` + `path`** for storage. **Both scores and settings live in SQLite.** Do not add
  `shared_preferences`, Hive, Isar, drift, etc.
- **Dev dependency:** `sqflite_common_ffi`, so db tests run on the Windows host.
- **No state-management packages** (no Provider/Riverpod/Bloc/GetX). Use `setState` plus one
  `ChangeNotifier` (`SimonGame`) for the game loop. Settings live in the root widget's
  state and are passed down.
- **Navigation:** plain `Navigator.push` / `pushReplacement`. No router package.
- **Icons:** built-in Material icons. No icon packages, no SVG assets.
- **No sound, no analytics, no network** in v1. The design has none.
- Adding **any** new dependency requires the user's approval.

## Layout (keep to these files, don't add more without a reason)

```
lib/
  main.dart            app root, opens db, loads settings, routes
  theme.dart           color tokens, accents, tile color themes, speeds
  db.dart              sqflite: scores + settings (top-level functions, no repository class)
  game.dart            SimonGame (ChangeNotifier), pure logic, no widget/db imports
  widgets.dart         Btn, TopBar, OptionRow, Chip, SimonCircle
  screens/{home,game,game_over,settings,leaderboard}.dart
test/
  game_test.dart       scoring + sequence rules
  db_test.dart         insert / top / best / clear via ffi in-memory db
```

## Game rules (source of truth = `plan/02-gameplay.md`)

- A correct tap adds `10 × round`. Completing the sequence adds a bonus of `25 × round`.
- Timing per step `d`: slow 900 ms, normal 550 ms, fast 350 ms. Each tile stays lit for `0.55·d`.
  After the last tile, input opens `0.35·d` later. There is a 600 ms delay before round 1,
  1100 ms between rounds, and 1200 ms from game over to the Game Over screen.
- **New high score** = `score > 0 && score > previousBest`. Read the previous best **before**
  inserting the new score.
- Leaving a game with Back does **not** save a score.

## Coding conventions

- Match the design values exactly (hex colors, font sizes/weights, paddings, radii). They are
  listed in each plan file. Don't eyeball them.
- Keep the code minimal: no interfaces with one implementation, no config for constants, no
  scaffolding "for later".
- `game.dart` must stay free of Flutter widget and db imports, so it stays unit-testable.
- Cancel every `Timer` in `dispose()`, so a timer never fires on a disposed widget.
- Keep SQL in `db.dart` only.

## Definition of done (every step)

1. It matches the design values in the step's plan file.
2. `flutter analyze` is clean.
3. `flutter test` passes, including the tests the plan file lists.
4. The flow is checked by hand on an emulator or device.
5. The wiki and log are updated (see below).

## Commands

```
flutter pub get
flutter analyze
flutter test
flutter run            # Android emulator/device
```

## Wiki-Brain — knowledge base (READ FIRST, KEEP UPDATED)

This repo has a persistent, cross-linked knowledge base at **`wiki-brain-vault/`**. It holds the
accumulated understanding of this project and exists to reduce token usage. Consult it
instead of re-reading the whole codebase, and treat it as primary context.

### Use it

- **At the start of a task, consult the wiki before digging through the code.** Entry point:
  `wiki-brain-vault/wiki/index.md`. Follow `[[Page]]` links to the relevant pages.
- Only read files in `wiki-brain-vault/raw/` if a page points you there or the user says
  "read the raw file". **Never modify `raw/`**. Its sources are immutable.

### Keep it updated (mandatory)

- **Claude fully owns `wiki-brain-vault/wiki/`.** When a task produces durable knowledge
  (a decision, a resolved bug, an architecture or state change, a new subsystem), create or update
  the relevant wiki page(s) before finishing. Don't ask permission for each page; just report what changed.
- **Cross-link aggressively** with Obsidian `[[Page Name]]` syntax. A page with no inbound links
  is a dead end.
- **Always update `wiki-brain-vault/wiki/index.md`** when you create or rename a page.
- **End every session with a log line** appended to `wiki-brain-vault/log.md`:

  ```text
  ## [YYYY-MM-DD HH:MM] session | <title in 3-8 words>
  Touched: <comma-separated wiki pages, or "none">
  ```

  If the session was trivial (a one-off fix, a routine chore, pure exploration), add only the log line
  and skip the wiki update.
- **Flag contradictions; don't silently resolve them.** If new info conflicts with an existing page,
  surface it to the user.

### Ingesting docs

To fold a source doc into the wiki, summarize a file from `wiki-brain-vault/raw/` (or `plan/`)
into a wiki page, cross-link it, update `index.md`, and add a log line.
