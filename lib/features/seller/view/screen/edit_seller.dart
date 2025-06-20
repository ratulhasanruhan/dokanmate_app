import 'package:dokanmate_app/features/seller/model/SellerModel.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/seller_controller.dart';

class EditSellerPage extends StatefulWidget {
  final SellerModel seller;

  const EditSellerPage({super.key, required this.seller});

  @override
  _EditSellerPageState createState() => _EditSellerPageState();
}

class _EditSellerPageState extends State<EditSellerPage> {
  final _formKey = GlobalKey<FormState>();
  final SellerController sellerController = Get.find<SellerController>();

  late String name;
  late String phone;
  String? shopName;
  String? address;
  String? notes;

  @override
  void initState() {
    super.initState();
    final s = widget.seller;
    name = s.name;
    phone = s.phone;
    shopName = s.shopName;
    address = s.address;
    notes = s.notes;
  }

  Future<void> _updateSeller() async {
    if (_formKey.currentState!.validate()) {
      final data = {
        'name': name.trim(),
        'phone': phone.trim(),
        'shopName': (shopName?.trim().isEmpty ?? true) ? null : shopName!.trim(),
        'address': (address?.trim().isEmpty ?? true) ? null : address!.trim(),
        'notes': (notes?.trim().isEmpty ?? true) ? null : notes!.trim(),
      };

      await sellerController.updateSeller(widget.seller.id, data);

      Get.back();
      Get.snackbar('সফল', 'বিক্রেতার তথ্য আপডেট হয়েছে',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.shade100);
    }
  }

  Widget _buildTextField({
    required String label,
    required Function(String) onChanged,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    int maxLines = 1,
    String? initialValue,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        initialValue: initialValue,
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
        title: Text('বিক্রেতার তথ্য সম্পাদনা করুন'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildTextField(
                label: 'নাম *',
                initialValue: name,
                onChanged: (val) => name = val,
                validator: (val) => val!.isEmpty ? 'নাম লিখুন' : null,
              ),
              _buildTextField(
                label: 'ফোন নম্বর *',
                initialValue: phone,
                keyboardType: TextInputType.phone,
                onChanged: (val) => phone = val,
                validator: (val) => val!.isEmpty ? 'ফোন নম্বর দিন' : null,
              ),
              _buildTextField(
                label: 'দোকানের নাম (ঐচ্ছিক)',
                initialValue: shopName,
                onChanged: (val) => shopName = val,
              ),
              _buildTextField(
                label: 'ঠিকানা (ঐচ্ছিক)',
                initialValue: address,
                onChanged: (val) => address = val,
              ),
              _buildTextField(
                label: 'নোট (ঐচ্ছিক)',
                initialValue: notes,
                maxLines: 3,
                onChanged: (val) => notes = val,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _updateSeller,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  textStyle: TextStyle(fontSize: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                child: Text('আপডেট করুন'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
