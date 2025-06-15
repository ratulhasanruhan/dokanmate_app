import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rounded_loading_button_plus/rounded_loading_button.dart';

class AuthController extends GetxController{
  Rxn<User> user = Rxn<User>();

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  RoundedLoadingButtonController loginButtonController = RoundedLoadingButtonController();

  @override
  void onInit() {
    user.bindStream(FirebaseAuth.instance.authStateChanges());
    super.onInit();
  }

  bool get isLoggedIn => user.value != null;


  Future<void> login() async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      loginButtonController.success();
      Get.offAllNamed('/dashboard'); // Navigate to home screen on success
    } on FirebaseAuthException catch (e) {
      loginButtonController.error();
      Get.snackbar('একটু সমস্যা হচ্ছে 🤏', e.message ?? 'An error occurred', snackPosition: SnackPosition.TOP);
      loginButtonController.reset();
    } catch (e) {
      Get.snackbar('একটু সমস্যা হচ্ছে 🤏', e.toString(), snackPosition: SnackPosition.TOP);
      loginButtonController.reset();
    }
  }

}