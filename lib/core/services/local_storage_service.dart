import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:nova/core/constants/storage_keys.dart';
import 'package:nova/core/services/secure_storage_service.dart';

class LocalStorageService {
  Box<dynamic>? _walletBox;
  Box<dynamic>? _queueBox;
  Box<dynamic>? _apiStateBox;
  HiveAesCipher? _cipher;

  bool get isInitialized => _walletBox != null && _queueBox != null && _apiStateBox != null;

  Future<void> init({SecureStorageService? secureStorage, bool encrypt = true}) async {
    if (encrypt && secureStorage != null) {
      final key = await secureStorage.getOrCreateHiveKey();
      _cipher = HiveAesCipher(key);
    }
    _walletBox = await Hive.openBox(
      StorageKeys.hiveWalletBox,
      encryptionCipher: _cipher,
    );
    _queueBox = await Hive.openBox(
      StorageKeys.hiveOfflineQueueBox,
      encryptionCipher: _cipher,
    );
    _apiStateBox = await Hive.openBox(
      StorageKeys.hiveApiStateBox,
      encryptionCipher: _cipher,
    );
  }

  Future<void> initPlainForTests() async {
    _walletBox = await Hive.openBox(StorageKeys.hiveWalletBox);
    _queueBox = await Hive.openBox(StorageKeys.hiveOfflineQueueBox);
    _apiStateBox = await Hive.openBox(StorageKeys.hiveApiStateBox);
  }

  Box<dynamic> get walletBox {
    final box = _walletBox;
    if (box == null) throw StateError('LocalStorageService not initialized');
    return box;
  }

  Box<dynamic> get queueBox {
    final box = _queueBox;
    if (box == null) throw StateError('LocalStorageService not initialized');
    return box;
  }

  Box<dynamic> get apiStateBox {
    final box = _apiStateBox;
    if (box == null) throw StateError('LocalStorageService not initialized');
    return box;
  }

  Future<void> clearAll() async {
    if (_walletBox == null) {
      throw StateError('LocalStorageService not initialized');
    }
    await walletBox.clear();
    await queueBox.clear();
    await apiStateBox.clear();
  }

  Future<void> close() async {
    await _walletBox?.close();
    await _queueBox?.close();
    await _apiStateBox?.close();
    _walletBox = null;
    _queueBox = null;
    _apiStateBox = null;
  }
}
