# Legacy preservation

New repository: `sohamtech-uk/cherry-money-mobile-app` (private). The original request to create a new repository takes precedence over the later attachment's example existing-repository migration.

- ZIP source revision: `41a45e79ed1b1627749a5500b6965d6ff48b3372` (archive comment).
- Sanitized import commit: `4430602b34b4a1249faf8d946edb0d683763316a`.
- Permanent preservation branch: `legacy/ionic-capacitor`, remotely verified at that import commit.
- `main` starts at the same sanitized import. Flutter changes are on `feat/flutter-revenuecat-shipaton` for PR review.
- This is not a claim that the new repository contains the upstream mobile repository's full history or an exact upstream main preservation branch.
- Original stack: Angular 18, Ionic 8, Capacitor 6. App ID: `com.cherryInvoiceNewApp.app`.
- New Flutter Android/iOS identity: `uk.co.cherrymoney.mobile`. No store identity registered or release submitted.

The original ZIP and upstream repositories are unmodified. Signing material (`private_key.pepk`), release binaries and miscellaneous scratch content are excluded from the imported history. Earlier local Ionic compatibility edits are retained separately in the sibling `cherry-money-ionic-update-wip` directory; they are not represented as Flutter implementation.

| Legacy | Flutter |
| --- | --- |
| Camera/gallery | ImagePicker with local preview |
| OCR | DocumentExtractionService; explicit sample extraction |
| Sign-in | Confirmed login contract, secure token store |
| Accounting menu | Focused dashboard / transactions / reconcile / copilot |
| Subscription web links | Native RevenueCat offerings, purchase, restore |
| OneSignal/social/Apple sign-in | Deferred; no nonfunctional buttons |
| Existing invoice/payment mutation screens | Deferred; API discrepancies documented |

Run legacy independently: `git worktree add ../cherry-ionic legacy/ionic-capacitor`, then `npm ci --legacy-peer-deps` and `npm start`. This old stack may require a compatible Node version and still contains legacy endpoint limitations. Do not use the old branch as a production-ready build.
