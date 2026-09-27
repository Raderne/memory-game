# Database

SQLite via `sqflite`. All SQL lives in `lib/db.dart` (planned), which exposes top-level functions and no repository class.

```sql
CREATE TABLE scores(
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  score INTEGER NOT NULL, round INTEGER NOT NULL,
  tiles INTEGER NOT NULL, speed TEXT NOT NULL, theme TEXT NOT NULL,
  created_at INTEGER NOT NULL            -- ms since epoch
);
CREATE INDEX idx_scores_score ON scores(score DESC);
CREATE TABLE settings(key TEXT PRIMARY KEY, value TEXT NOT NULL);
```

API: `insertScore`, `topScores([limit=10])` (score DESC, then created_at DESC), `bestScore()`
(MAX, null→0), `clearScores()`, `loadSettings()`, `saveSetting(key, value)`.
Setting keys and defaults: `tileCount`=4, `speed`=normal, `colorTheme`=classic.

## Decisions
- Every score row is kept. The prototype pruned to 20, but the leaderboard only shows the top 10, so pruning adds nothing.
- Settings are stored here too, to avoid a second storage dependency ([[Tech Stack]]).
- Tests use `sqflite_common_ffi` with an in-memory db (`test/db_test.dart`).

Used by: [[Screens]] (Home best, Game insert, Game Over best, Settings, Leaderboard).
Links: [[Game Engine]]
