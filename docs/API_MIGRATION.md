# Verified API migration

Sources: supplied ZIP `src/app/service/server.service.ts`, environments, login/home/capture pages; read-only backend inspection at `sohamtech-uk/cherrymoney` commit `cdca10f88ebe4e4d8cd012ff71f38c41fcfb8ebd` (`routes/api.php`, ApiController, AccountController, InvoiceController, ExpenseController). Source verification is not an authenticated live integration test.

| Legacy feature | Verified current route | Flutter implementation | Status |
| --- | --- | --- | --- |
| Login | POST `/api/login` | ApiClient.login | Implemented: email/password → msg, token, user; token saved securely |
| Dashboard | GET `/api/homepage` | ApiClient.dashboard | Implemented: Bearer token → data.company, overview, invoices |
| Logout | GET `/api/logout` | ApiClient.logout | Implemented; local token cleared even on server failure |
| Signup | POST `/api/signup` | None | Deferred; verification flow requires separate coverage |
| Invoice list | GET `/api/invoice?page=…&status=…` | None | Verified; homepage exposes recent invoices only in this MVP |
| Invoice create/edit | POST `/api/invoiceAdd`; PUT `/api/invoice/{invoice}` | None | Deferred; legacy edit-via-create is incompatible |
| Invoice delete | DELETE `/api/invoice/{invoice}` | None | Legacy GET removeInvoice is obsolete |
| Recurring stop | DELETE `/api/invoice/{invoice}/recurring?type=…` | None | Legacy GET stopRec is obsolete |
| Payment delete | DELETE `/api/payment/{payment}` | None | Legacy GET removePayment is obsolete |
| Invoice download | GET `/api/editInvoice?id=…` returns `download_url` | None | Signed per-invoice URL; legacy add.download is null |
| Receipt extraction | POST `/api/scanReceipt`, JSON `{image: base64Jpeg}` | DocumentExtractionService demo | Route verified; AI response schema/production policy not reliable enough to expose as live |
| Cherry Pay request | Legacy POST `/api/cherryPay/payment-request` | None | Not present in current API routes; no guessed fallback links |
| Reconciliation / bank feed / copilot | No matching legacy mobile API contract | Demo repositories | Explicit synthetic data only |

Dio sends `Accept: application/json` and `Authorization: Bearer <secure token>` for protected requests. Passwords and responses are not logged. Error messages are mapped to human-readable states rather than displaying raw network errors.

Backend source files remain untouched. Adding live bank transactions, reconciliation writes, server quotas, RevenueCat webhooks or account linking requires a separately authorized backend change.

## Restored authentication

Flutter implements POST `signup`, `verifyOtp`, `resendCode`, and `forgot` using the existing payloads. Signup requires Terms consent, then a six-digit email verification code. Reset completes in the emailed web link. Google POST `loginGoogle` now sends only `id_token`; enable it only after the separately prepared backend verification fix is deployed. Legacy profile-only payloads are intentionally not sent.
