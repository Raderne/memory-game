# 01 — Home (`screens/home.dart`)

Layout: a centered column with 32 px horizontal padding.

1. **SimonCircle**: width 70% of the screen, max 220. Disabled. The center shows `●` at 13/700, textDim.
   - Idle animation: every 1200 ms, light tile `i % tileCount` for 500 ms, then increment `i`. Use a `Timer.periodic`, cancelled in `dispose`.
2. **Title** "MEMORY": 32/800, letterSpacing 6, top margin 16 and bottom margin 4. The text has a linear gradient at 135° from accent to text (`ShaderMask`).
3. Subtitle "How far can you go?": 14, textSec, 6 px bottom margin.
4. If best > 0, show "Best: {best}" (13, textDim, 24 px bottom margin). Otherwise show a 37 px spacer so the layout doesn't shift.
5. **Btn** with accent, max width 260: play icon (18, white) + "Start Game" → push the Game screen.
6. A row with gap 12, 24 px above it, holding two secondary buttons: card bg, 1px border, radius 14, padding 12×20, icon 18 + 13/500 textSec label.
   - gear "Settings" → Settings screen
   - trophy "Scores" → Leaderboard screen

Data: `bestScore()` from the db. Reload it when returning to this screen (`await Navigator.push(...)` then `setState`).
Accent follows `settings.colorTheme`. The circle follows `tileCount` + `colorTheme`.

## Done when
- The idle light cycles through all tiles for 4, 6 and 8 tiles.
- "Best" appears after a game has been recorded (you can check this after step 02) and is hidden on a fresh install.
