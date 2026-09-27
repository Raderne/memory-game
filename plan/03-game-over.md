# 03 — Game Over (`screens/game_over.dart`)

Arguments: `score`, `round`, `prevBest`.
- `best = max(prevBest, score)`
- `isNew = score > 0 && score > prevBest`

The design compares against best *after* saving, using `>=`. Passing `prevBest` in gets the same result, and a tie with the old record does not count as new.

Entry animation: fade from 0 to 1 and slide from 20 px to 0 over 500 ms ease, starting 100 ms after build (`TweenAnimationBuilder` or `AnimatedSlide` + `AnimatedOpacity`).

Centered column, 32 px padding:
1. Trophy badge: 72×72 circle filled `accent@9%` (`18` hex) with a 2px `accent@25%` border. Trophy icon 32 in the accent color. 20 px below it.
2. "GAME OVER": 14/600, textSec, letterSpacing 1.5.
3. Score: 56/800, text color, height 1.0, 4 px above.
4. If `isNew`: a pill with 8 px above, padding 4×14, radius 20, bg `success@12%`, 1px `success@25%` border, text "★ NEW HIGH SCORE" at 12/700 in the success color, letterSpacing 1.
5. Stats row: 20 px above and 32 px below, gap 20. "{round}" / "Round" and "{best}" / "Best". Values are 24/700 text color, labels 12 textDim. A 1px cardBorder vertical divider sits between them.
6. Buttons, max width 260, gap 10:
   - accent Btn with replay icon, "Play Again" → `pushReplacement` Game
   - plain Btn with home icon, "Home" → pop to Home

Android back button behaves like Home.

## Done when
- The first game ever with score > 0 shows the badge. Scoring lower than best on a later game hides it.
- Play Again starts a fresh round-1 game with the current settings.
