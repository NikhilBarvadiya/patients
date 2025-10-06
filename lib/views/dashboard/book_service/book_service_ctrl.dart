import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:patients/models/models.dart';
import 'package:patients/utils/config/session.dart';
import 'package:patients/utils/storage.dart';

class BookServiceCtrl extends GetxController {
  final ServiceModel service;
  final TherapistModel therapist;

  BookServiceCtrl({required this.service, required this.therapist});

  var selectedDate = Rxn<DateTime>();
  var selectedTime = RxString('');
  var patientNotes = ''.obs;
  var isLoading = false.obs, isFormValid = false.obs;

  var availableDates = <DateTime>[].obs;
  var availableSlots = <String>[].obs;

  @override
  void onInit() {
    super.onInit();
    _generateAvailableDates();
    everAll([selectedDate, selectedTime, patientNotes], (_) => validateForm());
  }

  void _generateAvailableDates() {
    final now = DateTime.now();
    for (int i = 0; i < 14; i++) {
      final date = now.add(Duration(days: i));
      if (date.weekday != DateTime.sunday) {
        availableDates.add(date);
      }
    }
  }

  void selectDate(DateTime date) {
    selectedDate.value = date;
    _updateAvailableSlots(date);
  }

  void _updateAvailableSlots(DateTime date) {
    final dayName = _getDayName(date.weekday);
    final slots = therapist.availability?[dayName] ?? [];
    availableSlots.value = slots;
    selectedTime.value = '';
  }

  void selectTime(String time) {
    selectedTime.value = time;
  }

  void updatePatientNotes(String notes) {
    patientNotes.value = notes;
  }

  void validateForm() {
    isFormValid.value = selectedDate.value != null && selectedTime.value.isNotEmpty;
  }

  Future<void> bookService() async {
    if (!isFormValid.value) return;
    isLoading.value = true;
    try {
      await Future.delayed(Duration(seconds: 2));
      final userData = await read(AppSession.userData) ?? {'id': '1', 'name': 'Patient'};
      final patientId = userData['id'];
      final appointment = PatientRequestModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        patientId: patientId,
        therapistId: therapist.id,
        serviceName: service.name,
        serviceId: service.id.toString(),
        date: selectedDate.value!.toIso8601String().split('T')[0],
        time: selectedTime.value,
        status: 'pending',
        patientNotes: patientNotes.value,
        requestedAt: DateTime.now(),
        therapistName: therapist.name,
        therapistImage: therapist.image ?? '',
        duration: service.duration,
        price: service.price,
      );
      List<dynamic> existingAppointments = (await read('appointments') ?? []) as List<dynamic>;
      existingAppointments.add(appointment);
      await write('appointments', existingAppointments);
      isLoading.value = false;
      Get.close(2);
      Get.snackbar(
        'Booking Confirmed!',
        'Your ${service.name} appointment with ${therapist.name} is scheduled for ${selectedDate.value!.day}/${selectedDate.value!.month}/${selectedDate.value!.year} at ${selectedTime.value}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: Duration(seconds: 5),
      );
    } catch (e) {
      isLoading.value = false;
      Get.snackbar('Booking Failed', 'Please try again later', snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  String _getDayName(int weekday) {
    switch (weekday) {
      case 1:
        return 'Monday';
      case 2:
        return 'Tuesday';
      case 3:
        return 'Wednesday';
      case 4:
        return 'Thursday';
      case 5:
        return 'Friday';
      case 6:
        return 'Saturday';
      case 7:
        return 'Sunday';
      default:
        return '';
    }
  }
}
