import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../core/network/api_client.dart';

class GoogleAuthService {
  const GoogleAuthService();

  static Future<void>? _initialization;
  static const enabled = bool.fromEnvironment('CHERRY_GOOGLE_AUTH_ENABLED');
  static const serverClientId = String.fromEnvironment(
    'GOOGLE_SERVER_CLIENT_ID',
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
    if (error is GoogleSignInException &&
        error.code == GoogleSignInExceptionCode.canceled) {
      return 'Google sign-in was cancelled. You can try again or use email.';
    }
    return 'Google sign-in could not be completed. Please try again or use email.';
  }
}
