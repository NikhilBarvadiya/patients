import 'package:get/get.dart';
import 'package:patients/models/models.dart';
import 'package:patients/views/dashboard/appointments/ui/appointment_details.dart';

class AppointmentsCtrl extends GetxController {
  var selectedFilter = 'All'.obs;
  final filters = ['All', 'Pending', 'Confirmed', 'Completed', 'Cancelled'];

  var appointments = <PatientRequestModel>[
    PatientRequestModel(
      id: '1',
      patientId: '1',
      therapistId: '1',
      serviceName: 'Ortho Therapy',
      serviceId: '1',
      date: '2024-01-15',
      time: '10:00 AM',
      status: 'confirmed',
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
    PatientRequestModel(
      id: '3',
      patientId: '1',
      therapistId: '3',
      serviceName: 'Sports Therapy',
      serviceId: '3',
      date: '2024-01-20',
      time: '11:00 AM',
      status: 'completed',
      patientNotes: 'Ankle injury recovery session',
      requestedAt: DateTime.now().subtract(Duration(days: 5)),
      therapistName: 'Dr. Emily Davis',
      therapistImage: '',
      duration: '45 mins',
      price: 1800.0,
    ),
    PatientRequestModel(
      id: '4',
      patientId: '1',
      therapistId: '1',
      serviceName: 'Pain Management',
      serviceId: '4',
      date: '2024-01-22',
      time: '03:00 PM',
      status: 'cancelled',
      patientNotes: 'Back pain treatment',
      requestedAt: DateTime.now().subtract(Duration(days: 3)),
      therapistName: 'Dr. Sarah Johnson',
      therapistImage: '',
      duration: '30 mins',
      price: 1000.0,
    ),
    PatientRequestModel(
      id: '5',
      patientId: '1',
      therapistId: '2',
      serviceName: 'Neuro Therapy',
      serviceId: '2',
      date: '2024-01-25',
      time: '09:30 AM',
      status: 'confirmed',
      patientNotes: 'Follow-up session',
      requestedAt: DateTime.now().subtract(Duration(hours: 12)),
      therapistName: 'Dr. Mike Wilson',
      therapistImage: '',
      duration: '60 mins',
      price: 1500.0,
    ),
  ].obs;

  List<PatientRequestModel> get filteredAppointments {
    if (selectedFilter.value == 'All') {
      return appointments;
    }
    return appointments.where((appointment) => appointment.status == selectedFilter.value.toLowerCase()).toList();
  }

  void changeFilter(String filter) {
    selectedFilter.value = filter;
  }

  void cancelAppointment(String appointmentId) {
    final appointment = appointments.firstWhere((app) => app.id == appointmentId);
    final index = appointments.indexWhere((app) => app.id == appointmentId);

    appointments[index] = appointment.copyWith(status: 'cancelled');
    update();
  }

  void rescheduleAppointment(String appointmentId, String newDate, String newTime) {
    final appointment = appointments.firstWhere((app) => app.id == appointmentId);
    final index = appointments.indexWhere((app) => app.id == appointmentId);

    appointments[index] = appointment.copyWith(date: newDate, time: newTime, status: 'pending');
    update();
  }

  void viewAppointmentDetails(String appointmentId) {
    Get.to(() => AppointmentDetails(appointmentId: appointmentId));
  }
}
