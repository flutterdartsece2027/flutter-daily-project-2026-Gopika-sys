// lib/luxury_media_upload_screen.dart

import 'dart:io';
import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:hive/hive.dart';

// Navigation target screen modules updated to point to your new Firebase Dashboard
import 'firebase_dashboard_screen.dart';

class LuxuryMediaUploadScreen extends StatefulWidget {
  const LuxuryMediaUploadScreen({super.key});

  @override
  State<LuxuryMediaUploadScreen> createState() => _LuxuryMediaUploadScreenState();
}

class _LuxuryMediaUploadScreenState extends State<LuxuryMediaUploadScreen> with TickerProviderStateMixin {
  List<File> _selectedImages = [];
  final ImagePicker _picker = ImagePicker();
  late Box _studioBox;

  late AnimationController _cosmeticMandalaController;
  late AnimationController _beautyHaloController;
  late AnimationController _silkWaveController;

  @override
  void initState() {
    super.initState();
    _cosmeticMandalaController = AnimationController(vsync: this, duration: const Duration(seconds: 5))..repeat();
    _beautyHaloController = AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat(reverse: true);
    _silkWaveController = AnimationController(vsync: this, duration: const Duration(seconds: 4))..repeat();

    _initHiveAndLoadAssets();
  }

  void _initHiveAndLoadAssets() {
    _studioBox = Hive.box('luxury_studio_box');
    final List<dynamic>? cachedPaths = _studioBox.get('cached_image_paths');
    if (cachedPaths != null) {
      setState(() {
        _selectedImages = cachedPaths.map((path) => File(path as String)).toList();
      });
    }
  }

  void _updatePersistedStorage() {
    final List<String> pathsToSave = _selectedImages.map((file) => file.path).toList();
    _studioBox.put('cached_image_paths', pathsToSave);
  }

  @override
  void dispose() {
    _cosmeticMandalaController.dispose();
    _beautyHaloController.dispose();
    _silkWaveController.dispose();
    super.dispose();
  }

  Future<void> _pickMultiImages() async {
    try {
      final List<XFile> pickedFiles = await _picker.pickMultiImage(imageQuality: 90);
      if (pickedFiles.isNotEmpty) {
        setState(() {
          _selectedImages.addAll(pickedFiles.map((file) => File(file.path)));
        });
        _updatePersistedStorage();
        _showLuxuryToast("Premium assets compiled successfully");
      }
    } catch (e) {
      _showLuxuryToast("Vault Connection Interrupted", isError: true);
    }
  }

  Future<void> _captureCameraImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: ImageSource.camera, imageQuality: 90);
      if (pickedFile != null) {
        setState(() {
          _selectedImages.add(File(pickedFile.path));
        });
        _updatePersistedStorage();
        _showLuxuryToast("Studio capture synced to catalog");
      }
    } catch (e) {
      _showLuxuryToast("Camera Lens Ingestion Failed", isError: true);
    }
  }

  Future<bool> _showPurgeConfirmationDialog(int index) async {
    return await showDialog<bool>(
      context: context,
      builder: (ctx) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: AlertDialog(
          backgroundColor: const Color(0xFF160E1A).withOpacity(0.92),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Color(0xFFF3A3B1), width: 0.8),
          ),
          title: const Text(
            "DE-REGISTER ART PROFILE",
            style: TextStyle(fontFamily: 'Serif', fontSize: 13, color: Color(0xFFE2C9A1), letterSpacing: 3),
            textAlign: TextAlign.center,
          ),
          content: const Text(
            "Are you certain you want to strike this creative item profile from your permanent storage catalog row?",
            style: TextStyle(color: Colors.white70, fontSize: 11, height: 1.7, letterSpacing: 0.5),
            textAlign: TextAlign.center,
          ),
          actionsAlignment: MainAxisAlignment.spaceEvenly,
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text("RETAIN", style: TextStyle(color: Colors.white38, fontSize: 11, letterSpacing: 2)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3D1121),
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                side: const BorderSide(color: Color(0xFFF3A3B1), width: 0.5),
              ),
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text("CONFIRM DISCARD", style: TextStyle(color: Color(0xFFF3A3B1), fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
            )
          ],
        ),
      ),
    ) ?? false;
  }

  void _removeImage(int index) async {
    final confirm = await _showPurgeConfirmationDialog(index);
    if (confirm) {
      setState(() {
        _selectedImages.removeAt(index);
      });
      _updatePersistedStorage();
      _showLuxuryToast("Asset swept away from storage", isError: true);
    }
  }

  void _openUploadBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0F0A12),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        side: BorderSide(color: Color(0xFFE2C9A1), width: 0.6),
      ),
      builder: (ctx) => SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF1E1424), Color(0xFF0F0A12)],
            ),
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 16),
              Container(
                width: 50,
                height: 4,
                decoration: BoxDecoration(color: const Color(0xFFE2C9A1).withOpacity(0.3), borderRadius: BorderRadius.circular(2)),
              ),
              const SizedBox(height: 24),
              const Text(
                "INGEST HIGH-FASHION MEDIA",
                style: TextStyle(fontFamily: 'Serif', color: Color(0xFFE2C9A1), fontSize: 13, letterSpacing: 3),
              ),
              const SizedBox(height: 6),
              const Text(
                "CHOOSE AN ENTRY PATH TO ATTACH PRESERVED ASSETS",
                style: TextStyle(color: Colors.white24, fontSize: 8, letterSpacing: 1.2),
              ),
              const Divider(color: Colors.white12, height: 32, indent: 32, endIndent: 32),
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 40),
                leading: const Icon(Icons.camera_enhance_outlined, color: Color(0xFFF3A3B1), size: 22),
                title: const Text("LAUNCH STUDIO CAMERA TERMINAL", style: TextStyle(color: Color(0xFFEFEFEF), fontSize: 11, letterSpacing: 1.5, fontFamily: 'Serif')),
                onTap: () {
                  Navigator.pop(ctx);
                  _captureCameraImage();
                },
              ),
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 40),
                leading: const Icon(Icons.photo_library_outlined, color: Color(0xFFF3A3B1), size: 22),
                title: const Text("MOUNT FROM VAULT GALLERY", style: TextStyle(color: Color(0xFFEFEFEF), fontSize: 11, letterSpacing: 1.5, fontFamily: 'Serif')),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickMultiImages();
                },
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  void _showLuxuryToast(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message.toUpperCase(),
          style: TextStyle(fontFamily: 'Serif', fontSize: 10, letterSpacing: 1.5, color: isError ? const Color(0xFFF3A3B1) : const Color(0xFFE2C9A1)),
        ),
        backgroundColor: const Color(0xFF140D1A),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: isError ? const Color(0xFFF3A3B1).withOpacity(0.5) : const Color(0xFFE2C9A1).withOpacity(0.4), width: 0.6),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A060C),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A060C),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFFE2C9A1), size: 18),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: const Text(
          "COSMETIC CURATION DIRECTORY",
          style: TextStyle(fontFamily: 'Serif', letterSpacing: 3.5, fontSize: 13, color: Colors.white, fontWeight: FontWeight.w300),
        ),
      ),

      // UNCONDITIONALLY VISIBLE FLOATING ACTION BUTTON
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          if (_selectedImages.isEmpty) {
            _showLuxuryToast("Please ingest brand visuals before initiating sync", isError: true);
            return;
          }
          // Redirect transition mapped cleanly to the Maison Firebase Dashboard link
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const MaisonFirebaseDashboardScreen(),
            ),
          );
        },
        backgroundColor: const Color(0xFF3D1121),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
          side: const BorderSide(color: Color(0xFFF3A3B1), width: 0.8),
        ),
        icon: const Icon(Icons.cloud_upload_outlined, color: Color(0xFFE2C9A1), size: 18),
        label: const Text(
          "INITIATE VAULT SYNC",
          style: TextStyle(fontFamily: 'Serif', fontSize: 11, color: Color(0xFFE2C9A1), letterSpacing: 2),
        ),
      ),

      body: LayoutBuilder(
        builder: (context, constraints) {
          final halfHeight = constraints.maxHeight / 2;

          return Column(
            children: [
              Container(
                width: constraints.maxWidth,
                height: halfHeight,
                padding: const EdgeInsets.all(18),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF201329), Color(0xFF0E0814)],
                    ),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: const Color(0xFFE2C9A1).withOpacity(0.25), width: 0.8),
                  ),
                  child: _selectedImages.isEmpty
                      ? GestureDetector(
                    onTap: () => _openUploadBottomSheet(context),
                    child: _buildTopEmptyState(),
                  )
                      : ClipRRect(
                    borderRadius: BorderRadius.circular(23),
                    child: _buildDynamicMosaicContainer(constraints.maxWidth - 36, halfHeight - 36),
                  ),
                ),
              ),

              Container(
                width: constraints.maxWidth,
                height: halfHeight,
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(left: 8.0, bottom: 18),
                      child: Text(
                        "CREATIVE SHOWCASE PIPELINES",
                        style: TextStyle(fontFamily: 'Serif', fontSize: 11, color: Color(0xFFE2C9A1), letterSpacing: 2.5, fontWeight: FontWeight.w600),
                      ),
                    ),

                    Expanded(
                      child: Row(
                        children: [
                          Expanded(
                            child: AnimatedBuilder(
                              animation: _cosmeticMandalaController,
                              builder: (context, child) {
                                return _buildLuxuryCardFrame(
                                  title: "VISUAL STATS",
                                  bgGradient: const LinearGradient(
                                    colors: [Color(0xFF2E1A47), Color(0xFF140B21)],
                                    begin: Alignment.topLeft, end: Alignment.bottomRight,
                                  ),
                                  graphicWidget: CustomPaint(
                                    size: const Size(65, 65),
                                    painter: LuxuryCosmeticMandalaPainter(progress: _cosmeticMandalaController.value),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 14),

                          Expanded(
                            child: AnimatedBuilder(
                              animation: _beautyHaloController,
                              builder: (context, child) {
                                return _buildLuxuryCardFrame(
                                  title: "LUSTRE INDEX",
                                  bgGradient: const LinearGradient(
                                    colors: [Color(0xFF4A1E31), Color(0xFF210B14)],
                                    begin: Alignment.topCenter, end: Alignment.bottomCenter,
                                  ),
                                  graphicWidget: CustomPaint(
                                    size: const Size(65, 65),
                                    painter: ElegantBeautyHaloPainter(progress: _beautyHaloController.value),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 14),

                          Expanded(
                            child: AnimatedBuilder(
                              animation: _silkWaveController,
                              builder: (context, child) {
                                return _buildLuxuryCardFrame(
                                  title: "LIVE GLOW",
                                  bgGradient: const LinearGradient(
                                    colors: [Color(0xFF143530), Color(0xFF091715)],
                                    begin: Alignment.bottomLeft, end: Alignment.topRight,
                                  ),
                                  graphicWidget: CustomPaint(
                                    size: const Size(75, 45),
                                    painter: SatinSilkWavePainter(progress: _silkWaveController.value),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTopEmptyState() {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.auto_awesome_outlined, color: Color(0xFFE2C9A1), size: 36),
        SizedBox(height: 16),
        Text(
          "TAP TO INGEST BRAND VISUALS",
          style: TextStyle(fontFamily: 'Serif', color: Color(0xFFE2C9A1), fontSize: 12, letterSpacing: 3),
        ),
        SizedBox(height: 10),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 36.0),
          child: Text(
            "Assets loaded onto this premium staging terminal are securely saved inside local vault boxes until unmounted.",
            style: TextStyle(color: Colors.white30, fontSize: 10, height: 1.6, letterSpacing: 0.3),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _buildDynamicMosaicContainer(double width, double height) {
    return Scrollbar(
      thumbVisibility: true,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 24),
        itemCount: _selectedImages.length + 1,
        itemBuilder: (context, index) {
          if (index == _selectedImages.length) {
            return GestureDetector(
              onTap: () => _openUploadBottomSheet(context),
              child: Container(
                width: width * 0.45,
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF140D1A).withOpacity(0.5),
                  border: Border.all(color: const Color(0xFFE2C9A1).withOpacity(0.2), width: 0.8),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_circle_outline_rounded, color: Color(0xFFE2C9A1), size: 24),
                    SizedBox(height: 8),
                    Text(
                      "ADD IMAGE",
                      style: TextStyle(fontFamily: 'Serif', fontSize: 9, color: Color(0xFFE2C9A1), letterSpacing: 1.5),
                    ),
                  ],
                ),
              ),
            );
          }

          return Container(
            width: width * 0.75,
            margin: const EdgeInsets.only(right: 14),
            child: _buildTileItem(index, double.infinity, double.infinity),
          );
        },
      ),
    );
  }

  Widget _buildTileItem(int index, double width, double height) {
    return Stack(
      children: [
        Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: const Color(0xFF1E1424),
            border: Border.all(color: const Color(0xFFE2C9A1).withOpacity(0.35), width: 0.6),
            borderRadius: BorderRadius.circular(16),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Image.file(
              _selectedImages[index],
              fit: BoxFit.cover,
              width: width,
              height: height,
            ),
          ),
        ),
        Positioned(
          top: 10,
          right: 10,
          child: GestureDetector(
            onTap: () => _removeImage(index),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF0A060C).withOpacity(0.85),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFF3A3B1).withOpacity(0.5), width: 0.6),
              ),
              padding: const EdgeInsets.all(6),
              child: const Icon(Icons.close_rounded, color: Color(0xFFF3A3B1), size: 12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLuxuryCardFrame({
    required String title,
    required LinearGradient bgGradient,
    required Widget graphicWidget,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: bgGradient,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2C9A1).withOpacity(0.2), width: 0.8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(child: Center(child: graphicWidget)),
          Padding(
            padding: const EdgeInsets.only(bottom: 18.0),
            child: Text(
              title,
              style: const TextStyle(fontFamily: 'Serif', fontSize: 9.5, color: Color(0xFFE2C9A1), fontWeight: FontWeight.bold, letterSpacing: 2),
            ),
          ),
        ],
      ),
    );
  }
}

class LuxuryCosmeticMandalaPainter extends CustomPainter {
  final double progress;
  LuxuryCosmeticMandalaPainter({required this.progress});
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2.3;
    final rotation = progress * 2 * math.pi;
    final paintMesh = Paint()..style = PaintingStyle.stroke;
    for (int i = 0; i < 6; i++) {
      final double loopAngle = (i * (2 * math.pi / 6)) + rotation;
      final nodePoint = Offset(center.dx + radius * 0.4 * math.cos(loopAngle), center.dy + radius * 0.4 * math.sin(loopAngle));
      paintMesh.shader = const LinearGradient(colors: [Color(0xFFF3A3B1), Color(0xFFB388FF), Color(0xFFE2C9A1)]).createShader(Rect.fromCircle(center: center, radius: radius));
      paintMesh.strokeWidth = 1.2;
      canvas.drawCircle(nodePoint, radius * 0.5, paintMesh);
    }
  }
  @override
  bool shouldRepaint(covariant LuxuryCosmeticMandalaPainter oldDelegate) => true;
}

class ElegantBeautyHaloPainter extends CustomPainter {
  final double progress;
  ElegantBeautyHaloPainter({required this.progress});
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.width / 2;
    for (int ring = 1; ring <= 3; ring++) {
      final ringProgress = (ring * 0.33) * (0.85 + (progress * 0.15));
      final ringPaint = Paint()..style = PaintingStyle.stroke..strokeWidth = 2.5 - (ring * 0.6)
        ..shader = SweepGradient(colors: const [Color(0xFFFF80AB), Color(0xFFE2C9A1), Color(0xFFCC88FF), Color(0xFFFF80AB)], transform: GradientRotation(progress * 2 * math.pi)).createShader(Rect.fromCircle(center: center, radius: maxRadius * ringProgress));
      canvas.drawCircle(center, maxRadius * ringProgress, ringPaint);
    }
  }
  @override
  bool shouldRepaint(covariant ElegantBeautyHaloPainter oldDelegate) => true;
}

class SatinSilkWavePainter extends CustomPainter {
  final double progress;
  SatinSilkWavePainter({required this.progress});
  @override
  void paint(Canvas canvas, Size size) {
    final pathAlpha = Path(); final midY = size.height / 2; final amplitude = size.height * 0.35;
    pathAlpha.moveTo(0, midY);
    for (double x = 0; x <= size.width; x++) {
      final delta = x / size.width;
      final alphaAngle = (delta * 2.5 * math.pi) + (progress * 2 * math.pi);
      pathAlpha.lineTo(x, midY + math.sin(alphaAngle) * amplitude);
    }
    final paintAlpha = Paint()..style = PaintingStyle.stroke..strokeWidth = 2.2..shader = const LinearGradient(colors: [Color(0xFF00E676), Color(0xFF00B0FF)]).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawPath(pathAlpha, paintAlpha);
  }
  @override
  bool shouldRepaint(covariant SatinSilkWavePainter oldDelegate) => true;
}