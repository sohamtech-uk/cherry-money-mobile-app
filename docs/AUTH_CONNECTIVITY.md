# Google authentication connectivity investigation

Observed on 16 September 2026 after the localhost Google origins were corrected.

The Google SDK button loads successfully and opens Google Accounts. The enabled preview sends its signed Google ID token to `https://dev.cherrymoney.co.uk/api/loginGoogle`. That host resets the HTTPS connection before an HTTP response, so the app cannot receive a Cherry session.

DNS resolves `dev.cherrymoney.co.uk` to `ca-cm-dev-uks.proudhill-de1f30f8.uksouth.azurecontainerapps.io`. The active Azure subscription contains the Test and Production Container Apps; querying the named development resource returns no resource. Recreating infrastructure or silently sending a user's sign-in to a different account database is not part of the client error-message fix.

Backend PR #186 is merged, and CI plus the production release build passed for merge commit `22fea9441bb5eee8dc61f4491a13aeddc7bd2e4c`. The resulting release is `v0.1.11`. A build does not deploy the running app. Neither running Container App currently defines `GOOGLE_MOBILE_SERVER_CLIENT_ID`.

To complete connection setup, select Test or Production, deploy an appropriate release containing the Google verifier and its `users.google_subject` migration, configure the matching public audience, and rebuild the preview with that explicit API environment. Check HTTPS connectivity, CORS from localhost and invalid-token rejection before exercising a real Google login. Do not fall back automatically between account databases.

The client now distinguishes transport failures, temporary server failures, unavailable server Google configuration, rate limiting and Laravel validation/account errors. It does not surface private server exception text. Analysis and all 16 focused authentication/API tests passed, including seven new failure cases; no failed response saves a session.


## Production selected

The user selected Production. The local preview now uses `https://cherrymoney.co.uk/api/`, with Google enabled, via the reproducible `config/preview-production.json` profile. The original development URL remains the default for unconfigured builds; there is no automatic fallback.

Production HTTPS and CORS work, but its Google endpoint returns HTTP 500 on an invalid-token check. Registry metadata identifies the running Production image as `v0.1.3`; it lacks the Google audience environment value. The merged verifier release is `v0.1.11`, so deploying it is a shared-backend upgrade across multiple versions. No Production infrastructure or database changes were made while switching the preview.
