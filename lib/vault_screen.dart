import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';
import 'package:url_launcher/url_launcher.dart'; // REQUIRED FOR DEEP-LINKING
import 'models/vault_item.dart';
import 'luxury_media_upload_screen.dart';

class MaisonVaultScreen extends StatefulWidget {
  const MaisonVaultScreen({super.key});

  @override
  State<MaisonVaultScreen> createState() => _MaisonVaultScreenState();
}

class _MaisonVaultScreenState extends State<MaisonVaultScreen> {
  List<VaultItem> _vaultItems = [];
  bool _isLoadingHiveData = true;

  final _formKey = GlobalKey<FormState>();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  String? _selectedImagePath;
  final ImagePicker _picker = ImagePicker();

  // Optimized local asset configurations for pristine stability
  final String _luxuryLocalLottie = "assets/animations/sparkle.json";
  final String _brandImageBackground = "https://i.pinimg.com/736x/3d/f9/5d/3df95d194a8fbf381a682ec591af0646.jpg";

  @override
  void initState() {
    super.initState();
    _loadPersistedVaultData();
  }

  // Safely invokes your VaultDataManager database loading pipeline before rendering items
  Future<void> _loadPersistedVaultData() async {
    try {
      // Connects to local storage and fills up the session directory
      await VaultDataManager().initHiveAndLoadData();
      setState(() {
        _vaultItems = VaultDataManager().sessionVaultItems;
        _isLoadingHiveData = false;
      });
    } catch (e) {
      debugPrint("Hive storage retrieval exception: $e");
      setState(() {
        _isLoadingHiveData = false;
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  // Helper method to safely handle external application queries and intent routing
  Future<void> _launchExternalApp(String urlString) async {
    final Uri url = Uri.parse(urlString);
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        _showLuxuryToast("Target application unavailable", isError: true);
      }
    } catch (e) {
      debugPrint("Deep-linking pipeline error: \$e");
      _showLuxuryToast("Connection Interface Failed", isError: true);
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImagePath = pickedFile.path;
        });
      }
    } catch (e) {
      _showLuxuryToast("Resource Access Denied", isError: true);
    }
  }

  void _showImageSourceOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF161213),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
        side: BorderSide(color: Color(0xFFD4AF37), width: 0.5),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            const Text(
              "SELECT IMAGE SOURCE",
              style: TextStyle(fontFamily: 'Serif', color: Color(0xFFD4AF37), fontSize: 12, letterSpacing: 2),
            ),
            const Divider(color: Colors.white12, height: 20),
            ListTile(
              leading: const Icon(Icons.camera_enhance_outlined, color: Colors.white70),
              title: const Text("CAPTURE VIA CAMERA", style: TextStyle(color: Colors.white, fontSize: 13, letterSpacing: 1)),
              onTap: () {
                Navigator.pop(ctx);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined, color: Colors.white70),
              title: const Text("UPLOAD FROM GALLERY", style: TextStyle(color: Colors.white, fontSize: 13, letterSpacing: 1)),
              onTap: () {
                Navigator.pop(ctx);
                _pickImage(ImageSource.gallery);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _showLuxuryToast(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message.toUpperCase(),
          style: const TextStyle(fontFamily: 'Serif', fontSize: 11, letterSpacing: 1.5, color: Colors.white),
        ),
        backgroundColor: isError ? const Color(0xFF5C1D24) : const Color(0xFF1C1A1A),
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: isError ? Colors.redAccent : const Color(0xFFD4AF37), width: 0.5),
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
  }

  Future<bool> _showSaveConfirmationDialog(bool isUpdating) async {
    return await showDialog<bool>(
      context: context,
      builder: (ctx) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
        child: AlertDialog(
          backgroundColor: const Color(0xFF161213),
          shape: const RoundedRectangleBorder(
            side: BorderSide(color: Color(0xFFD4AF37), width: 0.8),
          ),
          title: Text(
            isUpdating ? "CONFIRM SPECIFICATIONS" : "CONFIRM CATALOG REGISTRY",
            style: const TextStyle(fontFamily: 'Serif', fontSize: 13, color: Color(0xFFD4AF37), letterSpacing: 2),
            textAlign: TextAlign.center,
          ),
          content: Text(
            isUpdating
                ? "Do you want to permanently commit these renewed specifications to your registry?"
                : "Are you certain you want to secure this premium asset to your vault directory?",
            style: const TextStyle(color: Colors.white70, fontSize: 12, height: 1.4),
            textAlign: TextAlign.center,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text("CANCEL", style: TextStyle(color: Colors.white38, fontSize: 11, letterSpacing: 1)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1C1A1A),
                side: const BorderSide(color: Color(0xFFD4AF37), width: 0.5),
              ),
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text("SAVE PRODUCT", style: TextStyle(color: Color(0xFFD4AF37), fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1)),
            )
          ],
        ),
      ),
    ) ?? false;
  }

  void _openItemFormSheet(VaultItem? existingItem) {
    if (existingItem != null) {
      _titleController.text = existingItem.title;
      _descController.text = existingItem.description;
      _priceController.text = existingItem.price.toString();
      _selectedImagePath = existingItem.imageUrl.isNotEmpty ? existingItem.imageUrl : null;
    } else {
      _titleController.clear();
      _descController.clear();
      _priceController.clear();
      _selectedImagePath = null;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF120F10),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 24,
                right: 24,
                top: 24,
              ),
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        existingItem == null ? "ADD TO COLLECTION" : "REFINE SPECIFICATIONS",
                        style: const TextStyle(fontFamily: 'Serif', color: Color(0xFFD4AF37), fontSize: 16, letterSpacing: 2),
                      ),
                      const SizedBox(height: 24),

                      GestureDetector(
                        onTap: () async {
                          _showImageSourceOptions(context);
                          await Future.delayed(const Duration(milliseconds: 300));
                          setModalState(() {});
                        },
                        child: Container(
                          width: double.infinity,
                          height: 120,
                          decoration: BoxDecoration(
                            color: const Color(0xFF1C1A1A),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.3), width: 0.8),
                          ),
                          child: _selectedImagePath != null
                              ? ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: Image.file(
                              File(_selectedImagePath!),
                              fit: BoxFit.cover,
                              width: double.infinity,
                            ),
                          )
                              : const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_a_photo_outlined, color: Color(0xFFD4AF37), size: 28),
                              SizedBox(height: 8),
                              Text(
                                "ATTACH VISUAL ASSET PROFILES",
                                style: TextStyle(color: Colors.white38, fontSize: 10, letterSpacing: 1),
                              )
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      TextFormField(
                        controller: _titleController,
                        style: const TextStyle(color: Colors.white),
                        cursorColor: const Color(0xFFD4AF37),
                        decoration: _buildFormDecoration("Signature Label"),
                        validator: (v) => (v == null || v.trim().isEmpty) ? "Label cannot be vacant" : null,
                      ),
                      const SizedBox(height: 20),

                      TextFormField(
                        controller: _descController,
                        style: const TextStyle(color: Colors.white),
                        cursorColor: const Color(0xFFD4AF37),
                        decoration: _buildFormDecoration("Aesthetic Properties Summary"),
                        validator: (v) => (v == null || v.trim().length < 5) ? "Provide a more descriptive catalog summary" : null,
                      ),
                      const SizedBox(height: 20),

                      TextFormField(
                        controller: _priceController,
                        style: const TextStyle(color: Colors.white),
                        keyboardType: TextInputType.number,
                        cursorColor: const Color(0xFFD4AF37),
                        decoration: _buildFormDecoration("Value Allocation (\$)"),
                        validator: (v) {
                          if (v == null || double.tryParse(v) == null) return "Specify a valid financial evaluation";
                          if (double.parse(v) <= 0) return "Value allocation must exceed zero";
                          return null;
                        },
                      ),
                      const SizedBox(height: 32),

                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1C1A1A),
                          side: const BorderSide(color: Color(0xFFD4AF37), width: 0.8),
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                        ),
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            final shouldSave = await _showSaveConfirmationDialog(existingItem != null);
                            if (!shouldSave) return;

                            final inputTitle = _titleController.text.trim();
                            final inputDesc = _descController.text.trim();
                            final inputPrice = double.parse(_priceController.text);

                            if (existingItem == null) {
                              final newItem = VaultItem(
                                id: DateTime.now().toIso8601String(),
                                title: inputTitle,
                                description: inputDesc,
                                price: inputPrice,
                                imageUrl: _selectedImagePath ?? "",
                              );

                              _vaultItems.add(newItem);
                              await VaultDataManager().saveOrUpdateItem(newItem);
                              _showLuxuryToast("Item Cataloged Successfully");
                            } else {
                              existingItem.title = inputTitle;
                              existingItem.description = inputDesc;
                              existingItem.price = inputPrice;
                              existingItem.imageUrl = _selectedImagePath ?? "";

                              await VaultDataManager().saveOrUpdateItem(existingItem);
                              _showLuxuryToast("Item Specifications Renewed");
                            }

                            if (mounted) {
                              setState(() {});
                              Navigator.pop(context);
                            }
                          }
                        },
                        child: Text(
                          existingItem == null ? "CATALOG ITEM" : "UPDATE RESERVATION",
                          style: const TextStyle(color: Colors.white, letterSpacing: 2, fontSize: 12),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            );
          }
      ),
    );
  }

  void _confirmDeletion(int index) {
    showDialog(
      context: context,
      builder: (ctx) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
        child: AlertDialog(
          backgroundColor: const Color(0xFF161213),
          shape: const RoundedRectangleBorder(
            side: BorderSide(color: Color(0xFFD4AF37), width: 0.8),
          ),
          title: const Text(
            "PURGE CONFIRMATION",
            style: TextStyle(fontFamily: 'Serif', fontSize: 13, color: Color(0xFFD4AF37), letterSpacing: 2),
            textAlign: TextAlign.center,
          ),
          content: const Text(
            "Are you entirely certain you want to strike this registry entry?",
            style: TextStyle(color: Colors.white70, fontSize: 12),
            textAlign: TextAlign.center,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("CANCEL", style: TextStyle(color: Colors.white38, fontSize: 11)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF3A1115)),
              onPressed: () async {
                final targetItem = _vaultItems[index];
                _vaultItems.removeAt(index);
                await VaultDataManager().deleteItemFromDisk(targetItem.id);

                if (mounted) {
                  setState(() {});
                  Navigator.pop(ctx);
                  _showLuxuryToast("Item Purged From Collection", isError: true);
                }
              },
              child: const Text("DELETE", style: TextStyle(color: Colors.redAccent, fontSize: 11, fontWeight: FontWeight.bold)),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF09060B),
      appBar: AppBar(
        backgroundColor: const Color(0xFF09060B),
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFFD4AF37)),
        title: const Text(
          "THE VAULT CATALOG",
          style: TextStyle(fontFamily: 'Serif', letterSpacing: 3, fontSize: 16, color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: Color(0xFFD4AF37)),
            onPressed: () => _openItemFormSheet(null),
          )
        ],
      ),
      body: _isLoadingHiveData
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFD4AF37), strokeWidth: 1.5))
          : _vaultItems.isEmpty
          ? _buildEmptyStateWidget()
          : _buildVaultItemListView(),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const LuxuryMediaUploadScreen()),
          );
        },
        backgroundColor: const Color(0xFF120F10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
          side: const BorderSide(color: Color(0xFFD4AF37), width: 0.8),
        ),
        icon: const Icon(Icons.arrow_forward_ios_outlined, color: Color(0xFFD4AF37), size: 14),
        label: const Text(
          "MEDIA MANAGER",
          style: TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontFamily: 'Serif',
            letterSpacing: 2,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyStateWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "MAISON COLLECTION DIRECTORY",
              style: TextStyle(fontFamily: 'Serif', fontSize: 11, color: Colors.white24, letterSpacing: 3),
            ),
            const SizedBox(height: 24),

            GestureDetector(
              onTap: () => _openItemFormSheet(null),
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.25), width: 0.8),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFD4AF37).withOpacity(0.04),
                      blurRadius: 40,
                      spreadRadius: 5,
                    )
                  ],
                ),
                child: ClipOval(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Image.network(
                        _brandImageBackground,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return const Center(
                            child: CircularProgressIndicator(
                              color: Color(0xFFD4AF37),
                              strokeWidth: 1,
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: const Color(0xFF161213),
                          child: const Icon(Icons.spa_outlined, color: Color(0xFFD4AF37), size: 32),
                        ),
                      ),

                      Lottie.asset(
                        _luxuryLocalLottie,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                        animate: true,
                        repeat: true,
                        errorBuilder: (context, error, stackTrace) {
                          return const SizedBox.shrink();
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 35),
            const Text(
              "THE VAULT IS VACANT",
              style: TextStyle(fontFamily: 'Serif', fontSize: 14, color: Color(0xFFD4AF37), letterSpacing: 4),
            ),
            const SizedBox(height: 14),
            const SizedBox(
              width: 260,
              child: Text(
                "Tap the active premium architecture to record your bespoke cosmetic inventory directory profiles.",
                style: TextStyle(color: Colors.white38, fontSize: 11, height: 1.6, letterSpacing: 0.8),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVaultItemListView() {
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      itemCount: _vaultItems.length,
      itemBuilder: (context, index) {
        final item = _vaultItems[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: const Color(0xFF120F10),
            border: Border.all(color: Colors.white12, width: 0.5),
            borderRadius: BorderRadius.circular(4),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            leading: item.imageUrl.isNotEmpty
                ? ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: SizedBox(
                width: 44,
                height: 44,
                child: Image.file(
                  File(item.imageUrl),
                  fit: BoxFit.cover,
                  errorBuilder: (context, e, s) => const Icon(Icons.broken_image_outlined, color: Colors.white24, size: 20),
                ),
              ),
            )
                : null,
            title: Text(
              item.title.toUpperCase(),
              style: const TextStyle(fontFamily: 'Serif', color: Colors.white, letterSpacing: 1.5, fontSize: 14),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                item.description,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white38, fontSize: 12),
              ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "\$${item.price.toStringAsFixed(2)}",
                  style: const TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.w600, fontSize: 14),
                ),
                const SizedBox(width: 4),

                IconButton(
                  icon: const Icon(Icons.edit_outlined, color: Colors.white60, size: 18),
                  onPressed: () => _openItemFormSheet(item),
                ),

                IconButton(
                  icon: const Icon(Icons.delete_sweep_outlined, color: Colors.redAccent, size: 18),
                  onPressed: () => _confirmDeletion(index),
                ),

                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, color: Color(0xFFD4AF37), size: 18),
                  tooltip: "Open Communications Hub",
                  color: const Color(0xFF161213),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: const BorderSide(color: Color(0xFFD4AF37), width: 0.5),
                  ),
                  onSelected: (String choice) async {
                    switch (choice) {
                      case 'whatsapp':
                      // FIXED: Appended country code and placeholder to prevent WhatsApp application panic faults
                        await _launchExternalApp("https://wa.me/919876543210");
                        break;
                      case 'message':
                        await _launchExternalApp("sms:");
                        break;
                      case 'call':
                        await _launchExternalApp("tel:");
                        break;
                      case 'youtube':
                        await _launchExternalApp("https://www.youtube.com");
                        break;
                    }
                  },
                  itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                    const PopupMenuItem<String>(
                      value: 'whatsapp',
                      child: Row(
                        children: [
                          Icon(Icons.chat_bubble_outline_rounded, color: Colors.green, size: 16),
                          SizedBox(width: 12),
                          Text("WhatsApp", style: TextStyle(color: Colors.white, fontSize: 12, fontFamily: 'Serif')),
                        ],
                      ),
                    ),
                    const PopupMenuItem<String>(
                      value: 'message',
                      child: Row(
                        children: [
                          Icon(Icons.sms_outlined, color: Colors.blue, size: 16),
                          SizedBox(width: 12),
                          Text("Message", style: TextStyle(color: Colors.white, fontSize: 12, fontFamily: 'Serif')),
                        ],
                      ),
                    ),
                    const PopupMenuItem<String>(
                      value: 'call',
                      child: Row(
                        children: [
                          Icon(Icons.phone_enabled_outlined, color: Colors.orange, size: 16),
                          SizedBox(width: 12),
                          Text("Call", style: TextStyle(color: Colors.white, fontSize: 12, fontFamily: 'Serif')),
                        ],
                      ),
                    ),
                    const PopupMenuItem<String>(
                      value: 'youtube',
                      child: Row(
                        children: [
                          Icon(Icons.play_circle_outline_rounded, color: Colors.red, size: 16),
                          SizedBox(width: 12),
                          Text("YouTube", style: TextStyle(color: Colors.white, fontSize: 12, fontFamily: 'Serif')),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  InputDecoration _buildFormDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white38, fontSize: 12),
      enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white12)),
      focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFFD4AF37))),
      errorBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.redAccent)),
      focusedErrorBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.redAccent)),
    );
  }
}