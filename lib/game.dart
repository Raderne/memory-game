import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';

enum GamePhase { idle, showing, input, success, gameover }

class SimonGame extends ChangeNotifier {
  final int tileCount;
  final int stepMs;
  final Random random;

  final List<int> seq = [];
  int inputIdx = 0;
  GamePhase phase = GamePhase.idle;
  int score = 0;
  int round = 0;
  int? activeTile;
  int? pressedTile;
  String msg = '';

  final List<Timer> _timers = [];
  bool _disposed = false;

  SimonGame({required this.tileCount, required this.stepMs, Random? random})
    : random = random ?? Random();

  void start() {
    _cancelTimers();
    seq
      ..clear()
      ..add(random.nextInt(tileCount));
    inputIdx = 0;
    phase = GamePhase.idle;
    score = 0;
    round = 1;
    activeTile = null;
    pressedTile = null;
    msg = '';
    notifyListeners();
    _schedule(const Duration(milliseconds: 600), _show);
  }

  void _show() {
    phase = GamePhase.showing;
    activeTile = null;
    pressedTile = null;
    msg = 'Watch carefully…';
    notifyListeners();

    final litFor = _stepFraction(0.55);
    for (var i = 0; i < seq.length; i++) {
      final tile = seq[i];
      final startsAt = Duration(milliseconds: i * stepMs);
      _schedule(startsAt, () {
        activeTile = tile;
        notifyListeners();
      });
      _schedule(startsAt + litFor, () {
        activeTile = null;
        notifyListeners();
      });
    }

    final inputAt =
        Duration(milliseconds: (seq.length - 1) * stepMs) +
        litFor +
        _stepFraction(0.35);
    _schedule(inputAt, () {
      phase = GamePhase.input;
      inputIdx = 0;
      msg = 'Your turn!';
      notifyListeners();
    });
  }

  void tap(int tile) {
    if (phase != GamePhase.input) return;

    pressedTile = tile;
    _schedule(const Duration(milliseconds: 180), () {
      pressedTile = null;
      notifyListeners();
    });

    if (tile != seq[inputIdx]) {
      phase = GamePhase.gameover;
      msg = 'Game Over';
      notifyListeners();
      return;
    }

    score += 10 * round;
    if (inputIdx < seq.length - 1) {
      inputIdx++;
      notifyListeners();
      return;
    }

    score += 25 * round;
    phase = GamePhase.success;
    msg = 'Correct!';
    seq.add(random.nextInt(tileCount));
    round++;
    notifyListeners();
    _schedule(const Duration(milliseconds: 1100), _show);
  }

  Duration _stepFraction(double fraction) => Duration(
    microseconds: (stepMs * fraction * Duration.microsecondsPerMillisecond)
        .round(),
  );

  void _schedule(Duration delay, VoidCallback callback) {
    _timers.add(
      Timer(delay, () {
        if (!_disposed) callback();
      }),
    );
  }

  void _cancelTimers() {
    for (final timer in _timers) {
      timer.cancel();
    }
    _timers.clear();
  }

  @override
  void dispose() {
    _disposed = true;
    _cancelTimers();
    super.dispose();
  }
}
