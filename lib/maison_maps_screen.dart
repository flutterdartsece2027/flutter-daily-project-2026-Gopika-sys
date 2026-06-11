// lib/maison_maps_screen.dart

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as loc;

/// Local data layer structure to hold added targets in transient state memory
class MaisonDestinationZone {
  final String id;
  final String areaName;
  final String condition;
  final LatLng coordinates;

  MaisonDestinationZone({
    required this.id,
    required this.areaName,
    required this.condition,
    required this.coordinates,
  });
}

class MaisonMapsScreen extends StatefulWidget {
  const MaisonMapsScreen({super.key});

  @override
  State<MaisonMapsScreen> createState() => _MaisonMapsScreenState();
}

class _MaisonMapsScreenState extends State<MaisonMapsScreen> {
  GoogleMapController? _mapController;
  final loc.Location _locationService = loc.Location();

  // Baseline standard fallback coordinates if location services are spinning
  static const LatLng _fallbackPosition = LatLng(11.0168, 76.9558);
  LatLng? _currentPosition;
  bool _isLoading = true;

  // Local In-Memory Storage List replacing database lookups entirely
  final List<MaisonDestinationZone> _localZones = [];

  // Reactive state maps passing geometry parameters to the Google Maps engine
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};

  @override
  void initState() {
    super.initState();
    _getUserLocation();
  }

  /// Handles hardware sync permissions and requests current source positions
  Future<void> _getUserLocation() async {
    bool serviceEnabled;
    loc.PermissionStatus permissionGranted;

    serviceEnabled = await _locationService.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _locationService.requestService();
      if (!serviceEnabled) return;
    }

    permissionGranted = await _locationService.hasPermission();
    if (permissionGranted == loc.PermissionStatus.denied) {
      permissionGranted = await _locationService.requestPermission();
      if (permissionGranted != loc.PermissionStatus.granted) return;
    }

    final loc.LocationData locationData = await _locationService.getLocation();

    if (mounted) {
      setState(() {
        _currentPosition = LatLng(locationData.latitude!, locationData.longitude!);
        _isLoading = false;
        _rebuildMapGraphics();
      });

      _mapController?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: _currentPosition!, zoom: 14.5),
        ),
      );
    }
  }

  /// Wipes and repaints local state layers safely on state adjustments
  void _rebuildMapGraphics() {
    if (_currentPosition == null) return;

    setState(() {
      _markers.clear();
      _polylines.clear();

      // 1. Establish Primary Source Pin Location Element
      _markers.add(
        Marker(
          markerId: const MarkerId('source_location_marker'),
          position: _currentPosition!,
          infoWindow: const InfoWindow(title: 'SOURCE POSITION', snippet: 'Your Present Coordinates'),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRose),
        ),
      );

      // 2. Loop through tracking zones to apply condition filters and trace routes
      int pathCounter = 0;
      for (var zone in _localZones) {
        pathCounter++;

        // 🟢 FIX: Define gold using its raw HSV degree coordinate (45.0) since .hueGold doesn't exist
        double markerHue = 45.0;
        Color polylineColor = const Color(0xFFD4AF37);

        // FILTER REGION CONDITIONS: Match user input strings
        if (zone.condition.toLowerCase() == 'active') {
          markerHue = BitmapDescriptor.hueCyan;
          polylineColor = Colors.cyan;
        } else if (zone.condition.toLowerCase() == 'priority') {
          markerHue = BitmapDescriptor.hueViolet;
          polylineColor = Colors.deepPurpleAccent;
        }

        // Render Dynamic Targeted Destination Marker safely linked to the set
        _markers.add(
          Marker(
            markerId: MarkerId('destination_${zone.id}'),
            position: zone.coordinates,
            icon: BitmapDescriptor.defaultMarkerWithHue(markerHue),
            infoWindow: InfoWindow(
              title: zone.areaName.toUpperCase(),
              snippet: "Status: ${zone.condition.toUpperCase()} • Active Path Line Enabled",
            ),
          ),
        );

        // Map Direct Polyline Connection Link stringing Source to this Destination
        _polylines.add(
          Polyline(
            polylineId: PolylineId('route_link_$pathCounter'),
            visible: true,
            points: [_currentPosition!, zone.coordinates],
            color: polylineColor,
            width: 5,
            geodesic: true,
          ),
        );
      }
    });
  }

  /// Premium Modal Sheet layout processing form field updates
  void _showZoneCreationModal(BuildContext context) {
    final TextEditingController areaController = TextEditingController();
    final TextEditingController conditionController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF120E16),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 24,
          right: 24,
          top: 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              "CREATE TARGET DESTINATION",
              style: TextStyle(
                fontFamily: 'Serif',
                color: Color(0xFFD4AF37),
                fontSize: 13,
                letterSpacing: 2,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: areaController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: "Target Region Name",
                labelStyle: TextStyle(color: Colors.white38, fontSize: 13),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white12)),
                focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFFD4AF37))),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: conditionController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: "Condition Rule (Type 'active' or 'priority')",
                labelStyle: TextStyle(color: Colors.white38, fontSize: 13),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white12)),
                focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFFD4AF37))),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD4AF37),
                foregroundColor: const Color(0xFF09060B),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
              ),
              onPressed: () {
                if (areaController.text.isNotEmpty && _currentPosition != null) {
                  // Incremental location offset generator away from the core source position
                  double geographicOffset = 0.0035 * (_localZones.length + 1);
                  double targetLat = _currentPosition!.latitude + geographicOffset;
                  double targetLng = _currentPosition!.longitude + geographicOffset;

                  // Update Transient List Layout directly in-app memory structures
                  _localZones.add(
                    MaisonDestinationZone(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      areaName: areaController.text.trim(),
                      condition: conditionController.text.trim().toLowerCase(),
                      coordinates: LatLng(targetLat, targetLng),
                    ),
                  );

                  // Commit updates back to the viewport state layout
                  _rebuildMapGraphics();

                  Navigator.pop(context);
                }
              },
              child: const Text("MAP DESTINATION", style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1, fontSize: 12)),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    LatLng initialTarget = _currentPosition ?? _fallbackPosition;

    return Scaffold(
      backgroundColor: const Color(0xFF09060B),
      appBar: AppBar(
        backgroundColor: const Color(0xFF09060B),
        elevation: 0,
        title: const Text(
          "MAISON DISCOVERY PLATFORM",
          style: TextStyle(fontFamily: 'Serif', letterSpacing: 2, fontSize: 12, color: Color(0xFFD4AF37)),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: initialTarget,
              zoom: 14.5,
            ),
            onMapCreated: (GoogleMapController controller) {
              _mapController = controller;
            },
            markers: _markers,
            polylines: _polylines,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: true,
          ),

          if (_isLoading)
            Container(
              color: const Color(0xFF09060B),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: Color(0xFFD4AF37), strokeWidth: 2),
                    SizedBox(height: 16),
                    Text(
                      "Synchronizing Satellite Geo-Coordinates...",
                      style: TextStyle(color: Colors.white60, fontSize: 11, fontFamily: 'Serif', letterSpacing: 1),
                    )
                  ],
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF09060B),
        shape: const CircleBorder(side: BorderSide(color: Color(0xFFD4AF37), width: 1.2)),
        onPressed: () => _showZoneCreationModal(context),
        child: const Icon(Icons.add, color: Color(0xFFD4AF37), size: 24),
      ),
    );
  }
}