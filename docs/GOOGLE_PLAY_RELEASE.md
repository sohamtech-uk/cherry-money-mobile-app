# Google Play release

This guide covers the first Cherry Money Android release. Upload the Android App Bundle (`.aab`) to Google Play. The standalone APKs are for direct device testing and must not be uploaded as the Play release.

## Release identity

| Field | Value |
| --- | --- |
| App name | Cherry Money |
| Package | `uk.co.cherrymoney.mobile` |
| Version | `1.0.0` |
| Bundle version code | `1` |
| Minimum Android | API 24 (Android 7.0) |
| Target Android | API 36 (Android 16) |
| Upload key alias | `cherrymoney-upload` |
| Upload certificate SHA-1 | `06:8F:F3:BA:10:7C:04:75:4A:DC:2C:33:1C:60:15:CE:39:14:32:B4` |
| Upload certificate SHA-256 | `51:73:81:B0:09:15:A4:96:1B:EE:AC:32:F7:B9:D3:02:93:5D:78:94:34:96:2F:F5:65:D9:8F:BF:3B:0B:20:9A` |

The private upload keystore and its password are intentionally outside the repository. Back up both in the organisation's password manager or secure vault. Losing the upload key requires a Play Console key-reset process.

## Build

Create `android/key.properties` from `android/key.properties.example`, using an absolute path to the upload keystore. Never commit the completed file or the keystore.

Production builds require the live RevenueCat **Google Play public SDK key**. A `test_` Test Store key is deliberately rejected in Production.

```sh
flutter clean
flutter pub get
flutter build appbundle --release \
  --dart-define-from-file=config/preview-production.json \
  --dart-define=REVENUECAT_ANDROID_API_KEY=YOUR_PUBLIC_GOOGLE_PLAY_SDK_KEY
```

For an internal build before RevenueCat is connected, omit the last define. Authentication and finance features remain available, but purchases and restores stay unavailable.

Every subsequent upload must have a greater version code. Change the value after `+` in `pubspec.yaml`, for example `1.0.0+2`.

## Create the Play app

1. Open Play Console, choose **All apps → Create app**, use **Cherry Money**, English (United Kingdom), App, and the intended free/paid setting. Complete the declarations and accept Play App Signing.
2. Complete the main store listing. Use the 512 × 512 icon from the release package. Add a 1024 × 500 feature graphic, phone screenshots, support email and the public privacy URL `https://cherrymoney.co.uk/privacy`.
3. Complete **App content**: privacy policy, app access, ads, content rating, target audience, Data safety and the financial-features declaration. Describe receipt images, invoice/business records, account data, bank-provider handoff and Ask Cherry data accurately. Do not mark data as uncollected merely because another processor receives it.
4. In **Testing → Internal testing**, create a release and upload `cherry-money-1.0.0+1-play.aab`. Add release notes, resolve every error, add testers and roll out to Internal testing first.
5. Install from the Play testing link and verify account creation, email login, Google login, receipt capture/OCR, bank connection, reconciliation, Ask Cherry, purchases, restore and account switching on a physical device.
6. Promote the tested bundle through Closed/Open testing if required, then create the Production release and submit it for review.

The app includes a labelled demo workspace. If Play review needs login access, provide either dedicated review credentials in **App access** or exact instructions for opening demo mode. Do not provide a personal account.

## Google login after the first upload

Google Play signs installed builds with the Play App Signing key, which is different from the local upload key and the existing debug key.

1. After the first bundle upload, open **Setup → App integrity → App signing**.
2. Copy the Play **app signing certificate** SHA-1 and SHA-256 fingerprints.
3. In Google Cloud project `cherry-invoice`, create an Android OAuth client for package `uk.co.cherrymoney.mobile` and the Play app-signing SHA-1. Keep the existing debug Android client for local builds.
4. Allow Google configuration time to propagate, then test Google login using the Play-installed internal-test build.

The upload-certificate SHA-1 in this document is not the fingerprint to use for Play-installed Google login.

## RevenueCat and Play Billing before selling Pro

1. Create the Google Play app in the existing RevenueCat project using package `uk.co.cherrymoney.mobile`.
2. Configure Google Play service credentials in RevenueCat and complete the Play Billing integration.
3. Create the Play subscription products and base plans, attach them to the `cherrymoney_pro` entitlement and the `default` offering, and keep identifiers aligned with the app's offering design.
4. Copy RevenueCat's public Android SDK key and pass it as `REVENUECAT_ANDROID_API_KEY` for the signed build. Never put a RevenueCat secret key or Google service-account JSON in the app.
5. Increment the version code, rebuild, upload to Internal testing, and test purchase, cancel, pending payment, restore, expiry, refund/revocation and account switching with Play license testers.

The prepared `1.0.0+1` bundle has no Production RevenueCat key. It is suitable for Play Console setup and core-function testing; it must be rebuilt with the public Google Play RevenueCat key before subscriptions are offered.

## Release package checks

The prepared bundle was validated with Bundletool 1.18.3. Its manifest reports package `uk.co.cherrymoney.mobile`, bundle version code `1`, minimum API 24 and target API 36. Bundletool estimates a per-device compressed Play download of **10.5–11.2 MB**, below the 20 MB target. The 47.8 MB bundle contains all supported device architectures and is only the upload file. Verify each copied file against `SHA256SUMS.txt` before transfer or upload.
