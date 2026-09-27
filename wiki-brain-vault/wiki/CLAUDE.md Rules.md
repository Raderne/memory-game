# CLAUDE.md Rules

Summary of the repo-root `CLAUDE.md`. That file is authoritative; read it for the details.

- Build **one step at a time** per [[Build Plan]]. Don't start the next step unasked.
- Stack is fixed ([[Tech Stack]]): Flutter + sqflite only. **No new dependencies** without user approval.
  No state-management, router, icon or other storage packages.
- Keep to the planned file layout. SQL stays in `db.dart`. `game.dart` stays free of widget and db imports.
- Match the design values exactly ([[Design Source]], `plan/`).
- Cancel every Timer in `dispose()`.
- Definition of done: design match, `flutter analyze` clean, `flutter test` green, checked by hand on a
  device or emulator, wiki and log updated.
- Keep the wiki current and append to `log.md` every session ([[Wiki-Brain Setup]]).

Links: [[Memory Game]]
