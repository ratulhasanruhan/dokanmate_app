import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/seller_controller.dart';

class AddSellerPage extends StatelessWidget {
  const AddSellerPage({super.key});

  @override
  Widget build(BuildContext context) {
    final SellerController controller = Get.find<SellerController>();

    Widget _buildTextField({
      required String label,
      required TextEditingController textController,
      TextInputType? keyboardType,
      int maxLines = 1,
      bool required = false,
      String? hintText,
      IconData? prefixIcon,
    }) {
      return Container(
        margin: EdgeInsets.only(bottom: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              required ? '$label *' : label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(height: 8),
            TextFormField(
              controller: textController,
              maxLines: maxLines,
              keyboardType: keyboardType ?? TextInputType.text,
              decoration: InputDecoration(
                hintText: hintText,
                prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: Colors.grey[600]) : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.blue.shade400, width: 2),
                ),
                filled: true,
                fillColor: Colors.grey[50],
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text('নতুন ক্রেতা যোগ করুন'),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: IconThemeData(color: Colors.black87),
        titleTextStyle: TextStyle(
          color: Colors.black87,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header card
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.person_add, color: Colors.blue[700], size: 24),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'নতুন ক্রেতার তথ্য দিন',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.blue[700],
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'সব তথ্য সঠিকভাবে পূরণ করুন',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.blue[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24),

            // Form card
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
                    hintText: 'ক্রেতার পূর্ণ নাম লিখুন',
                    prefixIcon: Icons.person,
                  ),
                  _buildTextField(
                    label: 'ফোন নম্বর',
                    textController: controller.phoneController,
                    keyboardType: TextInputType.phone,
                    required: true,
                    hintText: '০১১১১১১১১১১',
                    prefixIcon: Icons.phone,
                  ),
                  _buildTextField(
                    label: 'দোকানের নাম',
                    textController: controller.shopNameController,
                    hintText: 'দোকানের নাম (ঐচ্ছিক)',
                    prefixIcon: Icons.store,
                  ),
                  _buildTextField(
                    label: 'ঠিকানা',
                    textController: controller.addressController,
                    maxLines: 2,
                    hintText: 'ক্রেতার ঠিকানা (ঐচ্ছিক)',
                    prefixIcon: Icons.location_on,
                  ),
                  _buildTextField(
                    label: 'নোট',
                    textController: controller.notesController,
                    maxLines: 3,
                    hintText: 'অতিরিক্ত তথ্য বা নোট (ঐচ্ছিক)',
                    prefixIcon: Icons.note,
                  ),
                ],
              ),
            ),
            SizedBox(height: 24),

            // Save button
            Obx(() => ElevatedButton(
              onPressed: controller.isLoading.value ? null : controller.addSeller,
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
                          'সংরক্ষণ হচ্ছে...',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.save, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'সংরক্ষণ করুন',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
            )),
          ],
        ),
      ),
    );
  }
}
