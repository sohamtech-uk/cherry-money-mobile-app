import 'package:cherry_money_mobile/core/config/app_config.dart';
import 'package:cherry_money_mobile/core/network/api_client.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'api_client_test.dart' show ContractAdapter, MemoryStorage, jsonResponse;

void main() {
  final cases = <(int, Map<String, dynamic>, String)>[
    (
      503,
      {'message': 'Google sign-in is not configured.'},
      'Google sign-in is not ready on the server yet. Please use email or try again later.',
    ),
    (
      422,
      {
        'message': 'The given data was invalid.',
        'errors': {
          'id_token': ['Google could not verify this account.'],
        },
      },
      'Google could not verify this account.',
    ),
    (
      403,
      {'message': 'This account is not available for sign-in.'},
      'This account is not available for sign-in.',
    ),
    (
      429,
      {'message': 'Too Many Attempts.'},
      'Too many sign-in attempts. Please wait a moment before trying again.',
    ),
    (
      500,
      {
        'message': 'SQLSTATE private exception details',
        'error': 'Private debug details',
      },
      'The Cherry Money service is temporarily unavailable. Please try again later.',
    ),
  ];
  for (final (status, body, message) in cases) {
    test(
      'Google HTTP $status reports the right problem without saving a session',
      () async {
        final storage = MemoryStorage();
        final api = ApiClient(const AppConfig(), storage);
        api.dio.httpClientAdapter = ContractAdapter(
          (_) => jsonResponse(body, status),
        );
        await expectLater(
          api.googleLogin('test-token'),
          throwsA(
            isA<ApiException>().having((e) => e.message, 'message', message),
          ),
        );
        expect(storage.token, isNull);
      },
    );
  }
  test(
    'Apple HTTP 422 reports the returned problem without saving a session',
    () async {
      final storage = MemoryStorage();
      final api = ApiClient(const AppConfig(), storage);
      api.dio.httpClientAdapter = ContractAdapter(
        (_) => jsonResponse({
          'message': 'The given data was invalid.',
          'errors': {
            'id_token': ['Apple could not verify this account.'],
          },
        }, 422),
      );
      await expectLater(
        api.appleLogin('test-token'),
        throwsA(
          isA<ApiException>().having(
            (e) => e.message,
            'message',
            'Apple could not verify this account.',
          ),
        ),
      );
      expect(storage.token, isNull);
    },
  );
  for (final provider in ['Google', 'Email', 'Apple']) {
    test(
      '$provider transport failure is distinct from backend rejection',
      () async {
        final api = ApiClient(const AppConfig(), MemoryStorage());
        api.dio.httpClientAdapter = ContractAdapter(
          (request) => throw DioException(
            requestOptions: request,
            type: DioExceptionType.connectionError,
          ),
        );
        final call = switch (provider) {
          'Google' => api.googleLogin('test-token'),
          'Apple' => api.appleLogin('test-token'),
          _ => api.login('example@example.test', 'test-password'),
        };
        await expectLater(
          call,
          throwsA(
            isA<ApiException>().having(
              (e) => e.message,
              'message',
              'Cannot reach Cherry Money right now. Please check your connection and try again.',
            ),
          ),
        );
      },
    );
  }
}
