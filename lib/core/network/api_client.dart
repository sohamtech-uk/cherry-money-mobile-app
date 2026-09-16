import 'package:dio/dio.dart';
import '../config/app_config.dart';
import '../storage/secure_storage_service.dart';

class ApiException implements Exception {
  final String message;
  const ApiException(this.message);
}

class ApiClient {
  final Dio dio;
  final SecureStorageService storage;
  ApiClient(AppConfig config, this.storage)
    : dio = Dio(
        BaseOptions(
          baseUrl: config.apiBaseUrl,
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 25),
          headers: {'Accept': 'application/json'},
        ),
      ) {
    if (!config.valid) {
      throw const ApiException('Use a valid HTTPS Cherry API configuration.');
    }
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          try {
            final token = await storage.readToken();
            if (token != null && options.path != 'login') {
              options.headers['Authorization'] = 'Bearer $token';
            }
            handler.next(options);
          } catch (_) {
            handler.reject(
              DioException(
                requestOptions: options,
                error: 'Secure storage unavailable',
              ),
            );
          }
        },
      ),
    );
  }
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await dio.post(
        'login',
        data: {'email': email, 'password': password},
      );
      final data = Map<String, dynamic>.from(response.data as Map);
      if (data['msg'] != 'done' ||
          data['token'] is! String ||
          (data['token'] as String).isEmpty) {
        throw const ApiException(
          'Sign-in failed. Check your email and password.',
        );
      }
      await storage.saveToken(data['token'] as String);
      return Map<String, dynamic>.from(data['user'] as Map);
    } on ApiException {
      rethrow;
    } catch (_) {
      throw const ApiException(
        'Unable to sign in. Check your connection and try again.',
      );
    }
  }

  Future<Map<String, dynamic>> dashboard() async {
    try {
      return Map<String, dynamic>.from(
        (await dio.get('homepage')).data['data'] as Map,
      );
    } catch (_) {
      throw const ApiException(
        'Your account overview could not be loaded. Please retry or sign in again.',
      );
    }
  }

  Future<void> logout() async {
    try {
      await dio.get('logout');
    } finally {
      await storage.clear();
    }
  }
}
