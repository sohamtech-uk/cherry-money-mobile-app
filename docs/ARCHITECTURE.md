# Architecture

Material 3 / Flutter with feature-first screens. Riverpod supplies the observable Workspace; GoRouter owns routing and guards account/demo screens. Currency uses integer pence in the demo; matching never relies on floating-point currency comparisons.

- `core/config`: compile-time environments and centralized RevenueCat entitlement IDs.
- `core/network`: Dio, timeout handling, auth header attachment and friendly API errors.
- `core/storage`: OS secure token storage; SharedPreferences contains only monthly demo usage.
- `core/revenuecat`: SubscriptionRepository abstraction and Purchases SDK implementation.
- `data/demo`: synthetic source fixtures, including duplicate/missing/amount-conflict/low-confidence examples.
- `data/repositories`: mode boundary, matching decisions, entitlement state, local allowance and audit creation.
- `data/services`: DocumentExtractionService with explicit demo implementation.
- `features`: onboarding, account auth, dashboard, capture, transactions, reconciliation, copilot, plans and settings.

Purchase status refreshes at startup, app resume, paywall refresh and before gated actions. Failure to refresh a paid action falls back to Launch rather than granting access. UI never directly changes entitlements to simulate a purchase. Production entitlements are `cherrymoney_flow`, `cherrymoney_thrive`, and `cherrymoney_practice`; legacy Test Store `cherrymoney_pro`/`pro` access maps to Flow and `business` maps to Practice. SDK identity is anonymous/store-based; backend account linkage is deferred.

Matching: absent document → missing; possible duplicate → duplicate; amount difference → mismatch. Otherwise amount, calendar proximity, supplier and reference produce an explainable score weighted down by extraction uncertainty. Even high confidence is a proposal. Explicit human approval is required to mark reconciled. Rejected/exception decisions append events. Relinking removes the old document association and recomputes the target state.

Live mode calls only the verified account APIs. The backend's WebMCP bridge was not integrated: it has a separate origin/security contract and requires a dedicated mobile API design. No synthetic bank data is shown as live.

This is a prototype, not a production reconciliation engine. Audit events are in-memory session history. Usage is device-local and resettable by reinstalling. No real payments or accounting mutations are sent.
