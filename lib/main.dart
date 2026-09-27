import 'package:flutter/material.dart';

import 'db.dart';
import 'screens/game.dart';
import 'screens/home.dart';
import 'screens/leaderboard.dart';
import 'screens/settings.dart';
import 'screens/splash.dart';
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
  bool _splashDone = false;

  void _onSettingsChanged(Settings s) => setState(() => settings = s);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Memory',
      debugShowCheckedModeBanner: false,
      theme: appTheme,
      navigatorObservers: [homeRouteObserver],
      // Swapping `home` keeps Home as the root route; the splash has already
      // faded out, so Home fades in over the blank background.
      home: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _splashDone ? _home() : SplashScreen(onDone: _onSplashDone),
      ),
    );
  }

  void _onSplashDone() => setState(() => _splashDone = true);

  Widget _home() {
    return Builder(
      builder: (context) => HomeScreen(
        settings: settings,
        onSettingsChanged: _onSettingsChanged,
        onStartGame: () async {
          await Navigator.of(context).push<void>(
            MaterialPageRoute(builder: (_) => GameScreen(settings: settings)),
          );
        },
        onOpenSettings: () async {
          await Navigator.of(context).push<void>(
            MaterialPageRoute(
              builder: (_) => SettingsScreen(
                settings: settings,
                onSettingsChanged: _onSettingsChanged,
              ),
            ),
          );
        },
        onOpenScores: () async {
          await Navigator.of(context).push<void>(
            MaterialPageRoute(
              builder: (_) => LeaderboardScreen(accent: settings.accent),
            ),
          );
        },
      ),
    );
  }
}
