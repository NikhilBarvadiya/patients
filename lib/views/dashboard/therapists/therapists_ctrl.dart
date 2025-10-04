import 'package:get/get.dart';
import 'package:patients/models/models.dart';
import 'package:patients/views/dashboard/therapists/ui/therapist_details.dart';

class TherapistsCtrl extends GetxController {
  var therapists = <TherapistModel>[].obs;
  var filteredTherapists = <TherapistModel>[].obs;
  var isLoading = false.obs;
  var searchQuery = ''.obs, selectedSpecialty = 'All'.obs;

  @override
  void onInit() {
    super.onInit();
    fetchTherapists();
  }

  Future<void> fetchTherapists() async {
    isLoading.value = true;
    await Future.delayed(Duration(seconds: 1));
    therapists.value = [
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
      TherapistModel(
        id: '4',
        name: 'Dr. Anil Sharma',
        email: 'anil.s@example.com',
        specialty: 'Pediatric Physiotherapy',
        experienceYears: 10,
        clinicName: 'Kids Wellness Clinic',
        clinicAddress: '101, Child Care Road, Surat',
        rating: 4.6,
        totalPatients: 80,
      ),
      TherapistModel(
        id: '5',
        name: 'Dr. Priya Patel',
        email: 'priya.p@example.com',
        specialty: 'Geriatric Physiotherapy',
        experienceYears: 7,
        clinicName: 'Senior Care Physio',
        clinicAddress: '202, Elder Lane, Surat',
        rating: 4.5,
        totalPatients: 100,
      ),
    ];
    filteredTherapists.value = therapists;
    isLoading.value = false;
    applyFilters();
  }

  void searchTherapists(String query) {
    searchQuery.value = query;
    applyFilters();
  }

  void filterBySpecialty(String specialty) {
    selectedSpecialty.value = specialty;
    applyFilters();
  }

  void applyFilters() {
    List<TherapistModel> filtered = therapists;
    if (searchQuery.value.isNotEmpty) {
      filtered = filtered
          .where((therapist) => therapist.name.toLowerCase().contains(searchQuery.value.toLowerCase()) || therapist.specialty.toLowerCase().contains(searchQuery.value.toLowerCase()))
          .toList();
    }
    if (selectedSpecialty.value != 'All') {
      filtered = filtered.where((therapist) => therapist.specialty == selectedSpecialty.value).toList();
    }
    filteredTherapists.value = filtered;
  }

  List<String> getSpecialties() {
    return ['All', ...therapists.map((t) => t.specialty).toSet()];
  }

  void viewTherapistProfile(TherapistModel therapist) => Get.to(() => TherapistDetails(therapist: therapist));
}
