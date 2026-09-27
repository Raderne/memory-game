import 'package:flutter/material.dart';

import '../theme.dart';
import '../update.dart';
import '../widgets.dart';

class AboutScreen extends StatefulWidget {
  final Color accent;
  final Future<String> Function() loadVersion;
  final Future<String> Function() fetchLatest;
  final Future<String> Function(
    String url,
    void Function(double? progress) onProgress,
  )
  download;
  final Future<String> Function(String path) install;

  const AboutScreen({
    super.key,
    required this.accent,
    this.loadVersion = installedVersion,
    this.fetchLatest = fetchLatestReleaseJson,
    this.download = downloadRelease,
    this.install = installDownloadedRelease,
  });

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

enum _Phase { idle, checking, current, available, downloading, ready, failed }

class _AboutScreenState extends State<AboutScreen> {
  _Phase _phase = _Phase.idle;
  String _version = '';
  String _message = 'Check GitHub for a newer version.';
  String? _apkUrl;
  String? _filePath;
  double? _progress;
  bool _alive = true;
  var _reportedPercent = -1;

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  @override
  void dispose() {
    _alive = false;
    super.dispose();
  }

  Future<void> _loadVersion() async {
    try {
      final version = normalizeVersion(await widget.loadVersion());
      if (!_alive) return;
      setState(() => _version = version);
    } on UpdateException catch (error) {
      if (!_alive) return;
      setState(() {
        _phase = _Phase.failed;
        _message = error.message;
      });
    }
  }

  Future<void> _check() async {
    setState(() {
      _phase = _Phase.checking;
      _message = 'Checking for updates…';
      _apkUrl = null;
      _filePath = null;
      _progress = null;
    });
    try {
      final release = parseGithubRelease(await widget.fetchLatest());
      if (!_alive) return;
      final newer = _version.isNotEmpty && isNewer(release.version, _version);
      setState(() {
        _apkUrl = newer ? release.apkUrl : null;
        _phase = newer ? _Phase.available : _Phase.current;
        _message = newer
            ? 'Version ${release.version} is available.'
            : "You're up to date.";
      });
    } on UpdateException catch (error) {
      if (!_alive) return;
      setState(() {
        _phase = _Phase.failed;
        _message = error.message;
      });
    }
  }

  Future<void> _download() async {
    final url = _apkUrl;
    if (url == null) return;
    _reportedPercent = -1;
    setState(() {
      _phase = _Phase.downloading;
      _message = 'Downloading the update…';
      _progress = 0;
    });
    try {
      final path = await widget.download(url, (progress) {
        if (!_alive) return;
        final percent = progress == null ? -1 : (progress * 100).floor();
        if (percent == _reportedPercent) return;
        _reportedPercent = percent;
        setState(() => _progress = progress);
      });
      if (!_alive) return;
      setState(() => _filePath = path);
      await _install();
    } on UpdateException catch (error) {
      if (!_alive) return;
      setState(() {
        _phase = _Phase.available;
        _message = error.message;
        _progress = null;
      });
    }
  }

  Future<void> _install() async {
    final path = _filePath;
    if (path == null) return;
    try {
      final outcome = await widget.install(path);
      if (!_alive) return;
      setState(() {
        _phase = _Phase.ready;
        _progress = 1;
        _message = outcome == 'permission'
            ? 'Allow Memory to install updates, then tap Install.'
            : 'Follow the install prompt to finish.';
      });
    } on UpdateException catch (error) {
      if (!_alive) return;
      setState(() {
        _phase = _Phase.ready;
        _message = error.message;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final checking = _phase == _Phase.checking;
    final downloading = _phase == _Phase.downloading;
    final busy = checking || downloading;
    final canAct = _version.isNotEmpty && !busy;
    final label = switch (_phase) {
      _Phase.checking => 'Checking…',
      _Phase.downloading => 'Downloading…',
      _Phase.available => 'Download and install',
      _Phase.ready => 'Install',
      _ => 'Check for updates',
    };
    final icon = switch (_phase) {
      _Phase.available || _Phase.downloading => Icons.download,
      _Phase.ready => Icons.install_mobile,
      _ => Icons.system_update_alt,
    };
    final scaler = MediaQuery.textScalerOf(context);
    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          children: [
            const TopBar(title: 'About'),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                children: [
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: card,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: cardBorder),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Memory',
                            style: TextStyle(
                              color: text,
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _version.isEmpty
                                ? 'Version unavailable'
                                : 'Version $_version',
                            style: const TextStyle(
                              color: textSec,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Updates install from GitHub releases.',
                            style: TextStyle(
                              color: textSec,
                              fontSize: 14,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    key: const Key('update-status'),
                    height: scaler.scale(14 * 1.4 * 2),
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Semantics(
                        liveRegion: true,
                        child: Text(
                          _message,
                          maxLines: 2,
                          overflow: TextOverflow.fade,
                          style: TextStyle(
                            color: _messageColor(),
                            fontSize: 14,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    key: const Key('update-progress'),
                    height: 4,
                    child: LinearProgressIndicator(
                      value: downloading
                          ? _progress
                          : (_phase == _Phase.ready ? 1 : 0),
                      minHeight: 4,
                      backgroundColor: downloading || _phase == _Phase.ready
                          ? cardBorder
                          : Colors.transparent,
                      color: downloading || _phase == _Phase.ready
                          ? widget.accent
                          : Colors.transparent,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Btn(
                    label: label,
                    icon: icon,
                    accent: widget.accent,
                    onTap: !canAct
                        ? null
                        : switch (_phase) {
                            _Phase.available => _download,
                            _Phase.ready => _install,
                            _ => _check,
                          },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _messageColor() => switch (_phase) {
    _Phase.failed => danger,
    _Phase.current => success,
    _Phase.available || _Phase.ready => text,
    _ => textSec,
  };
}
