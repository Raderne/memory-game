# Simon Circle

The circular board widget (`SimonCircle` in `lib/widgets.dart`, built in step 0). A `CustomPainter` plus a
`GestureDetector`, ported from `simon-circle.jsx` ([[Design Source]]). Sibling widgets: [[Shared Widgets]].

## Geometry (from the plan, implemented as-is)
- Fills the square of its parent's shortest side (`LayoutBuilder`); the caller sets the width with a `SizedBox`.
- Size `S`: outer `R = S/2 − 8`, inner `r = 0.2·S`. Arc = 360/n. Gap is 4° for n ≤ 4, 3° for n ≤ 6, 2.5° for n = 8
  (`SimonCircle.gapDeg(n)`).
- Sector `i` is an annular sector spanning `[i·arc + gap/2, (i+1)·arc − gap/2]`, 0° at 12 o'clock, clockwise.
  Canvas angle = `deg − 90°`.
- Center disc: radius `r−2`, fill `#0C0C14`, stroke `#1C1C28` at 1.5. The optional `center` widget is stacked on top.

## Lighting
- A tile is lit when `i == activeTile || i == pressedTile`.
- One `AnimationController` (150 ms) per tile holds a 0→1 "lit" value; `didUpdateWidget` calls `animateTo`.
  The painter takes the controllers and uses `Listenable.merge` as its `repaint`, so lighting never rebuilds the widget.
- Paint per tile: if lit > 0, two glow passes (`MaskFilter.blur(normal, 18)` and `6`) in `lit` at alpha = t,
  then the fill `Color.lerp(dim, lit, t)`.

## Hit test
- `onTapDown` (immediate, so the game feels snappy). Accept when `r ≤ dist ≤ R`; tile = `floor(deg / arc)` with
  `deg = atan2(dx, −dy)` normalised to `[0, 360)`. Taps in the center disc or outside the ring are ignored.
- `disabled: true` passes `onTapDown: null`, so nothing fires.

Props: `tileCount, theme (ColorTheme), activeTile, pressedTile, onTileTap, disabled, center`.

Tests: `test/simon_circle_test.dart` taps the middle of every sector for 4/6/8 tiles and checks the index,
plus center/outside/disabled taps are ignored.

Used on Home (idle animation), Game (interactive) and Settings (preview) → [[Screens]].
Colors from [[Theme and Colors]]. Driven by [[Game Engine]].
