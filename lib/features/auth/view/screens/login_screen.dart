import 'package:dokanmate_app/core/utils/app_colors.dart';
import 'package:dokanmate_app/features/auth/controller/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:rounded_loading_button_plus/rounded_loading_button.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});
  final _formKey = GlobalKey<FormState>();

  final AuthController authController = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
        child: Center(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  height: MediaQuery.sizeOf(context).height * 0.16,
                ),
                Image.asset(
                  'assets/icons/app_icon.png',
                  width: 130.w,
                  height: 130.h,
                ),
                SizedBox(
                  height: 16.h,
                ),
                Text(
                  'লগইন',
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
                Text(
                  'ব্যবসা এখন হাতের মুঠোয়',
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: primaryColor,
                  ),
                ),
                SizedBox(
                  height: 16.h,
                ),
                TextFormField(
                  controller: authController.emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'ইমেইল ফিল্ডটি খালি রাখা যাবে না';
                    } else if (!GetUtils.isEmail(value)) {
                      return 'ইমেইলটি সঠিক নয়';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    labelText: 'ইমেইল',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    prefixIcon: Icon(Icons.email, color: primaryColor),
                  ),
                ),
                SizedBox(
                  height: 12.h,
                ),
                TextFormField(
                  obscureText: true,
                  controller: authController.passwordController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'পাসওয়ার্ড ফিল্ডটি খালি রাখা যাবে না';
                    } else if (value.length < 6) {
                      return 'পাসওয়ার্ডটি কমপক্ষে ৬ অক্ষরের হতে হবে';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    labelText: 'পাসওয়ার্ড',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    prefixIcon: Icon(Icons.lock, color: primaryColor),
                  ),
                ),
                SizedBox(
                  height: 18.h,
                ),
                RoundedLoadingButton(
                    controller: authController.loginButtonController,
                    color: primaryColor,
                    onPressed: (){
                      if (_formKey.currentState!.validate()) {
                        authController.login();
                      } else {
                        authController.loginButtonController.reset();
                      }
                    },
                    child: Text(
                      'লগইন',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.sp,
                      ),
                    ),
                )
              ],
            ),
          ),
        ),
      )
    );
  }
}
