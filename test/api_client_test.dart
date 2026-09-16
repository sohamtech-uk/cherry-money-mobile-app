import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cherry_money_mobile/core/config/app_config.dart';
import 'package:cherry_money_mobile/core/network/api_client.dart';
import 'package:cherry_money_mobile/core/storage/secure_storage_service.dart';

class MemoryStorage extends SecureStorageService {
  String? token;
  @override
  Future<String?> readToken() async => token;
  @override
  Future<void> saveToken(String value) async {
    token = value;
  }

  @override
  Future<void> clear() async {
    token = null;
  }
}

class ContractAdapter implements HttpClientAdapter {
  final ResponseBody Function(RequestOptions) respond;
  ContractAdapter(this.respond);
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async => respond(options);
  @override
  void close({bool force = false}) {}
}

ResponseBody jsonResponse(Object body, [int status = 200]) =>
    ResponseBody.fromString(
      jsonEncode(body),
      status,
      headers: {
        Headers.contentTypeHeader: ['application/json'],
      },
    );
void main() {
  test(
    'login uses confirmed payload and stores token without forwarding old bearer',
    () async {
      final storage = MemoryStorage()..token = 'previous';
      final api = ApiClient(const AppConfig(), storage);
      api.dio.httpClientAdapter = ContractAdapter((request) {
        expect(request.path, 'login');
        expect(request.method, 'POST');
        expect(request.data, {
          'email': 'person@example.test',
          'password': 'example',
        });
        expect(request.headers.containsKey('Authorization'), false);
        return jsonResponse({
          'msg': 'done',
          'token': 'synthetic-token',
          'user': {'name': 'Demo'},
        });
      });
      expect(
        (await api.login('person@example.test', 'example'))['name'],
        'Demo',
      );
      expect(storage.token, 'synthetic-token');
    },
  );
  test('dashboard attaches bearer and unwraps data', () async {
    final storage = MemoryStorage()..token = 'synthetic-token';
    final api = ApiClient(const AppConfig(), storage);
    api.dio.httpClientAdapter = ContractAdapter((request) {
      expect(request.path, 'homepage');
      expect(request.headers['Authorization'], 'Bearer synthetic-token');
      return jsonResponse({
        'data': {
          'overview': {'invoice': 4},
        },
      });
    });
    expect((await api.dashboard())['overview']['invoice'], 4);
  });
  test('failed logout still removes local credentials', () async {
    final storage = MemoryStorage()..token = 'synthetic-token';
    final api = ApiClient(const AppConfig(), storage);
    api.dio.httpClientAdapter = ContractAdapter(
      (request) => jsonResponse({'error': 'unavailable'}, 503),
    );
    await expectLater(api.logout(), throwsA(isA<DioException>()));
    expect(storage.token, isNull);
  });
  test('invalid login does not persist a returned token', () async {
    final storage = MemoryStorage();
    final api = ApiClient(const AppConfig(), storage);
    api.dio.httpClientAdapter = ContractAdapter(
      (request) => jsonResponse({'msg': 'error', 'token': 'invalid'}),
    );
    await expectLater(
      api.login('person@example.test', 'wrong'),
      throwsA(isA<ApiException>()),
    );
    expect(storage.token, isNull);
  });
}
