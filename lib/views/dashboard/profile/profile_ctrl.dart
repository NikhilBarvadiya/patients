import 'dart:io';
import 'package:dio/dio.dart' as dio;
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:path/path.dart' as path;
import 'package:patients/models/user_model.dart';
import 'package:patients/utils/config/session.dart';
import 'package:patients/utils/helper.dart';
import 'package:patients/utils/storage.dart';
import 'package:patients/utils/toaster.dart';
import 'package:patients/views/auth/auth_service.dart';
import 'package:patients/views/dashboard/home/home_ctrl.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfileCtrl extends GetxController {
  var user = UserModel(
    id: '',
    name: '',
    email: '',
    mobile: '',
    password: '',
    address: '',
    avatar: '',
    location: LocationModel(address: '', coordinates: [0.0, 0.0]),
  ).obs;
  var isLoading = false.obs, isSaving = false.obs, isGettingLocation = false.obs;
  var isCurrentPasswordVisible = false.obs, isNewPasswordVisible = false.obs, isConfirmPasswordVisible = false.obs;
  var coordinates = [0.0, 0.0].obs, locationStatus = 'Fetching location...'.obs;

  bool isEditMode = false;
  var avatar = Rx<File?>(null);

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController currentPasswordController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  final AuthService _authService = Get.find<AuthService>();

  @override
  void onInit() {
    super.onInit();
    loadProfile();
  }

  Future<void> retryLocation() async => await _fetchCurrentLocation();

  Future<void> _fetchCurrentLocation() async {
    isGettingLocation.value = true;
    locationStatus.value = 'Checking location permissions...';
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        locationStatus.value = 'Location services disabled';
        toaster.warning('Please enable location services for better experience');
        isGettingLocation.value = false;
        return;
      }
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        locationStatus.value = 'Requesting location permission...';
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          locationStatus.value = 'Location permission denied';
          toaster.warning('Location permission is required for better service');
          isGettingLocation.value = false;
          return;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        locationStatus.value = 'Location permission permanently denied';
        toaster.warning('Please enable location permissions in app settings');
        isGettingLocation.value = false;
        return;
      }
      locationStatus.value = 'Getting your location...';
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high, timeLimit: const Duration(seconds: 15));
      coordinates.value = [position.latitude, position.longitude];
      locationStatus.value = 'Location fetched successfully!';
      final request = {'coordinates': coordinates};
      dio.FormData formData = dio.FormData.fromMap(request);
      await _authService.updateProfile(formData);
    } catch (e) {
      locationStatus.value = 'Failed to get location';
      toaster.error('Location error: ${e.toString()}');
    } finally {
      isGettingLocation.value = false;
    }
  }

  Future<void> loadProfile() async {
    try {
      isLoading.value = true;
      final response = await _authService.getProfile();
      if (response != null) {
        _parseUserData(response);
        _updateControllers();
        await write(AppSession.userData, response);
        final dashboardCtrl = Get.find<HomeCtrl>();
        dashboardCtrl.loadUserData();
      } else {
        await _loadLocalData();
      }
    } catch (e) {
      toaster.error('Error loading profile: ${e.toString()}');
      await _loadLocalData();
    } finally {
      isLoading.value = false;
    }
  }

  void _parseUserData(Map<String, dynamic> data) {
    List coordinates = data['location']['coordinates'] ?? [];
    user.value = UserModel(
      id: data['_id'] ?? '',
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      mobile: data['mobile'] ?? '',
      password: data["password"] ?? '********',
      address: data['location'] != null ? data['location']['address'] ?? '' : '',
      avatar: data['avatar'] ?? '',
      location: LocationModel(
        address: data['location'] != null ? data['location']['address'] ?? '' : '',
        coordinates: data['location'] != null ? List<double>.from([double.tryParse(coordinates.first.toString()) ?? 0.0, double.tryParse(coordinates.last.toString()) ?? 0.0]) : [0.0, 0.0],
      ),
    );
  }

  Future<void> _loadLocalData() async {
    final userData = await read(AppSession.userData);
    if (userData != null) {
      _parseUserData(userData);
      _updateControllers();
    }
  }

  void _updateControllers() {
    nameController.text = user.value.name;
    emailController.text = user.value.email;
    mobileController.text = user.value.mobile;
    addressController.text = user.value.address;
  }

  void toggleCurrentPasswordVisibility() => isCurrentPasswordVisible.toggle();

  void toggleNewPasswordVisibility() => isNewPasswordVisible.toggle();

  void toggleConfirmPasswordVisibility() => isConfirmPasswordVisible.toggle();

  void toggleEditMode() {
    isEditMode = !isEditMode;
    if (!isEditMode) {
      _updateControllers();
    }
    update();
  }

  Future<void> pickAvatar() async {
    final result = await helper.pickImage();
    if (result != null) {
      avatar.value = result;
      dio.FormData formData = dio.FormData.fromMap({});
      formData.files.add(MapEntry('profileImage', await dio.MultipartFile.fromFile(avatar.value!.path, filename: path.basename(avatar.value!.path))));
      await _authService.updateProfile(formData);
    }
  }

  Future<void> saveProfile() async {
    if (!_validateForm()) return;
    try {
      isSaving.value = true;
      final request = {
        'name': nameController.text.trim(),
        'email': emailController.text.trim(),
        'mobile': mobileController.text.trim(),
        'address': user.value.location.address,
        'coordinates': user.value.location.coordinates,
      };
      dio.FormData formData = dio.FormData.fromMap(request);
      final response = await _authService.updateProfile(formData);
      if (response != null) {
        await write(AppSession.userData, response);
        _loadLocalData();
        isEditMode = false;
        toaster.success('Profile updated successfully');
        final dashboardCtrl = Get.find<HomeCtrl>();
        dashboardCtrl.loadUserData();
      }
    } catch (e) {
      toaster.error('Error updating profile: ${e.toString()}');
    } finally {
      isSaving.value = false;
      update();
    }
  }

  bool _validateForm() {
    if (nameController.text.isEmpty) {
      toaster.warning('Please enter your full name');
      return false;
    }
    if (emailController.text.isEmpty) {
      toaster.warning('Please enter your email');
      return false;
    }
    if (!GetUtils.isEmail(emailController.text)) {
      toaster.warning('Please enter a valid email');
      return false;
    }
    if (mobileController.text.isEmpty) {
      toaster.warning('Please enter your mobile number');
      return false;
    }
    if (!GetUtils.isPhoneNumber(mobileController.text)) {
      toaster.warning('Please enter a valid mobile number');
      return false;
    }
    if (addressController.text.isEmpty) {
      toaster.warning('Please enter your address');
      return false;
    }
    return true;
  }

  Future<void> changePassword() async {
    if (!_validatePasswordForm()) return;
    try {
      isSaving.value = true;
      final request = {'oldPassword': currentPasswordController.text.trim(), 'newPassword': newPasswordController.text.trim()};
      final response = await _authService.updatePassword(request);
      if (response != null) {
        currentPasswordController.clear();
        newPasswordController.clear();
        confirmPasswordController.clear();
        isCurrentPasswordVisible.value = false;
        isNewPasswordVisible.value = false;
        isConfirmPasswordVisible.value = false;
        toaster.success('Password updated successfully');
        if (Get.isDialogOpen ?? false) {
          Get.close(1);
        }
      }
    } catch (e) {
      toaster.error('Error updating password: ${e.toString()}');
    } finally {
      isSaving.value = false;
    }
  }

  bool _validatePasswordForm() {
    if (currentPasswordController.text.isEmpty) {
      toaster.warning('Please enter your current password');
      return false;
    }
    if (newPasswordController.text.isEmpty) {
      toaster.warning('Please enter new password');
      return false;
    }
    if (newPasswordController.text.length < 6) {
      toaster.warning('New password must be at least 6 characters');
      return false;
    }
    if (confirmPasswordController.text.isEmpty) {
      toaster.warning('Please confirm your new password');
      return false;
    }
    if (newPasswordController.text != confirmPasswordController.text) {
      toaster.warning('New passwords do not match');
      return false;
    }
    if (currentPasswordController.text == newPasswordController.text) {
      toaster.warning('New password must be different from current password');
      return false;
    }
    return true;
  }

  void logout() async {
    try {
      await clearStorage();
      update();
    } catch (e) {
      Get.snackbar('Error', 'Failed to logout: $e', snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> openPrivacyPolicy() async {
    try {
      final url = "https://sites.google.com/view/healup-privacy-policy/home";
      final uri = Uri.parse(url);
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      toaster.error('Error: $e');
    }
  }

  void openTermsOfService() async {
    try {
      final url = "https://itfuturz.in/support/healup-patient-support.html";
      final uri = Uri.parse(url);
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      toaster.error('Error: $e');
    }
  }

  void deleteAccount() async {
    try {
      await clearStorage();
      update();
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete account: $e', snackPosition: SnackPosition.BOTTOM);
    }
  }
}
