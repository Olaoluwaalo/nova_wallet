import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:nova/core/offline/sync_controller.dart';

class AppLifecycleSync extends WidgetsBindingObserver {
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && Get.isRegistered<SyncController>()) {
      Get.find<SyncController>().syncPending();
    }
  }
}
