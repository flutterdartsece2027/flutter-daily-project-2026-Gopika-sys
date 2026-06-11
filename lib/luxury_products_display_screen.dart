import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class LuxuryProductsDisplayScreen extends StatefulWidget {
  // Constructor is now clean and completely independent of incoming data arguments
  const LuxuryProductsDisplayScreen({super.key});

  @override
  State<LuxuryProductsDisplayScreen> createState() => _LuxuryProductsDisplayScreenState();
}

class _LuxuryProductsDisplayScreenState extends State<LuxuryProductsDisplayScreen> {
  List<dynamic> _allProducts = [];
  List<dynamic> _filteredProducts = [];
  bool _isLoading = true;
  String? _errorMessage;

  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = "ALL";
  List<String> _categories = ["ALL"];

  // Decoupled Endpoint Parameters Configuration
  final String _apiDomain = "dummyjson.com";
  final String _apiPath = "/products";

  @override
  void initState() {
    super.initState();
    _fetchRegistryManifest();
  }

  // Pure HTTP GET logic parsing the response pipeline natively
  Future<void> _fetchRegistryManifest() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      // Construct safe dynamic URI address parameters explicitly
      final Uri targetUri = Uri.https(_apiDomain, _apiPath);

      final response = await http.get(
        targetUri,
        headers: {
          "Accept": "application/json",
        },
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final Map<String, dynamic> decodedData = jsonDecode(response.body) as Map<String, dynamic>;

        if (decodedData.containsKey('products') && decodedData['products'] is List) {
          _allProducts = decodedData['products'] as List<dynamic>;
        }

        _filteredProducts = List.from(_allProducts);

        // Map dynamic category chips from real server elements
        final Set<String> dynamicCategories = {"ALL"};
        for (var item in _allProducts) {
          if (item['category'] != null) {
            dynamicCategories.add(item['category'].toString().toUpperCase());
          }
        }
        _categories = dynamicCategories.toList();

      } else {
        throw Exception("Server connection error: Return code ${response.statusCode}");
      }
    } catch (error) {
      _errorMessage = error.toString().toUpperCase();
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _filterInventoryPipeline() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredProducts = _allProducts.where((product) {
        final title = (product['title'] ?? '').toString().toLowerCase();
        final category = (product['category'] ?? '').toString().toUpperCase();

        final matchesSearch = title.contains(query);
        final matchesCategory = _selectedCategory == "ALL" || category == _selectedCategory;

        return matchesSearch && matchesCategory;
      }).toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A060C),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A060C),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFFE2C9A1), size: 16),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "VAULT ASSET REGISTRY",
          style: TextStyle(fontFamily: 'Serif', letterSpacing: 2.5, fontSize: 12, color: Color(0xFFE2C9A1)),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(
        child: SizedBox(
          width: 40,
          height: 40,
          child: CircularProgressIndicator(color: Color(0xFFE2C9A1), strokeWidth: 1.2),
        ),
      )
          : _errorMessage != null
          ? Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.cloud_off_rounded, color: Color(0xFFF3A3B1), size: 32),
              const SizedBox(height: 16),
              const Text(
                "DATA PIPELINE RETRIEVAL ERROR",
                style: TextStyle(fontFamily: 'Serif', color: Color(0xFFF3A3B1), fontSize: 12, letterSpacing: 1.5),
              ),
              const SizedBox(height: 8),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white24, fontSize: 9),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3D1121),
                  side: const BorderSide(color: Color(0xFFF3A3B1), width: 0.5),
                  elevation: 0,
                ),
                onPressed: _fetchRegistryManifest,
                child: const Text("RETRY REGISTRY FETCH", style: TextStyle(color: Color(0xFFF3A3B1), fontSize: 9, letterSpacing: 1)),
              )
            ],
          ),
        ),
      )
          : Column(
        children: [
          // Search Input Layout
          Padding(
            padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 8.0, bottom: 12.0),
            child: TextField(
              controller: _searchController,
              onChanged: (_) => _filterInventoryPipeline(),
              style: const TextStyle(color: Colors.white, fontSize: 12),
              cursorColor: const Color(0xFFE2C9A1),
              decoration: InputDecoration(
                hintText: "SEARCH CURRENT ARCHIVE...",
                hintStyle: const TextStyle(color: Colors.white24, fontSize: 11, letterSpacing: 1.5),
                prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFFE2C9A1), size: 18),
                filled: true,
                fillColor: const Color(0xFF140D1A),
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: const Color(0xFFE2C9A1).withOpacity(0.15)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFFE2C9A1), width: 0.8),
                ),
              ),
            ),
          ),

          // Filter Horizon Setup
          SizedBox(
            height: 35,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              physics: const BouncingScrollPhysics(),
              itemBuilder: (context, index) {
                final category = _categories[index];
                final isSelected = _selectedCategory == category;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: ChoiceChip(
                    label: Text(
                      category,
                      style: TextStyle(
                          color: isSelected ? const Color(0xFF0A060C) : const Color(0xFFE2C9A1),
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1
                      ),
                    ),
                    selected: isSelected,
                    selectedColor: const Color(0xFFE2C9A1),
                    backgroundColor: const Color(0xFF140D1A),
                    showCheckmark: false,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                      side: BorderSide(color: isSelected ? Colors.transparent : const Color(0xFFE2C9A1).withOpacity(0.2)),
                    ),
                    onSelected: (valid) {
                      if (valid) {
                        setState(() {
                          _selectedCategory = category;
                          _filterInventoryPipeline();
                        });
                      }
                    },
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),

          // Items Grid Track Output Builder
          Expanded(
            child: _filteredProducts.isEmpty
                ? const Center(
              child: Text(
                "NO COMPATIBLE RECORDS LOCATED",
                style: TextStyle(fontFamily: 'Serif', color: Colors.white24, fontSize: 11, letterSpacing: 1.5),
              ),
            )
                : ListView.builder(
              itemCount: _filteredProducts.length,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemBuilder: (context, index) {
                final item = _filteredProducts[index] as Map<String, dynamic>;
                return _buildProductPremiumCard(item);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductPremiumCard(Map<String, dynamic> item) {
    final String title = item['title']?.toString() ?? 'UNNAMED RECORD';
    final String brand = item['brand']?.toString() ?? 'VAULT SPEC';
    final String category = (item['category']?.toString() ?? 'MISC').toUpperCase();
    final double price = double.tryParse(item['price']?.toString() ?? '0.0') ?? 0.0;
    final double rating = double.tryParse(item['rating']?.toString() ?? '0.0') ?? 0.0;
    final int stock = int.tryParse(item['stock']?.toString() ?? '0') ?? 0;

    String imageUrl = '';
    if (item['images'] != null && (item['images'] as List).isNotEmpty) {
      imageUrl = item['images'][0].toString();
    } else if (item['thumbnail'] != null) {
      imageUrl = item['thumbnail'].toString();
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF140D1A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2C9A1).withOpacity(0.12), width: 0.8),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: 105,
                color: const Color(0xFF0A060C),
                child: imageUrl.isNotEmpty
                    ? Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => const Center(
                    child: Icon(Icons.broken_image_outlined, color: Colors.white12, size: 20),
                  ),
                )
                    : const Center(
                  child: Icon(Icons.image_not_supported_outlined, color: Colors.white12, size: 20),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(14.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                category,
                                style: const TextStyle(color: Color(0xFFE2C9A1), fontSize: 8, letterSpacing: 1.5, fontWeight: FontWeight.bold),
                              ),
                              Row(
                                children: [
                                  const Icon(Icons.star_rounded, color: Color(0xFFE2C9A1), size: 11),
                                  const SizedBox(width: 2),
                                  Text(
                                    rating.toStringAsFixed(1),
                                    style: const TextStyle(color: Colors.white54, fontSize: 9, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              )
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontFamily: 'Serif', color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            "BY $brand".toUpperCase(),
                            style: const TextStyle(color: Colors.white24, fontSize: 9, letterSpacing: 0.5),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "\$${price.toStringAsFixed(2)}",
                            style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                            decoration: BoxDecoration(
                                color: stock < 10 ? const Color(0xFF3D1121) : const Color(0xFF0F1A12),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(
                                    color: stock < 10 ? const Color(0xFFF3A3B1).withOpacity(0.3) : const Color(0xFFB1F3C1).withOpacity(0.2),
                                    width: 0.5
                                )
                            ),
                            child: Text(
                              stock < 10 ? "LOW STOCK ($stock)" : "AVAILABLE ($stock)",
                              style: TextStyle(
                                color: stock < 10 ? const Color(0xFFF3A3B1) : const Color(0xFFB1F3C1),
                                fontSize: 7,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                        ],
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}