# Apple App Store release

Cherry Money is prepared as the next version of the existing **Cherry invoice** App Store app so current users receive the upgrade.

## Release identity

- App Store Connect app ID: `6736350941`
- Apple team: `Soham Yoga Ltd` (`DK4T8B9KX7`)
- Bundle ID: `com.cherryInvoiceNewApp.app`
- Version: `5.1.0`
- Build: `502`
- Display name: `Cherry Money`

Apple accepted signed build 502 on 19 September 2026 and it is selected on the 5.1.0 release record. It adds the Launch, Flow, Thrive and Practice entitlement model. Apple emitted one future compatibility warning: starting in spring 2027, new uploads must target iOS 15 or later; this build's current iOS 13 deployment target remains valid for this release.

The App Store Connect API upload key is stored outside the repository. Do not commit signing certificates, provisioning profiles, private keys, or RevenueCat secret credentials.

The iOS sign-in screen exposes email/password and account creation. Google sign-in remains available on Android and web but is intentionally hidden on iOS until the backend supports Sign in with Apple. This avoids presenting a third-party social login without Apple's equivalent option.

## Xcode Cloud

The repository includes `ci_scripts/ci_post_clone.sh`. Xcode Cloud runs it after cloning to install Flutter, fetch packages, and install CocoaPods dependencies.

Configure the workflow to:

1. Use `Runner.xcworkspace` and the shared `Runner` scheme.
2. Build branch `feat/app-store-release` with the latest stable Xcode/macOS environment.
3. Archive for iOS using automatic signing for team `DK4T8B9KX7`.
4. Distribute the successful archive to TestFlight/App Store Connect.

Before App Review, replace the inherited Cherry Invoice store screenshots with current Cherry Money screens, verify email sign-in, account creation, receipt capture and in-app bank connection on TestFlight, and configure production subscription products/pricing in App Store Connect and RevenueCat. Then test purchase, cancellation, pending state, restore, expiry and entitlement revocation with an Apple sandbox account.

The `Cherry Money plans` subscription group and monthly Flow, Thrive and Practice product records exist in App Store Connect. Price schedules, territory availability, RevenueCat entitlement/offering assignments and sandbox verification remain pending.
