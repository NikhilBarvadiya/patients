import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:patients/utils/toaster.dart';
import 'package:patients/views/auth/auth_service.dart';
import 'package:patients/views/dashboard/appointments/ui/appointment_details.dart';
import '../../../models/patient_request_model.dart';

class AppointmentsCtrl extends GetxController {
  final AuthService _authService = Get.find<AuthService>();
  var selectedFilter = 'All'.obs;
  final filters = ['All', 'Pending', 'Accepted', 'Completed', 'Cancelled'];
  var appointments = <PatientRequestModel>[].obs;
  var filteredAppointments = <PatientRequestModel>[].obs;
  var isLoading = false.obs, isLoadMoreLoading = false.obs, hasMore = true.obs;
  var isSubmittingReview = false.obs, isCancelling = false.obs;
  var currentPage = 1.obs;

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
      final response = await _authService.getRequests(status: selectedFilter.value == 'All' ? '' : selectedFilter.value, page: currentPage.value);
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
          hasMore.value = currentPageNum < totalPages;
          if (hasMore.value) {
            currentPage.value = currentPageNum + 1;
          }
        } else {
          hasMore.value = false;
        }
      } else {
        if (!loadMore) {
          toaster.warning("'No services found'");
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
