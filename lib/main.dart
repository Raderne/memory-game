import 'package:flutter/material.dart';

import 'db.dart';
import 'screens/game.dart';
import 'screens/home.dart';
import 'theme.dart';

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
      navigatorObservers: [homeRouteObserver],
      home: Builder(
        builder: (context) => HomeScreen(
          settings: settings,
          onSettingsChanged: _onSettingsChanged,
          onStartGame: () async {
            await Navigator.of(context).push<void>(
              MaterialPageRoute(builder: (_) => GameScreen(settings: settings)),
            );
          },
          // Each callback is wired to its screen in that screen's build step.
          onOpenSettings: () async {},
          onOpenScores: () async {},
        ),
      ),
    );
  }
}
