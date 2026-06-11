import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'app_status_controller.dart';
import 'redux_screen.dart';

class GetXScreen extends StatelessWidget {
  const GetXScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AppStatusController controller = Get.put(AppStatusController());

    return Scaffold(
      appBar: AppBar(title: const Text('Glowher - GetX Screen')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Managed via GetX:',
              style: TextStyle(fontSize: 18, color: Colors.purpleAccent),
            ),
            const SizedBox(height: 10),
            Obx(() => Text(
              controller.isTracking.value ? 'Tracking: ACTIVE' : 'Tracking: OFF',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            )),
            Obx(() => Text('Alerts Registered: ${controller.alertCount.value}')),
            const SizedBox(height: 40),
            
            const Text(
              'Managed via GetBuilder (Simple):',
              style: TextStyle(fontSize: 18, color: Colors.orangeAccent),
            ),
            const SizedBox(height: 10),
            GetBuilder<AppStatusController>(
              builder: (controller) {
                return Text(
                  'Simple Counter: ${controller.simpleCounter}',
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                );
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => controller.toggleTracking(),
              child: const Text('Toggle Tracking State'),
            ),
            ElevatedButton(
              onPressed: () => controller.incrementAlerts(),
              child: const Text('Add Alert Entry'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              onPressed: () => controller.incrementSimpleCounter(),
              child: const Text('Increment Simple Counter (GetBuilder)'),
            ),
            const Divider(height: 50),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
              onPressed: () => Get.back(),
              child: const Text('⬅️ Return to Provider Screen'),
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.to(() => const ReduxScreen()),
        label: const Text('GO TO REDUX SCREEN'),
        icon: const Icon(Icons.layers_outlined),
        backgroundColor: Colors.green,
      ),
    );
  }
}
