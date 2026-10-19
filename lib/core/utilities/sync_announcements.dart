import 'package:flutter/semantics.dart';
import 'package:get/get.dart';

void announceSyncState(String message) {
  if (Get.testMode) return;
  SemanticsService.announce(message, TextDirection.ltr);
}
