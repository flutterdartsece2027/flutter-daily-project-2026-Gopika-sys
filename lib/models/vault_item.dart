import 'package:hive_flutter/hive_flutter.dart';

class VaultItem {
  final String id;
  String title;
  String description;
  double price;
  String imageUrl;

  VaultItem({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.imageUrl,
  });

  // Convert an object to a Map for simple Hive storage structure
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
    };
  }

  // Rebuild an object from a saved Hive Map
  factory VaultItem.fromMap(Map<dynamic, dynamic> map) {
    return VaultItem(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
      imageUrl: map['imageUrl'] ?? '',
    );
  }
}

class VaultDataManager {
  static final VaultDataManager _instance = VaultDataManager._internal();
  factory VaultDataManager() => _instance;
  VaultDataManager._internal();

  final List<VaultItem> sessionVaultItems = [];

  // Name of the persistent database box
  static const String _boxName = 'luxury_vault_box';

  // Initialize Hive and pull records into active runtime memory
  Future<void> initHiveAndLoadData() async {
    await Hive.initFlutter();

    // Open the local disk file box
    final box = await Hive.openBox(_boxName);

    sessionVaultItems.clear();
    // Read items out of Hive database storage and map them to our list
    if (box.isNotEmpty) {
      for (var key in box.keys) {
        final savedMap = box.get(key);
        if (savedMap is Map) {
          sessionVaultItems.add(VaultItem.fromMap(savedMap));
        }
      }
    }
  }

  // Writes a single item addition or modification down to disk storage
  Future<void> saveOrUpdateItem(VaultItem item) async {
    final box = Hive.box(_boxName);
    await box.put(item.id, item.toMap());
  }

  // Purges a single row item instantly off disk directory storage
  Future<void> deleteItemFromDisk(String id) async {
    final box = Hive.box(_boxName);
    await box.delete(id);
  }
}