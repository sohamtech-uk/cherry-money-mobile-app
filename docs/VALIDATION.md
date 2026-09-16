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

## Authentication and branding update (16 September 2026)

- Flutter analyze: passed; 22 Flutter tests passed, including consent gating, signup, OTP session validation, API error handling and signed-token-only Google exchange.
- Web build passed. Chrome at 390 × 844 verified sign-in → signup → required Terms checkbox → field validation → password reset, with no page errors. Screenshots: `login.png`, `signup.png`, `reset.png`.
- Supplied Cherry Money logo appears on welcome/authentication screens and the application header.
- Google native OAuth and live signup/email delivery remain untested; configuration and backend deployment are required. No live account was created by these tests.

Android validation for the authentication/logo update passed in [run 35148379987](https://github.com/sohamtech-uk/cherry-money-mobile-app/actions/runs/35148379987): formatting, analysis, 22 tests and debug APK build. [Download the debug APK artifact](https://github.com/sohamtech-uk/cherry-money-mobile-app/actions/runs/35148379987/artifacts/10467759138). The build tested code commit `15c25c5`; subsequent commits only update documentation/screenshots and merge the default-branch documentation. Backend Google fix PR #186 also passed its full CI tests and container build.

## Motion and finance interface update

Flutter analysis and 27 tests passed, including reduced motion, mid-animation preference changes, finite page entrances, immediate removal of stale statuses and a 320 px layout with 1.8× text. Web build passed. Chrome browser checks passed onboarding → demo dashboard → review → approval at 390 px with normal motion and 320 px with reduced motion; no page errors. Approval removed the action and displayed confirmation. The screenshots reflect the updated interface. Native gesture/performance testing still requires a device.

## Illustrated onboarding update

Analysis, 29 tests and the web build passed. Chrome verified all three local images, next/back navigation and Get started → sign-in at 390 px and 1280 px with standard motion, and 320 px with reduced motion. No page errors were observed. Three onboarding screenshots are included. The generated artwork totals approximately 5.1 MB, is bundled in the application, and is preloaded once for these three steps. Android CI is separate from these executed web and widget checks.

## Google browser flow and logo background fix

Analysis and all 35 Flutter tests passed on Flutter 3.41.9. Six new control tests cover unconfigured availability, initialization retry, cancellation, duplicate events while exchanging a token, backend rejection and late native/browser completion after navigation. Both configured and default web builds passed.

Chrome exercised the configured browser path using an intercepted Google SDK response and intercepted API responses: the Google authentication event sent only `id_token`, a rejected backend response stayed on login with an error, and an accepted response stored a Cherry session and fetched the account overview with its bearer token. These are simulated contract checks, not live OAuth verification.

The default preview passed login → signup → Terms gating → validation → password reset at 390 px. Onboarding passed at 390/1280 px and 320 px with reduced motion. No page errors occurred. Updated screenshots show the original logo blended with the page surface. Google remains disabled in the default build until the backend and OAuth configuration are ready; live Google and native device sign-in remain unverified.
