# Simon Circle

The circular board widget (`SimonCircle` in `lib/widgets.dart`, planned). It is a `CustomPainter` plus a
`GestureDetector`, ported from `simon-circle.jsx` ([[Design Source]]).

- Size `S`: outer `R = S/2 − 8`, inner `r = 0.2·S`. Arc = 360/n. Gap is 4° for n ≤ 4, 3° for n ≤ 6, and 2.5° for n = 8.
- Sector `i` spans `[i·arc + gap/2, (i+1)·arc − gap/2]`, with 0° at 12 o'clock, going clockwise.
- A tile uses its lit color when it is active or pressed, plus a glow (`MaskFilter.blur` 18 and 6 in the lit color).
  The color change takes 150 ms.
- Center disc: radius `r−2`, fill `#0C0C14`, stroke `#1C1C28` at 1.5. An optional child is stacked in the center.
- Hit test: `r ≤ dist ≤ R`, then the tile comes from the angle (atan2, rotated so 0 = up). No taps are accepted while `disabled`.
- Props: `tileCount, theme, activeTile, pressedTile, onTileTap, disabled, center`.

Used on Home (idle animation), Game (interactive) and Settings (preview) → [[Screens]].
Colors from [[Theme and Colors]]. Driven by [[Game Engine]].
