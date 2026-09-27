# 04 — Settings (`screens/settings.dart`)

TopBar "Settings" with back. The body is a scrollable column, padding 8×16, gap 14.

Every change applies immediately: `saveSetting(...)` + `onSettingsChanged(...)`. There is no Save button (same as the design).
The accent color on this screen follows the currently selected theme.

1. **OptionRow "TILES"**: Chips 4 / 6 / 8.
2. **OptionRow "SPEED"**: Chips Relaxed / Normal / Fast → slow / normal / fast.
3. **OptionRow "COLOR THEME"**: `Wrap` with 2 columns, gap 10. Each theme button:
   - padding 10×12, radius 10, min width 120.
   - Selected: bg `themeAccent@9%` with a 1.5px themeAccent border. Otherwise `bg` fill with cardBorder.
   - Contents: 4 dots (14×14 circles, gap 3) using the first 4 lit colors, then the name (Classic / Neon / Ocean / Sunset) at 13/600, themeAccent if selected, textSec if not.
4. **Preview**: SimonCircle 130 wide, disabled, `activeTile: 0`, following the current tiles and theme.
5. **Reset**: pinned to the bottom, 12 px padding below.
   - Idle state: an outlined button, full width, padding 12, radius 12, 1px `danger@25%` border, trash icon 16 + "Reset All Scores" at 14/500 in the danger color.
   - After a tap it becomes two small Btns: "Cancel" (plain) and "Confirm" (accent = danger) → `clearScores()`, then back to idle. This is inline, not a dialog.

## Done when
- Settings survive an app restart (they are read from SQLite).
- Changing the theme recolors Home, Game and the circle. Changing tiles changes how many sectors are drawn.
- After Reset, the Leaderboard is empty and the Home "Best" line is hidden.
