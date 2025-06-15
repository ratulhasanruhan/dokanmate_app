import 'package:dokanmate_app/features/dashboard/view/screens/dashboard_screen.dart';
import 'package:get/get.dart';

class AppRoutes {
  static const String dashboard = '/dashboard';
  static const String login = '/login';

  static final routes = <GetPage>[
    GetPage(
      name: dashboard,
      page: () => DashboardScreen(),
    ),
  ];

}