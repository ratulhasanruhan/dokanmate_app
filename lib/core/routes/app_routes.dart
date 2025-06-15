import 'package:dokanmate_app/core/routes/auth_middleware.dart';
import 'package:dokanmate_app/features/auth/view/screens/login_screen.dart';
import 'package:dokanmate_app/features/dashboard/view/screens/dashboard_screen.dart';
import 'package:dokanmate_app/features/splash/view/screen/splash_screen.dart';
import 'package:get/get.dart';

class AppRoutes {
  static const String dashboard = '/dashboard';
  static const String login = '/login';
  static const String splash = '/splash';

  static final routes = <GetPage>[
    GetPage(
      name: dashboard,
      page: () => DashboardScreen(),
      middlewares: [
        AuthMiddleware()
      ]
    ),
    GetPage(
      name: login,
      page: () => LoginScreen(),
    ),
    GetPage(
      name: splash,
      page: () => SplashScreen(),
    ),
  ];

}