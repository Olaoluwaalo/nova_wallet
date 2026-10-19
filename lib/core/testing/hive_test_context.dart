import 'dart:io';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:nova/core/services/local_storage_service.dart';
import 'package:nova/features/wallet/data/datasources/mock_novapay_api.dart';

class HiveTestContext {
  HiveTestContext._({
    required this.storage,
    required this.api,
    required this.directory,
  });

  final LocalStorageService storage;
  final MockNovaPayApi api;
  final Directory directory;

  static Future<HiveTestContext> create({Duration apiLatency = Duration.zero}) async {
    final directory = await Directory.systemTemp.createTemp('nova_hive_');
    Hive.init(directory.path);
    final storage = LocalStorageService();
    await storage.initPlainForTests();
    final api = MockNovaPayApi(storage: storage, apiLatency: apiLatency);
    await api.seedIfEmpty();
    return HiveTestContext._(storage: storage, api: api, directory: directory);
  }

  Future<void> dispose() async {
    await storage.close();
    await Hive.close();
    if (await directory.exists()) {
      await directory.delete(recursive: true);
    }
  }
}
