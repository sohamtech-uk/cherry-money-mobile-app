# Google sign-in activation

Flutter supports Android, iOS and the browser. Google returns an ID token; Cherry's backend verifies it and returns a Cherry session. A Google SDK success alone never grants access to the app.

## Configured public client

The default Web OAuth client is `996173642915-dvk7ac9old9oqj946uote1hr1plvkba0.apps.googleusercontent.com` in the `cherry-invoice` Google Cloud project. `GOOGLE_SERVER_CLIENT_ID` can override it for another environment. The downloaded credentials file and client secret are not included in the app or repository.

The supplied export lists `https://cherrymoney.co.uk/google/callback` as a redirect URI and does not list JavaScript origins. Keep that callback for the existing website. Add `http://localhost` and `http://localhost:8765` as **Authorized JavaScript origins** for this client in [Google Cloud](https://console.cloud.google.com/auth/clients?project=cherry-invoice), following [Google’s setup instructions](https://developers.google.com/identity/gsi/web/guides/get-google-api-clientid). Use `localhost` for the browser preview rather than the current numeric loopback address.

A live SDK origin check on 16 September 2026 loaded Google's client/style successfully, but `/gsi/button` returned HTTP 403 and `The given origin is not allowed for the given client ID.` for `http://localhost:8765`. This confirms the missing local-origin configuration; no Google account was signed in and no token was sent to Cherry.

## Backend prerequisite

Deploy [backend PR #186](https://github.com/sohamtech-uk/cherrymoney/pull/186), including the `users.google_subject` migration. Set the backend environment value below, then refresh Laravel's configuration cache. It must match the app's token audience:

```dotenv
GOOGLE_MOBILE_SERVER_CLIENT_ID=996173642915-dvk7ac9old9oqj946uote1hr1plvkba0.apps.googleusercontent.com
```

This endpoint requires an existing, active Cherry account with a verified company. New users complete signup, Terms acceptance and email verification first.

Do not enable this build against the old profile-only Google endpoint. This mobile PR does not deploy backend changes or alter Google Cloud settings.

## Browser

1. In the Google Cloud project's Web OAuth client, register the app's exact JavaScript origins. For this preview use `http://localhost` and `http://localhost:8765`, and open the preview using `localhost`. Register each production HTTPS origin separately. An authorized redirect URI is not a substitute for a JavaScript origin.
2. Configure the OAuth consent screen and test users if the client is in testing mode.
3. Build with the public client ID (never a client secret):

   ```sh
   flutter build web --no-wasm-dry-run \
     --dart-define=CHERRY_GOOGLE_AUTH_ENABLED=true
   python3 -m http.server 8765 --directory build/web
   ```

4. Open `http://localhost:8765/#/login`, click Google's button and choose an authorized test account. Verify the Cherry overview loads and logout clears the Cherry session. Check the API's CORS policy permits the browser origin.

The client ID is passed directly to SDK initialization. No second client ID in `web/index.html` is needed. The browser uses Google's rendered button and authentication events, as required by the [Flutter web plugin](https://pub.dev/packages/google_sign_in_web). It never calls the unsupported web `authenticate()` method. Login events are unsubscribed on navigation; duplicate events while a token exchange is pending are ignored. SDK failures have a retry action; backend failures remain visible with email sign-in available.

## Native apps

Android needs an OAuth Android client for `uk.co.cherrymoney.mobile` and its actual signing certificate. iOS needs its OAuth client and reversed-client-ID URL scheme in `ios/Runner/Info.plist`. Use the enable flag above, plus `GOOGLE_IOS_CLIENT_ID` for iOS. Override `GOOGLE_SERVER_CLIENT_ID` only when targeting a different configured Google project. Follow the [platform setup instructions](https://pub.dev/packages/google_sign_in).

## Default preview

The public client ID is configured, but without `CHERRY_GOOGLE_AUTH_ENABLED=true` the Google button is disabled and explains that email sign-in/signup are available. No authentication attempt or token exchange is started (the web plugin may still load Google’s SDK script during registration). This is a configuration state, not evidence that live Google OAuth has passed validation. Keep the enable flag false until the backend and OAuth origins/clients are ready.

## Logo rendering

The original supplied Cherry Money logo remains unchanged. `CherryLogo` multiplies its colors against the current scaffold background while rendering, so the white rectangle matches the warm page surface across welcome, login, signup, reset and the app header.

## Production preview

The local preview was explicitly switched to Production on 16 September 2026. Reproduce that build with:

```sh
flutter build web --no-wasm-dry-run --dart-define-from-file=config/preview-production.json
python3 -m http.server 8765 --directory build/web
```

Open `http://localhost:8765/#/login`. This profile uses real Production accounts at `https://cherrymoney.co.uk/api/`; it contains no credentials or client secret. It does not deploy the backend.

At the time of switching, the Production Google endpoint was reachable and returned CORS headers allowing the localhost browser, but an invalid-token probe returned HTTP 500. Azure was running `v0.1.3` with no `GOOGLE_MOBILE_SERVER_CLIENT_ID`; the merged verifier is in the published `v0.1.11` image. Full Google login requires a separately reviewed Production backend rollout and the matching audience setting. Do not treat the successful client connection as successful account authentication.
