import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseVaultController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Reactive list of vault items
  var vaultItems = <QueryDocumentSnapshot>[].obs;
  
  // Reactive loading state
  var isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    // Bind the firestore stream to our reactive list
    vaultItems.bindStream(
      _firestore.collection('maison_vault').snapshots().map((snapshot) => snapshot.docs)
    );
    
    // Update loading state when items are received
    ever(vaultItems, (_) => isLoading.value = false);
  }

  Future<void> addAsset(String name, String value) async {
    try {
      await _firestore.collection('maison_vault').add({
        'assetName': name,
        'valValue': value,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      Get.snackbar("Error", "Failed to add asset: $e");
    }
  }
}