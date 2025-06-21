import 'package:dokanmate_app/core/bindings/dashboard_binding.dart';
import 'package:dokanmate_app/core/routes/auth_middleware.dart';
import 'package:dokanmate_app/features/auth/view/screens/login_screen.dart';
import 'package:dokanmate_app/features/auth/view/screens/profile_screen.dart';
import 'package:dokanmate_app/features/dashboard/view/screens/dashboard_screen.dart';
import 'package:dokanmate_app/features/splash/view/screen/splash_screen.dart';
import 'package:get/get.dart';

import '../../features/seller/view/screen/seller_screen.dart';
import '../../features/seller/view/screen/seller_report.dart';
import '../../features/seller/view/screen/add_seller.dart';
import '../../features/seller/view/screen/edit_seller.dart';
import '../../features/seller/view/screen/seller_detail_report.dart';

class AppRoutes {
  static const String dashboard = '/dashboard';
  static const String login = '/login';
  static const String splash = '/splash';
  static const String profile = '/profile';
  static const String sellers = '/sellers';
  static const String sellerReport = '/seller_report';
  static const String addSeller = '/add_seller';
  static const String editSeller = '/edit_seller';
  static const String sellerDetailReport = '/seller_detail_report';

  static final routes = <GetPage>[
    GetPage(
      name: dashboard,
      page: () => DashboardScreen(),
      middlewares: [
        AuthMiddleware()
      ],
      binding: DashboardBinding(),
    ),
    GetPage(
      name: login,
      page: () => LoginScreen(),
    ),
    GetPage(
      name: splash,
      page: () => SplashScreen(),
    ),
    GetPage(
        name: profile,
        page: () => ProfileScreen()
    ),
    GetPage(
      name: sellers,
      page: () => SellerPage(),
    ),
    GetPage(
      name: sellerReport,
      page: () => SellerReportPage(),
    ),
    GetPage(
      name: addSeller,
      page: () => AddSellerPage(),
    ),
    GetPage(
      name: editSeller,
      page: () => EditSellerPage(seller: Get.arguments),
    ),
    GetPage(
      name: sellerDetailReport,
      page: () => SellerDetailReportPage(seller: Get.arguments),
    ),
  ];

}