import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:patients/models/models.dart';
import 'package:patients/views/dashboard/services/ui/service_details.dart';

class ServicesCtrl extends GetxController {
  var services = <ServiceModel>[].obs;
  var filteredServices = <ServiceModel>[].obs;
  var isLoading = false.obs;
  var searchQuery = ''.obs, selectedTherapist = 'All'.obs;
  var therapists = <TherapistModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchTherapists();
    fetchServices();
  }

  Future<void> fetchTherapists() async {
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
  }

  Future<void> fetchServices() async {
    isLoading.value = true;
    await Future.delayed(Duration(seconds: 1));
    services.value = [
      ServiceModel(
        id: 1,
        name: 'Ortho Therapy',
        description: 'Comprehensive rehabilitation for joint and muscle injuries.',
        icon: Icons.fitness_center,
        isActive: true,
        therapistId: '1',
        therapistName: 'Dr. Sarah Johnson',
        price: 1200.0,
      ),
      ServiceModel(
        id: 2,
        name: 'Neuro Therapy',
        description: 'Specialized therapy for neurological conditions.',
        icon: Icons.psychology,
        isActive: true,
        therapistId: '2',
        therapistName: 'Dr. Mike Wilson',
        price: 1500.0,
      ),
      ServiceModel(
        id: 3,
        name: 'Sports Therapy',
        description: 'Tailored recovery programs for athletes.',
        icon: Icons.sports_tennis,
        isActive: true,
        therapistId: '3',
        therapistName: 'Dr. Emily Davis',
        price: 1300.0,
      ),
      ServiceModel(
        id: 4,
        name: 'Pediatric Therapy',
        description: 'Therapy for children to support developmental milestones.',
        icon: Icons.child_care,
        isActive: true,
        therapistId: '4',
        therapistName: 'Dr. Anil Sharma',
        price: 1100.0,
      ),
      ServiceModel(
        id: 5,
        name: 'Geriatric Therapy',
        description: 'Gentle therapy for elderly patients to improve mobility.',
        icon: Icons.elderly,
        isActive: true,
        therapistId: '5',
        therapistName: 'Dr. Priya Patel',
        price: 1000.0,
      ),
      ServiceModel(
        id: 6,
        name: 'Pain Management',
        description: 'Advanced techniques to alleviate chronic pain.',
        icon: Icons.healing,
        isActive: false,
        therapistId: '1',
        therapistName: 'Dr. Sarah Johnson',
        price: 1400.0,
      ),
    ];
    applyFilters();
    isLoading.value = false;
  }

  void searchServices(String query) {
    searchQuery.value = query;
    applyFilters();
  }

  void filterByTherapist(String therapistId) {
    selectedTherapist.value = therapistId;
    applyFilters();
  }

  void applyFilters() {
    var filtered = services.where((service) => service.isActive).toList();
    if (searchQuery.value.isNotEmpty) {
      filtered = filtered.where((service) => service.name.toLowerCase().contains(searchQuery.value.toLowerCase())).toList();
    }
    if (selectedTherapist.value != 'All') {
      filtered = filtered.where((service) => service.therapistId == selectedTherapist.value).toList();
    }
    filteredServices.value = filtered;
  }

  List<String> getTherapists() {
    return ['All', ...therapists.map((t) => t.id)];
  }

  String getTherapistName(String therapistId) {
    return therapists
        .firstWhere(
          (t) => t.id == therapistId,
          orElse: () => TherapistModel(id: '', name: 'Unknown', email: '', specialty: '', experienceYears: 0, clinicName: '', clinicAddress: '', rating: 0, totalPatients: 0),
        )
        .name;
  }

  void viewServiceDetails(ServiceModel service) {
    Get.to(() => ServiceDetails(service: service));
  }

  void bookService(String serviceId, String therapistId) {
    Get.toNamed('/book-clinic', arguments: {'serviceId': serviceId, 'therapistId': therapistId});
  }
}
