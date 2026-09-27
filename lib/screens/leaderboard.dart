import 'package:flutter/material.dart';

import '../db.dart';
import '../theme.dart';
import '../widgets.dart';

/// Relative time for a finished game. Boundaries are exact seconds.
String timeAgo(DateTime then, DateTime now) {
  final seconds = now.difference(then).inSeconds;
  if (seconds < 60) return 'just now';
  if (seconds < 3600) return '${seconds ~/ 60}m ago';
  if (seconds < 86400) return '${seconds ~/ 3600}h ago';
  return '${seconds ~/ 86400}d ago';
}

Future<List<Score>> _loadTopScores() => topScores(10);

class LeaderboardScreen extends StatefulWidget {
  final Color accent;
  final Future<List<Score>> Function() loadScores;

  const LeaderboardScreen({
    super.key,
    required this.accent,
    this.loadScores = _loadTopScores,
  });

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  late final Future<List<Score>> _scores = widget.loadScores();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          children: [
            const TopBar(title: 'Leaderboard'),
            Expanded(
              child: FutureBuilder<List<Score>>(
                future: _scores,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const SizedBox.shrink();
                  final scores = snapshot.data!;
                  if (scores.isEmpty) return const _EmptyScores();
                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                    itemCount: scores.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final score = scores[index];
                      return _ScoreRow(
                        rank: index + 1,
                        score: score,
                        accent: widget.accent,
                        ago: timeAgo(score.createdAt, DateTime.now()),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyScores extends StatelessWidget {
  const _EmptyScores();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 4, 16, 16),
      child: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 60, horizontal: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 64,
                height: 64,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: card,
                    shape: BoxShape.circle,
                    border: Border.all(color: cardBorder),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.emoji_events_outlined,
                      size: 28,
                      color: textDim,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16),
              Text(
                'No scores yet',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: textSec,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 6),
              Text(
                'Play a game to set your first record!',
                textAlign: TextAlign.center,
                style: TextStyle(color: textDim, fontSize: 13),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ScoreRow extends StatelessWidget {
  final int rank;
  final Score score;
  final Color accent;
  final String ago;

  const _ScoreRow({
    required this.rank,
    required this.score,
    required this.accent,
    required this.ago,
  });

  @override
  Widget build(BuildContext context) {
    final first = rank == 1;
    final medal = switch (rank) {
      1 => '🥇',
      2 => '🥈',
      3 => '🥉',
      _ => null,
    };
    return Semantics(
      label: 'Rank $rank, score ${score.score}, round ${score.round}, $ago',
      child: ExcludeSemantics(
        child: DecoratedBox(
          key: Key('score-${rank - 1}'),
          decoration: BoxDecoration(
            color: first ? accent.withValues(alpha: 0x10 / 255) : card,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: first ? accent.withValues(alpha: 0x30 / 255) : cardBorder,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
            child: Row(
              children: [
                SizedBox(
                  width: 32,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      medal ?? '$rank',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: textDim,
                        fontSize: medal == null ? 16 : 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${score.score}',
                        maxLines: 1,
                        overflow: TextOverflow.fade,
                        softWrap: false,
                        style: const TextStyle(
                          color: text,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Round ${score.round}',
                        maxLines: 1,
                        overflow: TextOverflow.fade,
                        softWrap: false,
                        style: const TextStyle(color: textDim, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    ago,
                    maxLines: 1,
                    overflow: TextOverflow.fade,
                    softWrap: false,
                    textAlign: TextAlign.right,
                    style: const TextStyle(color: textDim, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
