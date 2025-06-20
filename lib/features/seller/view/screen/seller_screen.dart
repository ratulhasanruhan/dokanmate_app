import 'package:dokanmate_app/features/seller/controller/seller_controller.dart';
import 'package:dokanmate_app/features/seller/model/SellerModel.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'add_seller.dart';
import 'edit_seller.dart';

class SellerPage extends StatefulWidget {
  const SellerPage({super.key});

  @override
  State<SellerPage> createState() => _SellerPageState();
}

class _SellerPageState extends State<SellerPage> {
  final SellerController sellerController = Get.put(SellerController());
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();

    _searchController.addListener(() {
      sellerController.searchQuery.value = _searchController.text;
    });
  }

  void _showSearchSheet() {
    _searchController.text = sellerController.searchQuery.value;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom, top: 12, left: 16, right: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _searchController,
              autofocus: true,
              decoration: InputDecoration(
                labelText: 'বিক্রেতা খুঁজুন (নাম, ফোন, দোকানের নাম)',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  _searchController.clear();
                  sellerController.searchQuery.value = '';
                  Navigator.pop(context);
                },
                child: Text('বন্ধ করুন', style: TextStyle(fontSize: 16)),
              ),
            ),
            SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildSellerCard(SellerModel seller) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 6),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Name + Edit icon row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    seller.name,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.edit, color: Colors.lightGreen),
                  onPressed: () => Get.to(() => EditSellerPage(seller: seller)),
                  tooltip: 'সম্পাদনা করুন',
                ),
              ],
            ),

            SizedBox(height: 6),

            // Phone row with call button
            Row(
              children: [
                Icon(Icons.phone, size: 18, color: Colors.green[700]),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    seller.phone,
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                TextButton.icon(
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.green[50],
                    minimumSize: Size(80, 32),
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () => sellerController.callSeller(seller.phone),
                  icon: Icon(Icons.call, size: 18, color: Colors.green[700]),
                  label: Text('কল করুন', style: TextStyle(color: Colors.green[700])),
                )
              ],
            ),

            SizedBox(height: 6),

            if (seller.shopName != null && seller.shopName!.isNotEmpty)
              Row(
                children: [
                  Icon(Icons.store, size: 18, color: Colors.grey[600]),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      seller.shopName!,
                      style: TextStyle(fontSize: 15, color: Colors.grey[800]),
                    ),
                  ),
                ],
              ),

            if (seller.address != null && seller.address!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 6.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.location_on, size: 18, color: Colors.grey[600]),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        seller.address!,
                        style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ক্রেতাগন'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            tooltip: 'বিক্রেতা খুঁজুন',
            onPressed: _showSearchSheet,
          )
        ],
      ),
      body: Obx(() {
        final sellers = sellerController.filteredSellers;
        if (sellers.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('কোনো বিক্রেতা পাওয়া যায়নি'),
                SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () => Get.to(() => AddSellerPage()),
                  child: Text('নতুন বিক্রেতা যোগ করুন'),
                )
              ],
            ),
          );
        }
        return ListView.builder(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          itemCount: sellers.length,
          itemBuilder: (_, i) => _buildSellerCard(sellers[i]),
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.to(() => AddSellerPage()),
        tooltip: 'নতুন বিক্রেতা যোগ করুন',
        child: Icon(Icons.add),
      ),
    );
  }
}
