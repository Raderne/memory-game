# Releases

Publishing follows the rule: branch pushes validate, version tags publish. See [[Tech Stack]].

## Contract

These three values must match before a release:

1. `version:` in `pubspec.yaml`, for example `1.0.0+1`. The part before `+` is the release version. The integer after `+` is the Android `versionCode` and must increase for every update.
2. A `## [1.0.0] - YYYY-MM-DD` section in `CHANGELOG.md`.
3. The Git tag `v1.0.0`.

`scripts/changelog-section.mjs` copies that changelog section into the GitHub Release notes. A missing or empty section fails the workflow.

## Workflows

- `.github/workflows/ci.yml` runs on `main`, `develop`, and `release/**`, and on pull requests. It analyzes, tests, and builds a debug APK. It does not publish. Markdown-only pushes are ignored.
- `.github/workflows/release.yml` runs on tags `v*.*.*`. It checks that the tag is SemVer, that the commit is on `develop` (the default branch), and that `pubspec.yaml` matches the tag. It then tests, signs a release APK, and publishes a GitHub Release. A manual run builds the same artifact and does not publish.

## Signing

Release builds use `android/key.properties` when that file exists. Local release builds keep the debug key when it does not. The release workflow writes the file from these GitHub secrets, then deletes it. All four must be set. The v1.0.1 run had only the keystore secret, so Gradle tried to sign with an empty alias and an empty password and reported `keystore password was incorrect`.

- `ANDROID_KEYSTORE_BASE64`
- `ANDROID_KEYSTORE_PASSWORD`
- `ANDROID_KEY_ALIAS`
- `ANDROID_KEY_PASSWORD`

The workflow rejects an APK whose certificate is `CN=Android Debug`.

## Publish

```sh
git tag -a v1.0.0 -m "Release 1.0.0"
git push origin v1.0.0
```

A dry run is **Actions → Release → Run workflow**, with the version and no `v` prefix.

Links: [[Build Plan]], [[Memory Game]]
