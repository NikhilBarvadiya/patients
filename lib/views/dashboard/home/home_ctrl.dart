import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:patients/models/models.dart';
import 'package:patients/utils/config/session.dart';
import 'package:patients/utils/storage.dart';
import 'package:patients/views/dashboard/appointments/ui/appointment_details.dart';
import 'package:patients/views/dashboard/dashboard_ctrl.dart';
import 'package:patients/views/dashboard/services/ui/service_details.dart';
import 'package:patients/views/dashboard/services/ui/slot_selection.dart';

class HomeCtrl extends GetxController {
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

  var regularServices = [
    ServiceModel(id: 4, name: 'Pediatric Therapy', description: 'Therapy for children to support developmental milestones.', icon: Icons.child_care, isActive: true, price: 1100.0),
    ServiceModel(id: 5, name: 'Geriatric Therapy', description: 'Gentle therapy for elderly patients to improve mobility.', icon: Icons.elderly, isActive: true, price: 1000.0),
    ServiceModel(id: 6, name: 'Pain Management', description: 'Advanced techniques to alleviate chronic pain.', icon: Icons.healing, isActive: false, price: 1400.0),
  ].obs;

  @override
  void onInit() {
    super.onInit();
    loadUserData();
  }

  Future<void> loadUserData() async {
    final userData = await read(AppSession.userData);
    if (userData != null) {
      userName.value = userData['name'] ?? 'Patient';
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

  void bookDetails(ServiceModel service) {
    Get.to(() => ServiceDetails(service: service));
  }

  void bookService(ServiceModel service) {
    Get.to(() => SlotSelection(service: service));
  }
}
