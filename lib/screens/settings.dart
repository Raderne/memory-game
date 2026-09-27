import 'package:flutter/material.dart';

import '../db.dart' as db;
import '../theme.dart';
import '../widgets.dart';

class SettingsScreen extends StatefulWidget {
  final Settings settings;
  final ValueChanged<Settings> onSettingsChanged;
  final Future<void> Function(String key, String value) persistSetting;
  final Future<void> Function() clearScores;

  const SettingsScreen({
    super.key,
    required this.settings,
    required this.onSettingsChanged,
    this.persistSetting = db.saveSetting,
    this.clearScores = db.clearScores,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late Settings _settings = widget.settings;
  bool _confirming = false;

  Future<void> _apply(Settings next, String key, String value) async {
    setState(() => _settings = next);
    widget.onSettingsChanged(next);
    await widget.persistSetting(key, value);
  }

  @override
  Widget build(BuildContext context) {
    final accent = _settings.accent;
    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          children: [
            const TopBar(title: 'Settings'),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 16,
                ),
                children: [
                  OptionRow(
                    label: 'Tiles',
                    children: [
                      for (final count in [4, 6, 8])
                        ChoiceChipX(
                          label: '$count',
                          selected: _settings.tileCount == count,
                          accent: accent,
                          onTap: () => _apply(
                            _settings.copyWith(tileCount: count),
                            'tileCount',
                            '$count',
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  OptionRow(
                    label: 'Speed',
                    children: [
                      for (final speed in Speed.values)
                        ChoiceChipX(
                          label: speed.label,
                          selected: _settings.speed == speed,
                          accent: accent,
                          onTap: () => _apply(
                            _settings.copyWith(speed: speed),
                            'speed',
                            speed.name,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  OptionRow(
                    label: 'Color theme',
                    children: [
                      Expanded(
                        child: _ThemePicker(
                          settings: _settings,
                          onPick: _apply,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Center(
                    child: SizedBox(
                      width: 130,
                      height: 130,
                      child: SimonCircle(
                        tileCount: _settings.tileCount,
                        theme: _settings.colorTheme,
                        activeTile: 0,
                        disabled: true,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: _confirming
                  ? Row(
                      spacing: 8,
                      children: [
                        Expanded(
                          child: Btn(
                            label: 'Cancel',
                            small: true,
                            onTap: () => setState(() => _confirming = false),
                          ),
                        ),
                        Expanded(
                          child: Btn(
                            label: 'Confirm',
                            small: true,
                            accent: danger,
                            onTap: () async {
                              await widget.clearScores();
                              if (mounted) setState(() => _confirming = false);
                            },
                          ),
                        ),
                      ],
                    )
                  : _ResetButton(
                      onTap: () => setState(() => _confirming = true),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ThemePicker extends StatelessWidget {
  final Settings settings;
  final Future<void> Function(Settings next, String key, String value) onPick;

  const _ThemePicker({required this.settings, required this.onPick});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 120 * 2 + 10 ? 2 : 1;
        final width = (constraints.maxWidth - (columns - 1) * 10) / columns;
        return Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            for (final theme in ColorTheme.values)
              SizedBox(
                width: width,
                child: _ThemeButton(
                  theme: theme,
                  selected: settings.colorTheme == theme,
                  onTap: () => onPick(
                    settings.copyWith(colorTheme: theme),
                    'colorTheme',
                    theme.name,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _ThemeButton extends StatelessWidget {
  final ColorTheme theme;
  final bool selected;
  final VoidCallback onTap;

  const _ThemeButton({
    required this.theme,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final accent = theme.accent;
    final radius = BorderRadius.circular(10);
    return Semantics(
      button: true,
      selected: selected,
      label: theme.label,
      child: ExcludeSemantics(
        child: ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 120, minHeight: 48),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: selected ? accent.withValues(alpha: 0x18 / 255) : bg,
              borderRadius: radius,
              border: Border.all(
                color: selected ? accent : cardBorder,
                width: selected ? 1.5 : 1,
              ),
            ),
            child: Material(
              type: MaterialType.transparency,
              child: InkWell(
                borderRadius: radius,
                onTap: onTap,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 12,
                  ),
                  child: Row(
                    children: [
                      for (var i = 0; i < 4; i++) ...[
                        if (i > 0) const SizedBox(width: 3),
                        Container(
                          width: 14,
                          height: 14,
                          decoration: BoxDecoration(
                            color: theme.tiles[i].lit,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                      const SizedBox(width: 8),
                      Flexible(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            theme.label,
                            style: TextStyle(
                              color: selected ? accent : textSec,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
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

class _ResetButton extends StatelessWidget {
  final VoidCallback onTap;
  const _ResetButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(12);
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: radius,
        border: Border.all(color: danger.withValues(alpha: 0.25)),
      ),
      child: Material(
        type: MaterialType.transparency,
        color: Colors.transparent,
        child: InkWell(
          borderRadius: radius,
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 48),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Center(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    spacing: 8,
                    children: [
                      const Icon(Icons.delete_outline, size: 16, color: danger),
                      const Text(
                        'Reset All Scores',
                        style: TextStyle(
                          color: danger,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
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
