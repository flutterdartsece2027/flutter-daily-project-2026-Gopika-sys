// lib/firebase_dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'provider_screen.dart';
import 'firebase_vault_controller.dart';
import 'app_status_controller.dart';

// Import your unified notification service setup
import 'notification_service.dart';

class MaisonFirebaseDashboardScreen extends StatefulWidget {
  const MaisonFirebaseDashboardScreen({super.key});

  @override
  State<MaisonFirebaseDashboardScreen> createState() => _MaisonFirebaseDashboardScreenState();
}

class _MaisonFirebaseDashboardScreenState extends State<MaisonFirebaseDashboardScreen> {
  final TextEditingController _itemController = TextEditingController();
  final TextEditingController _valueController = TextEditingController();
  final FirebaseVaultController _controller = Get.put(FirebaseVaultController());
  bool _isUploading = false;

  // Push new luxury asset documents directly into Cloud Firestore database collections
  Future<void> _uploadAssetToFirebase() async {
    if (_itemController.text.trim().isEmpty || _valueController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please populate both asset parameters.")),
      );
      return;
    }

    setState(() => _isUploading = true);

    try {
      await _controller.addAsset(
        _itemController.text.trim(),
        _valueController.text.trim(),
      );

      _itemController.clear();
      _valueController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Asset logged into Cloud Vault securely.")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Vault syncing execution failure: $e")),
      );
    } finally {
      setState(() => _isUploading = false);
    }
  }

  @override
  void dispose() {
    _itemController.dispose();
    _valueController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF09060B),
      appBar: AppBar(
        backgroundColor: const Color(0xFF09060B),
        elevation: 0,
        title: const Text(
          "FIREBASE VAULT LINK",
          style: TextStyle(fontFamily: 'Serif', letterSpacing: 3, fontSize: 14, color: Color(0xFFD4AF37)),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          // Input Panel Component
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF141115),
                border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.3), width: 0.8),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Column(
                children: [
                  TextField(
                    controller: _itemController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      hintText: "Enter Asset Name (e.g., Rouge Perfume)",
                      hintStyle: TextStyle(color: Colors.white24, fontSize: 13),
                      enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white10)),
                      focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFFD4AF37))),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _valueController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      hintText: "Enter Valuation/Cost (e.g., \$280.00)",
                      hintStyle: TextStyle(color: Colors.white24, fontSize: 13),
                      enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white10)),
                      focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFFD4AF37))),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 45,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2C1619),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
                      ),
                      onPressed: _isUploading ? null : _uploadAssetToFirebase,
                      child: _isUploading
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Text("TRANSMIT TO CLOUD VAULT", style: TextStyle(color: Colors.white, fontSize: 11, letterSpacing: 1.5, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const Divider(color: Colors.white10, thickness: 1),

          // Real-time Dashboard Panel
          Expanded(
            child: Obx(() {
              if (_controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator(color: Color(0xFFD4AF37)));
              }

              final docs = _controller.vaultItems;
              
              if (docs.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(40.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.cloud_off_outlined, color: Colors.white10, size: 40),
                        const SizedBox(height: 16),
                        const Text("Cloud vault is currently empty.", 
                          style: TextStyle(color: Colors.white30, fontSize: 13, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        const Text("Ensure your Firestore collection is named 'maison_vault' and documents contain 'assetName' and 'valValue' fields.", 
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white10, fontSize: 10)),
                        const SizedBox(height: 20),
                        Text("Active Project: ${Firebase.app().options.projectId}", 
                          style: const TextStyle(color: Colors.white12, fontSize: 9)),
                      ],
                    ),
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  final doc = docs[index];
                  final data = doc.data() as Map<String, dynamic>;

                  // Flexible data extraction to handle different field naming conventions
                  final String displayTitle = data['assetName'] ?? data['asset name'] ?? data['title'] ?? 'Unnamed Core Asset';
                  final String displayPrice = data['valValue'] ?? data['price'] ?? data['valuation'] ?? 'Free';

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF110D12),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: ListTile(
                      leading: const Icon(Icons.cloud_done_outlined, color: Color(0xFFD4AF37), size: 20),
                      title: Text(
                        displayTitle,
                        style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
                      ),
                      trailing: Text(
                        displayPrice,
                        style: const TextStyle(color: Color(0xFFEEDC82), fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
      // Elegant, extended floating action button configured for your brand layout
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF2C1619),
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: Color(0xFFD4AF37), width: 0.5),
          borderRadius: BorderRadius.circular(4),
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const MaisonLocalNotificationScreen()),
          );
        },
        icon: const Icon(Icons.notifications_outlined, color: Color(0xFFD4AF37), size: 18),
        label: const Text(
          "MANAGE LOCAL ALERTS",
          style: TextStyle(
            color: Colors.white,
            fontSize: 11,
            letterSpacing: 1.5,
            fontWeight: FontWeight.bold,
            fontFamily: 'Serif',
          ),
        ),
      ),
    );
  }
}

/// =========================================================================
/// DEDICATED NEW SCREEN: LOCAL NOTIFICATION CONTROLLER
/// =========================================================================
class MaisonLocalNotificationScreen extends StatelessWidget {
  const MaisonLocalNotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF09060B),
      appBar: AppBar(
        backgroundColor: const Color(0xFF09060B),
        elevation: 0,
        title: const Text(
          "LOCAL NOTIFICATIONS",
          style: TextStyle(fontFamily: 'Serif', letterSpacing: 3, fontSize: 14, color: Color(0xFFD4AF37)),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: GetBuilder<AppStatusController>(
            init: AppStatusController(), // Initialize the controller if not already present
            builder: (controller) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () => controller.incrementSimpleCounter(),
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: const Color(0xFF141115),
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.2), width: 1),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          const Icon(
                            Icons.bolt_outlined,
                            size: 48,
                            color: Color(0xFFD4AF37),
                          ),
                          if (controller.simpleCounter > 0)
                            Positioned(
                              top: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                                child: Text("${controller.simpleCounter}", style: const TextStyle(fontSize: 10, color: Colors.white)),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    "Offline Notification Studio",
                    style: TextStyle(
                      fontFamily: 'Serif',
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "System Pings: ${controller.simpleCounter}",
                    style: const TextStyle(color: Color(0xFFD4AF37), fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "Tap the interactive control trigger at the bottom right corner of this interface frame to directly call your system message channels.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white30,
                      fontSize: 13,
                      height: 1.5,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
      // Dedicated trigger button execution environment
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton.extended(
            heroTag: "trigger_notification",
            backgroundColor: const Color(0xFF2C1619),
            shape: RoundedRectangleBorder(
              side: const BorderSide(color: Color(0xFFD4AF37), width: 0.5),
              borderRadius: BorderRadius.circular(4),
            ),
            onPressed: () async {
              // Fire your 100% offline local notification pipeline instantly
              await NotificationService.showLocalNotification(
                title: "Maison Alert System ✨",
                body: "Your offline app notification trigger system is running perfectly!",
              );
            },
            icon: const Icon(Icons.flash_on, color: Color(0xFFD4AF37), size: 16),
            label: const Text(
              "TRIGGER INSTANT BANNER",
              style: TextStyle(
                color: Colors.white,
                fontSize: 11,
                letterSpacing: 1.5,
                fontWeight: FontWeight.bold,
                fontFamily: 'Serif',
              ),
            ),
          ),
          const SizedBox(height: 12),
          FloatingActionButton.extended(
            heroTag: "nav_to_provider",
            backgroundColor: const Color(0xFFD4AF37),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
            onPressed: () => Get.to(() => const ProviderScreen()),
            icon: const Icon(Icons.arrow_forward, color: Colors.black, size: 16),
            label: const Text(
              "GO TO PROVIDER SCREEN",
              style: TextStyle(
                color: Colors.black,
                fontSize: 11,
                letterSpacing: 1.5,
                fontWeight: FontWeight.bold,
                fontFamily: 'Serif',
              ),
            ),
          ),
        ],
      ),
    );
  }
}