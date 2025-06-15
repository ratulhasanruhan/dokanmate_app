import 'package:dokanmate_app/core/routes/app_routes.dart';
import 'package:dokanmate_app/core/theme/app_themes.dart';
import 'package:dokanmate_app/core/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      builder: (context, child) {
        return GetMaterialApp(
          debugShowCheckedModeBanner: false,
          title: appName,
          theme: AppThemes.lightTheme,
          themeMode: ThemeMode.light,
          getPages: AppRoutes.routes,
          initialRoute: AppRoutes.dashboard,
        );
      },
    );
  }
}