import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cherry_money_mobile/core/config/app_config.dart';
import 'package:cherry_money_mobile/core/hmrc/hmrc_fraud_prevention.dart';
import 'package:cherry_money_mobile/core/network/api_client.dart';
import 'package:cherry_money_mobile/core/storage/secure_storage_service.dart';

class MemoryStorage extends SecureStorageService {
  String? token;
  String? hmrcDeviceId;
  @override
  Future<String?> readToken() async => token;
  @override
  Future<void> saveToken(String value) async {
    token = value;
  }

  @override
  Future<String?> readHmrcDeviceId() async => hmrcDeviceId;

  @override
  Future<void> saveHmrcDeviceId(String value) async {
    hmrcDeviceId = value;
  }

  @override
  Future<void> clear() async {
    token = null;
  }
}

class FixtureHmrcHeaders implements HmrcFraudPreventionHeaders {
  int calls = 0;
  @override
  Future<Map<String, String>> headers() async {
    calls++;
    return {
      'X-Cherry-HMRC-CONNECTION-METHOD': 'MOBILE_APP_VIA_SERVER',
      'X-Cherry-HMRC-DEVICE-ID': '3d8a8d57-1af9-4ccb-b87c-5bb7d05d9be7',
    };
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
  test('HMRC backend routes receive fresh mobile fraud telemetry', () async {
    final storage = MemoryStorage()..token = 'synthetic-token';
    final telemetry = FixtureHmrcHeaders();
    final api = ApiClient(
      const AppConfig(),
      storage,
      hmrcFraudPrevention: telemetry,
    );
    api.dio.httpClientAdapter = ContractAdapter((request) {
      expect(request.path, 'tax/hmrc/businesses');
      expect(
        request.headers['X-Cherry-HMRC-CONNECTION-METHOD'],
        'MOBILE_APP_VIA_SERVER',
      );
      expect(
        request.headers['X-Cherry-HMRC-DEVICE-ID'],
        '3d8a8d57-1af9-4ccb-b87c-5bb7d05d9be7',
      );
      return jsonResponse({'msg': 'done', 'data': <String, dynamic>{}});
    });

    await api.financeRequest('tax/hmrc/businesses');
    expect(telemetry.calls, 1);
  });
  test(
    'ordinary Cherry requests do not collect HMRC device telemetry',
    () async {
      final telemetry = FixtureHmrcHeaders();
      final api = ApiClient(
        const AppConfig(),
        MemoryStorage()..token = 'synthetic-token',
        hmrcFraudPrevention: telemetry,
      );
      api.dio.httpClientAdapter = ContractAdapter(
        (_) => jsonResponse({'msg': 'done', 'data': <String, dynamic>{}}),
      );

      await api.financeRequest('mobile/options');
      expect(telemetry.calls, 0);
    },
  );
}
