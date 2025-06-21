import 'package:dokanmate_app/core/routes/app_routes.dart';
import 'package:dokanmate_app/core/theme/app_colors.dart';
import 'package:dokanmate_app/core/utils/constants.dart';
import 'package:dokanmate_app/features/auth/controller/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class DashboardDrawer extends StatelessWidget {
  DashboardDrawer({super.key});

  final AuthController authController = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.2)
      ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 38.r,
                      backgroundImage: AssetImage('assets/images/logo.png'),
                    ),
                    Text(
                      appName,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'ভার্সন: ১.০.০',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          ListTile(
            leading: Icon(Iconsax.home, color: AppColors.primary),
            title: Text('ড্যাশবোর্ড', style: TextStyle(
                color: AppColors.primary,
            )),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: Icon(Iconsax.people, color: AppColors.primary),
            title: Text('ক্রেতাগন', style: TextStyle(
                color: AppColors.primary,
            )),
            onTap: () {
              // Navigate to sellers
              Navigator.pop(context);
              Get.toNamed(AppRoutes.sellers);
            },
          ),
          ListTile(
            leading: Icon(Iconsax.chart, color: AppColors.primary),
            title: Text('রিপোর্ট', style: TextStyle(
                color: AppColors.primary,
            )),
            onTap: () {
              // Navigate to sellers
              Navigator.pop(context);
              Get.toNamed(AppRoutes.sellerReport);
            },
          ),

          Divider(
            color: AppColors.primary.withValues(alpha: 0.5),
            thickness: 0.5,
          ),

          ListTile(
            leading: Icon(Iconsax.user, color: AppColors.primary),
            title: Text('প্রোফাইল', style: TextStyle(
                color: AppColors.primary,
            )),
            onTap: () {
              // Navigate to profile
//              Get.toNamed(AppRoutes.profile);
            Navigator.pop(context);
            },
          ),
          ListTile(
            leading: Icon(Iconsax.lifebuoy, color: AppColors.primary),
            title: Text('সহায়তা', style: TextStyle(
                color: AppColors.primary,
            )),
            onTap: () {
              // Navigate to settings
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: Icon(Iconsax.logout, color: AppColors.primary),
            title: Text('লগ আউট', style: TextStyle(
                color: AppColors.primary,
            )),
            onTap: () {
              authController.logout();
            },
          ),

        ],
      ),
    );
  }
}
