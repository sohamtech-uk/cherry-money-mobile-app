# Security and production boundary

Auth tokens are stored in flutter_secure_storage (Keychain/Android secure storage), never SharedPreferences. Password fields clear after sign-in. API requests use HTTPS, timeouts and no logging interceptors. Environment values select endpoints explicitly. Sign-out clears local tokens even when server revocation fails; remote revocation may need a later retry.

Live mode loads account overview only. No autonomous money movement, bank access or accounting writes exist in this build. Demo fixtures are synthetic. Selected documents stay in picker memory for preview and are not uploaded; sample extraction ignores file bytes. Native permission messages explain camera/photo use.

RevenueCat public client SDK keys are build-time values; secret REST keys, store service accounts and signing keys must never be shipped. Anonymous RevenueCat identity follows the store/installation, not the Cherry company login. Purchases do not grant company web entitlements. Before commercial rollout implement authenticated identity/linking policy and verified server entitlement synchronization.

Local starter/paid quotas are prototype UX controls, not tamper-resistant server enforcement. Reinstalling can reset them. Demo decisions and audit history are in memory and reset on demo restart. The history is not immutable or a compliance-grade ledger. No claim of FCA/Open Banking approval is made.

Production work: server quotas and idempotency, durable encrypted document lifecycle, access-control review, user deletion/data export, real extraction consent/schema validation, backend auth/2FA review, account-switch subscription behavior, restore/revocation/refund testing, retry/session-expiry handling, native permission tests, accessibility review and store privacy declarations. Web preview token storage is browser-backed and is not equivalent to a native keychain; use native builds for production evaluation.

No secrets or signing artifacts from the supplied ZIP are included in the new repository. Existing upstream historical secret hygiene is outside this migration.
