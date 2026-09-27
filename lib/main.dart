import 'package:flutter/material.dart';

import 'db.dart';
import 'theme.dart';
import 'widgets.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await openDb();
  runApp(MemoryApp(initialSettings: await loadSettings()));
}

class MemoryApp extends StatefulWidget {
  final Settings initialSettings;
  const MemoryApp({super.key, required this.initialSettings});

  @override
  State<MemoryApp> createState() => _MemoryAppState();
}

class _MemoryAppState extends State<MemoryApp> {
  late Settings settings = widget.initialSettings;

  void _onSettingsChanged(Settings s) => setState(() => settings = s);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Memory',
      debugShowCheckedModeBanner: false,
      theme: appTheme,
      // Step 1 replaces this with the Home screen.
      home: _FoundationPreview(
        settings: settings,
        onSettingsChanged: _onSettingsChanged,
      ),
    );
  }
}

/// Temporary start route for step 0: lets the shared widgets and the board be
/// checked by hand on a device. Removed when Home lands.
class _FoundationPreview extends StatefulWidget {
  final Settings settings;
  final ValueChanged<Settings> onSettingsChanged;
  const _FoundationPreview({
    required this.settings,
    required this.onSettingsChanged,
  });

  @override
  State<_FoundationPreview> createState() => _FoundationPreviewState();
}

class _FoundationPreviewState extends State<_FoundationPreview> {
  int? pressed;

  @override
  Widget build(BuildContext context) {
    final s = widget.settings;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            spacing: 14,
            children: [
              const TopBar(title: 'Foundation'),
              SizedBox(
                width: 220,
                child: SimonCircle(
                  tileCount: s.tileCount,
                  theme: s.colorTheme,
                  pressedTile: pressed,
                  // Tapped tile stays lit (and its index is shown) so the
                  // hit test and glow can be checked by eye.
                  onTileTap: (i) =>
                      setState(() => pressed = pressed == i ? null : i),
                  center: Text(
                    '${pressed ?? '●'}',
                    style: const TextStyle(
                      color: textDim,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              OptionRow(
                label: 'Tiles',
                children: [
                  for (final n in const [4, 6, 8])
                    ChoiceChipX(
                      label: '$n',
                      selected: s.tileCount == n,
                      accent: s.accent,
                      onTap: () {
                        saveSetting('tileCount', '$n');
                        widget.onSettingsChanged(s.copyWith(tileCount: n));
                      },
                    ),
                ],
              ),
              OptionRow(
                label: 'Color theme',
                children: [
                  for (final t in ColorTheme.values)
                    ChoiceChipX(
                      label: t.label,
                      selected: s.colorTheme == t,
                      accent: s.accent,
                      onTap: () {
                        saveSetting('colorTheme', t.name);
                        widget.onSettingsChanged(s.copyWith(colorTheme: t));
                      },
                    ),
                ],
              ),
              Btn(
                label: 'Accent button',
                icon: Icons.play_arrow,
                accent: s.accent,
                onTap: () {},
              ),
              Btn(label: 'Plain button', onTap: () {}),
              const Btn(label: 'Disabled', small: true),
            ],
          ),
        ),
      ),
    );
  }
}
