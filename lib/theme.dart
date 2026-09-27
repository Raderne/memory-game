import 'package:flutter/material.dart';

// Color tokens (design `T`).
const bg = Color(0xFF0A0A14);
const surface = Color(0xFF111120);
const card = Color(0xFF18182C);
const cardBorder = Color(0xFF252540);
const text = Color(0xFFE8E8F0);
const textSec = Color(0xFF80809A);
const textDim = Color(0xFF4A4A60);
const success = Color(0xFF30D158);
const danger = Color(0xFFFF453A);
const circleCenterFill = Color(0xFF0C0C14);
const circleCenterStroke = Color(0xFF1C1C28);

/// A tile's `(dim, lit)` pair, given as opaque RGB hex values.
class TileColor {
  final int _dim;
  final int _lit;
  const TileColor(this._dim, this._lit);

  Color get dim => Color(0xFF000000 | _dim);
  Color get lit => Color(0xFF000000 | _lit);
}

enum ColorTheme {
  classic('Classic', Color(0xFFFF2D55), [
    TileColor(0x3A1520, 0xFF2D55),
    TileColor(0x152040, 0x0A84FF),
    TileColor(0x103020, 0x30D158),
    TileColor(0x302A10, 0xFFD60A),
    TileColor(0x2A1540, 0xBF5AF2),
    TileColor(0x402210, 0xFF9F0A),
    TileColor(0x103030, 0x64D2FF),
    TileColor(0x401530, 0xFF375F),
  ]),
  neon('Neon', Color(0xFF00FFEE), [
    TileColor(0x0F2828, 0x00FFEE),
    TileColor(0x280F28, 0xFF00FF),
    TileColor(0x0F280F, 0x39FF14),
    TileColor(0x281A0F, 0xFF6B00),
    TileColor(0x280F1A, 0xFF1493),
    TileColor(0x1A0F28, 0x7B68EE),
    TileColor(0x28280F, 0xFFE700),
    TileColor(0x0F1A28, 0x1E90FF),
  ]),
  ocean('Ocean', Color(0xFF0EA5E9), [
    TileColor(0x0A1520, 0x0EA5E9),
    TileColor(0x0F1A28, 0x06B6D4),
    TileColor(0x0A2018, 0x14B8A6),
    TileColor(0x101838, 0x6366F1),
    TileColor(0x0A1830, 0x3B82F6),
    TileColor(0x0F2420, 0x2DD4BF),
    TileColor(0x101428, 0x818CF8),
    TileColor(0x0A1A28, 0x22D3EE),
  ]),
  sunset('Sunset', Color(0xFFF97316), [
    TileColor(0x281010, 0xEF4444),
    TileColor(0x281A0F, 0xF97316),
    TileColor(0x282010, 0xEAB308),
    TileColor(0x280F18, 0xEC4899),
    TileColor(0x200F0F, 0xDC2626),
    TileColor(0x301A10, 0xFB923C),
    TileColor(0x30240F, 0xFACC15),
    TileColor(0x300F1A, 0xF472B6),
  ]);

  final String label;
  final Color accent;
  final List<TileColor> tiles;
  const ColorTheme(this.label, this.accent, this.tiles);
}

enum Speed {
  slow(900, 'Relaxed'),
  normal(550, 'Normal'),
  fast(350, 'Fast');

  /// Milliseconds per sequence step.
  final int stepMs;
  final String label;
  const Speed(this.stepMs, this.label);
}

/// Player settings, held in the root widget's state and persisted in SQLite.
class Settings {
  final int tileCount;
  final Speed speed;
  final ColorTheme colorTheme;

  const Settings({
    this.tileCount = 4,
    this.speed = Speed.normal,
    this.colorTheme = ColorTheme.classic,
  });

  Color get accent => colorTheme.accent;

  Settings copyWith({int? tileCount, Speed? speed, ColorTheme? colorTheme}) =>
      Settings(
        tileCount: tileCount ?? this.tileCount,
        speed: speed ?? this.speed,
        colorTheme: colorTheme ?? this.colorTheme,
      );
}

/// WCAG contrast ratio between two opaque colors.
double contrastRatio(Color a, Color b) {
  final first = a.computeLuminance();
  final second = b.computeLuminance();
  final lighter = first > second ? first : second;
  final darker = first > second ? second : first;
  return (lighter + 0.05) / (darker + 0.05);
}

/// The app text color that stays readable on [background].
Color foregroundOn(Color background) =>
    contrastRatio(background, bg) >= contrastRatio(background, text)
    ? bg
    : text;

final appTheme = ThemeData(
  brightness: Brightness.dark,
  scaffoldBackgroundColor: bg,
  colorScheme: const ColorScheme.dark(surface: bg, onSurface: text),
  splashFactory: InkRipple.splashFactory,
);
