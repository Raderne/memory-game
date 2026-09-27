import 'dart:math' as math;
import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';

import '../theme.dart';
import '../widgets.dart';

const _totalMs = 5000.0;

// CSS cubic-bezier curves from the design's `launch.jsx`.
const _outQuint = Cubic(.2, .8, .2, 1);
const _popIn = Cubic(.3, 1.4, .5, 1);
const _popDot = Cubic(.3, 1.6, .5, 1);
const _bar = Cubic(.6, 0, .2, 1);

/// Progress of a [durMs] segment starting at [startMs], clamped to 0..1.
double _seg(double ms, double startMs, double durMs) =>
    ((ms - startMs) / durMs).clamp(0.0, 1.0);

/// Two-keyframe tween: [a]→[b] until [split], then [b]→[c], each eased by [curve].
double _keys(
  double p,
  double a,
  double b,
  double c,
  double split,
  Curve curve,
) => p < split
    ? a + (b - a) * curve.transform(p / split)
    : b + (c - b) * curve.transform((p - split) / (1 - split));

/// Animated launch screen. Plays once (5 s), then calls [onDone].
/// With reduced motion it calls [onDone] straight away.
class SplashScreen extends StatefulWidget {
  final VoidCallback onDone;
  const SplashScreen({super.key, required this.onDone});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 5000),
  );
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    if (MediaQuery.disableAnimationsOf(context)) {
      WidgetsBinding.instance.addPostFrameCallback((_) => widget.onDone());
    } else {
      // A cancelled ticker never completes this future, so no call after dispose.
      _c.forward().then((_) => widget.onDone());
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _c,
          builder: (context, _) {
            final ms = _c.value * _totalMs;
            final word = _outQuint.transform(_seg(ms, 1900, 800));
            final tag = Curves.easeOut.transform(_seg(ms, 2300, 600));
            final bar = _bar.transform(_seg(ms, 2600, 1600));
            return Opacity(
              opacity: 1 - _seg(ms, 4500, 500),
              child: Column(
                // Stretch so the Expanded content centers across the full width.
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox.square(
                            dimension: 200,
                            child: CustomPaint(painter: _SplashPainter(ms)),
                          ),
                          const SizedBox(height: 36),
                          Opacity(
                            opacity: word,
                            child: ImageFiltered(
                              imageFilter: ImageFilter.blur(
                                sigmaX: 6 * (1 - word),
                                sigmaY: 6 * (1 - word),
                              ),
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Padding(
                                  // Balances the trailing letter spacing.
                                  padding: const EdgeInsets.only(left: 8),
                                  child: Text(
                                    'MEMORY',
                                    style: TextStyle(
                                      fontSize: 30,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 18 - 10 * word,
                                      color: text,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Opacity(
                            opacity: tag,
                            child: Transform.translate(
                              offset: Offset(0, 8 * (1 - tag)),
                              child: const Text(
                                'How far can you go?',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 14, color: textSec),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 48),
                    child: Center(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(2),
                        child: Container(
                          width: 120,
                          height: 3,
                          color: card,
                          alignment: Alignment.centerLeft,
                          child: FractionallySizedBox(
                            widthFactor: bar,
                            heightFactor: 1,
                            child: const ColoredBox(color: text),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

/// The splash board, drawn on the design's 280×280 grid.
class _SplashPainter extends CustomPainter {
  final double ms;
  _SplashPainter(this.ms);

  static const _c = Offset(140, 140);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 280);
    final tiles = ColorTheme.classic.tiles;
    final paths = [
      for (var i = 0; i < 4; i++) sectorPath(_c, 132, 54, i * 90 + 2.5, 85),
    ];

    // The board spins in from −90°.
    canvas.save();
    canvas.translate(_c.dx, _c.dy);
    canvas.rotate(-(1 - _outQuint.transform(_seg(ms, 0, 1400))) * math.pi / 2);
    canvas.translate(-_c.dx, -_c.dy);

    // Each sector pops in lit, then fades to dim, 220 ms apart.
    for (var i = 0; i < 4; i++) {
      final delay = 150.0 + i * 220;
      final pop = _seg(ms, delay, 450);
      final fill = _seg(ms, delay, 900);
      final scale = _keys(pop, .6, 1.05, 1, .6, _popIn);
      final color = fill < .4
          ? tiles[i].lit
          : Color.lerp(
              tiles[i].lit,
              tiles[i].dim,
              Curves.easeOut.transform((fill - .4) / .6),
            )!;
      canvas.save();
      canvas.translate(_c.dx, _c.dy);
      canvas.scale(scale);
      canvas.translate(-_c.dx, -_c.dy);
      canvas.drawPath(
        paths[i],
        Paint()..color = color.withValues(alpha: (pop / .6).clamp(0.0, 1.0)),
      );
      canvas.restore();
    }

    // All four flash together once the dot lands.
    final flash = _keys(_seg(ms, 1550, 1000), 0, 1, 0, .3, Curves.easeOut);
    if (flash > 0) {
      for (var i = 0; i < 4; i++) {
        canvas.drawPath(
          paths[i],
          Paint()
            ..color = tiles[i].lit.withValues(alpha: .8 * flash)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
        );
      }
      for (var i = 0; i < 4; i++) {
        canvas.drawPath(
          paths[i],
          Paint()..color = tiles[i].lit.withValues(alpha: flash),
        );
      }
    }
    canvas.restore();

    canvas.drawCircle(_c, 50, Paint()..color = bg);

    // The ring shows faintly from the start (CSS fill-mode `both`), then ripples out.
    final ring = Curves.easeOut.transform(_seg(ms, 1550, 1100));
    final ringScale = 1 + 2.2 * ring;
    canvas.drawCircle(
      _c,
      12 * ringScale,
      Paint()
        ..color = text.withValues(alpha: .7 * (1 - ring))
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2 * ringScale,
    );

    final dot = _keys(_seg(ms, 1300, 500), 0, 1.3, 1, .7, _popDot);
    if (dot > 0) canvas.drawCircle(_c, 12 * dot, Paint()..color = text);
  }

  @override
  bool shouldRepaint(_SplashPainter old) => old.ms != ms;
}
