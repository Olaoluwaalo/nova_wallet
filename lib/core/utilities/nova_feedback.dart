import 'package:get/get.dart';

void showNovaMessage(String title, String message) {
  if (Get.testMode || Get.context == null) {
    return;
  }
  Get.snackbar(title, message);
}
