import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import '../../features/auth/controller/auth_controller.dart';

class AuthMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    final authController = Get.find<AuthController>();
    if (authController.user.value == null) {
      return RouteSettings(name: '/login');
    }
    return null;
  }
}
