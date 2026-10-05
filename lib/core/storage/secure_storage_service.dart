import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  final FlutterSecureStorage storage;
  const SecureStorageService([this.storage = const FlutterSecureStorage()]);
  Future<String?> readToken() => storage.read(key: 'cherry_session');
  Future<void> saveToken(String token) =>
      storage.write(key: 'cherry_session', value: token);
  Future<String?> readHmrcDeviceId() =>
      storage.read(key: 'cherry_hmrc_device_id');
  Future<void> saveHmrcDeviceId(String deviceId) =>
      storage.write(key: 'cherry_hmrc_device_id', value: deviceId);
  Future<void> clear() => storage.delete(key: 'cherry_session');
}
