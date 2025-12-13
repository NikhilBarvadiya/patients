import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:patients/utils/toaster.dart';
import 'package:patients/views/auth/auth_service.dart';
import 'package:patients/views/dashboard/appointments/ui/appointment_details.dart';
import 'package:patients/views/dashboard/appointments/ui/date_filter.dart';
import '../../../models/patient_request_model.dart';

class AppointmentsCtrl extends GetxController {
  final AuthService _authService = Get.find<AuthService>();
  var selectedFilter = 'All'.obs, selectedPaymentMethod = 'Online'.obs, selectedDateRange = 'All Time'.obs;
  final filters = ['All', 'Pending', 'Accepted', 'Completed', 'Cancelled'];
  final paymentMethods = ['Online', 'Offline'];
  final dateRanges = ['All Time', 'Today', 'Yesterday', 'Last 7 Days', 'Last 30 Days', 'This Month', 'Last Month', 'Custom Range'];
  var customStartDate = Rx<DateTime?>(null), customEndDate = Rx<DateTime?>(null);
  var appointments = <PatientRequestModel>[].obs;
  var filteredAppointments = <PatientRequestModel>[].obs;
  var isLoading = false.obs, isLoadMoreLoading = false.obs, hasMore = true.obs;
  var isSubmittingReview = false.obs, isCancelling = false.obs;
  var currentPage = 1.obs, totalDocs = 0.obs;
  final RxList<String> expandedCards = <String>[].obs;

  final ScrollController scrollController = ScrollController();

  @override
  void onInit() {
    super.onInit();
    loadAppointments();
    setupScrollListener();
  }

  void setupScrollListener() {
    scrollController.addListener(() {
      if (scrollController.position.pixels >= scrollController.position.maxScrollExtent - 200) {
        loadMoreAppointments();
      }
    });
  }

  Map<String, String> _getDateParameters() {
    final now = DateTime.now();
    final Map<String, String> params = {};
    switch (selectedDateRange.value) {
      case 'Today':
        final today = DateTime(now.year, now.month, now.day);
        params['dateFrom'] = today.toIso8601String();
        params['dateTo'] = now.toIso8601String();
        break;
      case 'Yesterday':
        final yesterday = now.subtract(const Duration(days: 1));
        final start = DateTime(yesterday.year, yesterday.month, yesterday.day);
        final end = DateTime(yesterday.year, yesterday.month, yesterday.day, 23, 59, 59);
        params['dateFrom'] = start.toIso8601String();
        params['dateTo'] = end.toIso8601String();
        break;
      case 'Last 7 Days':
        final start = now.subtract(const Duration(days: 7));
        params['dateFrom'] = start.toIso8601String();
        params['dateTo'] = now.toIso8601String();
        break;
      case 'Last 30 Days':
        final start = now.subtract(const Duration(days: 30));
        params['dateFrom'] = start.toIso8601String();
        params['dateTo'] = now.toIso8601String();
        break;
      case 'This Month':
        final start = DateTime(now.year, now.month, 1);
        params['dateFrom'] = start.toIso8601String();
        params['dateTo'] = now.toIso8601String();
        break;
      case 'Last Month':
        final lastMonth = DateTime(now.year, now.month - 1, 1);
        final end = DateTime(now.year, now.month, 0, 23, 59, 59);
        params['dateFrom'] = lastMonth.toIso8601String();
        params['dateTo'] = end.toIso8601String();
        break;
      case 'Custom Range':
        if (customStartDate.value != null) {
          params['dateFrom'] = customStartDate.value!.toIso8601String();
        }
        if (customEndDate.value != null) {
          params['dateTo'] = customEndDate.value!.add(const Duration(hours: 23, minutes: 59, seconds: 59)).toIso8601String();
        }
        break;
      default:
        break;
    }
    return params;
  }

  void showDateFilterBottomSheet(BuildContext context) {
    Get.bottomSheet(DateFilter(), isScrollControlled: true, enableDrag: true, backgroundColor: Colors.transparent);
  }

  Future<void> loadAppointments({bool loadMore = false}) async {
    if (isLoading.value) return;
    try {
      if (!loadMore) {
        isLoading.value = true;
        currentPage.value = 1;
        hasMore.value = true;
        appointments.clear();
        filteredAppointments.clear();
      } else {
        if (!hasMore.value || isLoadMoreLoading.value) return;
        isLoadMoreLoading.value = true;
      }
      totalDocs.value = 0;
      final params = <String, String>{'page': currentPage.value.toString(), 'limit': '10'};
      if (selectedFilter.value != 'All') {
        params['status'] = selectedFilter.value.toLowerCase();
      }
      params['paymentMethod'] = selectedPaymentMethod.value.toLowerCase();
      final dateParams = _getDateParameters();
      params.addAll(dateParams);
      final queryString = params.entries.map((e) => '${e.key}=${Uri.encodeComponent(e.value)}').join('&');
      final response = await _authService.getRequests(queryString: queryString);
      if (response != null && response['docs'] is List) {
        final List newServices = response['docs'];
        if (newServices.isNotEmpty) {
          final parsedServices = newServices.map((item) => PatientRequestModel.fromJson(item)).toList();
          if (loadMore) {
            appointments.addAll(parsedServices);
          } else {
            appointments.assignAll(parsedServices);
          }
          filteredAppointments.assignAll(appointments);
          final totalPages = response['totalPages'] ?? 1;
          final currentPageNum = response['currentPage'] ?? currentPage.value;
          totalDocs.value = response['totalDocs'] ?? 0;
          hasMore.value = currentPageNum < totalPages;
          if (hasMore.value) {
            currentPage.value = currentPageNum + 1;
          }
        } else {
          hasMore.value = false;
        }
      } else {
        if (!loadMore) {
          toaster.warning("No appointments found");
        }
        hasMore.value = false;
      }
    } catch (e) {
      if (!loadMore) {
        toaster.error('Error loading appointments: ${e.toString()}');
      }
    } finally {
      isLoading.value = false;
      isLoadMoreLoading.value = false;
    }
  }

  Future<void> loadMoreAppointments() {
    if (hasMore.value && !isLoading.value && !isLoadMoreLoading.value) {
      return loadAppointments(loadMore: true);
    }
    return Future.value();
  }

  void changeFilter(String filter) {
    selectedFilter.value = filter;
    currentPage.value = 1;
    update();
    loadAppointments();
  }

  void changePaymentMethod(String method) {
    selectedPaymentMethod.value = method;
    currentPage.value = 1;
    update();
    loadAppointments();
  }

  Future<void> cancelAppointment(String appointmentId) async {
    try {
      isCancelling.value = true;
      final response = await _authService.cancelRequests(requestId: appointmentId);
      if (response != null) {
        filteredAppointments.removeWhere((app) => app.id == appointmentId);
        toaster.success("Your appointment has been cancelled successfully");
      } else {
        throw Exception('Failed to cancel appointment');
      }
    } catch (e) {
      toaster.error(e.toString());
    } finally {
      isCancelling.value = false;
    }
  }

  Future<void> submitReview(String appointmentId, int rating, String feedback) async {
    try {
      isSubmittingReview.value = true;
      final response = await _authService.submitFeedback(requestId: appointmentId, rating: rating, feedback: feedback);
      if (response != null) {
        final index = appointments.indexWhere((app) => app.id == appointmentId);
        if (index != -1) {
          appointments[index].rating = rating;
          appointments[index].feedback = feedback;
          filteredAppointments.assignAll(appointments);
        }
        Get.close(1);
        toaster.success("Thank you for your feedback");
      } else {
        throw Exception('Failed to submit review');
      }
    } catch (e) {
      toaster.error(e.toString());
    } finally {
      isSubmittingReview.value = false;
    }
  }

  void viewAppointmentDetails(String appointmentId) {
    Get.to(() => AppointmentDetails(appointmentId: appointmentId));
  }

  Future<void> refreshAppointments() async {
    return loadAppointments();
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }
}
