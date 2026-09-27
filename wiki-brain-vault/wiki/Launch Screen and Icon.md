# Launch Screen and Icon

Ported from the design's `launch.jsx` ([[Design Source]]): `SplashScreen` and `IconGlyph`.

## Launch screen (`lib/screens/splash.dart`)
- `main.dart` shows `SplashScreen` as `home`. When it finishes, an `AnimatedSwitcher` (300 ms fade) swaps
  in Home, which **stays the root route**. `homeRouteObserver` and Game Over's "Home pops back" rely on that.
  A pushed route wouldn't work here: its page is cached, so it would miss settings changes.
- One 5000 ms `AnimationController`. `_SplashPainter` draws on the design's 280 grid at 200px. Timeline in ms,
  copied from the CSS keyframes:
  - board spins from −90° over 0–1400 (`cubic(.2,.8,.2,1)`)
  - sector *i* pops in at 150+220i: it takes 450 ms to scale .6→1.05→1, and over 900 ms its fill goes lit→dim
  - the dot pops at 1300; the flash and the ring ripple start at 1550
  - "MEMORY" (30/w800, spacing 18→8, blur 6→0) appears at 1900 and the tagline at 2300
  - the 120×3 bar fills over 2600–4200, and everything fades out over 4500–5000
- The ring shows at 0.7 opacity from t=0. That's deliberate: the CSS uses `fill-mode: both`.
- Tile colors reuse `ColorTheme.classic.tiles` (the same hex values as the design's `LP_COLORS`).
- Reduced motion → `onDone` on the first frame, so the splash is skipped. It plays once and doesn't loop
  (the design's 5.2 s loop exists only for the canvas preview).
- Tests: `test/splash_test.dart` (fires once at 5 s, reduced motion, no callback after dispose).

## Native launch (Android)
- Both `LaunchTheme` and `NormalTheme` (day + night) use `@color/window_background` = `#0A0A14`, so there is
  no white flash. The template's `launch_background.xml` drawables were deleted.
- Android 12+ shows the system splash (the adaptive icon on that color) before Flutter's first frame.

## Launcher icon
- Adaptive (`mipmap-anydpi-v26/ic_launcher.xml`): background `@color/ic_launcher_background` `#0E0E1A`,
  foreground `ic_launcher_foreground.png`. The glyph's 512 grid fills the centre 72dp of the 108dp canvas,
  so the board (R170) stays inside the 66dp safe zone.
- Legacy `ic_launcher.png` (48dp at each density): the full glyph in a squircle (rx 116).
- The glyph has 4 sectors (R170/r68, gap 14°). Red is lit with a blur-22 glow at .75; the others use the `mid`
  colors. The center is an r52 `#0A0A14` disc with an r14 `#E8E8F0` dot.
- The PNGs were rendered with Flutter's own canvas: a throwaway test drew with `sectorPath` and wrote PNGs,
  then it was deleted. To regenerate, recreate that test (PictureRecorder → `toImage` → PNG). No icon
  package was added ([[Tech Stack]]).
- No monochrome (themed) icon yet.

Links: [[Screens]], [[Simon Circle]], [[Shared Widgets]], [[Memory Game]]
