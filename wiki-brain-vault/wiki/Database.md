# Database

SQLite via `sqflite`. All SQL lives in `lib/db.dart` (built in step 0, see [[Build Plan]]). It exposes
top-level functions over one module-level `Database`; there is no repository class.

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

## API
- `openDb([path])`: opens `<databasesPath>/memory.db` (version 1, tables created in `onCreate`).
  Call once in `main()` before `runApp`. `closeDb()` exists for tests.
- `insertScore({score, round, tiles, speed: Speed, theme: ColorTheme})`: stores enum `.name`s.
- `topScores([limit = 10])` → `List<Score>` ordered `score DESC, created_at DESC`.
  `Score` has `score, round, tiles, speed, theme, createdAt` (typed back to the enums) and a public
  constructor. The query still builds rows through the private `Score._` factory.
- `bestScore()` → `MAX(score)`, 0 when empty.
- `clearScores()`.
- `loadSettings()` → `Settings` ([[Theme and Colors]]), applying defaults 4 / normal / classic for missing or
  unparsable rows. `saveSetting(key, value)` upserts (`ConflictAlgorithm.replace`).
  Keys: `tileCount`, `speed`, `colorTheme`.

## Decisions
- Every score row is kept. The prototype pruned to 20, but the leaderboard only shows the top 10, so pruning adds nothing.
- Settings are stored here too, to avoid a second storage dependency ([[Tech Stack]]).
- Tests: `test/db_test.dart` uses `sqflite_common_ffi` (`sqfliteFfiInit(); databaseFactory = databaseFactoryFfi;`)
  and `openDb(inMemoryDatabasePath)` per test. Covers fresh-db defaults, top/best/clear, settings round-trip.
  Works on the Windows host with no extra setup.

Used by: [[Screens]] (Home best, Game insert, Game Over best, Settings, Leaderboard).
Links: [[Game Engine]]
