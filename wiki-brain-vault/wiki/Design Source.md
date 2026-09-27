# Design Source

The visual and behavioural spec is a React/JSX prototype in claude.ai/design.

- Project id: `71c53062-9db7-4423-8239-dbf6989af89f`, entry file `Memory Game.html`
- Read via the DesignSync tool (`get_file`). Run `/design-login` first if it reports an auth error.

| File | Content | Ported? |
|---|---|---|
| `memory-app.jsx` | theme tokens `T`, speeds, storage, shared UI, `useSimonGame` hook | yes, to `theme.dart`, `db.dart`, `widgets.dart` and `game.dart` |
| `memory-screens.jsx` | the 5 screens + `MemoryApp` router | yes, to `screens/*` and `main.dart` |
| `simon-circle.jsx` | SVG sector board + `COLOR_THEMES` | yes, to [[Simon Circle]] and [[Theme and Colors]] |
| `Memory Game.html` | canvas page + fake Android `Phone` shell | **no** (presentation only) |
| `design-canvas.jsx` | Figma-like pan/zoom canvas | **no** (presentation only) |
| `android-frame.jsx` | not imported by the entry file | no |

`PhoneFrame` in the prototype has a fake status bar and home indicator. Flutter uses `SafeArea` for that space instead.
`DemoGameScreen` / `DemoGameOverScreen` are static mock-ups for the canvas, not real screens.

## Deliberate deviations
- Storage is localStorage in the prototype and SQLite here (see [[Database]]). We keep every score instead of pruning to 20.
- The new-high-score test differs; see [[Game Engine]].

Links: [[Memory Game]], [[Build Plan]], [[Screens]]
