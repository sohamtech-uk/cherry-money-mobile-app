# Validation

Toolchain: Flutter 3.41.9 stable / bundled Dart 3.11.5, macOS Intel. Java 17 available at `/usr/local/opt/openjdk@17`.

- `flutter pub get --offline`: PASS after resolving and SHA-256-verifying package downloads against pub.dev metadata; lockfile committed.
- `flutter analyze --no-pub`: PASS, no issues.
- `flutter test --no-pub`: PASS, 12 tests (8 unit / 4 widget), including demo launch → reconciliation → approval, sample capture, premium routing and no fabricated purchase success.
- Formatting: final verification pending.
- Android `flutter build apk --debug --no-pub`: attempted twice, blocked by TLS/DNS failures downloading Maven dependencies (AGP 8.5.1, Kotlin compiler, Netty and others). No APK produced locally yet.
- iOS `flutter build ios --simulator --no-pub`: attempted; reports `Application not configured for iOS`. `flutter doctor -v` reports missing full Xcode and CocoaPods; command-line tools alone are installed. No simulator build verified.
- Web preview build: in progress.
- Native integration test: supplied but not run; no Android/iOS simulator/device available. Equivalent full-widget happy path passes.
- Camera/gallery permissions and real document picker: code implemented, native hardware verification pending.
- RevenueCat real store purchase/restore: not tested, no configured SDK keys or store products supplied.
- Live Cherry auth/account APIs: source contracts verified; no customer credentials used.
- GitHub CI: workflow prepared, run pending feature branch push.

Initial widget failures were off-screen test taps and were fixed by scrolling the test viewport before tapping. No failing assertions were removed.
