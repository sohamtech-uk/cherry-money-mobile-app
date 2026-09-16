# Cherry Money Mobile

A Flutter finance workspace for small businesses: capture → understand → match → review exceptions → approve. A Flutter rebuild of the existing Cherry mobile product, with RevenueCat integration for a Shipaton prototype. This repository contains Flutter code only.

**Status: implementation in review, not store released.** RevenueCat products, keys and sandbox purchases still require external setup. Prior mobile release eligibility has not been confirmed. Renaming/rebuilding an existing released app does not establish Shipaton eligibility.

## Run

Development toolchain: Flutter **3.41.9 stable**, bundled Dart **3.11.5**. Use Flutter's bundled `dart` (the machine's standalone Dart is 3.11.4).

```sh
flutter pub get
flutter run --dart-define=CHERRY_ENV=development
```

Select **Try demo**. Synthetic data is labelled throughout. Camera/gallery/file selection previews files locally; demo extraction returns an explicitly labelled sample, not OCR results from the selected file. Web is a convenient demo preview only, not an eligible Shipaton submission platform.

```sh
flutter run \
  --dart-define=CHERRY_ENV=development \
  --dart-define=CHERRY_API_BASE_URL=https://dev.cherrymoney.co.uk/api/ \
  --dart-define=REVENUECAT_IOS_API_KEY=YOUR_PUBLIC_IOS_SDK_KEY \
  --dart-define=REVENUECAT_ANDROID_API_KEY=YOUR_PUBLIC_ANDROID_SDK_KEY
```

Production defaults to `https://cherrymoney.co.uk/api/` when `CHERRY_ENV=production`. Keys are passed during builds; no `.env` loader is used. Do not place secret server API keys in a mobile build.

## Integration boundary

| Capability | Implementation |
| --- | --- |
| Account creation | Company/name/email/country code/phone/password, required Terms acceptance, email verification and resend |
| Password recovery | Reset-link email through the existing Cherry API |
| Cherry sign-in, overview, logout | Backend contracts implemented; authenticated live account testing pending |
| Google sign-in | Native SDK and signed-token exchange implemented; requires backend fix deployment and OAuth configuration |
| Token storage | OS secure storage through flutter_secure_storage |
| Transactions, matching, audit, copilot | Synthetic, local demo; no bank connection or external AI calls |
| Camera, gallery, file preview | Native pickers; file stays local; hardware verification required |
| Extraction | Demo service abstraction; real receipt endpoint documented but intentionally not called |
| RevenueCat | Real SDK offerings, purchase, restore and entitlement refresh; unavailable without keys |
| Limits | Free 3 / Pro 100 / Business 500 capture or approval actions per calendar month on this device |
| Pro capability | Detailed demo cashflow insight and expanded demo action allowance |
| Business | Higher allowance; future teams/advanced agent workflows explicitly not included |

Subscriptions use RevenueCat's anonymous installation identity and store account. They do not modify an existing Cherry company web plan. Usage counters are prototype limits, not secure cross-device billing enforcement. Demo decisions reset on a new demo session; monthly usage persists.

## RevenueCat setup

Create iOS and Android apps matching `uk.co.cherrymoney.mobile`. Configure store credentials and products externally. Create entitlements **pro** and **business**, attach matching store products, and add packages to the current offering. Supply platform public SDK keys via dart defines. Exercise purchase/cancel/pending/restore/expiry on signed native sandbox builds. The app never pretends a purchase succeeded.

Before sale, review the limited demo-only value, publish privacy/subscription terms, implement production usage enforcement and account identity handling, and configure the commercial offering appropriately. See [security limitations](docs/SECURITY.md).

## Verify and build

```sh
dart format --set-exit-if-changed lib test integration_test
flutter analyze
flutter test
flutter build apk --debug
flutter build ios --simulator
# Clean device/session required for this test's starter allowance:
flutter test integration_test/demo_flow_test.dart -d DEVICE_ID
```

[Validation results](docs/VALIDATION.md) distinguish executed checks from unverified native/external integrations. CI runs formatting, analysis, tests and Android build without keys.

## Screenshots

Actual running Flutter web preview at a 390 × 844 phone viewport:

| Dashboard | Review inbox | Approved match |
| --- | --- | --- |
| ![Demo dashboard](docs/screenshots/dashboard.png) | ![Reconciliation inbox](docs/screenshots/inbox.png) | ![Approved match](docs/screenshots/reconciled.png) |

Browser smoke check: onboarding → demo dashboard → review inbox → Northstar transaction → approve → reconciled status and audit event. No page errors observed. Native store/paywall screenshots still require a configured device build.

## Development workflow

Use `feat/<description>` for feature development and `fix/<description>` for bug fixes. Keep `main` as the baseline; open a pull request for changes. Git author identity for this repository is `sohamtechuk`.

## Google sign-in setup

Deploy the [backend token-verification fix](https://github.com/sohamtech-uk/cherrymoney/pull/186) and migration before enabling mobile Google sign-in. Configure Google OAuth Android credentials for `uk.co.cherrymoney.mobile` and its signing certificate, and an iOS client for that bundle ID. Add the iOS client's reversed client-ID URL scheme to `ios/Runner/Info.plist` using your actual Google configuration. Follow the [Flutter Google sign-in setup](https://pub.dev/packages/google_sign_in).

Build with `CHERRY_GOOGLE_AUTH_ENABLED=true`, `GOOGLE_SERVER_CLIENT_ID=<web-client-id>` and, for iOS, `GOOGLE_IOS_CLIENT_ID=<ios-client-id>`. The backend `GOOGLE_MOBILE_SERVER_CLIENT_ID` must match the mobile server client ID. Without configuration the button explains that Google sign-in is unavailable; email sign-in and signup remain available. Google authentication is native-only; the browser preview uses email or demo.

The Terms link opens the configured Cherry website's `/term` page. Acceptance is required locally and sent as `terms_accepted`; the existing signup endpoint does not persist a versioned consent record.

## Provenance

This is a new Flutter repository for an existing Cherry product. The supplied ZIP identifies source revision `41a45e79ed1b1627749a5500b6965d6ff48b3372`. Its Angular/Ionic implementation is not included in the published branch history. The original archive and upstream mobile repository remain unchanged, and a local Git bundle preserves the history before cleanup.

The Flutter-only root commit is named **First commit**, authored by **sohamtechuk**, with its actual creation date. This is a repository-history cleanup, not evidence that the product or its existing authentication features were first created during Shipaton. Event eligibility still needs confirmation.

See [architecture](docs/ARCHITECTURE.md), [API migration](docs/API_MIGRATION.md), [migration provenance](docs/LEGACY_MIGRATION.md), [security](docs/SECURITY.md), and [Shipaton checklist](docs/SHIPATON.md).

## Authentication screens

| Sign in | Create account | Reset password |
| --- | --- | --- |
| ![Sign in](docs/screenshots/login.png) | ![Create account](docs/screenshots/signup.png) | ![Reset password](docs/screenshots/reset.png) |

## Interface and motion

The interface includes a clearer cash overview, review progress, gentle page entrances, animated onboarding, loading feedback and approval confirmations. Custom motion respects reduced-motion preferences; financial amounts remain stable. See [experience design](docs/EXPERIENCE.md).

## Illustrated welcome

Three original finance scenes introduce the workspace, receipt capture and review workflow. The artwork is bundled locally and transitions gently, with reduced-motion support.

| Finances together | Capture paperwork | Review with confidence |
| --- | --- | --- |
| ![Finances together](docs/screenshots/onboarding-finances.png) | ![Capture paperwork](docs/screenshots/onboarding-capture.png) | ![Review with confidence](docs/screenshots/onboarding-review.png) |

[Artwork prompts and asset provenance](docs/ONBOARDING_ARTWORK.md).
