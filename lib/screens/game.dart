import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../db.dart';
import '../game.dart';
import '../theme.dart';
import '../widgets.dart';
import 'game_over.dart';

typedef ScoreSaver =
    Future<void> Function({
      required int score,
      required int round,
      required int tiles,
      required Speed speed,
      required ColorTheme theme,
    });

class GameScreen extends StatefulWidget {
  final Settings settings;
  final Future<int> Function() loadBest;
  final ScoreSaver saveScore;

  const GameScreen({
    super.key,
    required this.settings,
    this.loadBest = bestScore,
    this.saveScore = insertScore,
  });

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late final SimonGame game;
  Timer? _gameOverTimer;
  bool _saved = false;

  @override
  void initState() {
    super.initState();
    game = SimonGame(
      tileCount: widget.settings.tileCount,
      stepMs: widget.settings.speed.stepMs,
    )..addListener(_onGameChanged);
    game.start();
  }

  void _onGameChanged() {
    if (game.phase != GamePhase.gameover || _saved) return;
    _saved = true;
    final saved = _saveResult();
    _gameOverTimer = Timer(
      const Duration(milliseconds: 1200),
      () => unawaited(_deliverResult(saved)),
    );
  }

  Future<int> _saveResult() async {
    final previousBest = await widget.loadBest();
    await widget.saveScore(
      score: game.score,
      round: game.round,
      tiles: widget.settings.tileCount,
      speed: widget.settings.speed,
      theme: widget.settings.colorTheme,
    );
    return previousBest;
  }

  Future<void> _deliverResult(Future<int> saved) async {
    final previousBest = await saved;
    if (!mounted) return;
    final settings = widget.settings;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => GameOverScreen(
          score: game.score,
          round: game.round,
          prevBest: previousBest,
          settings: settings,
          onPlayAgain: (routeContext) {
            Navigator.of(routeContext).pushReplacement(
              MaterialPageRoute<void>(
                builder: (_) => GameScreen(settings: settings),
              ),
            );
          },
          onHome: (routeContext) => Navigator.of(routeContext).pop(),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _gameOverTimer?.cancel();
    game
      ..removeListener(_onGameChanged)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accent = widget.settings.accent;
    return Scaffold(
      body: SafeArea(
        child: AnimatedBuilder(
          animation: game,
          builder: (context, _) => Column(
            children: [
              SizedBox(
                height: 48,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    children: [
                      IconButton(
                        tooltip: 'Back',
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(
                          Icons.arrow_back,
                          size: 20,
                          color: textSec,
                        ),
                      ),
                      Text(
                        'Round ${game.round}',
                        style: const TextStyle(
                          color: textSec,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 6,
                          horizontal: 14,
                        ),
                        decoration: BoxDecoration(
                          color: card,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: cardBorder),
                        ),
                        child: Text(
                          '${game.score}',
                          style: TextStyle(
                            color: accent,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(28),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final circleSize = math.min(
                        math.min(
                          MediaQuery.sizeOf(context).width * 0.85,
                          280.0,
                        ),
                        constraints.maxWidth,
                      );
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          spacing: 20,
                          children: [
                            SizedBox.square(
                              dimension: circleSize,
                              child: SimonCircle(
                                tileCount: widget.settings.tileCount,
                                theme: widget.settings.colorTheme,
                                activeTile: game.activeTile,
                                pressedTile: game.pressedTile,
                                onTileTap: game.tap,
                                disabled: game.phase != GamePhase.input,
                                center: Text(
                                  game.phase == GamePhase.gameover
                                      ? '✕'
                                      : '${game.round}',
                                  style: TextStyle(
                                    color: game.phase == GamePhase.gameover
                                        ? danger
                                        : accent,
                                    fontSize: 28,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ),
                            AnimatedDefaultTextStyle(
                              duration: MediaQuery.disableAnimationsOf(context)
                                  ? Duration.zero
                                  : const Duration(milliseconds: 300),
                              style: TextStyle(
                                color: _messageColor(accent),
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                              child: Text(game.msg),
                            ),
                            if (game.phase == GamePhase.input)
                              Padding(
                                padding: const EdgeInsets.only(top: 10),
                                child: Wrap(
                                  alignment: WrapAlignment.center,
                                  spacing: 6,
                                  runSpacing: 6,
                                  children: [
                                    for (var i = 0; i < game.seq.length; i++)
                                      _ProgressDot(
                                        done: i < game.inputIdx,
                                        accent: accent,
                                      ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _messageColor(Color accent) => switch (game.phase) {
    GamePhase.gameover => danger,
    GamePhase.input => accent,
    _ => textSec,
  };
}

class _ProgressDot extends StatelessWidget {
  final bool done;
  final Color accent;

  const _ProgressDot({required this.done, required this.accent});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: done ? accent : cardBorder,
        boxShadow: done
            ? [BoxShadow(color: accent.withValues(alpha: 0.38), blurRadius: 6)]
            : null,
      ),
    );
  }
}
