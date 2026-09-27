# Updates

The About screen checks [GitHub releases](https://github.com/Raderne/memory-game/releases) and can download and install a newer APK. The app is not distributed on the Play Store. See [[Screens]] and [[Releases]].

## Check

`GET https://api.github.com/repos/Raderne/memory-game/releases/latest` with a `Memory` user agent. The installed version is Android `versionName` (the `pubspec.yaml` version before `+`). Comparison ignores a leading `v` and the `+` build number. A prerelease is older than the same numbered release.

The `.apk` asset's `browser_download_url` is the file to install. The published asset name is `memory-X.Y.Z.apk`.

## Download and install

The APK is saved at the app cache path `updates/memory-update.apk`. Android then opens the system installer through a `FileProvider`. On Android 8 and later, if Memory is not allowed to install unknown apps, About opens that system setting and asks the user to allow it, then tap Install again.

The repository is public, so the check does not embed a token.

## Code

- `lib/update.dart` — version compare, release JSON, HTTP, and the `memory/updates` method channel. No widget imports.
- `lib/screens/about.dart` — About. `loadVersion`, `fetchLatest`, `download`, and `install` are injectable so tests never call GitHub.
- `MainActivity` handles `version`, `cacheDir`, and `install`.

The status block and the progress track keep a fixed height, so the button does not jump when a result appears.

Links: [[Tech Stack]], [[Screens]]
