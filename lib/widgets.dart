import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'theme.dart';

/// Full-width button. With [accent]: accent fill + white text + glow shadow.
/// Without: card fill + 1px border. Disabled (null [onTap]) renders at 40%.
class Btn extends StatelessWidget {
  final String label;
  final IconData? icon;
  final Color? accent;
  final bool small;
  final VoidCallback? onTap;

  const Btn({
    super.key,
    required this.label,
    this.icon,
    this.accent,
    this.small = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(small ? 12 : 16);
    final fg = accent == null ? text : Colors.white;
    return Opacity(
      opacity: onTap == null ? 0.4 : 1,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: accent ?? card,
          borderRadius: radius,
          border: accent == null ? Border.all(color: cardBorder) : null,
          boxShadow: accent == null
              ? null
              : [
                  BoxShadow(
                    color: accent!.withValues(alpha: 0.25),
                    blurRadius: 24,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            borderRadius: radius,
            onTap: onTap,
            child: Padding(
              padding: small
                  ? const EdgeInsets.symmetric(vertical: 10, horizontal: 20)
                  : const EdgeInsets.symmetric(vertical: 15, horizontal: 28),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: 8,
                children: [
                  if (icon != null) Icon(icon, size: 18, color: fg),
                  Text(
                    label,
                    style: TextStyle(
                      color: fg,
                      fontSize: small ? 14 : 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 48px header with a back button and a title.
class TopBar extends StatelessWidget {
  final String title;
  const TopBar({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back, size: 20, color: textSec),
            padding: const EdgeInsets.all(10),
            constraints: const BoxConstraints(),
          ),
          Text(
            title,
            style: const TextStyle(
              color: text,
              fontSize: 17,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}

/// Card with an uppercase label and a row of options (gap 8).
class OptionRow extends StatelessWidget {
  final String label;
  final List<Widget> children;
  const OptionRow({super.key, required this.label, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 10,
        children: [
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              color: textSec,
              fontSize: 13,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.5,
            ),
          ),
          Row(spacing: 8, children: children),
        ],
      ),
    );
  }
}

/// Selectable option chip. Expands to share the row with its siblings.
/// (Named `ChoiceChipX` because Material already exports `Chip`.)
class ChoiceChipX extends StatelessWidget {
  final String label;
  final bool selected;
  final Color accent;
  final VoidCallback onTap;

  const ChoiceChipX({
    super.key,
    required this.label,
    required this.selected,
    required this.accent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(10);
    return Expanded(
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: selected ? accent.withValues(alpha: 0x22 / 255) : bg,
          borderRadius: radius,
          border: Border.all(
            color: selected ? accent : cardBorder,
            width: 1.5,
          ),
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            borderRadius: radius,
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: selected ? accent : textSec,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The circular Simon board: `tileCount` annular sectors around a center disc.
/// Fills the square of its parent's shortest side.
class SimonCircle extends StatefulWidget {
  final int tileCount;
  final ColorTheme theme;
  final int? activeTile;
  final int? pressedTile;
  final ValueChanged<int>? onTileTap;
  final bool disabled;
  final Widget? center;

  const SimonCircle({
    super.key,
    required this.tileCount,
    required this.theme,
    this.activeTile,
    this.pressedTile,
    this.onTileTap,
    this.disabled = false,
    this.center,
  });

  static double gapDeg(int n) => n <= 4 ? 4 : (n <= 6 ? 3 : 2.5);

  @override
  State<SimonCircle> createState() => _SimonCircleState();
}

class _SimonCircleState extends State<SimonCircle>
    with TickerProviderStateMixin {
  // One 0→1 "lit" animation per tile (150 ms).
  final List<AnimationController> _lit = [];

  @override
  void initState() {
    super.initState();
    _syncControllers();
  }

  @override
  void didUpdateWidget(SimonCircle old) {
    super.didUpdateWidget(old);
    _syncControllers();
  }

  void _syncControllers() {
    while (_lit.length < widget.tileCount) {
      _lit.add(
        AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 150),
        ),
      );
    }
    for (var i = 0; i < _lit.length; i++) {
      final on = i == widget.activeTile || i == widget.pressedTile;
      _lit[i].animateTo(on ? 1 : 0);
    }
  }

  @override
  void dispose() {
    for (final c in _lit) {
      c.dispose();
    }
    super.dispose();
  }

  void _onTapDown(TapDownDetails d, double size) {
    final c = size / 2;
    final dx = d.localPosition.dx - c;
    final dy = d.localPosition.dy - c;
    final dist = math.sqrt(dx * dx + dy * dy);
    if (dist < 0.2 * size || dist > c - 8) return;
    // atan2 rotated so 0 is up, increasing clockwise.
    var deg = math.atan2(dx, -dy) * 180 / math.pi;
    if (deg < 0) deg += 360;
    widget.onTileTap?.call((deg / (360 / widget.tileCount)).floor());
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.biggest.shortestSide;
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: widget.disabled ? null : (d) => _onTapDown(d, size),
          child: SizedBox.square(
            dimension: size,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CustomPaint(
                  size: Size.square(size),
                  painter: _CirclePainter(
                    tileCount: widget.tileCount,
                    tiles: widget.theme.tiles,
                    lit: _lit.take(widget.tileCount).toList(),
                  ),
                ),
                if (widget.center != null) widget.center!,
              ],
            ),
          ),
        );
      },
    );
  }
}

class _CirclePainter extends CustomPainter {
  final int tileCount;
  final List<TileColor> tiles;
  final List<AnimationController> lit;

  _CirclePainter({
    required this.tileCount,
    required this.tiles,
    required this.lit,
  }) : super(repaint: Listenable.merge(lit));

  Path _sector(int i, Offset c, double outer, double inner) {
    final arc = 360 / tileCount;
    final gap = SimonCircle.gapDeg(tileCount);
    // 0° at 12 o'clock, clockwise → canvas angle is (deg − 90).
    final start = (i * arc + gap / 2 - 90) * math.pi / 180;
    final sweep = (arc - gap) * math.pi / 180;
    return Path()
      ..arcTo(Rect.fromCircle(center: c, radius: outer), start, sweep, true)
      ..arcTo(
        Rect.fromCircle(center: c, radius: inner),
        start + sweep,
        -sweep,
        false,
      )
      ..close();
  }

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.shortestSide;
    final c = Offset(size.width / 2, size.height / 2);
    final outer = s / 2 - 8;
    final inner = 0.2 * s;

    for (var i = 0; i < tileCount; i++) {
      final t = lit[i].value;
      final color = tiles[i];
      final path = _sector(i, c, outer, inner);
      if (t > 0) {
        for (final blur in const [18.0, 6.0]) {
          canvas.drawPath(
            path,
            Paint()
              ..color = color.lit.withValues(alpha: t)
              ..maskFilter = MaskFilter.blur(BlurStyle.normal, blur),
          );
        }
      }
      canvas.drawPath(
        path,
        Paint()..color = Color.lerp(color.dim, color.lit, t)!,
      );
    }

    canvas.drawCircle(c, inner - 2, Paint()..color = circleCenterFill);
    canvas.drawCircle(
      c,
      inner - 2,
      Paint()
        ..color = circleCenterStroke
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
  }

  @override
  bool shouldRepaint(_CirclePainter old) =>
      old.tileCount != tileCount || old.tiles != tiles || old.lit != lit;
}
