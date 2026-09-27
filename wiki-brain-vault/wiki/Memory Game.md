# Memory Game

A Simon-style memory game: a circular board of 4, 6 or 8 colored tiles lights up in a sequence,
and the player repeats it. Each correct round appends one more tile. Scores are stored locally
in SQLite. Android only (v1). Offline, no sound, no accounts.

- Built with: [[Tech Stack]]
- Spec: [[Design Source]], transcribed into `plan/`, build order in [[Build Plan]]
- Core pieces: [[Game Engine]], [[Simon Circle]], [[Database]], [[Theme and Colors]]
- UI: [[Screens]] (Home, Gameplay, Game Over, Settings, Leaderboard)
- Rules for contributors: [[CLAUDE.md Rules]]

## State (2026-09-27)
Planning done. No Flutter code yet. Next step: `plan/00-foundation.md`.
