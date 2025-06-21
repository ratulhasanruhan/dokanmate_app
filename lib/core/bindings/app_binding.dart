import 'package:get/get.dart';
import '../../features/auth/controller/auth_controller.dart';
import '../../features/export_data/controller/export_controller.dart';

class AppBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<AuthController>(AuthController(), permanent: true);
  }
}