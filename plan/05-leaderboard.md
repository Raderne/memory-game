# 05 — Leaderboard (`screens/leaderboard.dart`)

TopBar "Leaderboard" with back. Body padding 4 16 16 16. Data comes from `topScores(10)` via a `FutureBuilder`.

**Empty state** (centered, 60×20 padding):
- A 64×64 circle, card bg, 1px border, trophy icon 28 in textDim. 16 px below it.
- "No scores yet" at 16/600 textSec, then "Play a game to set your first record!" at 13 textDim with 6 px above.

**List**: `ListView.separated` with gap 8. Each row:
- padding 12×14, radius 12. Row 0 has bg `accent@6%` (`10` hex) and a `accent@19%` (`30` hex) border. Other rows use card bg and cardBorder.
- Rank cell, 32 wide and centered: 🥇 🥈 🥉 at size 22 for ranks 1–3, otherwise the number at 16/700 textDim.
- The middle expands and shows the score (18/700, text color), with "Round {round}" below it (12 textDim, 2 px above).
- On the right, the time ago (12 textDim): `<60s` "just now", `<1h` "{m}m ago", `<1d` "{h}h ago", otherwise "{d}d ago".

`timeAgo(DateTime then, DateTime now)` is a pure function. Keep it in this file.

## Checks
- A unit test for `timeAgo` at the boundaries 59 s, 60 s, 3599 s, 3600 s and 86400 s.
- By hand: play 3 games, and they appear sorted by score with medals on the top 3.
