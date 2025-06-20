import 'package:dokanmate_app/features/seller/model/SellerModel.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/seller_controller.dart';

class AddSellerPage extends StatefulWidget {
  @override
  _AddSellerPageState createState() => _AddSellerPageState();
}

class _AddSellerPageState extends State<AddSellerPage> {
  final _formKey = GlobalKey<FormState>();
  final SellerController sellerController = Get.find<SellerController>();

  String name = '';
  String phone = '';
  String? shopName;
  String? address;
  String? notes;

  void _saveSeller() async {
    if (_formKey.currentState!.validate()) {
      final newSeller = SellerModel(
        id: '',
        name: name.trim(),
        phone: phone.trim(),
        shopName: (shopName?.trim().isEmpty ?? true) ? null : shopName!.trim(),
        address: (address?.trim().isEmpty ?? true) ? null : address!.trim(),
        notes: (notes?.trim().isEmpty ?? true) ? null : notes!.trim(),
        createdAt: DateTime.now(),
      );

      await sellerController.addSeller(newSeller);

      Get.back();
      Get.snackbar('সফল', 'বিক্রেতা যোগ হয়েছে',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green.shade100);
    }
  }

  Widget _buildTextField({
    required String label,
    required Function(String) onChanged,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        maxLines: maxLines,
        keyboardType: keyboardType ?? TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          border:
          OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
        onChanged: onChanged,
        validator: validator,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('নতুন বিক্রেতা যোগ করুন'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildTextField(
                label: 'নাম *',
                onChanged: (val) => name = val,
                validator: (val) => val!.isEmpty ? 'নাম লিখুন' : null,
              ),
              _buildTextField(
                label: 'ফোন নম্বর *',
                keyboardType: TextInputType.phone,
                onChanged: (val) => phone = val,
                validator: (val) => val!.isEmpty ? 'ফোন নম্বর দিন' : null,
              ),
              _buildTextField(
                label: 'দোকানের নাম (ঐচ্ছিক)',
                onChanged: (val) => shopName = val,
              ),
              _buildTextField(
                label: 'ঠিকানা (ঐচ্ছিক)',
                onChanged: (val) => address = val,
              ),
              _buildTextField(
                label: 'নোট (ঐচ্ছিক)',
                maxLines: 3,
                onChanged: (val) => notes = val,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveSeller,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  textStyle: TextStyle(fontSize: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                child: Text('সংরক্ষণ করুন'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
