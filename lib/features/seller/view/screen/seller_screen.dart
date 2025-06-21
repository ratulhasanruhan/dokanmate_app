import 'package:dokanmate_app/features/seller/controller/seller_controller.dart';
import 'package:dokanmate_app/features/seller/model/SellerModel.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SellerPage extends StatelessWidget {
  SellerPage({super.key});

  final SellerController controller = Get.find<SellerController>();


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text('ক্রেতাগণ'),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 1,
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('ক্রেতা খুঁজুন'),
                  content: TextField(
                    controller: TextEditingController(text: controller.searchQuery.value),
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: 'নাম, ফোন বা দোকানের নাম লিখুন',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) => controller.searchQuery.value = value,
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        controller.searchQuery.value = '';
                        Navigator.pop(context);
                      },
                      child: Text('মুছুন'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('বন্ধ করুন'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Container(
            padding: EdgeInsets.all(16),
            child: TextField(
              controller: TextEditingController(text: controller.searchQuery.value),
              onChanged: (value) => controller.searchQuery.value = value,
              decoration: InputDecoration(
                hintText: 'ক্রেতা খুঁজুন...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),
          // Sellers list
          Expanded(
            child: Obx(() {
              final sellers = controller.filteredSellers;
              if (sellers.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.people_outline,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      SizedBox(height: 16),
                      Text(
                        controller.searchQuery.value.isEmpty
                            ? 'কোনো ক্রেতা নেই'
                            : 'কোনো ক্রেতা পাওয়া যায়নি',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                      SizedBox(height: 8),
                      if (controller.searchQuery.value.isEmpty)
                        TextButton(
                          onPressed: controller.navigateToAddSeller,
                          child: Text('প্রথম ক্রেতা যোগ করুন'),
                        ),
                    ],
                  ),
                );
              }
              return ListView.builder(
                itemCount: sellers.length,
                itemBuilder: (_, i) => _buildSellerItem(sellers[i]),
              );
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: controller.navigateToAddSeller,
        child: Icon(Icons.add),
        tooltip: 'নতুন ক্রেতা যোগ করুন',
      ),
    );
  }

  Widget _buildSellerItem(SellerModel seller) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(
          seller.name,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.phone, size: 14, color: Colors.grey[600]),
                SizedBox(width: 4),
                Text(
                  seller.phone,
                  style: TextStyle(fontSize: 14),
                ),
              ],
            ),
            if (seller.shopName != null && seller.shopName!.isNotEmpty) ...[
              SizedBox(height: 2),
              Row(
                children: [
                  Icon(Icons.store, size: 14, color: Colors.grey[600]),
                  SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      seller.shopName!,
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.bar_chart, size: 20, color: Colors.purple[600]),
              onPressed: () => controller.navigateToSellerDetailReport(seller),
              tooltip: 'রিপোর্ট দেখুন',
            ),
            IconButton(
              icon: Icon(Icons.call, size: 20, color: Colors.green[600]),
              onPressed: () => controller.callSeller(seller.phone),
              tooltip: 'কল করুন',
            ),
            IconButton(
              icon: Icon(Icons.edit, size: 20, color: Colors.blue[500]),
              onPressed: () => controller.navigateToEditSeller(seller),
              tooltip: 'সম্পাদনা করুন',
            ),
          ],
        ),
        onTap: () => controller.navigateToSellerDetailReport(seller),
      ),
    );
  }
}
