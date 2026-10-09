import 'package:cherry_money_mobile/core/config/app_config.dart';
import 'package:cherry_money_mobile/core/network/api_client.dart';
import 'package:cherry_money_mobile/data/repositories/workspace.dart';
import 'package:cherry_money_mobile/features/auth/mobile_mfa_screen.dart';
import 'package:cherry_money_mobile/features/auth/login_screen.dart';
import 'package:cherry_money_mobile/features/auth/google_sign_in_control.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'api_client_test.dart' show ContractAdapter, MemoryStorage, jsonResponse;

void main() {
  final challenge = List.filled(64, 'a').join();
  final pending = {
    'msg': 'two_factor_required',
    'challenge_token': challenge,
    'expires_in': 300,
  };

  for (final method in ['password', 'google', 'apple']) {
    test('$method waits for MFA without saving challenge as session', () async {
      final storage = MemoryStorage()..token = 'old-token';
      final api = ApiClient(const AppConfig(), storage);
      final workspace = Workspace(api: api);
      var requests = 0;
      api.dio.httpClientAdapter = ContractAdapter((request) {
        requests++;
        expect(request.headers.containsKey('Authorization'), false);
        return jsonResponse(pending, 202);
      });
      switch (method) {
        case 'google':
          await workspace.loginWithGoogle('provider-token');
        case 'apple':
          await workspace.loginWithApple('provider-token');
        default:
          await workspace.login('person@example.test', 'password');
      }
      expect(workspace.mfaChallenge?.challengeToken, challenge);
      expect(workspace.signedIn, false);
      expect(workspace.hasAccess, false);
      expect(storage.token, isNull);
      expect(requests, 1);
      workspace.cancelMfa();
      expect(workspace.mfaChallenge, isNull);
      expect(requests, 1);
      workspace.dispose();
    });
  }

  test(
    'only successful challenge verification stores the access token',
    () async {
      final storage = MemoryStorage();
      final api = ApiClient(const AppConfig(), storage);
      api.dio.httpClientAdapter = ContractAdapter((request) {
        expect(request.path, 'two-factor/challenge');
        expect(request.data, {'challenge_token': challenge, 'code': '123456'});
        expect(request.headers.containsKey('Authorization'), false);
        return jsonResponse({'msg': 'error', 'error': 'Invalid code'}, 422);
      });
      await expectLater(
        api.verifyMfa(challenge, '123456'),
        throwsA(isA<ApiException>()),
      );
      expect(storage.token, isNull);
      api.dio.httpClientAdapter = ContractAdapter(
        (_) => jsonResponse({
          'msg': 'done',
          'token': 'verified-session',
          'user': {'name': 'Test'},
        }),
      );
      await api.verifyMfa(challenge, '123456');
      expect(storage.token, 'verified-session');
    },
  );

  test('expired pending challenge requires a new sign-in', () async {
    final api = ApiClient(const AppConfig(), MemoryStorage());
    final workspace = Workspace(api: api);
    workspace.mfaChallenge = MobileMfaRequired(
      challenge,
      DateTime.now().subtract(const Duration(seconds: 1)),
    );
    await workspace.verifyMfa('123456');
    expect(workspace.mfaChallenge, isNull);
    expect(workspace.signedIn, false);
    expect(workspace.error, contains('expired'));
    workspace.dispose();
  });

  test('malformed challenge is rejected as an invalid response', () {
    expect(
      () => MobileMfaRequired.fromResponse({
        ...pending,
        'challenge_token': 'bad',
      }),
      throwsA(isA<ApiException>()),
    );
  });

  testWidgets('cancelling social MFA unlocks the sign-in controls', (
    tester,
  ) async {
    final api = ApiClient(const AppConfig(), MemoryStorage());
    api.dio.httpClientAdapter = ContractAdapter(
      (_) => jsonResponse(pending, 202),
    );
    final workspace = Workspace(api: api);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [workspaceProvider.overrideWith((ref) => workspace)],
        child: const MaterialApp(home: LoginScreen()),
      ),
    );
    final social = tester.widget<GoogleSignInControl>(
      find.byType(GoogleSignInControl),
    );
    social.onBusyChanged(true);
    await social.onToken('provider-token');
    await tester.pump();
    expect(find.byType(MobileMfaScreen), findsOneWidget);
    await tester.tap(find.text('Cancel sign-in'));
    await tester.pump();
    expect(find.byType(MobileMfaScreen), findsNothing);
    expect(
      tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
      isNotNull,
    );
    expect(workspace.signedIn, false);
  });

  testWidgets('MFA screen validates six digits and supports cancellation', (
    tester,
  ) async {
    String? submitted;
    var cancelled = false;
    await tester.pumpWidget(
      MaterialApp(
        home: MobileMfaScreen(
          busy: false,
          error: '',
          onVerify: (code) async {
            submitted = code;
          },
          onCancel: () {
            cancelled = true;
          },
        ),
      ),
    );
    await tester.tap(find.text('Verify and sign in'));
    await tester.pump();
    expect(find.text('Enter the six-digit code'), findsOneWidget);
    expect(submitted, isNull);
    await tester.enterText(find.byType(TextFormField), '123456');
    await tester.tap(find.text('Verify and sign in'));
    await tester.pump();
    expect(submitted, '123456');
    await tester.tap(find.text('Cancel sign-in'));
    expect(cancelled, true);
  });
}
