import 'package:dokanmate_app/features/dashboard/controller/invoice_controller.dart';
import 'package:dokanmate_app/features/seller/controller/seller_controller.dart';
import 'package:dokanmate_app/features/export_data/controller/export_controller.dart';
import 'package:get/get.dart';

class DashboardBinding extends Bindings{

  @override
  void dependencies() {
    Get.put<SellerController>(SellerController());
    Get.put<InvoiceController>(InvoiceController());
    Get.put<ExportController>(ExportController());
  }
}