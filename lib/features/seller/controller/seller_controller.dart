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

  // Add seller
  Future<void> addSeller(SellerModel seller) async {
    try {
      await _db
          .collection('main')
          .doc(uid)
          .collection('seller')
          .add(seller.toMap());
      Get.back();
      Get.snackbar('সফল', 'বিক্রেতা যোগ হয়েছে',
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.green[100]);
    } catch (e) {
      Get.snackbar('ত্রুটি', 'বিক্রেতা যোগ করা যায়নি');
    }
  }

  // Edit seller
  Future<void> updateSeller(String sellerId, Map<String, dynamic> data) async {
    try {
      await _db
          .collection('main')
          .doc(uid)
          .collection('seller')
          .doc(sellerId)
          .update(data);
      Get.back();
      Get.snackbar('আপডেট হয়েছে', 'বিক্রেতার তথ্য সংরক্ষিত হয়েছে',
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.blue[100]);
    } catch (e) {
      Get.snackbar('ত্রুটি', 'বিক্রেতা আপডেট করা যায়নি');
    }
  }

  // Delete seller
  Future<void> deleteSeller(String sellerId) async {
    try {
      await _db
          .collection('main')
          .doc(uid)
          .collection('seller')
          .doc(sellerId)
          .delete();
      Get.snackbar('মুছে ফেলা হয়েছে', 'বিক্রেতার তথ্য মুছে ফেলা হয়েছে',
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red[100]);
    } catch (e) {
      Get.snackbar('ত্রুটি', 'বিক্রেতা মুছে ফেলা যায়নি');
    }
  }

  Future<void> callSeller(String phone) async {
    final telUrl = 'tel:$phone';
    if (await canLaunchUrlString(telUrl)) {
      await launchUrlString(telUrl);
    } else {
      Get.snackbar('ত্রুটি', 'ফোন কল শুরু করা যায়নি');
    }
  }

}
