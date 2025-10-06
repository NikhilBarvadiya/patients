import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:patients/models/models.dart';

class SlotSelectionScreen extends StatelessWidget {
  final ServiceModel service;
  final TherapistModel therapist;
  final selectedDate = Rx<DateTime>(DateTime.now());
  final selectedSlot = Rx<String?>(null);

  SlotSelectionScreen({super.key, required this.service, required this.therapist});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text('Select Time Slot', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Get.back()),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [_buildServiceInfo(), const SizedBox(height: 24), _buildTherapistInfo(), const SizedBox(height: 24), _buildSlotSelection()],
        ),
      ),
      bottomNavigationBar: _buildBookButton(),
    );
  }

  Widget _buildServiceInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: const Color(0xFF2563EB).withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
            child: Icon(service.icon, color: const Color(0xFF2563EB), size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(service.name, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600)),
                Text('₹${service.price.toStringAsFixed(0)} • ${service.duration}', style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600])),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTherapistInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: const Color(0xFF2563EB).withOpacity(0.1),
            child: const Icon(Icons.person, color: Color(0xFF2563EB)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(therapist.name, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600)),
                Text(therapist.specialty, style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600])),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSlotSelection() {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Select Date & Time', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
          _buildDateSelector(),
          const SizedBox(height: 24),
          _buildTimeSlots(),
        ],
      ),
    );
  }

  Widget _buildDateSelector() {
    return SizedBox(
      height: 42,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: 7,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final date = DateTime.now().add(Duration(days: index));
          return Obx(() {
            final isSelected = selectedDate.value.day == date.day;
            return GestureDetector(
              onTap: () {
                selectedDate.value = date;
                selectedSlot.value = null;
              },
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF2563EB) : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: isSelected ? const Color(0xFF2563EB) : Colors.grey[300]!),
                ),
                child: Text(
                  _getDayName(date.weekday),
                  style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500, color: isSelected ? Colors.white : Colors.grey[600]),
                ),
              ),
            );
          });
        },
      ),
    );
  }

  Widget _buildTimeSlots() {
    return Expanded(
      child: Obx(() {
        final dayName = _getDayName(selectedDate.value.weekday);
        final availableSlots = therapist.availability?[dayName] ?? [];

        if (availableSlots.isEmpty) {
          return Center(
            child: Text('No slots available for selected date', style: GoogleFonts.poppins(color: Colors.grey[600])),
          );
        }

        return GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 2.5),
          itemCount: availableSlots.length,
          itemBuilder: (context, index) {
            final slot = availableSlots[index];
            return Obx(() {
              final isSelected = selectedSlot.value == slot;
              return GestureDetector(
                onTap: () => selectedSlot.value = slot,
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF2563EB) : Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: isSelected ? const Color(0xFF2563EB) : Colors.grey[300]!),
                  ),
                  child: Center(
                    child: Text(
                      slot,
                      style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500, color: isSelected ? Colors.white : Colors.black87),
                    ),
                  ),
                ),
              );
            });
          },
        );
      }),
    );
  }

  Widget _buildBookButton() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, -2))],
      ),
      child: Obx(
        () => ElevatedButton(
          onPressed: selectedSlot.value != null ? () => _confirmBooking(selectedDate.value, selectedSlot.value!) : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2563EB),
            disabledBackgroundColor: Colors.grey[400],
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: Text(
            'Confirm Booking',
            style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
          ),
        ),
      ),
    );
  }

  void _confirmBooking(DateTime date, String slot) {
    Get.close(2);
    Get.snackbar(
      'Booking Confirmed!',
      '${service.name} booked with ${therapist.name} on ${_formatDate(date)} at $slot',
      backgroundColor: Colors.green,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 3),
    );
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
        return 'Monday';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
