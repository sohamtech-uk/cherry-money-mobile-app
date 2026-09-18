# Apple App Store release

Cherry Money is prepared as the next version of the existing **Cherry invoice** App Store app so current users receive the upgrade.

## Release identity

- App Store Connect app ID: `6736350941`
- Apple team: `Soham Yoga Ltd` (`DK4T8B9KX7`)
- Bundle ID: `com.cherryInvoiceNewApp.app`
- Version: `5.0.0`
- Build: `500`
- Display name: `Cherry Money`

The iOS sign-in screen exposes email/password and account creation. Google sign-in remains available on Android and web but is intentionally hidden on iOS until the backend supports Sign in with Apple. This avoids presenting a third-party social login without Apple's equivalent option.

## Xcode Cloud

The repository includes `ci_scripts/ci_post_clone.sh`. Xcode Cloud runs it after cloning to install Flutter, fetch packages, and install CocoaPods dependencies.

Configure the workflow to:

1. Use `Runner.xcworkspace` and the shared `Runner` scheme.
2. Build branch `feat/app-store-release` with the latest stable Xcode/macOS environment.
3. Archive for iOS using automatic signing for team `DK4T8B9KX7`.
4. Distribute the successful archive to TestFlight/App Store Connect.

Before App Review, verify email sign-in, account creation, receipt capture, in-app bank connection, RevenueCat sandbox purchase and restore on a signed TestFlight build.
