import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:patients/models/models.dart';
import 'package:patients/views/dashboard/book_service/book_service_ctrl.dart';

class BookServiceScreen extends StatelessWidget {
  final ServiceModel service;
  final TherapistModel therapist;

  const BookServiceScreen({
    super.key,
    required this.service,
    required this.therapist,
  });

  @override
  Widget build(BuildContext context) {
    final BookServiceCtrl ctrl = Get.put(BookServiceCtrl(service: service, therapist: therapist));

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            elevation: 0,
            toolbarHeight: 65,
            backgroundColor: Colors.white,
            pinned: true,
            title: Text(
              'Book Service',
              style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.black87),
              onPressed: () => Get.back(),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildServiceTherapistCard(ctrl),
                  const SizedBox(height: 24),
                  _buildDateSelection(ctrl),
                  const SizedBox(height: 20),
                  _buildTimeSlots(ctrl),
                  const SizedBox(height: 24),
                  _buildNotesSection(ctrl),
                  const SizedBox(height: 24),
                  _buildActionButtons(ctrl),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceTherapistCard(BookServiceCtrl ctrl) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Color(0xFF2563EB).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(service.icon, color: Color(0xFF2563EB), size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  service.name,
                  style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black87),
                ),
                const SizedBox(height: 4),
                Text(
                  therapist.name,
                  style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600]),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.timer_outlined, size: 14, color: Colors.grey[500]),
                    const SizedBox(width: 4),
                    Text(service.duration, style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600])),
                    const SizedBox(width: 12),
                    Icon(Icons.currency_rupee_outlined, size: 14, color: Colors.grey[500]),
                    const SizedBox(width: 4),
                    Text(
                      service.price.toStringAsFixed(0),
                      style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateSelection(BookServiceCtrl ctrl) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select Date',
            style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),
          ),
          const SizedBox(height: 12),
          Obx(() => SizedBox(
            height: 80,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: ctrl.availableDates.length,
              itemBuilder: (context, index) {
                final date = ctrl.availableDates[index];
                final isSelected = ctrl.selectedDate.value == date;
                return GestureDetector(
                  onTap: () => ctrl.selectDate(date),
                  child: Container(
                    width: 60,
                    margin: const EdgeInsets.only(right: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isSelected ? Color(0xFF2563EB) : Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _getDayName(date.weekday),
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: isSelected ? Colors.white : Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          date.day.toString(),
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? Colors.white : Colors.black87,
                          ),
                        ),
                        Text(
                          _getMonthName(date.month),
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            color: isSelected ? Colors.white : Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildTimeSlots(BookServiceCtrl ctrl) {
    return Obx(() {
      if (ctrl.selectedDate.value == null) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
          ),
          child: Center(
            child: Text(
              'Please select a date to see available time slots',
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600]),
            ),
          ),
        );
      }

      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Available Time Slots',
              style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),
            ),
            const SizedBox(height: 12),
            ctrl.availableSlots.isEmpty
                ? Center(
              child: Column(
                children: [
                  Icon(Icons.schedule_outlined, size: 48, color: Colors.grey[300]),
                  const SizedBox(height: 8),
                  Text(
                    'No slots available for selected date',
                    style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
            )
                : Wrap(
              spacing: 8,
              runSpacing: 8,
              children: ctrl.availableSlots.map((slot) {
                final isSelected = ctrl.selectedTime.value == slot;
                return GestureDetector(
                  onTap: () => ctrl.selectTime(slot),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? Color(0xFF2563EB) : Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected ? Color(0xFF2563EB) : Colors.grey[300]!,
                      ),
                    ),
                    child: Text(
                      slot,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: isSelected ? Colors.white : Colors.grey[700],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildNotesSection(BookServiceCtrl ctrl) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Additional Notes (Optional)',
            style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),
          ),
          const SizedBox(height: 12),
          TextField(
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Any specific requirements or notes for the therapist...',
              hintStyle: GoogleFonts.poppins(color: Colors.grey[600]),
              filled: true,
              fillColor: Colors.grey[50],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
            style: GoogleFonts.poppins(fontSize: 14),
            onChanged: ctrl.updatePatientNotes,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BookServiceCtrl ctrl) {
    return Obx(() => Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: ctrl.isFormValid.value ? ctrl.bookService : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF2563EB),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: ctrl.isLoading.value
                ? SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
            )
                : Text(
              'Confirm Booking - ₹${service.price.toStringAsFixed(0)}',
              style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton(
            onPressed: () => Get.back(),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              side: BorderSide(color: Colors.grey[300]!),
            ),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w500, color: Colors.grey[700]),
            ),
          ),
        ),
      ],
    ));
  }

  String _getDayName(int weekday) {
    switch (weekday) {
      case 1: return 'Mon';
      case 2: return 'Tue';
      case 3: return 'Wed';
      case 4: return 'Thu';
      case 5: return 'Fri';
      case 6: return 'Sat';
      case 7: return 'Sun';
      default: return '';
    }
  }

  String _getMonthName(int month) {
    switch (month) {
      case 1: return 'Jan';
      case 2: return 'Feb';
      case 3: return 'Mar';
      case 4: return 'Apr';
      case 5: return 'May';
      case 6: return 'Jun';
      case 7: return 'Jul';
      case 8: return 'Aug';
      case 9: return 'Sep';
      case 10: return 'Oct';
      case 11: return 'Nov';
      case 12: return 'Dec';
      default: return '';
    }
  }
}