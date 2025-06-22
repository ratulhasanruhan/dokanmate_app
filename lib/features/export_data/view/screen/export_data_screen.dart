import 'package:dokanmate_app/core/theme/app_colors.dart';
import 'package:dokanmate_app/features/export_data/controller/export_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ExportDataScreen extends StatelessWidget {
  ExportDataScreen({super.key});
  final ExportController controller = Get.find<ExportController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'ডাটা এক্সপোর্ট',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: 'Ador',
          ),
        ),
        centerTitle: true,
        backgroundColor: AppColors.primary,
        iconTheme: IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header section
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.file_download,
                    size: 48,
                    color: Colors.white,
                  ),
                  SizedBox(height: 12),
                  Text(
                    'আপনার ডাটা এক্সপোর্ট করুন',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Ador',
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'সকল তথ্য পিডিএফ ফাইলে সংরক্ষণ করুন',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            // Export options
            Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                children: [
                  // Export all data option
                  _buildExportCard(
                    title: 'সম্পূর্ণ ডাটা এক্সপোর্ট',
                    subtitle: 'সকল ক্রেতা এবং বিলের তথ্য',
                    icon: Icons.all_inclusive,
                    color: AppColors.primary,
                    onTap: controller.exportAllData,
                    controller: controller,
                    exporting: controller.isExportingAll,
                  ),

                  SizedBox(height: 16),

                  // Export sellers option
                  _buildExportCard(
                    title: 'ক্রেতাদের তালিকা এক্সপোর্ট',
                    subtitle: 'সকল ক্রেতার তথ্য',
                    icon: Icons.people,
                    color: Colors.green,
                    onTap: controller.exportSellers,
                    controller: controller,
                    exporting: controller.isExportingSeller,
                  ),

                  SizedBox(height: 16),

                  // Export invoices option
                  _buildExportCard(
                    title: 'বিলের তালিকা এক্সপোর্ট',
                    subtitle: 'সকল বিলের তথ্য',
                    icon: Icons.receipt_long,
                    color: Colors.orange,
                    onTap: controller.exportInvoices,
                    controller: controller,
                    exporting: controller.isExportingInvoice,
                  ),

                  SizedBox(height: 24),

                  // Info section
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue[200]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.info_outline, color: Colors.blue[700], size: 20),
                            SizedBox(width: 8),
                            Text(
                              'এক্সপোর্ট সম্পর্কে',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Colors.blue[700],
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 12),
                        Text(
                          '• পিডিএফ ফাইল ডাউনলোড ফোল্ডারে সংরক্ষিত হবে\n'
                          '• প্রতিটি ফাইলে DokanMate লোগো এবং ওয়াটারমার্ক থাকবে\n'
                          '• ফাইল শেয়ার করার অপশন থাকবে\n'
                          '• বাংলা ভাষায় সকল তথ্য দেখানো হবে',
                          style: TextStyle(
                            color: Colors.blue[800],
                            fontSize: 14,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Add bottom padding for better scrolling
                  SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExportCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    required ExportController controller,
    required RxBool exporting,
  }) {
    return Obx(() {
      final isExporting = exporting.value;
      final exportStatus = controller.exportStatus.value;
      
      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: isExporting ? null : onTap,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          icon,
                          color: color,
                          size: 24,
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[800],
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              subtitle,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (isExporting)
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(color),
                          ),
                        )
                      else
                        Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.grey[400],
                          size: 16,
                        ),
                    ],
                  ),
                  if (isExporting && exportStatus.isNotEmpty) ...[
                    SizedBox(height: 12),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: 16,
                            color: color,
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              exportStatus,
                              style: TextStyle(
                                fontSize: 12,
                                color: color,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}
