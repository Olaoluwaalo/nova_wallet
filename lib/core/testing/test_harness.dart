import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:nova/core/bindings/initial_binding.dart';
import 'package:nova/core/constants/app_constants.dart';
import 'package:nova/core/routes/app_pages.dart';
import 'package:nova/core/services/connectivity_service.dart';
import 'package:nova/core/services/local_storage_service.dart';
import 'package:nova/features/wallet/data/datasources/mock_novapay_api.dart';
import 'package:nova/features/wallet/presentation/controllers/wallet_bindings.dart';
import 'package:nova/features/wallet/presentation/pages/wallet_home_screen.dart';
import 'package:nova/l10n/app_localizations.dart';

Future<void> setupNovaTest({
  required LocalStorageService storage,
  required MockNovaPayApi api,
  ConnectivityService? connectivity,
}) async {
  Get.reset();
  Get.testMode = true;
  if (!storage.isInitialized) {
    await storage.init();
  }
  await api.seedIfEmpty();
  Get.put(storage, permanent: true);
  Get.put(api, permanent: true);
  final conn = connectivity ?? FakeConnectivityService(online: true);
  Get.put<ConnectivityService>(conn, permanent: true);
  InitialBinding(storage: storage, connectivity: conn, api: api).dependencies();
  WalletBindings().dependencies();
}

Widget buildTestApp({String initialRoute = WalletHomeScreen.path}) {
  return ScreenUtilInit(
    designSize: AppConstants.designSize,
    minTextAdapt: true,
    builder: (context, child) => GetMaterialApp(
      initialRoute: initialRoute,
      getPages: AppPages.appPages,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
    ),
  );
}

Future<void> pumpNovaApp(
  WidgetTester tester, {
  String initialRoute = WalletHomeScreen.path,
}) async {
  tester.view.physicalSize = const Size(1170, 2532);
  tester.view.devicePixelRatio = 3.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(buildTestApp(initialRoute: initialRoute));
  await tester.pump();
}
