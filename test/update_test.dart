import 'package:flutter_test/flutter_test.dart';
import 'package:memory_app/update.dart';

void main() {
  test('versions ignore the v prefix and the build number', () {
    expect(compareVersions('1.0.3', '1.0.2'), 1);
    expect(compareVersions('v1.0.2', '1.0.2+3'), 0);
    expect(compareVersions('1.2', '1.2.0'), 0);
    expect(compareVersions('1.0.2-beta', '1.0.2'), -1);
    expect(compareVersions('1.0.3-beta', '1.0.2'), 1);
    expect(isNewer('v1.0.3', '1.0.2'), isTrue);
    expect(isNewer('1.0.2', '1.0.2'), isFalse);
  });

  test('a GitHub release uses the apk asset', () {
    final release = parseGithubRelease('''
      {
        "tag_name": "v1.0.3",
        "assets": [
          {"name": "notes.txt", "browser_download_url": "https://example.com/notes.txt"},
          {"name": "memory-1.0.3.apk", "browser_download_url": "https://example.com/memory-1.0.3.apk"}
        ]
      }
    ''');

    expect(release.version, '1.0.3');
    expect(release.apkUrl, 'https://example.com/memory-1.0.3.apk');
  });

  test('a release without an apk is rejected', () {
    expect(
      () => parseGithubRelease('{"tag_name":"v1.0.3","assets":[]}'),
      throwsA(
        isA<UpdateException>().having(
          (error) => error.message,
          'message',
          'The latest release has no Android package.',
        ),
      ),
    );
  });
}
