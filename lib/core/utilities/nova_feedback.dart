import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:nova/shared/widgets/app_toast.dart';

ToastType toastTypeForTitle(String title) {
  final lower = title.toLowerCase();
  if (lower.contains('success')) return ToastType.success;
  if (lower.contains('failed') || lower.contains('invalid')) {
    return ToastType.error;
  }
  if (lower.contains('pending') || lower.contains('offline')) {
    return ToastType.warning;
  }
  return ToastType.info;
}

BuildContext? resolveNovaFeedbackContext() {
  return Get.overlayContext ?? Get.context;
}

void showNovaMessage(String title, String message) {
  if (Get.testMode) return;

  void present() {
    final context = resolveNovaFeedbackContext();
    if (context == null) return;

    AppToast.show(
      context,
      title: title,
      message: message,
      type: toastTypeForTitle(title),
    );
  }

  final phase = SchedulerBinding.instance.schedulerPhase;
  if (phase == SchedulerPhase.idle ||
      phase == SchedulerPhase.postFrameCallbacks) {
    present();
  } else {
    SchedulerBinding.instance.addPostFrameCallback((_) => present());
  }
}
