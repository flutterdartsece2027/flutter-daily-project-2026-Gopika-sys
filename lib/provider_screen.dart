import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:get/get.dart';
import 'app_status_provider.dart';
import 'getx_screen.dart';

class ProviderScreen extends StatelessWidget {
  const ProviderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Glowher - Provider Screen')),
      body: Center(
        child: Consumer<AppStatusProvider>(
          builder: (context, statusProvider, child) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Managed via Provider:',
                  style: TextStyle(fontSize: 18, color: Colors.blueAccent),
                ),
                const SizedBox(height: 10),
                Text(
                  statusProvider.isTracking ? 'Tracking: ACTIVE' : 'Tracking: OFF',
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                Text('Alerts Registered: ${statusProvider.alertCount}'),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => statusProvider.toggleTracking(),
                  child: const Text('Toggle Tracking State'),
                ),
                ElevatedButton(
                  onPressed: () => statusProvider.incrementAlerts(),
                  child: const Text('Add Alert Entry'),
                ),
                const Divider(height: 50),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
                  onPressed: () => Get.to(() => const GetXScreen()),
                  child: const Text('Go to GetX Screen ➡️'),
                )
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.to(() => const GetXScreen()),
        label: const Text('GO TO GETX SCREEN'),
        icon: const Icon(Icons.bolt),
        backgroundColor: Colors.purple,
      ),
    );
  }
}