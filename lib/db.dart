import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import 'theme.dart';

late Database _db;

/// Opens (and creates, on first run) the app database. Tests pass
/// [inMemoryDatabasePath] after pointing `databaseFactory` at the ffi factory.
Future<void> openDb([String? path]) async {
  _db = await openDatabase(
    path ?? p.join(await getDatabasesPath(), 'memory.db'),
    version: 1,
    onCreate: (db, _) async {
      await db.execute('''
        CREATE TABLE scores(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          score INTEGER NOT NULL,
          round INTEGER NOT NULL,
          tiles INTEGER NOT NULL,
          speed TEXT NOT NULL,
          theme TEXT NOT NULL,
          created_at INTEGER NOT NULL
        )''');
      await db.execute('CREATE INDEX idx_scores_score ON scores(score DESC)');
      await db.execute(
        'CREATE TABLE settings(key TEXT PRIMARY KEY, value TEXT NOT NULL)',
      );
    },
  );
}

Future<void> closeDb() => _db.close();

// ---- scores ----

class Score {
  final int score;
  final int round;
  final int tiles;
  final Speed speed;
  final ColorTheme theme;
  final DateTime createdAt;

  Score._(Map<String, Object?> row)
    : score = row['score'] as int,
      round = row['round'] as int,
      tiles = row['tiles'] as int,
      speed = Speed.values.byName(row['speed'] as String),
      theme = ColorTheme.values.byName(row['theme'] as String),
      createdAt = DateTime.fromMillisecondsSinceEpoch(row['created_at'] as int);
}

Future<void> insertScore({
  required int score,
  required int round,
  required int tiles,
  required Speed speed,
  required ColorTheme theme,
}) => _db.insert('scores', {
  'score': score,
  'round': round,
  'tiles': tiles,
  'speed': speed.name,
  'theme': theme.name,
  'created_at': DateTime.now().millisecondsSinceEpoch,
});

Future<List<Score>> topScores([int limit = 10]) async {
  final rows = await _db.query(
    'scores',
    orderBy: 'score DESC, created_at DESC',
    limit: limit,
  );
  return rows.map(Score._).toList();
}

Future<int> bestScore() async {
  final rows = await _db.rawQuery('SELECT MAX(score) AS best FROM scores');
  return (rows.first['best'] as int?) ?? 0;
}

Future<void> clearScores() => _db.delete('scores');

// ---- settings ----

Future<Settings> loadSettings() async {
  final rows = await _db.query('settings');
  final map = {for (final r in rows) r['key'] as String: r['value'] as String};
  const defaults = Settings();
  return Settings(
    tileCount: int.tryParse(map['tileCount'] ?? '') ?? defaults.tileCount,
    speed: Speed.values.asNameMap()[map['speed']] ?? defaults.speed,
    colorTheme:
        ColorTheme.values.asNameMap()[map['colorTheme']] ?? defaults.colorTheme,
  );
}

Future<void> saveSetting(String key, String value) => _db.insert(
  'settings',
  {'key': key, 'value': value},
  conflictAlgorithm: ConflictAlgorithm.replace,
);
