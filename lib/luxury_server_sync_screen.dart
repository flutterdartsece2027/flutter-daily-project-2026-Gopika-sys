import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'luxury_products_display_screen.dart';

class LuxuryServerSyncScreen extends StatefulWidget {
  final List<File> mediaFiles;
  final List<Map<String, dynamic>>? customPayloadItems;

  const LuxuryServerSyncScreen({
    super.key,
    required this.mediaFiles,
    this.customPayloadItems,
  });

  @override
  State<LuxuryServerSyncScreen> createState() => _LuxuryServerSyncScreenState();
}

class _LuxuryServerSyncScreenState extends State<LuxuryServerSyncScreen> {
  bool _isSyncing = true;
  String _statusMessage = "INITIALIZING SECURE TRANSACTIONS...";
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _executeInventorySync();
  }

  Future<void> _executeInventorySync() async {
    try {
      // 1. Process local media assets safely into base64 structures
      List<Map<String, dynamic>> processedAssets = [];
      for (var file in widget.mediaFiles) {
        if (await file.exists()) {
          List<int> bytes = await file.readAsBytes();
          processedAssets.add({
            "filename": file.path.split('/').last,
            "content_type": "image/jpeg",
            "data": base64Encode(bytes),
          });
        }
      }

      // 2. Build the decoupled raw outgoing map bundle
      Map<String, dynamic> outgoingPayload = {
        "title": "Maison Vault Premium Catalog Package",
        "sync_metadata": {
          "timestamp": DateTime.now().toIso8601String(),
          "client_id": "maison_vault_mobile_node",
          "item_count": widget.customPayloadItems?.length ?? 0,
          "media_count": widget.mediaFiles.length,
        },
        "products": widget.customPayloadItems ?? [],
        "attached_assets": processedAssets,
      };

      setState(() {
        _statusMessage = "UPLOADING TRANSACTION ENVELOPE...";
      });

      // 3. Fire the request directly into the secure endpoint
      final response = await http.post(
        Uri.parse('https://dummyjson.com/products/add'),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode(outgoingPayload),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (!mounted) return;

        setState(() {
          _isSyncing = false;
          _statusMessage = "SYNCHRONIZATION PIPELINE SUCCESSFUL";
        });

        // Safe slight delay to display completion status before transitioning
        Future.delayed(const Duration(milliseconds: 600), () {
          if (!mounted) return;

          // FIXED: Navigating to the parameterless constructor matching your new GET file layout
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const LuxuryProductsDisplayScreen(),
            ),
          );
        });
      } else {
        throw HttpException("Server rejected data package with code: ${response.statusCode}");
      }
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isSyncing = false;
        _errorMessage = error.toString().toUpperCase();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A060C),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_isSyncing) ...[
                const SizedBox(
                  width: 45,
                  height: 45,
                  child: CircularProgressIndicator(color: Color(0xFFE2C9A1), strokeWidth: 1.2),
                ),
                const SizedBox(height: 32),
                Text(
                  _statusMessage,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontFamily: 'Serif', color: Color(0xFFE2C9A1), fontSize: 11, letterSpacing: 2.5),
                ),
              ] else if (_errorMessage != null) ...[
                const Icon(Icons.gpp_maybe_outlined, color: Color(0xFFF3A3B1), size: 36),
                const SizedBox(height: 24),
                const Text(
                  "UPLINK PIPELINE FAILURE",
                  style: TextStyle(fontFamily: 'Serif', color: Color(0xFFF3A3B1), fontSize: 13, letterSpacing: 2),
                ),
                const SizedBox(height: 12),
                Text(
                  _errorMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white24, fontSize: 9, height: 1.6),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3D1121),
                    side: const BorderSide(color: Color(0xFFF3A3B1), width: 0.5),
                    elevation: 0,
                  ),
                  onPressed: () {
                    setState(() {
                      _isSyncing = true;
                      _errorMessage = null;
                    });
                    _executeInventorySync();
                  },
                  child: const Text("RETRY PIPELINE TRANSMISSION", style: TextStyle(color: Color(0xFFF3A3B1), fontSize: 10, letterSpacing: 1.5)),
                )
              ] else ...[
                const Icon(Icons.check_circle_outline_rounded, color: Color(0xFFE2C9A1), size: 36),
                const SizedBox(height: 24),
                Text(
                  _statusMessage,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontFamily: 'Serif', color: Color(0xFFE2C9A1), fontSize: 12, letterSpacing: 1.5),
                ),
                const SizedBox(height: 16),
                const Text(
                  "REDIRECTING TO REGISTRY REGION...",
                  style: TextStyle(color: Colors.white30, fontSize: 9, letterSpacing: 1),
                )
              ]
            ],
          ),
        ),
      ),
    );
  }
}