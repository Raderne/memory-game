# Theme and Colors

`lib/theme.dart` (planned). The full hex tables are in `plan/00-foundation.md`.

- Tokens: bg `#0A0A14`, surface `#111120`, card `#18182C`, cardBorder `#252540`, text `#E8E8F0`,
  textSec `#7E7E98`, textDim `#4A4A60`, success `#30D158`, danger `#FF453A`.
- 4 color themes (**classic, neon, ocean, sunset**). Each has 8 `(dim, lit)` tile colors, and the glow uses the lit color.
- Accent per theme: classic `#FF2D55`, neon `#00FFEE`, ocean `#0EA5E9`, sunset `#F97316`.
  The accent colors buttons, the score and the progress dots.
- Speeds: slow 900 "Relaxed", normal 550 "Normal", fast 350 "Fast".
- The design writes alpha tints as hex suffixes: `18`≈9%, `22`≈13%, `30`≈19%, `40`≈25%, `60`≈38%.

Chosen in Settings ([[Screens]]) and persisted in [[Database]]. Consumed by [[Simon Circle]].
