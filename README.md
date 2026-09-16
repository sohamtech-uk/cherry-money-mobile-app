# Cherry Money Mobile

A Flutter finance workspace for small businesses: capture → understand → match → review exceptions → approve. Built from the supplied CherryBankMobileApp source for a RevenueCat Shipaton prototype.

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
| Cherry sign-in, overview, logout | Verified backend routes implemented; no authenticated live account test performed |
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

Capture onboarding, dashboard with Demo data label, match evidence, mismatch exception, audit after approval, document review, and the configured store paywall. Screenshots should be taken from the verified build; do not substitute design mockups.

## Migration

Original supplied ZIP provenance: `41a45e79ed1b1627749a5500b6965d6ff48b3372`. Sanitized import preserved in [legacy/ionic-capacitor](https://github.com/sohamtech-uk/cherry-money-mobile-app/tree/legacy/ionic-capacitor). This is a **new repository**, following the original user request. The existing upstream mobile repository and `sohamtech-uk/cherrymoney` were not modified. Signing artifacts from the ZIP are excluded.

See [architecture](docs/ARCHITECTURE.md), [API migration](docs/API_MIGRATION.md), [legacy migration](docs/LEGACY_MIGRATION.md), [security](docs/SECURITY.md), and [Shipaton checklist](docs/SHIPATON.md).
