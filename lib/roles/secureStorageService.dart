import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  final FlutterSecureStorage _storage = FlutterSecureStorage();

  Future<void> saveUserData(String key, String uid) async {
    await _storage.write(key: key, value: uid);
  }

  Future<void> clearUserData(String key) async {
    await _storage.delete(key: key);
  }
}

