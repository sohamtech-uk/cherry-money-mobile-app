import 'package:dio/dio.dart';
import '../config/app_config.dart';
import '../hmrc/hmrc_fraud_prevention.dart';
import '../storage/secure_storage_service.dart';

class ApiException implements Exception {
  final String message;
  const ApiException(this.message);
}

/// A pending first-factor sign-in. Kept in memory; never stored as an access token.
class MobileMfaRequired extends ApiException {
  final String challengeToken;
  final DateTime expiresAt;

  MobileMfaRequired(this.challengeToken, this.expiresAt)
    : super('Enter the code from your authenticator app.');

  factory MobileMfaRequired.fromResponse(Map<String, dynamic> data) {
    final token = data['challenge_token'];
    final seconds = data['expires_in'];
    if (token is! String ||
        !RegExp(r'^[a-f0-9]{64}$').hasMatch(token) ||
        seconds is! int ||
        seconds < 1 ||
        seconds > 300) {
      throw const ApiException(
        'Sign-in returned an invalid authenticator request. Please retry.',
      );
    }
    return MobileMfaRequired(
      token,
      DateTime.now().add(Duration(seconds: seconds)),
    );
  }
}

class ApiClient {
  final Dio dio;
  final SecureStorageService storage;
  final HmrcFraudPreventionHeaders hmrcFraudPrevention;
  ApiClient(
    AppConfig config,
    this.storage, {
    HmrcFraudPreventionHeaders? hmrcFraudPrevention,
  }) : hmrcFraudPrevention =
           hmrcFraudPrevention ?? HmrcFraudPreventionService(storage),
       dio = Dio(
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
            if (_usesHmrcFraudPrevention(options.path)) {
              options.headers.addAll(await this.hmrcFraudPrevention.headers());
            }
            final token = await storage.readToken();
            if (token != null &&
                !const {
                  'login',
                  'signup',
                  'forgot',
                  'verifyOtp',
                  'resendCode',
                  'loginGoogle',
                  'loginApple',
                  'two-factor/challenge',
                }.contains(options.path)) {
              options.headers['Authorization'] = 'Bearer $token';
            }
            handler.next(options);
          } catch (_) {
            handler.reject(
              DioException(
                requestOptions: options,
                error: _usesHmrcFraudPrevention(options.path)
                    ? 'Required HMRC fraud-prevention data is unavailable'
                    : 'Secure storage unavailable',
              ),
            );
          }
        },
      ),
    );
  }

  bool _usesHmrcFraudPrevention(String path) {
    final normalised = path.startsWith('/') ? path.substring(1) : path;
    return normalised.startsWith('tax/hmrc/');
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    final data = await authRequest('login', {
      'email': email,
      'password': password,
    });
    await acceptSession(data);
    return Map<String, dynamic>.from(data['user'] as Map);
  }

  Future<void> verifyMfa(String challengeToken, String code) async {
    await acceptSession(
      await authRequest('two-factor/challenge', {
        'challenge_token': challengeToken,
        'code': code.trim(),
      }),
    );
  }

  Future<Map<String, dynamic>> authRequest(
    String path,
    Map<String, dynamic> payload,
  ) async {
    try {
      final response = await dio.post(path, data: payload);
      final data = Map<String, dynamic>.from(response.data as Map);
      if (data['msg'] == 'two_factor_required') {
        final challenge = MobileMfaRequired.fromResponse(data);
        await storage.clear();
        throw challenge;
      }
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
      throw ApiException(_authFailure(e));
    } catch (_) {
      throw const ApiException('Unexpected response. Please try again.');
    }
  }

  String _authFailure(DioException failure) {
    final response = failure.response;
    if (response == null) {
      return 'Cannot reach Cherry Money right now. Please check your connection and try again.';
    }
    final status = response.statusCode ?? 0;
    final body = response.data;
    if (status == 503 &&
        body is Map &&
        body['message'] == 'Google sign-in is not configured.') {
      return 'Google sign-in is not ready on the server yet. Please use email or try again later.';
    }
    if (status >= 500) {
      // Server exception details must not be displayed as account errors.
      return 'The Cherry Money service is temporarily unavailable. Please try again later.';
    }
    if (status == 429) {
      return 'Too many sign-in attempts. Please wait a moment before trying again.';
    }
    if (body is Map && status >= 400 && status < 500) {
      if (body['error'] case final String message when message.isNotEmpty) {
        return message;
      }
      if (body['errors'] case final Map errors) {
        for (final value in errors.values) {
          if (value is List && value.isNotEmpty && value.first is String) {
            return value.first as String;
          }
        }
      }
      if (body['message'] case final String message when message.isNotEmpty) {
        return message;
      }
    }
    return 'Unable to complete sign-in. Please try again.';
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

  Future<void> appleLogin(String idToken) async {
    // Send only a signed token. Never trust a client-supplied email/profile.
    await acceptSession(await authRequest('loginApple', {'id_token': idToken}));
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

  /// Company-scoped finance requests. Only relative API routes are accepted.
  Future<Map<String, dynamic>> financeRequest(
    String path, {
    String method = 'GET',
    Map<String, dynamic>? data,
    Map<String, dynamic>? query,
    Map<String, String>? headers,
  }) async {
    if (path.startsWith('/') || path.contains('://') || path.contains('..')) {
      throw const ApiException('Invalid finance request.');
    }
    try {
      final response = await dio.request<dynamic>(
        path,
        data: data,
        queryParameters: query,
        options: Options(
          method: method,
          headers: headers,
          receiveTimeout: const Duration(seconds: 90),
        ),
      );
      if (response.data is! Map) {
        throw const ApiException(
          'Cherry returned an unexpected response. Please retry.',
        );
      }
      final result = Map<String, dynamic>.from(response.data as Map);
      if (result['msg'] == 'error' || result['success'] == false) {
        throw ApiException(
          result['error']?.toString() ??
              result['message']?.toString() ??
              'The request could not be completed.',
        );
      }
      return result;
    } on ApiException {
      rethrow;
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      if (status == 401) {
        throw const ApiException(
          'Your session has expired. Please sign in again.',
        );
      }
      if (status == 404) {
        throw const ApiException(
          'This feature is not available on the server yet. Please retry after the mobile update is deployed.',
        );
      }
      if (status == 429) {
        throw const ApiException(
          'Too many requests. Please wait a moment and retry.',
        );
      }
      final body = e.response?.data;
      if (body is Map && body['reply'] is String) {
        throw ApiException(body['reply'] as String);
      }
      throw ApiException(
        _authFailure(
          e,
        ).replaceAll('sign-in', 'request').replaceAll('sign in', 'continue'),
      );
    } catch (_) {
      throw const ApiException(
        'The request could not be completed. Please retry.',
      );
    }
  }

  Future<Map<String, dynamic>> askCherry(
    String message,
    List<Map<String, String>> history,
  ) => financeRequest(
    'webmcp/ask',
    method: 'POST',
    data: {
      'message': message,
      'history': history
          .skip(history.length > 10 ? history.length - 10 : 0)
          .map(
            (item) => {
              'role': item['role'],
              'content': (item['content'] ?? '').substring(
                0,
                (item['content'] ?? '').length.clamp(0, 2000),
              ),
            },
          )
          .toList(),
    },
  );

  Future<void> logout() async {
    try {
      await dio.get('logout');
    } finally {
      await storage.clear();
    }
  }
}
