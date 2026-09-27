import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memory_app/screens/settings.dart';
import 'package:memory_app/theme.dart';
import 'package:memory_app/widgets.dart';

void main() {
  test('secondary text and accent button labels clear 4.5:1', () {
    expect(contrastRatio(textSec, card), greaterThanOrEqualTo(4.5));
    for (final color in [...ColorTheme.values.map((theme) => theme.accent), danger]) {
      expect(
        contrastRatio(foregroundOn(color), color),
        greaterThanOrEqualTo(4.5),
      );
    }
  });

  Future<void> pumpSettings(
    WidgetTester tester, {
    List<List<String>>? saved,
    Future<void> Function()? clearScores,
    ValueChanged<Settings>? onChanged,
    bool largeText = false,
  }) async {
    tester.view.physicalSize = const Size(360, 720);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    await tester.pumpWidget(
      MaterialApp(
        theme: appTheme,
        home: MediaQuery(
          data: MediaQueryData(textScaler: TextScaler.linear(largeText ? 2 : 1)),
          child: SettingsScreen(
            settings: const Settings(),
            onSettingsChanged: onChanged ?? (_) {},
            persistSetting: (key, value) async => saved?.add([key, value]),
            clearScores: clearScores ?? () async {},
          ),
        ),
      ),
    );
    await tester.pump();
  }

  testWidgets('tile, speed, and theme changes apply immediately', (
    tester,
  ) async {
    final saved = <List<String>>[];
    Settings? changed;
    await pumpSettings(
      tester,
      saved: saved,
      onChanged: (value) => changed = value,
    );

    await tester.tap(find.text('8'));
    await tester.pump();
    expect(tester.widget<SimonCircle>(find.byType(SimonCircle)).tileCount, 8);
    expect(saved, [
      ['tileCount', '8'],
    ]);
    expect(changed?.tileCount, 8);

    await tester.tap(find.text('Fast'));
    await tester.pump();
    expect(saved.last, ['speed', 'fast']);
    expect(changed?.speed, Speed.fast);

    await tester.tap(find.text('Ocean'));
    await tester.pump();
    final circle = tester.widget<SimonCircle>(find.byType(SimonCircle));
    expect(circle.theme, ColorTheme.ocean);
    expect(circle.activeTile, 0);
    expect(circle.disabled, isTrue);
    expect(saved.last, ['colorTheme', 'ocean']);
    expect(changed?.colorTheme, ColorTheme.ocean);
  });

  testWidgets('reset asks before clearing scores', (tester) async {
    var cleared = 0;
    await pumpSettings(tester, clearScores: () async => cleared++);

    await tester.tap(find.text('Reset All Scores'));
    await tester.pump();
    expect(find.text('Confirm'), findsOneWidget);
    expect(cleared, 0);

    await tester.tap(find.text('Cancel'));
    await tester.pump();
    expect(find.text('Reset All Scores'), findsOneWidget);
    expect(cleared, 0);

    await tester.tap(find.text('Reset All Scores'));
    await tester.pump();
    await tester.tap(find.text('Confirm'));
    await tester.pump();
    expect(cleared, 1);
    expect(find.text('Reset All Scores'), findsOneWidget);
  });

  testWidgets('settings controls fit a narrow screen at large text', (
    tester,
  ) async {
    await pumpSettings(tester, largeText: true);

    expect(find.text('COLOR THEME'), findsOneWidget);
    expect(tester.takeException(), isNull);
    for (final label in ['4', 'Relaxed', 'Reset All Scores']) {
      expect(
        tester.getSize(find.widgetWithText(InkWell, label).first).height,
        greaterThanOrEqualTo(48),
      );
    }
  });
}
