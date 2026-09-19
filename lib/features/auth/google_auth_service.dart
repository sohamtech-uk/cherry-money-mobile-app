import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../core/network/api_client.dart';

class GoogleAuthService {
  const GoogleAuthService();

  static Future<void>? _initialization;
  static const enabled = bool.fromEnvironment('CHERRY_GOOGLE_AUTH_ENABLED');
  static const serverClientId = String.fromEnvironment(
    'GOOGLE_SERVER_CLIENT_ID',
    // Public Web OAuth client ID; no client secret belongs in the app.
    defaultValue:
        '996173642915-dvk7ac9old9oqj946uote1hr1plvkba0.apps.googleusercontent.com',
  );
  static const iosClientId = String.fromEnvironment('GOOGLE_IOS_CLIENT_ID');

  bool get usesWebButton => kIsWeb;
  bool get configured =>
      enabled &&
      serverClientId.isNotEmpty &&
      (kIsWeb ||
          defaultTargetPlatform == TargetPlatform.android ||
          (defaultTargetPlatform == TargetPlatform.iOS &&
              iosClientId.isNotEmpty));

  Future<void> initialize() async {
    if (!configured) {
      throw const ApiException('Google sign-in is not enabled in this build.');
    }
    // The browser client and native server client use the same Web OAuth ID,
    // which must match the audience verified by the Cherry backend.
    _initialization ??= GoogleSignIn.instance
        .initialize(
          clientId: kIsWeb
              ? serverClientId
              : defaultTargetPlatform == TargetPlatform.iOS
              ? iosClientId
              : null,
          serverClientId: kIsWeb ? null : serverClientId,
        )
        .catchError((Object error) {
          _initialization = null;
          throw error;
        });
    await _initialization;
  }

  Stream<String> get tokens => GoogleSignIn.instance.authenticationEvents
      .where((event) => event is GoogleSignInAuthenticationEventSignIn)
      .map(
        (event) =>
            _token((event as GoogleSignInAuthenticationEventSignIn).user),
      );

  Future<String> authenticate() async {
    await initialize();
    if (usesWebButton) {
      throw const ApiException('Use the Google sign-in button to continue.');
    }
    return _token(await GoogleSignIn.instance.authenticate());
  }

  String _token(GoogleSignInAccount account) {
    final token = account.authentication.idToken;
    if (token == null || token.isEmpty) {
      throw const ApiException(
        'Google did not return a sign-in token. Please retry.',
      );
    }
    return token;
  }

  static String errorMessage(Object error) {
    if (error is ApiException) return error.message;
    if (error is GoogleSignInException) {
      if (kDebugMode) debugPrint('Google sign-in failed: $error');
      switch (error.code) {
        case GoogleSignInExceptionCode.canceled:
          return 'Google sign-in was cancelled. You can try again or use email.';
        case GoogleSignInExceptionCode.clientConfigurationError:
        case GoogleSignInExceptionCode.providerConfigurationError:
          return 'Google sign-in is not configured for this app version. Please use email while the app setup is updated.';
        case GoogleSignInExceptionCode.uiUnavailable:
          return 'Google sign-in is unavailable on this device. Check Google Play services or use email.';
        case GoogleSignInExceptionCode.interrupted:
          return 'Google sign-in was interrupted. Please try again or use email.';
        default:
          break;
      }
    }
    return 'Google sign-in could not be completed. Please try again or use email.';
  }
}
