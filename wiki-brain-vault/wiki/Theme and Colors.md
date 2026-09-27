# Theme and Colors

`lib/theme.dart` (built in step 0, see [[Build Plan]]). The full hex tables are in `plan/00-foundation.md`
and are transcribed 1:1 into the file.

## What the file exposes
- Top-level `const Color` tokens: `bg #0A0A14`, `surface #111120`, `card #18182C`, `cardBorder #252540`,
  `text #E8E8F0`, `textSec #80809A`, `textDim #4A4A60`, `success #30D158`, `danger #FF453A`,
  `circleCenterFill #0C0C14`, `circleCenterStroke #1C1C28`.
- `enum ColorTheme { classic, neon, ocean, sunset }` with `label`, `accent` and `tiles` (8 × `TileColor`).
  `TileColor` stores the RGB ints and exposes `Color get dim` / `Color get lit`. Glow uses `lit`.
  Accents: classic `#FF2D55`, neon `#00FFEE`, ocean `#0EA5E9`, sunset `#F97316`.
- `enum Speed { slow(900,'Relaxed'), normal(550,'Normal'), fast(350,'Fast') }` with `stepMs` and `label`.
- `class Settings { tileCount = 4, speed = normal, colorTheme = classic }` with `accent` and `copyWith`.
  Lives in the root widget's state and is passed down ([[Screens]]); persisted by [[Database]].
  Enums are stored as `.name` strings and parsed with `values.asNameMap()`, so bad values fall back to defaults.
- `appTheme`: dark `ThemeData`, `scaffoldBackgroundColor: bg`, system font (no `fontFamily`).
- `contrastRatio(a, b)` and `foregroundOn(background)`. `foregroundOn` picks `bg` or `text`, whichever
  contrasts more with the fill. Every theme accent and `danger` currently resolve to `bg`, so accent
  buttons (Start Game, Play Again, Confirm) use dark labels. Accent hex values are unchanged.

## Notes
- The design writes alpha tints as hex suffixes: `18`≈9%, `22`≈13%, `30`≈19%, `40`≈25%, `60`≈38%.
  In Dart use `color.withValues(alpha: 0x22 / 255)` etc.
- Const gotcha: `Color(0xFF000000 | x)` is not a valid const initializer, hence the int fields + getters
  on `TileColor`.
- **Contrast adjustment (step 4).** The plan's `textSec #7E7E98` is about 4.42:1 on `card`, under the
  4.5:1 body-text bar, so labels on cards use `#80809A` (about 4.5:1 on `card`, 5.1:1 on `bg`).
  `textDim #4A4A60` stays as specified. Lifting it to 4.5:1 would make it nearly the same as `textSec`
  and erase the hierarchy; it is still about 2.3:1 on `bg` and is used for the Home "Best" line.

Consumed by [[Simon Circle]] and [[Shared Widgets]]. Changed in Settings ([[Screens]]).
