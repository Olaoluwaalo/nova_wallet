import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:nova/app.dart';
import 'package:nova/core/services/local_storage_service.dart';
import 'package:nova/core/services/notification_service.dart';
import 'package:nova/core/services/secure_storage_service.dart';
import 'package:nova/features/wallet/data/datasources/mock_novapay_api.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  final secureStorage = SecureStorageService();
  await secureStorage.ensureMockAuthToken();

  final storage = LocalStorageService();
  await storage.init(secureStorage: secureStorage);

  final api = MockNovaPayApi(storage: storage);
  await api.seedIfEmpty();

  Get.put(secureStorage, permanent: true);
  Get.put(storage, permanent: true);
  Get.put(api, permanent: true);

  final notifications = NotificationService();
  await notifications.init();
  Get.put(notifications, permanent: true);

  runApp(const NovaApp());
}
