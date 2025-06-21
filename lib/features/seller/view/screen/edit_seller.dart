import 'package:dokanmate_app/features/seller/model/SellerModel.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/seller_controller.dart';

class EditSellerPage extends StatelessWidget {
  final SellerModel seller;

  const EditSellerPage({super.key, required this.seller});

  @override
  Widget build(BuildContext context) {
    final SellerController controller = Get.find<SellerController>();

    Widget _buildTextField({
      required String label,
      required TextEditingController textController,
      TextInputType? keyboardType,
      int maxLines = 1,
      bool required = false,
    }) {
      return Container(
        margin: EdgeInsets.only(bottom: 16),
        child: TextFormField(
          controller: textController,
          maxLines: maxLines,
          keyboardType: keyboardType ?? TextInputType.text,
          decoration: InputDecoration(
            labelText: required ? '$label *' : label,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            filled: true,
            fillColor: Colors.grey[50],
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text('সম্পাদনা করুন'),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: IconThemeData(color: Colors.black87),
        titleTextStyle: TextStyle(
          color: Colors.black87,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.delete, color: Colors.red[600]),
            onPressed: () => controller.showDeleteConfirmation(seller.id, seller.name),
            tooltip: 'মুছে ফেলুন',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  _buildTextField(
                    label: 'নাম',
                    textController: controller.nameController,
                    required: true,
                  ),
                  _buildTextField(
                    label: 'ফোন নম্বর',
                    textController: controller.phoneController,
                    keyboardType: TextInputType.phone,
                    required: true,
                  ),
                  _buildTextField(
                    label: 'দোকানের নাম',
                    textController: controller.shopNameController,
                  ),
                  _buildTextField(
                    label: 'ঠিকানা',
                    textController: controller.addressController,
                    maxLines: 2,
                  ),
                  _buildTextField(
                    label: 'নোট',
                    textController: controller.notesController,
                    maxLines: 3,
                  ),
                ],
              ),
            ),
            SizedBox(height: 24),
            Obx(() => ElevatedButton(
              onPressed: controller.isLoading.value ? null : () => controller.updateSeller(seller.id),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[600],
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
              child: controller.isLoading.value
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ),
                        SizedBox(width: 8),
                        Text(
                          'আপডেট হচ্ছে...',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    )
                  : Text(
                      'আপডেট করুন',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            )),
          ],
        ),
      ),
    );
  }
}
