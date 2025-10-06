import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:patients/models/models.dart';
import 'package:patients/views/dashboard/home/home_ctrl.dart';
import 'package:patients/views/dashboard/home/notifications/notifications.dart';

class Home extends StatelessWidget {
  Home({super.key});

  final HomeCtrl ctrl = Get.put(HomeCtrl());

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          elevation: 0,
          toolbarHeight: 65,
          backgroundColor: Colors.white,
          pinned: true,
          floating: true,
          automaticallyImplyLeading: false,
          title: Obx(
            () => Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Hello,', style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600])),
                Text(
                  ctrl.userName.value,
                  style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
              ],
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: IconButton(
                icon: Badge(
                  smallSize: 8,
                  backgroundColor: Colors.red,
                  child: const Icon(Icons.notifications_outlined, color: Colors.black87),
                ),
                onPressed: () => Get.to(() => Notifications()),
              ),
            ),
          ],
        ),
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              _buildBannerSection(),
              const SizedBox(height: 10),
              Padding(
                padding: EdgeInsets.only(left: 20, right: 20, top: 18),
                child: TextField(
                  readOnly: true,
                  onTap: () => ctrl.viewAllServices(),
                  decoration: InputDecoration(
                    hintText: 'Search services...',
                    hintStyle: GoogleFonts.poppins(color: Colors.grey[600]),
                    prefixIcon: Icon(Icons.search_rounded, color: Colors.grey[600]),
                    suffixIcon: Icon(Icons.ads_click_rounded, color: Colors.grey[600]),
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  ),
                  style: GoogleFonts.poppins(fontSize: 16),
                ),
              ),
              const SizedBox(height: 16),
              _buildRegularServices(),
              const SizedBox(height: 16),
              _buildPendingAppointments(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBannerSection() {
    final banners = [
      {
        'image': 'https://images.pexels.com/photos/3825529/pexels-photo-3825529.jpeg?auto=compress&cs=tinysrgb&w=1080',
        'title': 'Welcome to Our Clinic',
        'subtitle': 'Where care meets expertise — your recovery starts here.',
        'color': Colors.blue[700]!,
      },
      {
        'image': 'https://images.pexels.com/photos/4506107/pexels-photo-4506107.jpeg?auto=compress&cs=tinysrgb&w=1080',
        'title': 'Special Offer',
        'subtitle': 'Enjoy 20% off your first physiotherapy session!',
        'color': Colors.green[700]!,
      },
      {
        'image': 'https://images.pexels.com/photos/8376234/pexels-photo-8376234.jpeg?auto=compress&cs=tinysrgb&w=1080',
        'title': 'New Services',
        'subtitle': 'Now offering maternity & pediatric physiotherapy programs.',
        'color': Colors.purple[700]!,
      },
    ];
    return SizedBox(
      height: 160,
      child: PageView.builder(
        itemCount: banners.length,
        padEnds: false,
        controller: PageController(viewportFraction: 0.85),
        itemBuilder: (context, index) {
          final banner = banners[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CachedNetworkImage(
                      imageUrl: banner['image'].toString(),
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: banner['color'] as Color,
                        child: const Center(child: CircularProgressIndicator(color: Colors.white)),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: banner['color'] as Color,
                        child: const Icon(Icons.error, color: Colors.white, size: 40),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [Colors.black.withOpacity(0.6), Colors.transparent], begin: Alignment.bottomCenter, end: Alignment.topCenter),
                      ),
                    ),
                    Positioned(
                      bottom: 20,
                      left: 20,
                      right: 20,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            banner['title'].toString(),
                            style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          const SizedBox(height: 4),
                          Text(banner['subtitle'].toString(), style: GoogleFonts.poppins(fontSize: 12, color: Colors.white.withOpacity(0.9))),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRegularServices() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Regular Services',
                style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black87),
              ),
              const Spacer(),
              TextButton(
                onPressed: ctrl.viewAllAppointments,
                child: Text(
                  'View All',
                  style: GoogleFonts.poppins(color: Color(0xFF2563EB), fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Obx(() {
            if (ctrl.regularServices.isEmpty) {
              return _buildEmptyState('No regular appointments', 'Book your first session to get started', Icons.calendar_today_outlined);
            }
            return SizedBox(
              height: 200,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 2),
                itemCount: ctrl.regularServices.length > 5 ? 5 : ctrl.regularServices.length,
                itemBuilder: (context, index) {
                  return _buildServiceCard(ctrl.regularServices[index]);
                },
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildServiceCard(ServiceModel service) {
    return Container(
      width: 300,
      margin: const EdgeInsets.only(right: 12),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        elevation: 2,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => ctrl.bookDetails(service),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: const Color(0xFF2563EB).withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                      child: Icon(service.icon, color: const Color(0xFF2563EB), size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            service.name,
                            style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),
                          ),
                          Text(
                            '₹${service.price.toStringAsFixed(0)}',
                            style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF2563EB)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(service.description, style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[700], letterSpacing: .5)),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => ctrl.bookDetails(service),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF2563EB),
                          side: const BorderSide(color: Color(0xFF2563EB)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: Text('View Details', style: GoogleFonts.poppins(fontWeight: FontWeight.w500, fontSize: 12)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => ctrl.bookService(service),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2563EB),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: Text('Book Now', style: GoogleFonts.poppins(fontWeight: FontWeight.w500, fontSize: 12)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPendingAppointments() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Pending Appointments',
                style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black87),
              ),
              const Spacer(),
              TextButton(
                onPressed: ctrl.viewAllAppointments,
                child: Text(
                  'View All',
                  style: GoogleFonts.poppins(color: Color(0xFF2563EB), fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Obx(() {
            if (ctrl.pendingAppointments.isEmpty) {
              return _buildEmptyState('No pending appointments', 'Book your first session to get started', Icons.calendar_today_outlined);
            }
            return SizedBox(
              height: 180,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 2),
                itemCount: ctrl.pendingAppointments.length > 5 ? 5 : ctrl.pendingAppointments.length,
                itemBuilder: (context, index) {
                  return _buildAppointmentCard(ctrl.pendingAppointments[index]);
                },
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildAppointmentCard(PatientRequestModel appointment) {
    return Container(
      width: 280,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => ctrl.viewAppointmentDetails(appointment.id),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: Color(0xFFF59E0B).withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                      child: Icon(Icons.pending_outlined, color: Color(0xFFF59E0B), size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            appointment.serviceName.toString(),
                            style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),
                          ),
                          const SizedBox(height: 2),
                          Text(appointment.therapistName.toString(), style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600])),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildDetailRow(appointment),
                if (appointment.status == 'pending') ...[
                  const SizedBox(height: 12),
                  Divider(color: Colors.grey[200]),
                  const SizedBox(height: 8),
                  _buildActionButtons(appointment.id, appointment.status),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(PatientRequestModel appointment) {
    return Row(
      children: [
        Expanded(child: _buildDetailItem(Icons.calendar_today_outlined, appointment.date)),
        Expanded(child: _buildDetailItem(Icons.access_time_outlined, appointment.time)),
        Expanded(child: _buildDetailItem(Icons.timer_outlined, appointment.duration)),
      ],
    );
  }

  Widget _buildDetailItem(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Colors.grey[500]),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(String title, String subtitle, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          Icon(icon, size: 48, color: Colors.grey[300]),
          const SizedBox(height: 8),
          Text(
            title,
            style: GoogleFonts.poppins(color: Colors.grey[600], fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 4),
          Text(subtitle, style: GoogleFonts.poppins(color: Colors.grey[500], fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildActionButtons(String appointmentId, String status) {
    return Row(
      children: [
        if (status == 'pending') ...[
          Expanded(
            child: OutlinedButton(
              onPressed: () => _showCancelDialog(appointmentId),
              style: OutlinedButton.styleFrom(
                foregroundColor: Color(0xFFEF4444),
                side: BorderSide(color: Color(0xFFEF4444)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.symmetric(vertical: 8),
              ),
              child: Text('Cancel', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500)),
            ),
          ),
          const SizedBox(width: 8),
        ],
        Expanded(
          child: ElevatedButton(
            onPressed: () => _showRescheduleDialog(appointmentId),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF2563EB),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(vertical: 8),
            ),
            child: Text('Reschedule', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500)),
          ),
        ),
      ],
    );
  }

  void _showCancelDialog(String appointmentId) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Color(0xFFEF4444).withOpacity(0.1), shape: BoxShape.circle),
                child: Icon(Icons.cancel_outlined, color: Color(0xFFEF4444), size: 40),
              ),
              const SizedBox(height: 16),
              Text(
                'Cancel Appointment?',
                style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              const SizedBox(height: 8),
              Text(
                'Are you sure you want to cancel this appointment? This action cannot be undone.',
                style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text('Keep', style: GoogleFonts.poppins(fontWeight: FontWeight.w500, fontSize: 12)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        ctrl.cancelAppointment(appointmentId);
                        Get.back();
                        Get.snackbar(
                          'Appointment Cancelled',
                          'Your appointment has been cancelled successfully',
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: Color(0xFF10B981),
                          colorText: Colors.white,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFEF4444),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text(
                        'Cancel',
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w500, color: Colors.white, fontSize: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  void _showRescheduleDialog(String appointmentId) {
    final appointment = ctrl.pendingAppointments.firstWhere((app) => app.id == appointmentId);
    final dateController = TextEditingController(text: appointment.date);
    final timeController = TextEditingController(text: appointment.time);
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: ClipRRect(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: Color(0xFF2563EB).withOpacity(0.1), shape: BoxShape.circle),
                  child: Icon(Icons.schedule_outlined, color: Color(0xFF2563EB), size: 40),
                ),
                const SizedBox(height: 16),
                Text(
                  'Appointment',
                  style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
                const SizedBox(height: 8),
                Text(
                  'Choose new date and time for your appointment',
                  style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: dateController,
                  decoration: InputDecoration(
                    labelText: 'Date',
                    prefixIcon: Icon(Icons.calendar_today_outlined),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  readOnly: true,
                  onTap: () async {
                    final DateTime now = DateTime.now();
                    final DateTime? picked = await showDatePicker(context: Get.context!, initialDate: now, firstDate: now, lastDate: DateTime(now.year + 1, now.month, now.day));
                    if (picked != null) {
                      dateController.text = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
                    }
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: timeController,
                  decoration: InputDecoration(
                    labelText: 'Time',
                    prefixIcon: Icon(Icons.access_time_outlined),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  readOnly: true,
                  onTap: () async {
                    final TimeOfDay? picked = await showTimePicker(context: Get.context!, initialTime: TimeOfDay.now());
                    if (picked != null) {
                      timeController.text = "${picked.hourOfPeriod}:${picked.minute.toString().padLeft(2, '0')} ${picked.period == DayPeriod.am ? 'AM' : 'PM'}";
                    }
                  },
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Get.back(),
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: Text('Cancel', style: GoogleFonts.poppins(fontWeight: FontWeight.w500, fontSize: 12)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          if (dateController.text.isNotEmpty && timeController.text.isNotEmpty) {
                            ctrl.rescheduleAppointment(appointmentId, dateController.text, timeController.text);
                            Get.back();
                            Get.snackbar(
                              'Appointment Rescheduled',
                              'Your appointment has been rescheduled successfully',
                              snackPosition: SnackPosition.BOTTOM,
                              backgroundColor: Color(0xFF10B981),
                              colorText: Colors.white,
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF2563EB),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: Text(
                          'Reschedule',
                          style: GoogleFonts.poppins(fontWeight: FontWeight.w500, color: Colors.white, fontSize: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }
}
