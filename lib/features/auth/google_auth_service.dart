import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../core/network/api_client.dart';

class GoogleAuthService {
  static Future<void>? _initialization;
  static const enabled = bool.fromEnvironment('CHERRY_GOOGLE_AUTH_ENABLED');
  static const serverClientId = String.fromEnvironment(
    'GOOGLE_SERVER_CLIENT_ID',
  );
  static const iosClientId = String.fromEnvironment('GOOGLE_IOS_CLIENT_ID');

  Future<void> signIn(ApiClient api) async {
    if (!enabled || serverClientId.isEmpty) {
      throw const ApiException(
        'Google sign-in is not available yet. Please sign in with your email or create an account.',
      );
    }
    if (kIsWeb ||
        ![
          TargetPlatform.iOS,
          TargetPlatform.android,
        ].contains(defaultTargetPlatform)) {
      throw const ApiException(
        'Google sign-in is available in the configured Android and iOS app. Please use email in this preview.',
      );
    }
    if (defaultTargetPlatform == TargetPlatform.iOS && iosClientId.isEmpty) {
      throw const ApiException(
        'Google sign-in is not configured for this iOS build. Please use email.',
      );
    }
    try {
      _initialization ??= GoogleSignIn.instance
          .initialize(
            serverClientId: serverClientId,
            clientId: defaultTargetPlatform == TargetPlatform.iOS
                ? iosClientId
                : null,
          )
          .catchError((Object error) {
            _initialization = null;
            throw error;
          });
      await _initialization;
      final account = await GoogleSignIn.instance.authenticate();
      final token = account.authentication.idToken;
      if (token == null || token.isEmpty) {
        throw const ApiException(
          'Google did not return a sign-in token. Please retry.',
        );
      }
      await api.googleLogin(token);
    } on GoogleSignInException catch (e) {
      throw ApiException(
        e.code == GoogleSignInExceptionCode.canceled
            ? 'Google sign-in was cancelled.'
            : 'Google sign-in could not be completed. Please try again or use email.',
      );
    }
  }
}
