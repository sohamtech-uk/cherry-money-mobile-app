import 'package:cherry_money_mobile/core/config/app_config.dart';
import 'package:cherry_money_mobile/core/network/api_client.dart';
import 'package:cherry_money_mobile/features/auth/account_screen.dart';
import 'package:cherry_money_mobile/features/auth/apple_auth_service.dart';
import 'package:cherry_money_mobile/features/auth/google_auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'api_client_test.dart' show MemoryStorage, ContractAdapter, jsonResponse;

void main() {
  test(
    'signup requires consent before sending and handles company object',
    () async {
      final storage = MemoryStorage()..token = 'old-session';
      final api = ApiClient(const AppConfig(), storage);
      int requests = 0;
      api.dio.httpClientAdapter = ContractAdapter((request) {
        requests++;
        expect(request.path, 'signup');
        expect(request.headers.containsKey('Authorization'), false);
        expect(request.data['terms_accepted'], true);
        return jsonResponse({
          'msg': 'done',
          'user': {'id': 42},
          'email_sent': true,
        });
      });
      await expectLater(
        api.signup({'terms_accepted': false}),
        throwsA(isA<ApiException>()),
      );
      expect(requests, 0);
      expect(await api.signup({'terms_accepted': true}), '42');
      expect(storage.token, 'old-session');
    },
  );
  test('verification stores session only with valid user and token', () async {
    final storage = MemoryStorage();
    final api = ApiClient(const AppConfig(), storage);
    api.dio.httpClientAdapter = ContractAdapter((request) {
      expect(request.path, 'verifyOtp');
      expect(request.data, {'id': '42', 'otp': '123456'});
      return jsonResponse({
        'msg': 'done',
        'token': 'verified',
        'user': {'name': 'Test'},
      });
    });
    await api.verifyOtp('42', '123456');
    expect(storage.token, 'verified');
    storage.token = null;
    api.dio.httpClientAdapter = ContractAdapter(
      (_) => jsonResponse({'msg': 'done', 'token': 'bad'}),
    );
    await expectLater(
      api.verifyOtp('42', '123456'),
      throwsA(isA<ApiException>()),
    );
    expect(storage.token, isNull);
  });
  test('validation and reset email failures are surfaced', () async {
    final api = ApiClient(const AppConfig(), MemoryStorage());
    api.dio.httpClientAdapter = ContractAdapter(
      (_) => jsonResponse({
        'msg': 'error',
        'error': 'Use your business email.',
      }, 422),
    );
    await expectLater(
      api.signup({'terms_accepted': true}),
      throwsA(
        isA<ApiException>().having(
          (e) => e.message,
          'message',
          'Use your business email.',
        ),
      ),
    );
    api.dio.httpClientAdapter = ContractAdapter(
      (_) => jsonResponse({'msg': 'done', 'email_sent': false}),
    );
    await expectLater(
      api.forgot('test@example.test'),
      throwsA(isA<ApiException>()),
    );
  });
  test(
    'Google sends signed token only; unconfigured sign-in sends nothing',
    () async {
      final api = ApiClient(const AppConfig(), MemoryStorage());
      int requests = 0;
      api.dio.httpClientAdapter = ContractAdapter((request) {
        requests++;
        expect(request.data, {'id_token': 'signed-token'});
        return jsonResponse({
          'msg': 'done',
          'token': 'session',
          'user': {'name': 'Test'},
        });
      });
      await expectLater(
        GoogleAuthService().authenticate(),
        throwsA(isA<ApiException>()),
      );
      expect(requests, 0);
      await api.googleLogin('signed-token');
      expect(requests, 1);
    },
  );
  test(
    'Apple sends signed token only; unconfigured sign-in sends nothing',
    () async {
      final api = ApiClient(const AppConfig(), MemoryStorage());
      int requests = 0;
      api.dio.httpClientAdapter = ContractAdapter((request) {
        requests++;
        expect(request.data, {'id_token': 'signed-token'});
        return jsonResponse({
          'msg': 'done',
          'token': 'session',
          'user': {'name': 'Test'},
        });
      });
      await expectLater(
        AppleAuthService().authenticate(),
        throwsA(isA<ApiException>()),
      );
      expect(requests, 0);
      await api.appleLogin('signed-token');
      expect(requests, 1);
    },
  );
  testWidgets(
    'create account stays disabled until terms accepted; validates fields',
    (tester) async {
      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: AccountScreen())),
      );
      final create = find.widgetWithText(FilledButton, 'Create account');
      expect(tester.widget<FilledButton>(create).onPressed, isNull);
      await tester.ensureVisible(find.byType(CheckboxListTile));
      await tester.tap(find.byType(CheckboxListTile));
      await tester.pump();
      expect(tester.widget<FilledButton>(create).onPressed, isNotNull);
      await tester.ensureVisible(create);
      await tester.tap(create);
      await tester.pump();
      expect(find.text('Enter Company name'), findsOneWidget);
      expect(find.text('Enter Business email'), findsOneWidget);
      expect(find.text('Enter Choose password'), findsOneWidget);
    },
  );
}
