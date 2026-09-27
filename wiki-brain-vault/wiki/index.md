# Memory — Wiki index

> Maintained by Claude. Entry point for the vault. Read this first, then follow links.

## Product
- [[Memory Game]] — what the app is, and the hub linking everything
- [[Build Plan]] — screen-by-screen build order and **current step status**

## Entities (components)
- [[Database]] — SQLite schema + `db.dart` API (scores and settings)
- [[Game Engine]] — `SimonGame` state machine, timing, scoring
- [[Simon Circle]] — the circular tile board widget (painter + hit test)
- [[Screens]] — the 5 screens and how they navigate
- [[Theme and Colors]] — color tokens, 4 color themes, speeds

## Concepts / decisions
- [[Tech Stack]] — Flutter + sqflite, and why there is no other state or storage library
- [[CLAUDE.md Rules]] — the repo's hard rules, summarized

## Sources
- [[Design Source]] — the claude.ai/design prototype and what was / wasn't ported
- [[Wiki-Brain Setup]] — how this vault is wired and maintained

## Known gotchas
- [[Game Engine]] § Gotchas — high-score check order, timer cleanup
