import 'package:cloud_firestore/cloud_firestore.dart';

class SellerModel {
  String id; // Firestore doc ID
  String name;
  String phone;
  String? shopName;
  String? address;
  DateTime createdAt;
  String? notes;

  SellerModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.createdAt,
    this.shopName,
    this.address,
    this.notes,
  });

  factory SellerModel.fromMap(Map<String, dynamic> map, String docId) {
    return SellerModel(
      id: docId,
      name: map['name'] ?? '',
      phone: map['phone'] ?? '',
      shopName: map['shopName'],
      address: map['address'],
      notes: map['notes'],
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'phone': phone,
      if (shopName != null) 'shopName': shopName,
      if (address != null) 'address': address,
      if (notes != null) 'notes': notes,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  @override
  String toString() {
    return name + (shopName != null ? ' ($shopName)' : '');
  }

}
