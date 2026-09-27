import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memory_app/screens/about.dart';
import 'package:memory_app/theme.dart';
import 'package:memory_app/update.dart';
import 'package:memory_app/widgets.dart';

void main() {
  const releaseJson = '''
    {
      "tag_name": "v1.0.3",
      "assets": [
        {
          "name": "memory-1.0.3.apk",
          "browser_download_url": "https://example.com/memory-1.0.3.apk"
        }
      ]
    }
  ''';

  Future<void> pumpAbout(
    WidgetTester tester, {
    required Future<String> Function() fetchLatest,
    Future<String> Function(String url, void Function(double?) onProgress)?
    download,
    Future<String> Function(String path)? install,
    double textScale = 1,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: appTheme,
        home: MediaQuery(
          data: MediaQueryData(textScaler: TextScaler.linear(textScale)),
          child: AboutScreen(
            accent: const Color(0xFF00FFEE),
            loadVersion: () async => '1.0.2',
            fetchLatest: fetchLatest,
            download:
                download ??
                (url, onProgress) async {
                  onProgress(1);
                  return '/tmp/memory-update.apk';
                },
            install: install ?? (_) async => 'install',
          ),
        ),
      ),
    );
    await tester.pump();
  }

  testWidgets('an older install offers the GitHub release', (tester) async {
    tester.view.physicalSize = const Size(360, 720);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    String? downloaded;
    String? installed;
    await pumpAbout(
      tester,
      fetchLatest: () async => releaseJson,
      download: (url, onProgress) async {
        downloaded = url;
        onProgress(0.5);
        onProgress(1);
        return '/cache/memory-update.apk';
      },
      install: (path) async {
        installed = path;
        return 'install';
      },
    );

    expect(find.text('Version 1.0.2'), findsOneWidget);
    expect(find.text('Updates install from GitHub releases.'), findsOneWidget);
    final before = tester.getTopLeft(find.byType(Btn));

    await tester.tap(find.text('Check for updates'));
    await tester.pump();
    await tester.pump();

    expect(find.text('Version 1.0.3 is available.'), findsOneWidget);
    expect(tester.getTopLeft(find.byType(Btn)), before);
    expect(
      tester.getSize(find.byKey(const Key('update-status'))).height,
      closeTo(14 * 1.4 * 2, 0.01),
    );
    expect(tester.getSize(find.byType(Btn)).height, greaterThanOrEqualTo(48));

    await tester.tap(find.text('Download and install'));
    await tester.pump();
    await tester.pump();

    expect(downloaded, 'https://example.com/memory-1.0.3.apk');
    expect(installed, '/cache/memory-update.apk');
    expect(find.text('Follow the install prompt to finish.'), findsOneWidget);
    expect(find.text('Install'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('the current release does not download', (tester) async {
    var downloaded = false;
    await pumpAbout(
      tester,
      fetchLatest: () async => releaseJson.replaceAll('v1.0.3', 'v1.0.2'),
      download: (url, onProgress) async {
        downloaded = true;
        return '/cache/memory-update.apk';
      },
    );

    await tester.tap(find.text('Check for updates'));
    await tester.pump();
    await tester.pump();

    expect(find.text("You're up to date."), findsOneWidget);
    expect(find.text('Download and install'), findsNothing);
    expect(downloaded, isFalse);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('a failed check stays next to the button', (tester) async {
    await pumpAbout(
      tester,
      fetchLatest: () async =>
          throw const UpdateException("Couldn't check for updates."),
    );

    await tester.tap(find.text('Check for updates'));
    await tester.pump();
    await tester.pump();

    expect(find.text("Couldn't check for updates."), findsOneWidget);
    expect(find.text('Check for updates'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('install permission tells the user what to allow', (
    tester,
  ) async {
    await pumpAbout(
      tester,
      fetchLatest: () async => releaseJson,
      install: (_) async => 'permission',
    );

    await tester.tap(find.text('Check for updates'));
    await tester.pump();
    await tester.pump();
    await tester.tap(find.text('Download and install'));
    await tester.pump();
    await tester.pump();

    expect(
      find.text('Allow Memory to install updates, then tap Install.'),
      findsOneWidget,
    );
    expect(find.text('Install'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('large text keeps the update button tappable', (tester) async {
    tester.view.physicalSize = const Size(360, 720);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await pumpAbout(tester, fetchLatest: () async => releaseJson, textScale: 2);
    expect(tester.takeException(), isNull);
    expect(tester.getSize(find.byType(Btn)).height, greaterThanOrEqualTo(48));
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
