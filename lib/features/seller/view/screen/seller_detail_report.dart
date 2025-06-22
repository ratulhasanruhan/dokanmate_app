import 'package:dokanmate_app/features/dashboard/controller/invoice_controller.dart';
import 'package:dokanmate_app/features/export_data/controller/export_controller.dart';
import 'package:dokanmate_app/features/seller/model/SellerModel.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../core/utils/status.dart';
import '../../../dashboard/model/InvoiceModel.dart';
import '../../controller/seller_controller.dart';

class SellerDetailReportPage extends StatelessWidget {
  final SellerModel seller;
  SellerDetailReportPage({super.key, required this.seller});

  final InvoiceController invoiceController = Get.find<InvoiceController>();
  final SellerController sellerController = Get.find<SellerController>();
  final ExportController exportController = Get.find<ExportController>();


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text('${seller.name} - রিপোর্ট'),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: IconThemeData(color: Colors.black87),
        titleTextStyle: TextStyle(
          color: Colors.black87,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          fontFamily: 'Ador'
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.file_download, color: Colors.black87),
            onPressed: () => exportController.exportSellerData(seller),
            tooltip: 'রিপোর্ট এক্সপোর্ট করুন',
          ),
        ],
      ),
      body: Obx(() {
        final allInvoices = invoiceController.invoices;
        final sellerInvoices = _getSellerInvoices(allInvoices);
        final stats = _calculateStats(sellerInvoices);

        if (sellerInvoices.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.receipt_long_outlined, size: 64, color: Colors.grey[400]),
                SizedBox(height: 16),
                Text(
                  'কোনো বিল নেই',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
                SizedBox(height: 8),
                Text(
                  'এই ক্রেতার কোনো বিক্রয় রেকর্ড নেই',
                  style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                ),
              ],
            ),
          );
        }

        return ListView(
          padding: EdgeInsets.all(16),
          children: [
            // Seller info card
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    seller.name,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (seller.shopName != null) ...[
                    SizedBox(height: 4),
                    Text(
                      seller.shopName!,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                  SizedBox(height: 8),
                  InkWell(
                    onTap: () {
                      sellerController.callSeller(seller.phone);
                    },
                    child: Row(
                      children: [
                        Icon(Icons.phone, size: 16, color: Colors.grey[600]),
                        SizedBox(width: 4),
                        Text(
                          seller.phone,
                          style: TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                  if (seller.address != null && seller.address!.isNotEmpty) ...[
                    SizedBox(height: 4),
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
                  if (seller.notes != null && seller.notes!.isNotEmpty) ...[
                    SizedBox(height: 8),
                    Text(
                      'নোট: ${seller.notes}',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ],
                ],
              ),
            ),
            SizedBox(height: 16),

            // Stats grid
            GridView.count(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              crossAxisCount: MediaQuery.of(context).size.width > 600 ? 4 : 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.2,
              children: [
                _buildStatCard(
                  'মোট বিক্রয়',
                  '৳${stats['totalSales']!.toStringAsFixed(0)}',
                  Icons.trending_up,
                  Colors.blue,
                ),
                _buildStatCard(
                  'পরিশোধিত',
                  '৳${stats['totalPaid']!.toStringAsFixed(0)}',
                  Icons.check_circle,
                  Colors.green,
                ),
                _buildStatCard(
                  'বাকি',
                  '৳${stats['totalDue']!.toStringAsFixed(0)}',
                  Icons.pending,
                  Colors.red,
                ),
                _buildStatCard(
                  'মোট ওজন',
                  '${stats['totalKg']!.toStringAsFixed(1)} কেজি',
                  Icons.monitor_weight,
                  Colors.orange,
                ),
              ],
            ),
            SizedBox(height: 24),

            // Chart
            Container(
              height: 220.h,
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'বিক্রয় চার্ট',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 16),
                  Expanded(
                    child: PieChart(
                      PieChartData(
                        sections: [
                          PieChartSectionData(
                            value: stats['totalPaid']!,
                            title: 'পরিশোধিত\n৳${stats['totalPaid']!.toStringAsFixed(0)}',
                            color: Colors.green,
                            radius: 60,
                            titleStyle: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          PieChartSectionData(
                            value: stats['totalDue']!,
                            title: 'বাকি\n৳${stats['totalDue']!.toStringAsFixed(0)}',
                            color: Colors.red,
                            radius: 60,
                            titleStyle: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                        centerSpaceRadius: 40,
                        sectionsSpace: 2,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24),

            // Invoice list
            Text(
              'বিল তালিকা',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 12),
            ...sellerInvoices.map((invoice) => _buildInvoiceItem(invoice)).toList(),
          ],
        );
      }),
    );
  }
  List<Invoice> _getSellerInvoices(List<Invoice> invoices) {
    return invoices.where((inv) => inv.sellerId == seller.id).toList();
  }

  Map<String, double> _calculateStats(List<Invoice> sellerInvoices) {
    double totalSales = 0;
    double totalPaid = 0;
    double totalDue = 0;
    double totalKg = 0;
    int totalPieces = 0;

    for (var inv in sellerInvoices) {
      totalSales += inv.totalAmount;
      totalPaid += inv.amountPaid;
      totalDue += inv.amountDue;
      totalKg += inv.kg;
      totalPieces += inv.pieces.toInt();
    }

    return {
      'totalSales': totalSales,
      'totalPaid': totalPaid,
      'totalDue': totalDue,
      'totalKg': totalKg,
      'totalPieces': totalPieces.toDouble(),
    };
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 24, color: color),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildInvoiceItem(Invoice invoice) {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'বিল #${invoice.id?.substring(0, 8) ?? 'N/A'}',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: getStatusColor(invoice.status).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  getStatusText(invoice.status),
                  style: TextStyle(
                    fontSize: 12,
                    color: getStatusColor(invoice.status),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text('পিস: ${invoice.pieces.toInt()}', style: TextStyle(fontSize: 12)),
              ),
              Expanded(
                child: Text('ওজন: ${invoice.kg} কেজি', style: TextStyle(fontSize: 12)),
              ),
              Expanded(
                child: Text('দর: ৳${invoice.unitPrice}', style: TextStyle(fontSize: 12)),
              ),
            ],
          ),
          SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'মোট: ৳${invoice.totalAmount.toStringAsFixed(0)}',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              ),
              Text(
                DateFormat('dd/MM/yyyy').format(invoice.createdAt),
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
        ],
      ),
    );
  }
} 