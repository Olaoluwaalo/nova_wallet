import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive/hive.dart';
import 'package:nova/core/constants/storage_keys.dart';

class SecureStorageService {
  SecureStorageService({FlutterSecureStorage? storage})
      : _storage = storage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(encryptedSharedPreferences: true),
            );

  final FlutterSecureStorage _storage;

  Future<void> ensureMockAuthToken() async {
    final existing = await _storage.read(key: StorageKeys.mockAuthToken);
    if (existing == null) {
      await _storage.write(key: StorageKeys.mockAuthToken, value: 'nova_mock_session_token');
    }
  }

  Future<String?> readMockAuthToken() => _storage.read(key: StorageKeys.mockAuthToken);

  Future<List<int>> getOrCreateHiveKey() async {
    final encoded = await _storage.read(key: StorageKeys.hiveEncryptionKey);
    if (encoded != null) {
      return base64Decode(encoded);
    }
    final key = Hive.generateSecureKey();
    await _storage.write(key: StorageKeys.hiveEncryptionKey, value: base64Encode(key));
    return key;
  }
}
