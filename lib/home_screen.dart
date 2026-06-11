// lib/home_screen.dart

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// Navigation target screen modules (living directly under lib/)
import 'login_screen.dart';
import 'vault_screen.dart';
import 'maison_maps_screen.dart'; // Safe routing reference to your map layout

// Data architecture models (living under lib/models/)
import 'models/products_model.dart';

class MainStorefrontScreen extends StatefulWidget {
  final String username;
  const MainStorefrontScreen({super.key, required this.username});

  @override
  State<MainStorefrontScreen> createState() => _MainStorefrontScreenState();
}

class _MainStorefrontScreenState extends State<MainStorefrontScreen> {
  bool showGlamSuiteLayout = true;

  // Live Inventory Storage Variables
  ProductResponse? _maisonCatalog;
  bool _isLoadingInventory = true;
  String _networkErrorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchLiveMaisonInventory();
  }

  Future<void> _fetchLiveMaisonInventory() async {
    try {
      setState(() {
        _isLoadingInventory = true;
        _networkErrorMessage = '';
      });

      final url = Uri.parse('https://dummyjson.com/products?limit=0');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> dynamicJsonMap = json.decode(response.body);
        setState(() {
          _maisonCatalog = ProductResponse.fromJson(dynamicJsonMap);
          _isLoadingInventory = false;
        });
      } else {
        setState(() {
          _networkErrorMessage = 'Maison Server Denied Handshake [Code: ${response.statusCode}]';
          _isLoadingInventory = false;
        });
      }
    } catch (connectionError) {
      setState(() {
        _networkErrorMessage = 'Connection dropped. Please review network configurations.';
        _isLoadingInventory = false;
      });
    }
  }

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext dialogContext) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: AlertDialog(
            backgroundColor: const Color(0xFF161213),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
              side: const BorderSide(color: Color(0xFFD4AF37), width: 0.8),
            ),
            title: const Text(
              "MAISON VALENTINE",
              style: TextStyle(
                fontFamily: 'Serif',
                fontSize: 14,
                color: Color(0xFFD4AF37),
                letterSpacing: 3,
                fontWeight: FontWeight.w400,
              ),
              textAlign: TextAlign.center,
            ),
            content: const Text(
              "Are you sure you wish to exit your premium vanity session?",
              style: TextStyle(
                color: Colors.white70,
                fontSize: 13,
                letterSpacing: 0.5,
              ),
              textAlign: TextAlign.center,
            ),
            actionsAlignment: MainAxisAlignment.spaceEvenly,
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text(
                  "CANCEL",
                  style: TextStyle(
                    color: Colors.white38,
                    fontSize: 11,
                    letterSpacing: 1.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2C1619),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                  _executeLogout();
                },
                child: const Text(
                  "LOGOUT",
                  style: TextStyle(
                    color: Colors.redAccent,
                    fontSize: 11,
                    letterSpacing: 1.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _executeLogout() {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const LoginScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) =>
            FadeTransition(opacity: animation, child: child),
        transitionDuration: const Duration(milliseconds: 600),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return showGlamSuiteLayout ? _buildPremiumGlamLayout() : _buildAdvancedGlowLayout();
  }

  Widget _buildPremiumGlamLayout() {
    return Scaffold(
      backgroundColor: const Color(0xFF09060B),
      appBar: AppBar(
        backgroundColor: const Color(0xFF09060B),
        elevation: 0,
        title: const Text(
            "GLAM SUITE",
            style: TextStyle(fontFamily: 'Serif', fontWeight: FontWeight.w400, letterSpacing: 5, fontSize: 18, color: Colors.white)
        ),
        actions: [
          IconButton(
              icon: const Icon(Icons.blur_on_outlined, color: Color(0xFFD4AF37)),
              onPressed: () => setState(() => showGlamSuiteLayout = false)
          ),
          IconButton(
            icon: const Icon(Icons.logout_outlined, color: Colors.redAccent, size: 20),
            tooltip: 'Logout',
            onPressed: () => _showLogoutConfirmation(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              color: const Color(0xFFEEDC82),
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: const Center(
                child: Text(
                  "COMPLIMENTARY SHIPPING ON ORDERS OVER \$150 • CODE: ATELIER",
                  style: TextStyle(color: Colors.black, fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 2),
                ),
              ),
            ),

            Stack(
              children: [
                Container(
                  width: double.infinity,
                  height: 480,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage("https://images.unsplash.com/photo-1547887537-6158d64c35b3?w=800&auto=format&fit=crop"),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Container(
                  width: double.infinity,
                  height: 480,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, const Color(0xFF09060B).withOpacity(0.95)],
                    ),
                  ),
                ),
                Positioned(
                  bottom: 30,
                  left: 24,
                  right: 24,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          "Hello, ${widget.username.toUpperCase()}",
                          style: const TextStyle(
                              fontFamily: 'Serif',
                              color: Color(0xFFD4AF37),
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 3
                          )
                      ),
                      const SizedBox(height: 6),
                      const Text("L'Édition Exclusive", style: TextStyle(fontFamily: 'Cursive', color: Colors.white70, fontSize: 24, fontStyle: FontStyle.italic)),
                      const SizedBox(height: 4),
                      const Text("ELEVATE YOUR SOUL\nWITH ABSOLUTE RADIANCY", style: TextStyle(fontFamily: 'Serif', fontSize: 26, fontWeight: FontWeight.w300, color: Colors.white, height: 1.2, letterSpacing: 3)),
                      const SizedBox(height: 12),
                      OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.white70),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
                          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                        ),
                        onPressed: () {},
                        child: const Text("DISCOVER NOW", style: TextStyle(color: Colors.white, fontSize: 11, letterSpacing: 2, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                )
              ],
            ),

            const SizedBox(height: 32),
            _buildSectionHeader("SHOP BY OCCASION", "Tailored Cosmetic Rituals"),
            const SizedBox(height: 16),

            SizedBox(
              height: 240,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                physics: const BouncingScrollPhysics(),
                children: [
                  _buildCuratedOccasionCard("ATELIER DIURNE", "https://images.unsplash.com/photo-1596462502278-27bfdc403348?w=500"),
                  _buildCuratedOccasionCard("SOIRÉE ÉLÉGANTE", "https://images.unsplash.com/photo-1522335789203-aabd1fc54bc9?w=500"),
                  _buildCuratedOccasionCard("MINUIT NOIR", "https://images.unsplash.com/photo-1512496015851-a90fb38ba796?w=500"),
                ],
              ),
            ),

            const SizedBox(height: 40),
            _buildSectionHeader("MAISON BESTSELLERS", "The Signature Collection Essentials"),
            const SizedBox(height: 20),

            _isLoadingInventory
                ? const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: CircularProgressIndicator(color: Color(0xFFD4AF37), strokeWidth: 2),
              ),
            )
                : _networkErrorMessage.isNotEmpty
                ? Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(_networkErrorMessage, style: const TextStyle(color: Colors.redAccent, fontSize: 12)),
              ),
            )
                : _maisonCatalog?.products == null || _maisonCatalog!.products!.isEmpty
                ? const Center(
              child: Text("Vault array currently vacant.", style: TextStyle(color: Colors.white30)),
            )
                : GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.65,
                mainAxisSpacing: 24,
                crossAxisSpacing: 20,
              ),
              itemCount: _maisonCatalog!.products!.length,
              itemBuilder: (context, index) {
                final Products assetItem = _maisonCatalog!.products![index];

                return _buildProductShelfUnit(
                  assetItem.title ?? 'Maison Private Asset',
                  '\$${assetItem.price?.toStringAsFixed(2) ?? '0.00'}',
                  assetItem.thumbnail ?? "https://images.unsplash.com/photo-1523293182086-7651a899d37f?w=500",
                );
              },
            ),
            const SizedBox(height: 60),
          ],
        ),
      ),
      // 🟢 UPDATED: Stacked Action Matrix for Glam Layout (Gavel + Map)
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: "glam_vault_btn",
            backgroundColor: const Color(0xFF1C1A1A),
            shape: const CircleBorder(side: BorderSide(color: Color(0xFFD4AF37), width: 1)),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MaisonVaultScreen()),
              );
            },
            child: const Icon(Icons.gavel_outlined, color: Color(0xFFD4AF37)),
          ),
          const SizedBox(height: 12),
          FloatingActionButton.extended(
            heroTag: "glam_map_btn",
            backgroundColor: const Color(0xFFD4AF37),
            foregroundColor: const Color(0xFF09060B),
            elevation: 5,
            icon: const Icon(Icons.map_rounded),
            label: const Text(
              "View Maison Map",
              style: TextStyle(fontFamily: 'Serif', fontWeight: FontWeight.bold, letterSpacing: 1),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MaisonMapsScreen()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAdvancedGlowLayout() {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            const SizedBox(height: 50),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.logout, color: Colors.redAccent),
                    onPressed: () => _showLogoutConfirmation(context),
                  ),
                  const Text("LUNA ENERGY", style: TextStyle(fontFamily: 'Serif', letterSpacing: 4, fontSize: 16, color: Colors.white)),
                  IconButton(icon: const Icon(Icons.invert_colors_outlined, color: Color(0xFFD4AF37)), onPressed: () => setState(() => showGlamSuiteLayout = true)),
                ],
              ),
            ),
            const SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Welcome back, ${widget.username}",
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.66),
                      fontFamily: 'Serif',
                      fontSize: 16,
                      letterSpacing: 1.5,
                      fontWeight: FontWeight.w300
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: Image.network("https://images.unsplash.com/photo-1615396879835-53379544600e?w=400", width: 130, height: 210, fit: BoxFit.cover),
                  ),
                  const SizedBox(width: 16),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFFD4AF37), width: 0.8),
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(120)),
                    ),
                    padding: const EdgeInsets.all(6),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(120)),
                      child: Image.network("https://images.unsplash.com/photo-1617897903246-719242758050?w=400", width: 140, height: 240, fit: BoxFit.cover),
                    ),
                  )
                ],
              ),
            ),

            const SizedBox(height: 32),
            const Text("Winter Essence", style: TextStyle(fontFamily: 'Cursive', fontSize: 40, color: Colors.white, fontStyle: FontStyle.italic)),
            const SizedBox(height: 6),
            const Text("CURATED HARMONY FOR HIGH ENERGY RADIANCE", style: TextStyle(fontSize: 9, letterSpacing: 2, color: Colors.white38)),
            const SizedBox(height: 24),

            Container(
              margin: const EdgeInsets.all(24),
              padding: const EdgeInsets.all(24),
              color: const Color(0xFF121212),
              child: Column(
                children: [
                  const Text("JOIN THE MAISON CIRCLE", style: TextStyle(fontFamily: 'Serif', color: Colors.white, fontSize: 13, letterSpacing: 2)),
                  const SizedBox(height: 6),
                  const Text("Receive immediate notification access keys to exclusive drops.", style: TextStyle(color: Colors.white38, fontSize: 11), textAlign: TextAlign.center),
                  const SizedBox(height: 20),
                  TextField(
                    decoration: InputDecoration(
                      hintText: "Enter Email Address",
                      hintStyle: const TextStyle(color: Colors.white24, fontSize: 12),
                      filled: true,
                      fillColor: Colors.black,
                      suffixIcon: const Icon(Icons.arrow_right_alt_outlined, color: Color(0xFFD4AF37)),
                      enabledBorder: OutlineInputBorder(borderSide: BorderSide.none, borderRadius: BorderRadius.circular(0)),
                      focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Color(0xFFD4AF37))),
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
      // 🟢 UPDATED: Stacked Action Matrix for Luna Layout (Gavel + Map)
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: "luna_vault_btn",
            backgroundColor: const Color(0xFF1C1A1A),
            shape: const CircleBorder(side: BorderSide(color: Color(0xFFD4AF37), width: 1)),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MaisonVaultScreen()),
              );
            },
            child: const Icon(Icons.gavel_outlined, color: Color(0xFFD4AF37)),
          ),
          const SizedBox(height: 12),
          FloatingActionButton.extended(
            heroTag: "luna_map_btn",
            backgroundColor: const Color(0xFFD4AF37),
            foregroundColor: const Color(0xFF09060B),
            elevation: 5,
            icon: const Icon(Icons.map_rounded),
            label: const Text(
              "View Maison Map",
              style: TextStyle(fontFamily: 'Serif', fontWeight: FontWeight.bold, letterSpacing: 1),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MaisonMapsScreen()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String heading, String sub) {
    return Column(
      children: [
        Text(heading, style: const TextStyle(fontFamily: 'Serif', fontSize: 16, color: Colors.white, letterSpacing: 3, fontWeight: FontWeight.w300)),
        const SizedBox(height: 4),
        Text(sub, style: const TextStyle(fontFamily: 'Cursive', fontSize: 14, color: Color(0xFFD4AF37), fontStyle: FontStyle.italic)),
      ],
    );
  }

  Widget _buildCuratedOccasionCard(String name, String imgUrl) {
    return Container(
      width: 150,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(80)),
        image: DecorationImage(image: NetworkImage(imgUrl), fit: BoxFit.cover),
      ),
      child: Container(
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.vertical(top: Radius.circular(80)),
          gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.transparent, Colors.black87]),
        ),
        padding: const EdgeInsets.all(16),
        alignment: Alignment.bottomCenter,
        child: Text(name, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 2), textAlign: TextAlign.center),
      ),
    );
  }

  Widget _buildProductShelfUnit(String title, String cost, String imgUrl) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF121212),
              borderRadius: BorderRadius.circular(4),
              image: DecorationImage(
                image: NetworkImage(imgUrl),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontFamily: 'Serif', color: Colors.white, fontSize: 13, letterSpacing: 0.5)),
        const SizedBox(height: 4),
        Text(cost, style: const TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold, fontSize: 12)),
      ],
    );
  }
}