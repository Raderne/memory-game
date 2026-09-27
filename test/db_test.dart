import 'package:flutter_test/flutter_test.dart';
import 'package:memory_app/db.dart';
import 'package:memory_app/theme.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });
  setUp(() => openDb(inMemoryDatabasePath));
  tearDown(closeDb);

  Future<void> add(int score, int round) => insertScore(
    score: score,
    round: round,
    tiles: 4,
    speed: Speed.normal,
    theme: ColorTheme.classic,
  );

  test('fresh db: no scores, best is 0, default settings', () async {
    expect(await topScores(), isEmpty);
    expect(await bestScore(), 0);
    final s = await loadSettings();
    expect(s.tileCount, 4);
    expect(s.speed, Speed.normal);
    expect(s.colorTheme, ColorTheme.classic);
  });

  test('topScores orders by score desc, bestScore is max, clear empties',
      () async {
    await add(35, 2);
    await add(200, 5);
    await add(90, 3);

    final top = await topScores();
    expect(top.map((s) => s.score), [200, 90, 35]);
    expect(top.first.round, 5);
    expect(top.first.speed, Speed.normal);
    expect(top.first.theme, ColorTheme.classic);
    expect(await topScores(2), hasLength(2));
    expect(await bestScore(), 200);

    await clearScores();
    expect(await topScores(), isEmpty);
    expect(await bestScore(), 0);
  });

  test('settings round-trip and overwrite', () async {
    await saveSetting('tileCount', '8');
    await saveSetting('speed', 'fast');
    await saveSetting('colorTheme', 'ocean');
    var s = await loadSettings();
    expect(s.tileCount, 8);
    expect(s.speed, Speed.fast);
    expect(s.colorTheme, ColorTheme.ocean);

    await saveSetting('speed', 'slow');
    s = await loadSettings();
    expect(s.speed, Speed.slow);
  });
}
