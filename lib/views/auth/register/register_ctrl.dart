import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:patients/utils/config/session.dart';
import 'package:patients/utils/routes/route_name.dart';
import 'package:patients/utils/storage.dart';
import 'package:patients/utils/toaster.dart';

class RegisterCtrl extends GetxController {
  final nameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  final mobileCtrl = TextEditingController();
  final addressCtrl = TextEditingController();

  var isLoading = false.obs, isPasswordVisible = false.obs;

  void togglePasswordVisibility() => isPasswordVisible.toggle();

  Future<void> register() async {
    if (nameCtrl.text.isEmpty) {
      return toaster.warning('Please enter your full name');
    }
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
    if (mobileCtrl.text.isEmpty) {
      return toaster.warning('Please enter your mobile number');
    }
    if (!GetUtils.isPhoneNumber(mobileCtrl.text)) {
      return toaster.warning('Please enter a valid mobile number');
    }
    if (addressCtrl.text.isEmpty) {
      return toaster.warning('Please enter your address');
    }
    isLoading.value = true;
    try {
      final request = {'name': nameCtrl.text.trim(), 'email': emailCtrl.text.trim(), 'password': passwordCtrl.text.trim(), 'mobile': mobileCtrl.text.trim(), 'address': addressCtrl.text.trim()};
      await write(AppSession.token, DateTime.now().toIso8601String());
      await write(AppSession.userData, request);
      toaster.success("Welcome to HealSync! Your account has been created.");
      nameCtrl.clear();
      emailCtrl.clear();
      passwordCtrl.clear();
      mobileCtrl.clear();
      addressCtrl.clear();
      Get.offAllNamed(AppRouteNames.dashboard);
    } finally {
      isLoading.value = false;
    }
  }

  void goToLogin() => Get.toNamed(AppRouteNames.login);
}
