import 'package:get/get.dart';
import 'package:patients/utils/config/session.dart';
import 'package:patients/utils/network/api_index.dart';
import 'package:patients/utils/network/api_manager.dart';
import 'package:patients/utils/routes/route_name.dart';
import 'package:patients/utils/storage.dart';
import 'package:patients/utils/toaster.dart';

class AuthService extends GetxService {
  Future<AuthService> init() async => this;

  Future<void> login(Map<String, dynamic> request) async {
    try {
      final response = await ApiManager().call(APIIndex.login, request, ApiType.post);
      if (!response.success || response.data == null || response.data == 0) {
        toaster.warning(response.message ?? 'Something went wrong');
        return;
      }
      await write(AppSession.token, response.data["accessToken"]);
      await write(AppSession.userData, response.data["patient"]);
      if (response.data["isEmailVerified"] != true) {
        await sendOTP({'email': request["email"]});
        Get.toNamed(AppRouteNames.otp, arguments: request["email"].toString());
      } else {
        Get.toNamed(AppRouteNames.dashboard);
      }
    } catch (err) {
      toaster.error(err.toString());
      return;
    }
  }

  Future<dynamic> sendOTP(Map<String, dynamic> request) async {
    try {
      final response = await ApiManager().call(APIIndex.otpSend, request, ApiType.post);
      if (!response.success || response.data == null) {
        toaster.warning(response.message ?? 'Failed to send OTP');
        return null;
      }
      return response.data;
    } catch (err) {
      toaster.error(err.toString());
      return null;
    }
  }

  Future<dynamic> verifyOTP(Map<String, dynamic> request) async {
    try {
      final response = await ApiManager().call(APIIndex.otpVerify, request, ApiType.post);
      if (!response.success || response.data == null) {
        toaster.warning(response.message ?? 'Failed to verify OTP');
        return null;
      }
      await write(AppSession.userData, response.data["patient"]);
      Get.toNamed(AppRouteNames.dashboard);
      return response.data;
    } catch (err) {
      toaster.error(err.toString());
      return null;
    }
  }

  Future<dynamic> forgotPassword(Map<String, dynamic> request) async {
    try {
      final response = await ApiManager().call(APIIndex.forgotPassword, request, ApiType.post);
      if (!response.success) {
        toaster.warning(response.message ?? 'Failed to send reset link');
        return null;
      }
      return true;
    } catch (err) {
      toaster.error(err.toString());
      return null;
    }
  }

  Future<void> register(Map<String, dynamic> request) async {
    try {
      final response = await ApiManager().call(APIIndex.register, request, ApiType.post);
      if (!response.success || response.data == null || response.data == 0) {
        toaster.warning(response.message ?? 'Something went wrong');
        return;
      }
      Get.close(1);
      toaster.success(response.message.toString().capitalizeFirst.toString());
    } catch (err) {
      toaster.error(err.toString());
      return;
    }
  }

  Future<dynamic> getProfile() async {
    try {
      final response = await ApiManager().call(APIIndex.getProfile, {}, ApiType.get);
      if (!response.success || response.data == null || response.data == 0) {
        toaster.warning(response.message ?? 'Something went wrong');
        return;
      }
      return response.data;
    } catch (err) {
      toaster.error(err.toString());
      return;
    }
  }

  Future<dynamic> updateProfile(dynamic request) async {
    try {
      final response = await ApiManager().call(APIIndex.updateProfile, request, ApiType.post);
      if (!response.success || response.data == null || response.data == 0) {
        toaster.warning(response.message ?? 'Something went wrong');
        return;
      }
      return response.data;
    } catch (err) {
      toaster.error(err.toString());
      return;
    }
  }

  Future<dynamic> updatePassword(Map<String, dynamic> request) async {
    try {
      final response = await ApiManager().call(APIIndex.updatePassword, request, ApiType.post);
      if (!response.success) {
        toaster.warning(response.message ?? 'Failed to update password');
        return null;
      }
      return true;
    } catch (err) {
      toaster.error('Network error: ${err.toString()}');
      return null;
    }
  }

  Future<dynamic> patientServices({int page = 1, String search = ""}) async {
    try {
      final response = await ApiManager().call("${APIIndex.patientServices}?page=$page&limit=10&search=$search&isActive=true", {}, ApiType.get);
      if (!response.success || response.data == null) return [];
      return response.data;
    } catch (err) {
      toaster.error(err.toString());
      return [];
    }
  }

  Future<dynamic> createRequests(Map<String, dynamic> request) async {
    try {
      final response = await ApiManager().call(APIIndex.createRequests, request, ApiType.post);
      if (!response.success) {
        toaster.warning(response.message ?? 'Failed to requests booking');
        return null;
      }
      return response.data;
    } catch (err) {
      toaster.error('Network error: ${err.toString()}');
      return null;
    }
  }

  Future<bool> createPaymentRequests(Map<String, dynamic> request) async {
    try {
      final response = await ApiManager().call(APIIndex.createPaymentRequests, request, ApiType.post);
      if (!response.success) {
        toaster.warning(response.message ?? 'Failed to requests payment');
        return false;
      }
      return true;
    } catch (err) {
      toaster.error('Network error: ${err.toString()}');
      return false;
    }
  }

  Future<dynamic> getRequests({required String queryString}) async {
    try {
      final response = await ApiManager().call("${APIIndex.getRequests}?$queryString", {}, ApiType.get);
      if (!response.success || response.data == null) return [];
      return response.data;
    } catch (err) {
      toaster.error(err.toString());
      return [];
    }
  }

  Future<dynamic> cancelRequests({required String requestId}) async {
    try {
      final response = await ApiManager().call(APIIndex.cancelRequests, {"requestId": requestId}, ApiType.post);
      if (!response.success) {
        toaster.warning(response.message ?? 'Failed to requests booking');
        return null;
      }
      return true;
    } catch (err) {
      toaster.error('Network error: ${err.toString()}');
      return null;
    }
  }

  Future<dynamic> submitFeedback({required String requestId, required int rating, required String feedback}) async {
    try {
      final response = await ApiManager().call(APIIndex.submitFeedback, {"requestId": requestId, "rating": rating, "feedback": feedback}, ApiType.post);
      if (!response.success) {
        toaster.warning(response.message ?? 'Failed to requests booking');
        return null;
      }
      return true;
    } catch (err) {
      toaster.error('Network error: ${err.toString()}');
      return null;
    }
  }
}
