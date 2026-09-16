# Live finance and Ask Cherry

This update replaces the live-mode placeholders with API-backed screens. Demo mode remains synthetic and separate. It does not claim every website feature has been ported natively.

## Native workflows

- Home: invoice totals and actionable navigation to invoices, expenses, quotes, receipt scanning, Ask Cherry and More.
- Ask Cherry: POST `webmcp/ask`, server-side AI and company records, user/assistant history capped at ten messages with 2,000 characters each. Questions capped at 2,400. Conversation is session-only and cleared on sign-out/demo switch.
- Invoices, quotes, expenses, clients, products, payments and recurring invoices: paginated existing API lists with search and record details. Some legacy list endpoints have limited server-side search support.
- Invoice detail: existing signed preview and download links. No bearer token appears in a URL.
- Guided actions: invoice/quote creation, expense creation, supplier bill, VAT preview, payment draft. Saves require a confirmation screen. VAT preview does not submit to HMRC; payment drafts do not move money. No emails are sent by these screens.
- Receipt OCR: JPEG/PNG up to 8 MB. The server validates image content and sends it to its existing OpenAI provider. Extracted values remain editable; unknown net/VAT values require manual entry. Foreign currency amounts must be converted and entered in company currency. Saved expense receipts use existing durable storage. A failed attachment rolls back expense creation. PDF OCR is not implemented.
- Banking: up to 100 latest company-scoped transactions, accounts and balances when supplied by the bank provider. Full history and connection setup open the website.
- Reconciliation: fresh match suggestion → prepare proposal → explicit human approval. The existing backend rechecks permissions, current balances and match evidence. Approval records the ledger payment; it does not transfer funds.

## Existing web modules

More exposes purchase invoices, credit notes, VAT/HMRC, accounting reports, cash-flow forecasts, budgets, chart of accounts, opening balances, accounting controls, ledger reconciliation, Cherry Pay, users and settings. These launch the configured Cherry host in a browser and may require a separate website sign-in. They retain the website's plan/permission rules. Invoice/quote editing, email preview/send, client/product maintenance, manual payments and recurring settings remain web workflows.

## Backend dependency

Branch `feat/mobile-finance-api`, based on the deployed Google hotfix, adds authenticated `mobile/options`, `mobile/receipt/scan`, `mobile/invoice`, `mobile/quote`, `mobile/expense` and `mobile/vat/preview`. The existing `webmcp` endpoints serve chat, banking, reconciliation and payment drafts. The browser origin `http://localhost:8765` must be allowed on that bridge. Native bearer clients do not send an Origin header. No new database migration is required.

The API delegates writes to the existing Ask Cherry services and enforces module permissions and enabled-company checks. OCR credentials remain server-side. The frontend sends authenticated finance requests only to relative configured API paths.

## Verification boundaries

Flutter tests exercise live request contracts, real reply rendering, conversation follow-ups, explicit reconciliation confirmation and separation from demo data. Browser integration uses synthetic fixtures and intercepts all API calls; it does not create Production finance records. Backend tests cover auth/origin/permission failures, invalid images, provider errors, extraction schema, attachment storage and rollback.

Real account verification is still needed after the backend release: Ask Cherry response with the company's records, a real receipt scan, bank-provider data, and user-confirmed record creation. Native camera hardware and Google consent require device/account testing.
