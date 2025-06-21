import 'package:dokanmate_app/core/utils/app_colors.dart';
import 'package:dokanmate_app/features/dashboard/controller/invoice_controller.dart';
import 'package:dokanmate_app/features/dashboard/view/widgets/dashboard_drawer.dart';
import 'package:dokanmate_app/features/seller/model/SellerModel.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../core/utils/constants.dart';
import '../../model/InvoiceModel.dart';
import 'add_invoice.dart';

class DashboardScreen extends StatelessWidget {
  DashboardScreen({super.key});

  final InvoiceController controller = Get.find<InvoiceController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        centerTitle: true,
        title: Text(
          appName,
          style: TextStyle(
            color: Colors.white
          ),
        ),
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
      ),
      drawer: DashboardDrawer(),
      body: Obx(() {
        if (controller.isLoading.value && controller.invoices.isEmpty) {
          return Center(child: CupertinoActivityIndicator(color: primaryColor, radius: 22));
        }

        if (controller.invoices.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.receipt_long_outlined, size: 80, color: Colors.grey[400]),
                SizedBox(height: 16),
                Text('কোন বিল নেই', style: TextStyle(
                    fontSize: 18, color: Colors.grey[600]
                )),
                SizedBox(height: 8),
                Text('নতুন বিল যোগ করুন', style: TextStyle(
                    fontSize: 14, color: Colors.grey[500]
                )),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.loadInvoices,
          color: Color(0xFF3498DB),
          child: ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: controller.invoices.length,
            itemBuilder: (context, index) {
              final invoice = controller.invoices[index];
              final seller = controller.getSellerById(invoice.sellerId);

              return Container(
                margin: EdgeInsets.only(bottom: 12),
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
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => _showInvoiceDetails(context, invoice, seller),
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      seller?.name ?? 'অজানা ক্রেতা',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF2C3E50),
                                      ),
                                    ),
                                    if (seller?.shopName != null) ...[
                                      SizedBox(height: 2),
                                      Text(
                                        seller!.shopName!,
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              _buildStatusBadge(invoice.status),
                            ],
                          ),

                          SizedBox(height: 12),

                          Row(
                            children: [
                              Expanded(
                                child: _buildInfoCard('পিস', '${invoice.pieces.toInt()}', Icons.apps),
                              ),
                              SizedBox(width: 8),
                              Expanded(
                                child: _buildInfoCard('ওজন', '${invoice.kg.toStringAsFixed(1)} কেজি', Icons.monitor_weight),
                              ),
                              SizedBox(width: 8),
                              Expanded(
                                child: _buildInfoCard('দর', '৳${invoice.unitPrice.toInt()}', Icons.price_change),
                              ),
                            ],
                          ),

                          if (!invoice.isDraft) ...[
                            SizedBox(height: 12),
                            Container(
                              padding: EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Color(0xFFF8F9FA),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Color(0xFFE9ECEF)),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('মোট: ৳${invoice.totalAmount.toStringAsFixed(0)}',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 16,
                                            color: Color(0xFF2C3E50),
                                          )),
                                      if (invoice.amountDue > 0)
                                        Text('বাকি: ৳${invoice.amountDue.toStringAsFixed(0)}',
                                            style: TextStyle(
                                              color: Color(0xFFE74C3C),
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                            )),
                                    ],
                                  ),
                                  if (invoice.amountDue > 0)
                                    GestureDetector(
                                      onTap: () => _showPaymentDialog(context, invoice),
                                      child: Container(
                                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: Color(0xFF27AE60),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text('পেমেন্ট',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                            )),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],

                          if (invoice.isDraft) ...[
                            SizedBox(height: 12),
                            GestureDetector(
                              onTap: () => controller.finalizeInvoice(invoice),
                              child: Container(
                                width: double.infinity,
                                padding: EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Color(0xFF3498DB),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text('বিল চূড়ান্ত করুন',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500,
                                    )),
                              ),
                            ),
                          ],

                          SizedBox(height: 8),
                          Text(
                            'তারিখ: ${DateFormat('dd/MM/yyyy').format(invoice.createdAt)}',
                            style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[500]
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      }),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.to(() => AddInvoiceScreen()),
        backgroundColor: primaryColor,
        label: Text(
          'নতুন বিল',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        icon: Icon(Icons.add, color: Colors.white, size: 20)
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    String text;

    switch (status) {
      case 'paid':
        color = Color(0xFF27AE60);
        text = 'পরিশোধিত';
        break;
      case 'partial':
        color = Color(0xFFF39C12);
        text = 'আংশিক';
        break;
      case 'finalized':
        color = Color(0xFFE74C3C);
        text = 'বাকি';
        break;
      default:
        color = Color(0xFF95A5A6);
        text = 'খসড়া';
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: color,
        ),
      ),
    );
  }

  Widget _buildInfoCard(String label, String value, IconData icon) {
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        children: [
          Icon(icon, size: 18, color: Color(0xFF6C757D)),
          SizedBox(height: 4),
          Text(value, style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: Color(0xFF2C3E50),
          )),
          Text(label, style: TextStyle(
              fontSize: 12,
              color: Color(0xFF6C757D)
          )),
        ],
      ),
    );
  }

  void _showInvoiceDetails(BuildContext context, Invoice invoice, SellerModel? seller) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text('বিলের বিস্তারিত',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600
                      )),
                ),
                IconButton(
                  onPressed: () => Get.back(),
                  icon: Icon(Icons.close),
                ),
              ],
            ),
            Divider(),
            SizedBox(height: 16),

            _buildDetailRow('ক্রেতা', seller?.name ?? 'অজানা'),
            if (seller?.shopName != null)
              _buildDetailRow('দোকান', seller!.shopName!),
            _buildDetailRow('পিস', '${invoice.pieces.toInt()}'),
            _buildDetailRow('ওজন', '${invoice.kg} কেজি'),
            _buildDetailRow('দর', '৳${invoice.unitPrice}/কেজি'),

            if (!invoice.isDraft) ...[
              Divider(height: 32),
              _buildDetailRow('মোট টাকা', '৳${invoice.totalAmount.toStringAsFixed(0)}'),
              if (invoice.amountPaid > 0)
                _buildDetailRow('জমা', '৳${invoice.amountPaid.toStringAsFixed(0)}'),
              if (invoice.amountDue > 0)
                _buildDetailRow('বাকি', '৳${invoice.amountDue.toStringAsFixed(0)}'),
            ],

            _buildDetailRow('তারিখ', DateFormat('dd MMMM yyyy').format(invoice.createdAt)),
            _buildDetailRow('স্ট্যাটাস', _getStatusText(invoice.status)),

            if (invoice.notes != null) ...[
              SizedBox(height: 16),
              Text('নোট:', style: TextStyle(
                  fontWeight: FontWeight.w500
              )),
              SizedBox(height: 4),
              Text(invoice.notes!),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text('$label:', style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            )),
          ),
          Expanded(
            child: Text(value, style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 14,
            )),
          ),
        ],
      ),
    );
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'paid': return 'পরিশোধিত';
      case 'partial': return 'আংশিক পরিশোধ';
      case 'finalized': return 'বাকি';
      default: return 'খসড়া';
    }
  }

  void _showPaymentDialog(BuildContext context, Invoice invoice) {
    final paymentController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text('পেমেন্ট যোগ করুন'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('বাকি টাকা: ৳${invoice.amountDue.toStringAsFixed(0)}',
                style: TextStyle(fontSize: 16)),
            SizedBox(height: 16),
            TextField(
              controller: paymentController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'পেমেন্ট পরিমাণ',
                prefixText: '৳',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('বাতিল'),
          ),
          ElevatedButton(
            onPressed: () {
              final amount = double.tryParse(paymentController.text);
              if (amount != null && amount > 0) {
                controller.addPayment(invoice, amount);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF27AE60)),
            child: Text('যোগ করুন', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }


}
