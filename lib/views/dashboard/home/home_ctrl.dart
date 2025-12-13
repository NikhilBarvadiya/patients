import 'package:get/get.dart';
import 'package:patients/models/service_model.dart';
import 'package:patients/utils/config/session.dart';
import 'package:patients/utils/storage.dart';
import 'package:patients/utils/toaster.dart';
import 'package:patients/views/auth/auth_service.dart';
import 'package:patients/views/dashboard/appointments/ui/appointment_details.dart';
import 'package:patients/views/dashboard/dashboard_ctrl.dart';
import '../../../models/patient_request_model.dart';

class HomeCtrl extends GetxController {
  final AuthService _authService = Get.find<AuthService>();

  var userName = ''.obs;
  var isLoading = false.obs, isAppointmentLoading = false.obs, isDeleteLoading = false.obs;
  var pendingAppointments = <PatientRequestModel>[].obs;
  var regularServices = <ServiceModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadUserData();
    loadHomeData();
  }

  Future<void> loadUserData() async {
    final userData = await read(AppSession.userData);
    if (userData != null) {
      userName.value = userData['name'] ?? 'Patient';
    }
  }

  Future<void> loadHomeData() async {
    try {
      isLoading.value = true;
      await Future.wait([loadPendingAppointments(), loadServices()]);
    } catch (e) {
      toaster.error('Error loading home data: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadPendingAppointments() async {
    try {
      isAppointmentLoading.value = true;
      final response = await _authService.getRequests(status: 'Pending', page: 1);
      if (response != null && response['docs'] is List) {
        final List appointmentsData = response['docs'];
        pendingAppointments.assignAll(appointmentsData.map((item) => PatientRequestModel.fromJson(item)).toList());
        pendingAppointments.sort((a, b) => b.requestedAt.compareTo(a.requestedAt));
      }
    } catch (e) {
      toaster.error('Error loading appointments: ${e.toString()}');
    } finally {
      isAppointmentLoading.value = false;
    }
  }

  Future<void> loadServices() async {
    try {
      final response = await _authService.patientServices(page: 1, search: "");
      if (response != null && response['docs'] is List) {
        final List newServices = response['docs'];
        if (newServices.isNotEmpty) {
          final parsedServices = newServices.map((item) => ServiceModel.fromJson(item)).toList();
          regularServices.assignAll(parsedServices);
        }
      }
    } catch (e) {
      toaster.error('Error loading services: ${e.toString()}');
    }
  }

  Future<void> cancelAppointment(String requestId) async {
    try {
      isDeleteLoading.value = true;
      final response = await _authService.cancelRequests(requestId: requestId);
      if (response != null) {
        pendingAppointments.removeWhere((app) => app.id == requestId);
        toaster.success('Appointment cancelled successfully');
        update();
      }
    } catch (e) {
      toaster.error('Error cancelling appointment: ${e.toString()}');
    } finally {
      isDeleteLoading.value = false;
    }
  }

  void viewAllServices() {
    DashboardCtrl ctrl = Get.put(DashboardCtrl());
    ctrl.changeTab(1);
  }

  void viewAllAppointments() {
    DashboardCtrl ctrl = Get.put(DashboardCtrl());
    ctrl.changeTab(2);
  }

  void viewAppointmentDetails(String appointmentId) {
    Get.to(() => AppointmentDetails(appointmentId: appointmentId, isHomeAppoint: "isHomeAppoint"));
  }
}
