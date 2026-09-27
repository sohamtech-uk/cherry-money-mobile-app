import 'package:flutter/foundation.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import '../../core/network/api_client.dart';

class AppleAuthService {
  const AppleAuthService();

  static const enabled = bool.fromEnvironment('CHERRY_APPLE_AUTH_ENABLED');

  bool get configured =>
      enabled &&
      (defaultTargetPlatform == TargetPlatform.iOS ||
          defaultTargetPlatform == TargetPlatform.macOS);

  Future<String> authenticate() async {
    if (!configured) {
      throw const ApiException('Apple sign-in is not enabled in this build.');
    }
    final credential = await SignInWithApple.getAppleIDCredential(
      scopes: const [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
    );
    final token = credential.identityToken;
    if (token == null || token.isEmpty) {
      throw const ApiException(
        'Apple did not return a sign-in token. Please retry.',
      );
    }
    return token;
  }

  static String errorMessage(Object error) {
    if (error is ApiException) return error.message;
    if (error is SignInWithAppleAuthorizationException) {
      if (kDebugMode) debugPrint('Apple sign-in failed: $error');
      switch (error.code) {
        case AuthorizationErrorCode.canceled:
          return 'Apple sign-in was cancelled. You can try again or use email.';
        case AuthorizationErrorCode.notHandled:
        case AuthorizationErrorCode.notInteractive:
        case AuthorizationErrorCode.invalidResponse:
          return 'Apple sign-in is not configured for this app version. Please use email while the app setup is updated.';
        case AuthorizationErrorCode.failed:
        case AuthorizationErrorCode.unknown:
        case AuthorizationErrorCode.credentialExport:
        case AuthorizationErrorCode.credentialImport:
        case AuthorizationErrorCode.matchedExcludedCredential:
          return 'Apple sign-in is unavailable right now. Please try again or use email.';
      }
    }
    return 'Apple sign-in could not be completed. Please try again or use email.';
  }
}
