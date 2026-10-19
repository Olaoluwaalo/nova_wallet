import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:nova/core/bindings/initial_binding.dart';
import 'package:nova/core/constants/app_constants.dart';
import 'package:nova/core/lifecycle/app_lifecycle_sync.dart';
import 'package:nova/core/routes/app_pages.dart';
import 'package:nova/core/theme/app_theme.dart';
import 'package:nova/features/wallet/presentation/pages/wallet_home_screen.dart';
import 'package:nova/l10n/app_localizations.dart';

class NovaApp extends StatefulWidget {
  const NovaApp({super.key});

  @override
  State<NovaApp> createState() => _NovaAppState();
}

class _NovaAppState extends State<NovaApp> {
  final AppLifecycleSync _lifecycleSync = AppLifecycleSync();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(_lifecycleSync);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(_lifecycleSync);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: AppConstants.designSize,
      minTextAdapt: true,
      builder: (context, child) {
        return GetMaterialApp(
          title: AppConstants.appName,
          debugShowCheckedModeBanner: false,
          initialBinding: InitialBinding(),
          initialRoute: WalletHomeScreen.path,
          getPages: AppPages.appPages,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          theme: AppTheme.light,
          builder: (context, widget) {
            final mediaQuery = MediaQuery.of(context);
            return MediaQuery(
              data: mediaQuery.copyWith(textScaler: mediaQuery.textScaler.clamp(minScaleFactor: 1, maxScaleFactor: 2.0)),
              child: widget ?? const SizedBox.shrink(),
            );
          },
        );
      },
    );
  }
}
