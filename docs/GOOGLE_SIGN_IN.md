# Google sign-in activation

Flutter supports Android, iOS and the browser. Google returns an ID token; Cherry's backend verifies it and returns a Cherry session. A Google SDK success alone never grants access to the app.

## Backend prerequisite

Deploy [backend PR #186](https://github.com/sohamtech-uk/cherrymoney/pull/186), including the `users.google_subject` migration. Set `GOOGLE_MOBILE_SERVER_CLIENT_ID` to the same **Web OAuth client ID** used by Flutter's `GOOGLE_SERVER_CLIENT_ID`, then refresh Laravel's configuration cache. This endpoint requires an existing, active Cherry account with a verified company. New users complete signup, Terms acceptance and email verification first.

Do not enable this build against the old profile-only Google endpoint. This mobile PR does not deploy backend changes or alter Google Cloud settings.

## Browser

1. In the Google Cloud project's Web OAuth client, register the app's exact JavaScript origins. For this preview use `http://localhost` and `http://localhost:8765`, and open the preview using `localhost`. Register each production HTTPS origin separately. An authorized redirect URI is not a substitute for a JavaScript origin.
2. Configure the OAuth consent screen and test users if the client is in testing mode.
3. Build with the public client ID (never a client secret):

   ```sh
   flutter build web --no-wasm-dry-run \
     --dart-define=CHERRY_GOOGLE_AUTH_ENABLED=true \
     --dart-define=GOOGLE_SERVER_CLIENT_ID=YOUR_WEB_CLIENT_ID.apps.googleusercontent.com
   python3 -m http.server 8765 --directory build/web
   ```

4. Open `http://localhost:8765/#/login`, click Google's button and choose an authorized test account. Verify the Cherry overview loads and logout clears the Cherry session. Check the API's CORS policy permits the browser origin.

The client ID is passed directly to SDK initialization. No second client ID in `web/index.html` is needed. The browser uses Google's rendered button and authentication events, as required by the [Flutter web plugin](https://pub.dev/packages/google_sign_in_web). It never calls the unsupported web `authenticate()` method. Login events are unsubscribed on navigation; duplicate events while a token exchange is pending are ignored. SDK failures have a retry action; backend failures remain visible with email sign-in available.

## Native apps

Android needs an OAuth Android client for `uk.co.cherrymoney.mobile` and its actual signing certificate. iOS needs its OAuth client and reversed-client-ID URL scheme in `ios/Runner/Info.plist`. Use the two build flags above, plus `GOOGLE_IOS_CLIENT_ID` for iOS. Follow the [platform setup instructions](https://pub.dev/packages/google_sign_in).

## Default preview

Without these settings, the Google button is disabled and explains that email sign-in/signup are available. No authentication attempt or token exchange is started (the web plugin may still load Google’s SDK script during registration). This is a configuration state, not evidence that live Google OAuth has passed validation. Keep the enable flag false until the backend and OAuth origins/clients are ready.

## Logo rendering

The original supplied Cherry Money logo remains unchanged. `CherryLogo` multiplies its colors against the current scaffold background while rendering, so the white rectangle matches the warm page surface across welcome, login, signup, reset and the app header.
