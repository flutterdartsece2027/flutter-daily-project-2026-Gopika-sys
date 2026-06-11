import 'package:get/get.dart';

class AppStatusController extends GetxController {
  // 1. Reactive state (for Obx)
  var isTracking = false.obs;
  var alertCount = 0.obs;

  // 2. Simple state (for GetBuilder)
  int simpleCounter = 0;

  void toggleTracking() {
    isTracking.value = !isTracking.value;
  }

  void incrementAlerts() {
    alertCount.value++;
  }

  // Method for GetBuilder
  void incrementSimpleCounter() {
    simpleCounter++;
    update(); // This triggers GetBuilder to rebuild
  }
}