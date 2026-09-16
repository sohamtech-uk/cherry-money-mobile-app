# Verified API migration

Sources: supplied ZIP `src/app/service/server.service.ts`, environments, login/home/capture pages; read-only backend inspection at `sohamtech-uk/cherrymoney` commit `cdca10f88ebe4e4d8cd012ff71f38c41fcfb8ebd` (`routes/api.php`, ApiController, AccountController, InvoiceController, ExpenseController). Source verification is not an authenticated live integration test.

| Legacy feature | Verified current route | Flutter implementation | Status |
| --- | --- | --- | --- |
| Login | POST `/api/login` | ApiClient.login | Implemented: email/password → msg, token, user; token saved securely |
| Dashboard | GET `/api/homepage` | ApiClient.dashboard | Implemented: Bearer token → data.company, overview, invoices |
| Logout | GET `/api/logout` | ApiClient.logout | Implemented; local token cleared even on server failure |
| Signup | POST `/api/signup` | ApiClient.signup | Required local Terms consent, company details and email verification |
| Email verification / resend | POST `/api/verifyOtp`, `/api/resendCode` | ApiClient.verifyOtp / resendCode | Code validation, secure session acceptance and resend feedback |
| Password reset | POST `/api/forgot` | ApiClient.forgot | Reset link delivered by the backend; password changed on the web |
| Google login | POST `/api/loginGoogle` with `id_token` | Native Google SDK / ApiClient.googleLogin | Requires backend PR #186 and OAuth configuration |
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

A separately authorized [backend fix](https://github.com/sohamtech-uk/cherrymoney/pull/186) verifies Google ID tokens. It is prepared for review, not deployed. Adding live bank transactions, reconciliation writes, server quotas, RevenueCat webhooks or account linking requires a separately authorized backend change.

## Restored authentication

Flutter implements POST `signup`, `verifyOtp`, `resendCode`, and `forgot` using the existing payloads. Signup requires Terms consent, then a six-digit email verification code. Reset completes in the emailed web link. Google POST `loginGoogle` now sends only `id_token`; enable it only after the separately prepared backend verification fix is deployed. Legacy profile-only payloads are intentionally not sent.
