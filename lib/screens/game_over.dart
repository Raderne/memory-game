import 'dart:async';

import 'package:flutter/material.dart';

import '../theme.dart';
import '../widgets.dart';

class GameOverScreen extends StatelessWidget {
  final int score;
  final int round;
  final int prevBest;
  final Settings settings;
  final void Function(BuildContext context) onPlayAgain;
  final void Function(BuildContext context) onHome;

  const GameOverScreen({
    super.key,
    required this.score,
    required this.round,
    required this.prevBest,
    required this.settings,
    required this.onPlayAgain,
    required this.onHome,
  });

  @override
  Widget build(BuildContext context) {
    final best = score > prevBest ? score : prevBest;
    final isNew = score > 0 && score > prevBest;
    final accent = settings.accent;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) onHome(context);
      },
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Center(
              child: _ResultReveal(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ExcludeSemantics(
                      child: Container(
                        width: 72,
                        height: 72,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: accent.withValues(alpha: 0x18 / 255),
                          border: Border.all(
                            color: accent.withValues(alpha: 0.25),
                            width: 2,
                          ),
                        ),
                        child: Icon(
                          Icons.emoji_events_outlined,
                          size: 32,
                          color: accent,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'GAME OVER',
                      style: TextStyle(
                        color: textSec,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$score',
                      style: const TextStyle(
                        color: text,
                        fontSize: 56,
                        fontWeight: FontWeight.w800,
                        height: 1,
                      ),
                    ),
                    if (isNew) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 4,
                          horizontal: 14,
                        ),
                        decoration: BoxDecoration(
                          color: success.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: success.withValues(alpha: 0.25),
                          ),
                        ),
                        child: const Text(
                          '★ NEW HIGH SCORE',
                          style: TextStyle(
                            color: success,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      spacing: 20,
                      children: [
                        _Stat(value: '$round', label: 'Round'),
                        Container(width: 1, height: 32, color: cardBorder),
                        _Stat(value: '$best', label: 'Best'),
                      ],
                    ),
                    const SizedBox(height: 32),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 260),
                      child: Column(
                        spacing: 10,
                        children: [
                          Btn(
                            label: 'Play Again',
                            icon: Icons.replay,
                            accent: accent,
                            onTap: () => onPlayAgain(context),
                          ),
                          Btn(
                            label: 'Home',
                            icon: Icons.home_outlined,
                            onTap: () => onHome(context),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String value;
  final String label;

  const _Stat({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: text,
            fontSize: 24,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(label, style: const TextStyle(color: textDim, fontSize: 12)),
      ],
    );
  }
}

class _ResultReveal extends StatefulWidget {
  final Widget child;

  const _ResultReveal({required this.child});

  @override
  State<_ResultReveal> createState() => _ResultRevealState();
}

class _ResultRevealState extends State<_ResultReveal> {
  Timer? _timer;
  var _play = false;
  var _reduceMotion = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    if (reduceMotion) {
      _timer?.cancel();
      _reduceMotion = true;
      _play = true;
      return;
    }
    if (_timer != null || _play) return;
    _timer = Timer(const Duration(milliseconds: 100), () {
      if (mounted) setState(() => _play = true);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: _play ? 1 : 0),
      duration: _reduceMotion || !_play
          ? Duration.zero
          : const Duration(milliseconds: 500),
      curve: Curves.ease,
      builder: (context, value, child) {
        return Opacity(
          key: const Key('game-over-reveal'),
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: child,
          ),
        );
      },
      child: widget.child,
    );
  }
}
