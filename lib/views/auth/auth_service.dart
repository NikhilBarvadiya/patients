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
      Get.toNamed(AppRouteNames.dashboard);
    } catch (err) {
      toaster.error(err.toString());
      return;
    }
  }

  Future<void> register(Map<String, dynamic> request) async {
    try {
      final response = await ApiManager().call(APIIndex.register, request, ApiType.post);
      if (!response.success || response.data == null || response.data == 0) {
        toaster.warning(response.message ?? 'Something went wrong');
        return;
      }
      Get.back();
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

  Future<bool> createRequests(Map<String, dynamic> request) async {
    try {
      final response = await ApiManager().call(APIIndex.createRequests, request, ApiType.post);
      if (!response.success) {
        toaster.warning(response.message ?? 'Failed to requests booking');
        return false;
      }
      return true;
    } catch (err) {
      toaster.error('Network error: ${err.toString()}');
      return false;
    }
  }

  Future<dynamic> getRequests({int page = 1, String status = ""}) async {
    try {
      final response = await ApiManager().call("${APIIndex.getRequests}?page=$page&limit=10&status=$status", {}, ApiType.get);
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
