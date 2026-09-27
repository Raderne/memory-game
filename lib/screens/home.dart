import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../db.dart';
import '../theme.dart';
import '../widgets.dart';

class HomeScreen extends StatefulWidget {
  final Settings settings;
  final ValueChanged<Settings> onSettingsChanged;
  final Future<void> Function() onStartGame;
  final Future<void> Function() onOpenSettings;
  final Future<void> Function() onOpenScores;
  final Future<int> Function() loadBest;

  const HomeScreen({
    super.key,
    required this.settings,
    required this.onSettingsChanged,
    required this.onStartGame,
    required this.onOpenSettings,
    required this.onOpenScores,
    this.loadBest = bestScore,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Timer? _idleTimer;
  Timer? _offTimer;
  int _tile = 0;
  int? _activeTile;
  int _best = 0;
  bool? _reduceMotion;

  @override
  void initState() {
    super.initState();
    _loadBest();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    if (_reduceMotion == reduceMotion) return;
    _reduceMotion = reduceMotion;
    _idleTimer?.cancel();
    _offTimer?.cancel();
    _idleTimer = null;
    _activeTile = null;
    if (!reduceMotion) {
      _idleTimer = Timer.periodic(
        const Duration(milliseconds: 1200),
        (_) => _lightNextTile(),
      );
    }
  }

  @override
  void didUpdateWidget(HomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.settings.tileCount != widget.settings.tileCount) {
      _offTimer?.cancel();
      _tile = 0;
      _activeTile = null;
    }
  }

  Future<void> _loadBest() async {
    final value = await widget.loadBest();
    if (mounted) setState(() => _best = value);
  }

  void _lightNextTile() {
    if (!mounted) return;
    setState(() => _activeTile = _tile % widget.settings.tileCount);
    _offTimer?.cancel();
    _offTimer = Timer(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      setState(() => _activeTile = null);
      _tile = (_tile + 1) % widget.settings.tileCount;
    });
  }

  Future<void> _open(Future<void> Function() destination) async {
    await destination();
    if (mounted) await _loadBest();
  }

  @override
  void dispose() {
    _idleTimer?.cancel();
    _offTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = widget.settings;
    final circleSize = math.min(MediaQuery.sizeOf(context).width * 0.7, 220.0);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ExcludeSemantics(
                  child: SizedBox.square(
                    dimension: circleSize,
                    child: SimonCircle(
                      tileCount: settings.tileCount,
                      theme: settings.colorTheme,
                      activeTile: _activeTile,
                      disabled: true,
                      center: const Text(
                        '●',
                        style: TextStyle(
                          color: textDim,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                ShaderMask(
                  blendMode: BlendMode.srcIn,
                  shaderCallback: (bounds) => LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [settings.accent, text],
                  ).createShader(bounds),
                  child: const Text(
                    'MEMORY',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 6,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'How far can you go?',
                  style: TextStyle(color: textSec, fontSize: 14),
                ),
                const SizedBox(height: 6),
                if (_best > 0) ...[
                  Text(
                    'Best: $_best',
                    style: const TextStyle(color: textDim, fontSize: 13),
                  ),
                  const SizedBox(height: 24),
                ] else
                  const SizedBox(height: 37),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 260),
                  child: Semantics(
                    button: true,
                    label: 'Start Game',
                    child: Btn(
                      label: 'Start Game',
                      icon: Icons.play_arrow,
                      accent: settings.accent,
                      onTap: () => _open(widget.onStartGame),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  spacing: 12,
                  children: [
                    Expanded(
                      child: _SecondaryButton(
                        label: 'Settings',
                        icon: Icons.settings_outlined,
                        onTap: () => _open(widget.onOpenSettings),
                      ),
                    ),
                    Expanded(
                      child: _SecondaryButton(
                        label: 'Scores',
                        icon: Icons.emoji_events_outlined,
                        onTap: () => _open(widget.onOpenScores),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SecondaryButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _SecondaryButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(14);
    return Semantics(
      button: true,
      label: label,
      child: ExcludeSemantics(
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 48),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: card,
              borderRadius: radius,
              border: Border.all(color: cardBorder),
            ),
            child: Material(
              type: MaterialType.transparency,
              child: InkWell(
                borderRadius: radius,
                onTap: onTap,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 20,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    spacing: 8,
                    children: [
                      Icon(icon, size: 18, color: textSec),
                      Flexible(
                        child: Text(
                          label,
                          maxLines: 1,
                          overflow: TextOverflow.fade,
                          style: const TextStyle(
                            color: textSec,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
