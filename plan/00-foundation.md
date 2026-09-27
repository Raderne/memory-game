# 00 — Foundation

## Setup
```
flutter create --org com.memory --platforms android memory_app .
flutter pub add sqflite path
flutter pub add --dev sqflite_common_ffi
```
Lock the app to portrait and a dark theme. Set `scaffoldBackgroundColor: bg` and use the system font (the design uses `system-ui`).

## theme.dart: tokens (from `memory-app.jsx` `T`)
| token | hex |
|---|---|
| bg | `#0A0A14` |
| surface | `#111120` |
| card | `#18182C` |
| cardBorder | `#252540` |
| text | `#E8E8F0` |
| textSec | `#7E7E98` |
| textDim | `#4A4A60` |
| success | `#30D158` |
| danger | `#FF453A` |
| circle center fill / stroke | `#0C0C14` / `#1C1C28` |

Accent per theme: classic `#FF2D55`, neon `#00FFEE`, ocean `#0EA5E9`, sunset `#F97316`.

Speeds (ms per step): slow 900 "Relaxed", normal 550 "Normal", fast 350 "Fast".

Tile colors `(dim, lit)`, 8 per theme, indexed by tile:
- **classic**: 3A1520/FF2D55, 152040/0A84FF, 103020/30D158, 302A10/FFD60A, 2A1540/BF5AF2, 402210/FF9F0A, 103030/64D2FF, 401530/FF375F
- **neon**: 0F2828/00FFEE, 280F28/FF00FF, 0F280F/39FF14, 281A0F/FF6B00, 280F1A/FF1493, 1A0F28/7B68EE, 28280F/FFE700, 0F1A28/1E90FF
- **ocean**: 0A1520/0EA5E9, 0F1A28/06B6D4, 0A2018/14B8A6, 101838/6366F1, 0A1830/3B82F6, 0F2420/2DD4BF, 101428/818CF8, 0A1A28/22D3EE
- **sunset**: 281010/EF4444, 281A0F/F97316, 282010/EAB308, 280F18/EC4899, 200F0F/DC2626, 301A10/FB923C, 30240F/FACC15, 300F1A/F472B6

Glow color = lit color.

## db.dart: SQLite
```sql
CREATE TABLE scores(
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  score INTEGER NOT NULL,
  round INTEGER NOT NULL,
  tiles INTEGER NOT NULL,
  speed TEXT NOT NULL,
  theme TEXT NOT NULL,
  created_at INTEGER NOT NULL          -- ms since epoch
);
CREATE INDEX idx_scores_score ON scores(score DESC);
CREATE TABLE settings(key TEXT PRIMARY KEY, value TEXT NOT NULL);
```
API (top-level functions on one opened `Database`; no repository class):
- `insertScore({score, round, tiles, speed, theme})`
- `topScores([limit = 10])` → `ORDER BY score DESC, created_at DESC LIMIT ?`
- `bestScore()` → `SELECT MAX(score)`, null → 0
- `clearScores()`
- `loadSettings()` / `saveSetting(key, value)`. Keys are `tileCount`, `speed` and `colorTheme`. Defaults are 4 / normal / classic.

The design keeps only 20 rows in localStorage. SQLite keeps every row, so no pruning is needed.

## widgets.dart: shared UI
- **Btn**: full width. With an accent: accent fill, white text, shadow `accent@25%` blur 24 y4. Without: `card` fill + 1px `cardBorder`. Radius 16 (small: 12), padding 15×28 (small: 10×20), font 16/600 (small: 14). Icon gap 8. Disabled means opacity 0.4.
- **TopBar**: height 48, back icon button (20px, textSec, padding 10), title 17/600, letterSpacing 0.2.
- **OptionRow**: `card` bg, radius 14, padding 14×16, 1px border. Label 13/500 uppercase textSec, letterSpacing 0.5, 10px gap to its children row (gap 8).
- **Chip**: expands, padding 10 vertical, radius 10, 14/600. Selected: bg `accent@13%` (`22` hex), 1.5px accent border, accent text. Unselected: `bg` fill, cardBorder, textSec.
- **SimonCircle**: `CustomPainter` + `GestureDetector`.
  - size S, `R = S/2 - 8`, inner `r = 0.2*S`, arc = 360/n, gap° = 4 (n≤4), 3 (n≤6), 2.5 (n=8).
  - Sector i spans `[i*arc + gap/2, (i+1)*arc - gap/2]`, with 0° at 12 o'clock going clockwise.
  - A tile uses its lit color when it is active or pressed. Glow = extra draw with `MaskFilter.blur(normal, 18)` and 6 in the lit color. The color change animates over 150 ms.
  - Center: circle radius `r-2` filled `#0C0C14`, 1.5px stroke `#1C1C28`, with an optional child widget stacked in the center.
  - Hit test on `onTapDown`: accept when `r ≤ dist ≤ R`, and pick the tile from `atan2` angle (rotated so 0 is up). Ignore taps while `disabled`.
  - Props: `tileCount, theme, activeTile, pressedTile, onTileTap, disabled, center`.

Icon mapping: back→`arrow_back`, gear→`settings_outlined`, trophy→`emoji_events_outlined`, play→`play_arrow`, replay→`replay`, home→`home_outlined`, trash→`delete_outline`.

## main.dart
Open the db, then load the settings. Keep `settings` in the root `State` and pass `settings` + `onSettingsChanged` down to screens. Home is the start route.

## Checks
- `test/db_test.dart` (ffi, in-memory): insert 3 scores, then assert `topScores` order, `bestScore`, and `clearScores` → empty.
- A widget test that taps each sector of a 4/6/8-tile circle and checks the right index comes back.
