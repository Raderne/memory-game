# Wiki-Brain Setup

A persistent, Claude-maintained knowledge vault. It lets future sessions and teammates get up to speed
without re-reading the whole tree.

- `wiki-brain-vault/wiki/`: the pages. Claude owns them. Entry point is `index.md`.
- `wiki-brain-vault/log.md`: an append-only session journal. Use `grep "^## \[" log.md | tail -5`.
- `wiki-brain-vault/raw/`: immutable source docs, never modified.
- `.gitignore` excludes `wiki-brain-vault/graphify-out/`.
- The enforcement contract is the "Wiki-Brain" section of the repo-root `CLAUDE.md` ([[CLAUDE.md Rules]]).

## Maintaining it
- Create or update pages when a task produces durable knowledge (a decision, a fixed bug, a state change).
- Cross-link with `[[Page Name]]`. Add new or renamed pages to `index.md`.
- Bug and gotcha pages use `## Symptom / ## Root cause / ## Fix / ## State (YYYY-MM-DD)` + `Links:`.
- Flag contradictions to the user instead of silently overwriting them.
- The vault must be committed to git for teammates to benefit.

Set up from `C:\Dev\wiki-brain-setup-guide.md` on 2026-09-27. No `/wiki-brain` slash command or graphify is installed.
Links: [[Memory Game]]
