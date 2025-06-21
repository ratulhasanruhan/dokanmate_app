import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dokanmate_app/features/seller/model/SellerModel.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../auth/controller/auth_controller.dart';

class SellerController extends GetxController {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final uid = Get.find<AuthController>().user.value?.uid;

  final RxList<SellerModel> sellers = <SellerModel>[].obs;

  // Search query
  final RxString searchQuery = ''.obs;

  // Form controllers
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController shopNameController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController notesController = TextEditingController();

  // Loading states
  final RxBool isLoading = false.obs;

  // Filtered sellers computed based on searchQuery
  RxList<SellerModel> get filteredSellers {
    if (searchQuery.value.trim().isEmpty) {
      return sellers;
    }
    final lowerQuery = searchQuery.value.toLowerCase();
    final filtered = sellers.where((seller) {
      return seller.name.toLowerCase().contains(lowerQuery) ||
          seller.phone.toLowerCase().contains(lowerQuery) ||
          (seller.shopName?.toLowerCase().contains(lowerQuery) ?? false);
    }).toList();
    return filtered.obs;
  }

  // Live sync from Firestore
  @override
  void onInit() {
    super.onInit();
    _listenToSellers();
  }

  @override
  void onClose() {
    nameController.dispose();
    phoneController.dispose();
    shopNameController.dispose();
    addressController.dispose();
    notesController.dispose();
    super.onClose();
  }

  void _listenToSellers() {
    _db
        .collection('main')
        .doc(uid)
        .collection('seller')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen((snapshot) {
      sellers.value = snapshot.docs
          .map((doc) => SellerModel.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  // Clear form
  void clearForm() {
    nameController.clear();
    phoneController.clear();
    shopNameController.clear();
    addressController.clear();
    notesController.clear();
  }

  // Load seller data for editing
  void loadSellerForEdit(SellerModel seller) {
    nameController.text = seller.name;
    phoneController.text = seller.phone;
    shopNameController.text = seller.shopName ?? '';
    addressController.text = seller.address ?? '';
    notesController.text = seller.notes ?? '';
  }

  // Validate form
  bool validateForm() {
    if (nameController.text.trim().isEmpty) {
      Get.snackbar('ত্রুটি', 'নাম প্রয়োজন');
      return false;
    }
    if (phoneController.text.trim().isEmpty) {
      Get.snackbar('ত্রুটি', 'ফোন নম্বর প্রয়োজন');
      return false;
    }
    return true;
  }

  // Add seller
  Future<void> addSeller() async {
    if (!validateForm()) return;

    try {
      isLoading.value = true;
      final seller = SellerModel(
        id: '',
        name: nameController.text.trim(),
        phone: phoneController.text.trim(),
        shopName: shopNameController.text.trim().isEmpty ? null : shopNameController.text.trim(),
        address: addressController.text.trim().isEmpty ? null : addressController.text.trim(),
        notes: notesController.text.trim().isEmpty ? null : notesController.text.trim(),
        createdAt: DateTime.now(),
      );

      await _db
          .collection('main')
          .doc(uid)
          .collection('seller')
          .add(seller.toMap());
      
      clearForm();
      Get.back();
      Get.snackbar('সফল', 'ক্রেতা যোগ হয়েছে',
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.green[100]);
    } catch (e) {
      Get.snackbar('ত্রুটি', 'ক্রেতা যোগ করা যায়নি');
    } finally {
      isLoading.value = false;
    }
  }

  // Update seller
  Future<void> updateSeller(String sellerId) async {
    if (!validateForm()) return;

    try {
      isLoading.value = true;
      final data = {
        'name': nameController.text.trim(),
        'phone': phoneController.text.trim(),
        'shopName': shopNameController.text.trim().isEmpty ? null : shopNameController.text.trim(),
        'address': addressController.text.trim().isEmpty ? null : addressController.text.trim(),
        'notes': notesController.text.trim().isEmpty ? null : notesController.text.trim(),
      };

      await _db
          .collection('main')
          .doc(uid)
          .collection('seller')
          .doc(sellerId)
          .update(data);
      
      clearForm();
      Get.back();
      Get.snackbar('আপডেট হয়েছে', 'ক্রেতার তথ্য সংরক্ষিত হয়েছে',
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.blue[100]);
    } catch (e) {
      Get.snackbar('ত্রুটি', 'ক্রেতা আপডেট করা যায়নি');
    } finally {
      isLoading.value = false;
    }
  }

  // Delete seller
  Future<void> deleteSeller(String sellerId) async {
    try {
      isLoading.value = true;
      await _db
          .collection('main')
          .doc(uid)
          .collection('seller')
          .doc(sellerId)
          .delete();
      Get.back();
      Get.snackbar('মুছে ফেলা হয়েছে', 'ক্রেতার তথ্য মুছে ফেলা হয়েছে',
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red[100]);
    } catch (e) {
      Get.snackbar('ত্রুটি', 'ক্রেতা মুছে ফেলা যায়নি');
    } finally {
      isLoading.value = false;
    }
  }

  // Call seller
  Future<void> callSeller(String phone) async {
    final telUrl = 'tel:$phone';
    if (await canLaunchUrlString(telUrl)) {
      await launchUrlString(telUrl);
    } else {
      Get.snackbar('ত্রুটি', 'ফোন কল শুরু করা যায়নি');
    }
  }

  // Show delete confirmation dialog
  void showDeleteConfirmation(String sellerId, String sellerName) {
    Get.dialog(
      AlertDialog(
        title: Text('মুছে ফেলুন'),
        content: Text('আপনি কি "$sellerName" কে মুছে ফেলতে চান?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('না'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              deleteSeller(sellerId);
            },
            child: Text('হ্যাঁ', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // Navigate to add seller
  void navigateToAddSeller() {
    clearForm();
    Get.toNamed('/add_seller');
  }

  // Navigate to edit seller
  void navigateToEditSeller(SellerModel seller) {
    loadSellerForEdit(seller);
    Get.toNamed('/edit_seller', arguments: seller);
  }

  // Navigate to seller report
  void navigateToSellerReport() {
    Get.toNamed('/seller_report');
  }

  // Navigate to individual seller detail report
  void navigateToSellerDetailReport(SellerModel seller) {
    Get.toNamed('/seller_detail_report', arguments: seller);
  }
}
