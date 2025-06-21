import 'package:dokanmate_app/features/seller/model/SellerModel.dart';
import 'package:dokanmate_app/features/seller/view/screen/add_seller.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../controller/invoice_controller.dart';

class AddInvoiceScreen extends StatelessWidget {
  AddInvoiceScreen({super.key});

  final InvoiceController controller = Get.find<InvoiceController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text('নতুন বিল', style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        )),
        backgroundColor: Color(0xFF16610E),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        actions: [
          InkWell(
            onTap: (){
              Get.to(() => AddSellerPage());
            },
            borderRadius: BorderRadius.circular(6.r),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 12.w,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5.r),
                      border: Border.all(
                        color: Colors.white,
                        width: 1,
                      ),
                    ),
                    child: Icon(
                      Icons.add,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  Text(
                    'নতুন\nক্রেতা',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: Offset(0, 2),
              ),
            ],
          ),
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Color(0xFF16610E).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.receipt_long,
                      color: Color(0xFF16610E),
                      size: 24,
                    ),
                  ),
                  SizedBox(width: 12),
                  Text(
                    'বিলের তথ্য দিন',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2C3E50),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 24),

              // Seller Dropdown
              Text('ক্রেতা নির্বাচন করুন *', style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
                color: Color(0xFF2C3E50),
              )),
              SizedBox(height: 8),

              Obx(() => Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Color(0xFFDEE2E6)),
                  color: Colors.white,
                ),
                child: DropdownSearch<SellerModel>(
                  items: controller.sellerController.sellers, // must be List<SellerModel>
                  selectedItem: controller.sellerController.sellers.firstWhereOrNull(
                        (e) => e.id == controller.selectedSellerId.value,
                  ),
                  onChanged: (SellerModel? seller) {
                    if (seller != null) {
                      controller.selectedSellerId.value = seller.id;
                    }
                  },
                  popupProps: PopupProps.menu(
                    showSearchBox: true,
                    searchFieldProps: TextFieldProps(
                      decoration: InputDecoration(
                        hintText: 'সার্চ করুন',
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                    ),
                    itemBuilder: (context, SellerModel item, bool isSelected) {
                      return ListTile(
                        title: Text(
                          '${item.name}${item.shopName != null ? ' (${item.shopName})' : ''}',
                          style: TextStyle(fontSize: 14),
                        ),
                      );
                    },
                  ),
                  dropdownDecoratorProps: DropDownDecoratorProps(
                    dropdownSearchDecoration: InputDecoration(
                      hintText: 'ক্রেতা বেছে নিন',
                      hintStyle: TextStyle(color: Colors.grey[500]),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      prefixIcon: Icon(Icons.person, color: Color(0xFF16610E)),
                    ),
                  ),
                  dropdownButtonProps: DropdownButtonProps(
                    icon: Icon(Icons.keyboard_arrow_down, color: Color(0xFF16610E)),
                  ),
                    filterFn: (item, filter) {
                      final query = filter.toLowerCase();
                      return item.name.toLowerCase().contains(query) ||
                          (item.shopName?.toLowerCase().contains(query) ?? false) ||
                          (item.phone.toLowerCase().contains(query));
                    }
                ),
              )),
              SizedBox(height: 20),

              // Input Fields Row 1
              Row(
                children: [
                  Expanded(
                    child: _buildInputField(
                      'পিস *',
                      controller.piecesController,
                      TextInputType.number,
                      Icons.apps,
                      'পিস সংখ্যা',
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: _buildInputField(
                      'ওজন (কেজি) *',
                      controller.kgController,
                      TextInputType.numberWithOptions(decimal: true),
                      Icons.monitor_weight,
                      '০.০',
                    ),
                  ),
                ],
              ),

              SizedBox(height: 16),

              // Unit Price Field
              _buildInputField(
                'দর (প্রতি কেজি) *',
                controller.unitPriceController,
                TextInputType.number,
                Icons.price_change,
                'প্রতি কেজি দাম',
              ),

              SizedBox(height: 16),

              // Notes Field
              Text('নোট (ঐচ্ছিক)', style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
                color: Color(0xFF2C3E50),
              )),
              SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Color(0xFFDEE2E6)),
                  color: Colors.white,
                ),
                child: TextField(
                  controller: controller.notesController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'অতিরিক্ত তথ্য লিখুন...',
                    hintStyle: TextStyle(color: Colors.grey[500]),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(16),
                    prefixIcon: Padding(
                      padding: EdgeInsets.only(top: 12, left: 12),
                      child: Icon(Icons.note_alt, color: Color(0xFF16610E)),
                    ),
                  ),
                ),
              ),

              SizedBox(height: 32),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Get.back();
                      },
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        side: BorderSide(color: Color(0xFF16610E)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'বাতিল',
                        style: TextStyle(
                          color: Color(0xFF16610E),
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: Obx(() => ElevatedButton(
                      onPressed: controller.isLoading.value ? null : () => controller.addInvoice(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF16610E),
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 2,
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
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      )
                          : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.save, color: Colors.white, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'বিল সংরক্ষণ করুন',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    )),
                  ),
                ],
              ),

              SizedBox(height: 16),

              // Info Card
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Color(0xFF16610E).withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Color(0xFF16610E).withValues(alpha: 0.2)),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Color(0xFF16610E),
                      size: 20,
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'বিল সংরক্ষণের পর আপনি এটি চূড়ান্ত করতে পারবেন এবং মোট টাকার হিসাব দেখতে পাবেন।',
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF16610E),
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField(
      String label,
      TextEditingController controller,
      TextInputType keyboardType,
      IconData icon,
      String hint,
      ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 14,
          color: Color(0xFF2C3E50),
        )),
        SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Color(0xFFDEE2E6)),
            color: Colors.white,
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: Colors.grey[500]),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              prefixIcon: Icon(icon, color: Color(0xFF16610E)),
            ),
          ),
        ),
      ],
    );
  }
}