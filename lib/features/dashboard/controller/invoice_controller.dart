import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dokanmate_app/features/seller/model/SellerModel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../seller/controller/seller_controller.dart';
import '../model/InvoiceModel.dart';

class InvoiceController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final RxList<Invoice> invoices = <Invoice>[].obs;
  final RxBool isLoading = false.obs;
  final RxString selectedSellerId = ''.obs;

  // Form controllers
  final TextEditingController piecesController = TextEditingController();
  final TextEditingController kgController = TextEditingController();
  final TextEditingController unitPriceController = TextEditingController();
  final TextEditingController notesController = TextEditingController();

  final SellerController sellerController = Get.find<SellerController>();

  @override
  void onInit() {
    super.onInit();
    loadInvoices();
  }

  String get currentUserId => _auth.currentUser?.uid ?? '';

  // Load invoices
  Future<void> loadInvoices() async {
    try {
      isLoading.value = true;
      final snapshot = await _firestore
          .collection('main')
          .doc(currentUserId)
          .collection('invoices')
          .orderBy('createdAt', descending: true)
          .get();

      invoices.value = snapshot.docs
          .map((doc) => Invoice.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      Get.snackbar('দুঃখিত', 'ইনভয়েস লোড হচ্ছে না: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Add new invoice (draft)
  Future<void> addInvoice() async {
    if (!_validateForm()) return;

    try {
      isLoading.value = true;

      final invoice = Invoice(
        sellerId: selectedSellerId.value,
        pieces: double.parse(piecesController.text),
        kg: double.parse(kgController.text),
        unitPrice: double.parse(unitPriceController.text),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        notes: notesController.text.isEmpty ? null : notesController.text,
      );

      await _firestore
          .collection('main')
          .doc(currentUserId)
          .collection('invoices')
          .add(invoice.toMap());

      _clearForm();
      await loadInvoices();
      Get.back();

      Get.snackbar('সফল', 'খসড়া বিল তৈরী হয়েছে', backgroundColor: Colors.green[100]);

    } catch (e) {
      Get.snackbar('দুঃখিত', 'বিল তৈরিতে সমস্যা হৈছে: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Finalize invoice (calculate totals)
  Future<void> finalizeInvoice(Invoice invoice) async {
    try {
      isLoading.value = true;

      final totalAmount = invoice.kg * invoice.unitPrice;
      final finalizedInvoice = invoice.copyWith(
        totalAmount: totalAmount,
        amountDue: totalAmount,
        status: 'finalized',
        isDraft: false,
        finalizedAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _firestore
          .collection('main')
          .doc(currentUserId)
          .collection('invoices')
          .doc(invoice.id)
          .update(finalizedInvoice.toMap());

      await loadInvoices();
      Get.snackbar('সফল', 'Invoice finalized', backgroundColor: Colors.green[100]);
    } catch (e) {
      Get.snackbar('দুঃখিত', 'Failed to finalize invoice: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Add payment
  Future<void> addPayment(Invoice invoice, double amount) async {
    try {
      isLoading.value = true;

      final newAmountPaid = invoice.amountPaid + amount;
      final newAmountDue = invoice.totalAmount - newAmountPaid;

      String newStatus;
      if (newAmountDue <= 0) {
        newStatus = 'paid';
      } else if (newAmountPaid > 0) {
        newStatus = 'partial';
      } else {
        newStatus = 'finalized';
      }

      final updatedInvoice = invoice.copyWith(
        amountPaid: newAmountPaid,
        amountDue: newAmountDue,
        status: newStatus,
        paymentDate: newStatus == 'paid' ? DateTime.now() : invoice.paymentDate,
        updatedAt: DateTime.now(),
      );

      await _firestore
          .collection('main')
          .doc(currentUserId)
          .collection('invoices')
          .doc(invoice.id)
          .update(updatedInvoice.toMap());

      await loadInvoices();
      Get.back();
      Get.snackbar('সফল', 'পেমেন্ট যুক্ত হয়েছে', backgroundColor: Colors.green[100]);
    } catch (e) {
      Get.snackbar('দুঃখিত', 'পেমেন্ট এ ত্রুটি: $e');
    } finally {
      isLoading.value = false;
    }
  }

  bool _validateForm() {
    if (selectedSellerId.value.isEmpty) {
      Get.snackbar('দুঃখিত', 'একজন ক্রেতা নির্বাচন করুন। অথবা যুক্ত করুন');
      return false;
    }
    if (piecesController.text.isEmpty || double.tryParse(piecesController.text) == null) {
      Get.snackbar('দুঃখিত', 'কত পিচ্?');
      return false;
    }
    if (kgController.text.isEmpty || double.tryParse(kgController.text) == null) {
      Get.snackbar('দুঃখিত', 'ওজন কত?');
      return false;
    }
    if (unitPriceController.text.isEmpty || double.tryParse(unitPriceController.text) == null) {
      Get.snackbar('দুঃখিত', 'প্রতি কেজি দাম কত?');
      return false;
    }
    return true;
  }

  void _clearForm() {
    selectedSellerId.value = '';
    piecesController.clear();
    kgController.clear();
    unitPriceController.clear();
    notesController.clear();
  }

  SellerModel? getSellerById(String sellerId) {
    try {
      return sellerController.sellers.firstWhere((seller) => seller.id == sellerId);
    } catch (e) {
      return null;
    }
  }

  @override
  void onClose() {
    piecesController.dispose();
    kgController.dispose();
    unitPriceController.dispose();
    notesController.dispose();
    super.onClose();
  }
}