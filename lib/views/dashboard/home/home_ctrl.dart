import 'package:get/get.dart';
import 'package:patients/models/models.dart';
import 'package:patients/utils/config/session.dart';
import 'package:patients/utils/storage.dart';
import 'package:patients/views/dashboard/dashboard_ctrl.dart';
import 'package:patients/views/dashboard/therapists/therapists.dart';
import 'package:patients/views/dashboard/therapists/ui/therapist_details.dart';

class HomeCtrl extends GetxController {
  var userName = ''.obs;

  var upcomingAppointments = <PatientRequestModel>[
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
  ].obs;

  var featuredTherapists = <TherapistModel>[
    TherapistModel(
      id: '1',
      name: 'Dr. Sarah Johnson',
      email: 'sarah.j@example.com',
      specialty: 'Orthopedic Physiotherapy',
      experienceYears: 8,
      clinicName: 'Bone & Joint Care',
      clinicAddress: '123, Health Street, Surat',
      rating: 4.8,
      totalPatients: 120,
    ),
    TherapistModel(
      id: '2',
      name: 'Dr. Mike Wilson',
      email: 'mike.w@example.com',
      specialty: 'Neuro Physiotherapy',
      experienceYears: 12,
      clinicName: 'Neuro Care Center',
      clinicAddress: '456, Brain Road, Surat',
      rating: 4.9,
      totalPatients: 150,
    ),
    TherapistModel(
      id: '3',
      name: 'Dr. Emily Davis',
      email: 'emily.d@example.com',
      specialty: 'Sports Medicine',
      experienceYears: 6,
      clinicName: 'Sports Therapy Hub',
      clinicAddress: '789, Fitness Lane, Surat',
      rating: 4.7,
      totalPatients: 90,
    ),
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

  void viewAllAppointments() {
    DashboardCtrl ctrl = Get.put(DashboardCtrl());
    ctrl.changeTab(2);
  }

  void viewAllTherapists() => Get.to(() => Therapists());

  void viewTherapistProfile(TherapistModel therapist) => Get.to(() => TherapistDetails(therapist: therapist));
}
