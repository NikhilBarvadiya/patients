import 'package:get/get.dart';
import 'package:patients/models/models.dart';
import 'package:patients/models/service_model.dart';
import 'package:patients/utils/config/session.dart';
import 'package:patients/utils/storage.dart';
import 'package:patients/utils/toaster.dart';
import 'package:patients/views/auth/auth_service.dart';
import 'package:patients/views/dashboard/appointments/ui/appointment_details.dart';
import 'package:patients/views/dashboard/dashboard_ctrl.dart';

class HomeCtrl extends GetxController {
  final AuthService _authService = Get.find<AuthService>();

  var userName = ''.obs;

  var pendingAppointments = <PatientRequestModel>[
    PatientRequestModel(
      id: '1',
      patientId: '1',
      therapistId: '1',
      serviceName: 'Ortho Therapy',
      serviceId: '1',
      date: '2024-01-15',
      time: '10:00 AM',
      status: 'pending',
      patientNotes: 'Regular checkup for shoulder pain',
      requestedAt: DateTime.now().subtract(Duration(days: 2)),
      therapistName: 'Dr. Sarah Johnson',
      therapistImage: '',
      duration: '45 mins',
      price: 1200.0,
    ),
    PatientRequestModel(
      id: '2',
      patientId: '1',
      therapistId: '2',
      serviceName: 'Neuro Therapy',
      serviceId: '2',
      date: '2024-01-18',
      time: '02:30 PM',
      status: 'pending',
      patientNotes: 'First session for coordination issues',
      requestedAt: DateTime.now().subtract(Duration(days: 1)),
      therapistName: 'Dr. Mike Wilson',
      therapistImage: '',
      duration: '60 mins',
      price: 1500.0,
    ),
  ].obs;

  var regularServices = [].obs;

  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadUserData();
    loadServices();
  }

  Future<void> loadUserData() async {
    final userData = await read(AppSession.userData);
    if (userData != null) {
      userName.value = userData['name'] ?? 'Patient';
    }
  }

  Future<void> loadServices() async {
    if (isLoading.value) return;
    try {
      final response = await _authService.patientServices(page: 1, search: "");
      if (response != null && response['docs'] is List) {
        final List newServices = response['docs'];
        if (newServices.isNotEmpty) {
          final parsedServices = newServices.map((item) => ServiceModel.fromJson(item)).toList();
          regularServices.addAll(parsedServices);
        }
      }
    } catch (e) {
      toaster.error(e.toString());
    } finally {
      isLoading.value = false;
      update();
    }
  }

  void cancelAppointment(String appointmentId) {
    final appointment = pendingAppointments.firstWhere((app) => app.id == appointmentId);
    final index = pendingAppointments.indexWhere((app) => app.id == appointmentId);
    pendingAppointments[index] = appointment.copyWith(status: 'cancelled');
    update();
  }

  void rescheduleAppointment(String appointmentId, String newDate, String newTime) {
    final appointment = pendingAppointments.firstWhere((app) => app.id == appointmentId);
    final index = pendingAppointments.indexWhere((app) => app.id == appointmentId);
    pendingAppointments[index] = appointment.copyWith(date: newDate, time: newTime, status: 'pending');
    update();
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
    Get.to(() => AppointmentDetails(appointmentId: appointmentId));
  }

  void bookService(ServiceModel service) {
    // Get.to(() => SlotSelection(service: service));
  }
}
