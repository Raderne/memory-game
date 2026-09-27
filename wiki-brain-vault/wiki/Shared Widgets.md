# Shared Widgets

The reusable UI in `lib/widgets.dart` (built in step 0, see [[Build Plan]]), next to [[Simon Circle]].
Values come from `plan/00-foundation.md`; colors from [[Theme and Colors]].

| Widget | Props | Look |
|---|---|---|
| `Btn` | `label, icon?, accent?, small, onTap?` | Full width. With `accent`: accent fill, label and icon in `foregroundOn(accent)` (see [[Theme and Colors]]), shadow `accent@25%` blur 24 y4. Without: `card` fill + 1px `cardBorder`, `text` color. Radius 16 / small 12, padding 15×28 / small 10×20, font 16 / small 14 at w600, icon 18 with gap 8, min height 48. The label scales down instead of overflowing. `onTap == null` → opacity 0.4. |
| `TopBar` | `title` | 48 high. Back `IconButton` is at least 48×48, tooltip "Back", icon 20 in textSec, then the title 17/600, letterSpacing 0.2. The title scales down if it does not fit beside the button. |
| `OptionRow` | `label, children` | `card` bg, radius 14, padding 14×16, 1px border. Label uppercased 13/500 textSec letterSpacing 0.5, 10 gap, then `Row(spacing: 8, children)`. For a `Wrap` (Settings themes) pass one `Expanded` child. |
| `ChoiceChipX` | `label, selected, accent, onTap` | Returns an `Expanded`, so it must sit in a `Row` (`OptionRow` provides one). Padding 10 vertical, radius 10, 14/600 centred, min height 48, button semantics with `selected`. The label scales down at large text. Selected: `accent@13%` bg, 1.5px accent border, accent text. Unselected: `bg` fill, 1.5px cardBorder, textSec. |

## Decisions
- **Name `ChoiceChipX`, not `Chip`.** `package:flutter/material.dart` already exports `Chip`, so a widget of that
  name would force `hide Chip` on every import. `plan/README.md` already used `ChoiceChipX`; `CLAUDE.md` says `Chip`.
  Flagged to the user on 2026-09-27; `CLAUDE.md` still says `Chip` until they decide.
- Tap feedback uses `Material(type: transparency)` + `InkWell` so the ripple clips to the radius. No custom
  pressed-state colors, matching the design (which has none).
- Icons are Material built-ins: back→`arrow_back`, gear→`settings_outlined`, trophy→`emoji_events_outlined`,
  play→`play_arrow`, replay→`replay`, home→`home_outlined`, trash→`delete_outline`.

## Where they are used
Every screen in [[Screens]]. Settings uses `TopBar`, `OptionRow`, `ChoiceChipX`, and small `Btn`s for the
reset confirm.

Links: [[Memory Game]], [[Design Source]]
