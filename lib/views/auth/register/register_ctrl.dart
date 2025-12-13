import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:patients/utils/routes/route_name.dart';
import 'package:patients/utils/service/location_service.dart';
import 'package:patients/utils/toaster.dart';
import 'package:patients/views/auth/auth_service.dart';

class RegisterCtrl extends GetxController {
  final nameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  final mobileCtrl = TextEditingController();
  final addressCtrl = TextEditingController();

  var isLoading = false.obs, isPasswordVisible = false.obs, isGettingLocation = false.obs;
  var coordinates = [0.0, 0.0].obs;

  AuthService get authService => Get.find<AuthService>();

  LocationService get locationService => Get.find<LocationService>();

  void togglePasswordVisibility() => isPasswordVisible.toggle();

  @override
  void onInit() {
    super.onInit();
    _fetchCurrentLocation();
  }

  @override
  void onClose() {
    nameCtrl.dispose();
    emailCtrl.dispose();
    passwordCtrl.dispose();
    mobileCtrl.dispose();
    addressCtrl.dispose();
    super.onClose();
  }

  Future<void> _fetchCurrentLocation() async {
    try {
      isGettingLocation(true);
      final addressData = await locationService.getCurrentAddress();
      if (addressData != null) {
        addressCtrl.text = addressData['address'] ?? '';
        coordinates.value = [addressData['latitude'] ?? 0.0, addressData['longitude'] ?? 0.0];
        toaster.success('Location fetched successfully');
      }
    } catch (e) {
      toaster.error('Failed to fetch location: ${e.toString()}');
    } finally {
      isGettingLocation(false);
    }
  }

  Future<void> retryLocation() async => await _fetchCurrentLocation();

  Future<void> register() async {
    if (!_validateForm()) return;
    isLoading.value = true;
    try {
      final request = {
        'name': nameCtrl.text.trim(),
        'email': emailCtrl.text.trim(),
        'password': passwordCtrl.text.trim(),
        'mobile': mobileCtrl.text.trim(),
        'coordinates': coordinates,
        'address': addressCtrl.text.trim(),
      };
      await authService.register(request);
    } catch (e) {
      toaster.error("Registration failed: ${e.toString()}");
    } finally {
      isLoading.value = false;
    }
  }

  bool _validateForm() {
    if (nameCtrl.text.isEmpty) {
      toaster.warning('Please enter your full name');
      return false;
    }
    if (emailCtrl.text.isEmpty) {
      toaster.warning('Please enter your email');
      return false;
    }
    if (!GetUtils.isEmail(emailCtrl.text)) {
      toaster.warning('Please enter a valid email address');
      return false;
    }
    if (passwordCtrl.text.isEmpty) {
      toaster.warning('Please enter your password');
      return false;
    }
    if (passwordCtrl.text.length < 6) {
      toaster.warning('Password must be at least 6 characters long');
      return false;
    }
    if (mobileCtrl.text.isEmpty) {
      toaster.warning('Please enter your mobile number');
      return false;
    }
    if (!GetUtils.isPhoneNumber(mobileCtrl.text) || mobileCtrl.text.length != 10) {
      toaster.warning('Please enter a valid 10-digit mobile number');
      return false;
    }
    if (addressCtrl.text.isEmpty) {
      toaster.warning('Please enter your address');
      return false;
    }
    return true;
  }

  void goToLogin() => Get.toNamed(AppRouteNames.login);
}
