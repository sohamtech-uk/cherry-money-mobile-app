# Validation

Toolchain: Flutter 3.41.9 stable / bundled Dart 3.11.5, macOS Intel. Java 17 available at `/usr/local/opt/openjdk@17`.

- `flutter pub get --offline`: PASS after resolving and SHA-256-verifying package downloads against pub.dev metadata; lockfile committed.
- `flutter analyze --no-pub`: PASS, no issues.
- `flutter test --no-pub`: PASS, 17 tests (13 unit / 4 widget), including demo launch → reconciliation → approval, sample capture, premium routing and no fabricated purchase success.
- `dart format --set-exit-if-changed lib test integration_test`: PASS.
- Android: PASS in GitHub Actions run [35136983944](https://github.com/sohamtech-uk/cherry-money-mobile-app/actions/runs/35136983944) for app revision `820a655b39c9a6dc8d09678719d93f8c1010444c`. The debug APK was built and uploaded as [cherry-money-debug-apk](https://github.com/sohamtech-uk/cherry-money-mobile-app/actions/runs/35136983944/artifacts/10463458675). Local attempts were blocked by Maven TLS/DNS errors; clean Ubuntu CI succeeded.
- iOS `flutter build ios --simulator --no-pub`: attempted; reports `Application not configured for iOS`. `flutter doctor -v` reports missing full Xcode and CocoaPods; command-line tools alone are installed. No simulator build verified.
- `flutter build web --no-pub`: PASS (JavaScript/CanvasKit). RevenueCat dependency reports a Wasm dry-run incompatibility; Wasm is not the selected build target. Phone-sized browser verification PASS: onboarding → Demo → reconciliation inbox → Northstar → approve → Reconciled and audit update. No browser page errors observed. Screenshots in docs/screenshots.
- Native integration test: supplied but not run; no Android/iOS simulator/device available. Equivalent full-widget happy path passes.
- Camera/gallery permissions and real document picker: code implemented, native hardware verification pending.
- RevenueCat real store purchase/restore: not tested, no configured SDK keys or store products supplied.
- Live Cherry auth/account APIs: source contracts verified; no customer credentials used.
- GitHub CI: formatting, analysis, tests, Android debug build and APK upload all PASS in run `35136983944`. Final repository updates after the tested revision change only documentation and explicitly skip redundant CI. Native device runtime and real store transactions remain unverified.

Initial widget failures were off-screen test taps and were fixed by scrolling the test viewport before tapping. No failing assertions were removed.
