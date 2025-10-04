import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:patients/utils/config/session.dart';
import 'package:patients/utils/routes/route_name.dart';
import 'package:patients/utils/storage.dart';
import 'package:patients/utils/toaster.dart';

class LoginCtrl extends GetxController {
  final emailCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  var isLoading = false.obs, isPasswordVisible = false.obs;

  void togglePasswordVisibility() => isPasswordVisible.toggle();

  Future<void> login() async {
    if (emailCtrl.text.isEmpty) {
      return toaster.warning('Please enter your email');
    }
    if (!GetUtils.isEmail(emailCtrl.text)) {
      return toaster.warning('Please enter a valid email');
    }
    if (passwordCtrl.text.isEmpty) {
      return toaster.warning('Please enter your password');
    }
    if (passwordCtrl.text.length < 6) {
      return toaster.warning('Password must be at least 6 characters');
    }
    isLoading.value = true;
    try {
      final request = {'email': emailCtrl.text.trim(), 'password': passwordCtrl.text.trim()};
      await write(AppSession.token, DateTime.now().toIso8601String());
      await write(AppSession.userData, request);
      toaster.success("Welcome to your health journey!");
      Get.offAllNamed(AppRouteNames.dashboard);
    } finally {
      emailCtrl.clear();
      passwordCtrl.clear();
      isLoading.value = false;
    }
  }

  void goToRegister() => Get.toNamed(AppRouteNames.register);
}
