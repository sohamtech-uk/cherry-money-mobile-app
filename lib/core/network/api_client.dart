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
            if (token != null &&
                !const {
                  'login',
                  'signup',
                  'forgot',
                  'verifyOtp',
                  'resendCode',
                  'loginGoogle',
                }.contains(options.path)) {
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
          (data['token'] as String).isEmpty ||
          data['user'] is! Map) {
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

  Future<Map<String, dynamic>> authRequest(
    String path,
    Map<String, dynamic> payload,
  ) async {
    try {
      final response = await dio.post(path, data: payload);
      final data = Map<String, dynamic>.from(response.data as Map);
      if (data['msg'] != 'done') {
        throw ApiException(
          data['error'] is String
              ? data['error'] as String
              : 'Unable to complete this request. Please try again.',
        );
      }
      return data;
    } on ApiException {
      rethrow;
    } on DioException catch (e) {
      final body = e.response?.data;
      throw ApiException(
        body is Map && body['error'] is String
            ? body['error'] as String
            : 'Unable to connect. Please try again.',
      );
    } catch (_) {
      throw const ApiException('Unexpected response. Please try again.');
    }
  }

  Future<String> signup(Map<String, dynamic> fields) async {
    if (fields['terms_accepted'] != true) {
      throw const ApiException('Please agree to the Terms & Conditions.');
    }
    final data = await authRequest('signup', fields);
    final user = data['user'];
    final id = user is Map ? user['id'] : user;
    if (id == null) {
      throw const ApiException(
        'Missing verification reference. Please contact support.',
      );
    }
    return id.toString();
  }

  Future<bool> resendCode(String id) async =>
      (await authRequest('resendCode', {'id': id}))['email_sent'] != false;

  Future<String> forgot(String email) async {
    final data = await authRequest('forgot', {'email': email});
    if (data['email_sent'] == false) {
      throw const ApiException(
        'The reset email could not be sent. Please retry.',
      );
    }
    return data['message'] is String
        ? data['message'] as String
        : 'Check your email for a password reset link.';
  }

  Future<void> verifyOtp(String id, String otp) async {
    await acceptSession(await authRequest('verifyOtp', {'id': id, 'otp': otp}));
  }

  Future<void> googleLogin(String idToken) async {
    // Send only a signed token. Never trust a client-supplied email/profile.
    await acceptSession(
      await authRequest('loginGoogle', {'id_token': idToken}),
    );
  }

  Future<void> acceptSession(Map<String, dynamic> data) async {
    final token = data['token'];
    if (token is! String || token.isEmpty || data['user'] is! Map) {
      throw const ApiException(
        'Sign-in returned an invalid session. Please retry.',
      );
    }
    await storage.saveToken(token);
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
