# Tech Stack

- **Flutter 3.44 / Dart 3.12**, Android only, portrait, dark theme.
- **sqflite + path** for storage; **sqflite_common_ffi** (dev) for host-side db tests.
- No state-management library: `setState` + one `ChangeNotifier` ([[Game Engine]]).
- Navigation: `Navigator.push` / `pushReplacement`.
- Material icons only.
- Project: package `memory_app`, Android id `com.memory.memory_app`, label "Memory". Created with
  `flutter create --org com.memory --platforms android --project-name memory_app .` (the repo folder
  `Memory` is not a valid Dart package name, hence `--project-name`). Portrait is locked in
  `AndroidManifest.xml` (`android:screenOrientation="portrait"`). The template's `cupertino_icons` was dropped.

## Why (decided 2026-09-27)
- Flutter compiles to native ARM and paints via its own engine, with no JS bridge. That gives smooth
  glow animations and precise sequence timing for [[Simon Circle]] on mid-range phones.
- sqflite wraps the SQLite already built into Android, so there is no bundled engine. That is plenty for
  a few hundred score rows, and the data survives the app being killed.
- Settings also go in SQLite, so there is only one storage dependency (no `shared_preferences`).
- Native Kotlin was considered and rejected: twice the work for no visible gain on a game this small.
- iOS is deferred. It's cheap to add later from the same codebase, but it isn't needed yet.

Any new dependency needs the user's approval ([[CLAUDE.md Rules]]).

Links: [[Memory Game]], [[Database]]
