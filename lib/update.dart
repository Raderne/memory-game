import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/services.dart';

const githubLatestRelease =
    'https://api.github.com/repos/Raderne/memory-game/releases/latest';

const updateChannel = MethodChannel('memory/updates');

class UpdateException implements Exception {
  final String message;
  const UpdateException(this.message);

  @override
  String toString() => message;
}

class AppRelease {
  final String version;
  final String apkUrl;

  const AppRelease({required this.version, required this.apkUrl});
}

/// `v1.0.2+3` and `1.0.2` compare equal. A prerelease is older than the
/// matching release (`1.0.2-beta` < `1.0.2`).
int compareVersions(String a, String b) {
  final left = _split(a);
  final right = _split(b);
  final count = math.max(left.parts.length, right.parts.length);
  for (var i = 0; i < count; i++) {
    final delta = left.part(i) - right.part(i);
    if (delta != 0) return delta > 0 ? 1 : -1;
  }
  if (left.pre == right.pre) return 0;
  if (left.pre == null) return 1;
  if (right.pre == null) return -1;
  return left.pre!.compareTo(right.pre!);
}

bool isNewer(String latest, String current) =>
    compareVersions(latest, current) > 0;

String normalizeVersion(String raw) {
  var value = raw.trim();
  if (value.startsWith('v') || value.startsWith('V')) {
    value = value.substring(1);
  }
  final plus = value.indexOf('+');
  if (plus >= 0) value = value.substring(0, plus);
  return value;
}

AppRelease parseGithubRelease(String body) {
  final Object? decoded;
  try {
    decoded = jsonDecode(body);
  } on FormatException {
    throw const UpdateException("Couldn't read the release.");
  }
  if (decoded is! Map) {
    throw const UpdateException("Couldn't read the release.");
  }
  final tag = decoded['tag_name'];
  if (tag is! String || tag.trim().isEmpty) {
    throw const UpdateException("Couldn't read the release.");
  }
  final assets = decoded['assets'];
  if (assets is! List) {
    throw const UpdateException('The latest release has no Android package.');
  }
  String? url;
  for (final asset in assets) {
    if (asset is! Map) continue;
    final name = asset['name'];
    final link = asset['browser_download_url'];
    if (name is String &&
        name.endsWith('.apk') &&
        link is String &&
        link.isNotEmpty) {
      url = link;
      break;
    }
  }
  if (url == null) {
    throw const UpdateException('The latest release has no Android package.');
  }
  try {
    return AppRelease(version: normalizeVersion(tag), apkUrl: url);
  } on UpdateException {
    throw const UpdateException("Couldn't read the release.");
  }
}

Future<String> installedVersion() async {
  final version = await updateChannel.invokeMethod<String>('version');
  if (version == null || version.trim().isEmpty) {
    throw const UpdateException('This build has no version.');
  }
  return version;
}

Future<String> fetchLatestReleaseJson() async {
  final client = HttpClient();
  try {
    client.connectionTimeout = const Duration(seconds: 20);
    final request = await client.getUrl(Uri.parse(githubLatestRelease));
    request.headers.set(HttpHeaders.userAgentHeader, 'Memory');
    request.headers.set(
      HttpHeaders.acceptHeader,
      'application/vnd.github+json',
    );
    final response = await request.close().timeout(const Duration(seconds: 20));
    final body = await response.transform(utf8.decoder).join();
    if (response.statusCode == 404) {
      throw const UpdateException('No release has been published yet.');
    }
    if (response.statusCode != 200) {
      throw const UpdateException("Couldn't check for updates.");
    }
    return body;
  } on SocketException {
    throw const UpdateException("Couldn't check for updates.");
  } on TimeoutException {
    throw const UpdateException("Couldn't check for updates.");
  } finally {
    client.close(force: true);
  }
}

Future<String> downloadRelease(
  String url,
  void Function(double? progress) onProgress,
) async {
  final directory = await updateChannel.invokeMethod<String>('cacheDir');
  if (directory == null || directory.isEmpty) {
    throw const UpdateException("Couldn't prepare the download.");
  }
  final file = File('$directory/memory-update.apk');
  if (await file.exists()) await file.delete();

  final client = HttpClient();
  IOSink? sink;
  try {
    client.connectionTimeout = const Duration(seconds: 20);
    final request = await client.getUrl(Uri.parse(url));
    request.headers.set(HttpHeaders.userAgentHeader, 'Memory');
    final response = await request.close();
    if (response.statusCode != 200) {
      throw const UpdateException("Couldn't download the update.");
    }
    final total = response.contentLength;
    var received = 0;
    sink = file.openWrite();
    await for (final chunk in response) {
      sink.add(chunk);
      received += chunk.length;
      onProgress(total > 0 ? received / total : null);
    }
    await sink.flush();
    await sink.close();
    sink = null;
    return file.path;
  } on SocketException {
    throw const UpdateException("Couldn't download the update.");
  } on UpdateException {
    rethrow;
  } catch (_) {
    throw const UpdateException("Couldn't download the update.");
  } finally {
    if (sink != null) await sink.close();
    client.close(force: true);
  }
}

Future<String> installDownloadedRelease(String path) async {
  try {
    final outcome = await updateChannel.invokeMethod<String>('install', {
      'path': path,
    });
    if (outcome == 'install') return 'install';
    if (outcome == 'permission') return 'permission';
    throw const UpdateException("Couldn't open the installer.");
  } on PlatformException {
    throw const UpdateException("Couldn't open the installer.");
  }
}

class _SemVer {
  final List<int> parts;
  final String? pre;

  _SemVer(this.parts, this.pre);

  int part(int index) => index < parts.length ? parts[index] : 0;
}

_SemVer _split(String raw) {
  final version = normalizeVersion(raw);
  final dash = version.indexOf('-');
  final core = dash >= 0 ? version.substring(0, dash) : version;
  final pre = dash >= 0 ? version.substring(dash + 1) : null;
  if (core.isEmpty || pre == '') {
    throw const UpdateException("Couldn't read the release.");
  }
  final parts = <int>[];
  for (final piece in core.split('.')) {
    final number = int.tryParse(piece);
    if (number == null || number < 0) {
      throw const UpdateException("Couldn't read the release.");
    }
    parts.add(number);
  }
  return _SemVer(parts, pre);
}
