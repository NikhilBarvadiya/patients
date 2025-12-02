import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:patients/utils/theme/light.dart';
import 'package:patients/views/dashboard/appointments/appointments_ctrl.dart';
import 'package:patients/views/dashboard/home/home_ctrl.dart';
import '../../../../models/patient_request_model.dart';

class AppointmentDetails extends StatelessWidget {
  final String appointmentId;
  final String? isHomeAppoint;

  final HomeCtrl homeCtrl = Get.find<HomeCtrl>();

  AppointmentsCtrl? get appointmentsCtrl => Get.isRegistered<AppointmentsCtrl>() ? Get.find<AppointmentsCtrl>() : null;

  AppointmentDetails({super.key, required this.appointmentId, this.isHomeAppoint});

  PatientRequestModel get appointment {
    if (isHomeAppoint != null) {
      return homeCtrl.pendingAppointments.firstWhere((app) => app.id == appointmentId, orElse: () => throw Exception('Appointment not found in HomeCtrl'));
    } else if (appointmentsCtrl != null) {
      return appointmentsCtrl!.appointments.firstWhere((app) => app.id == appointmentId, orElse: () => throw Exception('Appointment not found in AppointmentsCtrl'));
    } else {
      return PatientRequestModel.fromJson({});
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(appointment.status);
    final formattedDate = DateFormat('dd MMM yyyy').format(appointment.requestedAt);
    final formattedTime = DateFormat('hh:mm a').format(appointment.requestedAt);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text(
          'Appointment Details',
          style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        leading: IconButton(
          style: ButtonStyle(
            shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            padding: const WidgetStatePropertyAll(EdgeInsets.all(8)),
            backgroundColor: WidgetStatePropertyAll(Colors.grey[100]),
          ),
          icon: const Icon(Icons.arrow_back, color: Colors.black87, size: 20),
          onPressed: () => Get.close(1),
        ),
        actions: [
          IconButton(
            style: ButtonStyle(
              shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              padding: const WidgetStatePropertyAll(EdgeInsets.all(8)),
              backgroundColor: WidgetStatePropertyAll(Colors.grey[100]),
            ),
            icon: Icon(Icons.refresh_rounded, color: Colors.black87),
            onPressed: () {
              if (isHomeAppoint != null) {
                homeCtrl.loadPendingAppointments();
              } else {
                appointmentsCtrl?.refreshAppointments();
              }
            },
          ),
          SizedBox(width: 10),
        ],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildStatusCard(statusColor, formattedDate, formattedTime),
                  const SizedBox(height: 16),
                  _buildDoctorCard(),
                  const SizedBox(height: 16),
                  _buildAppointmentDetails(formattedDate, formattedTime),
                  if (appointment.status == 'Completed' && appointment.rating > 0) ...[const SizedBox(height: 16), _buildFeedbackSection()],
                  if (appointment.status == 'Completed' && appointment.rating == 0) ...[const SizedBox(height: 16), _buildReviewSection()],
                  if (appointment.status == 'Pending') ...[const SizedBox(height: 16), _buildActionButtons()],
                  const SizedBox(height: 20),
                ],
              ),
            ),
            Obx(() {
              if (isHomeAppoint != null) {
                if (homeCtrl.isDeleteLoading.value) {
                  return _buildFullScreenLoading('Cancelling Appointment...', Icons.cancel_outlined);
                }
              } else if (appointmentsCtrl != null) {
                if (appointmentsCtrl!.isCancelling.value || appointmentsCtrl!.isSubmittingReview.value) {
                  return _buildFullScreenLoading(
                    appointmentsCtrl!.isCancelling.value ? 'Cancelling Appointment...' : 'Submitting Review...',
                    appointmentsCtrl!.isCancelling.value ? Icons.cancel_outlined : Icons.star_outlined,
                  );
                }
              }
              return const SizedBox.shrink();
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildFullScreenLoading(String message, IconData icon) {
    return Container(
      color: Colors.black.withOpacity(0.7),
      child: Center(
        child: Container(
          width: 200,
          height: 200,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(color: AppTheme.primaryBlue.withOpacity(0.1), shape: BoxShape.circle),
                    child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryBlue), strokeWidth: 3),
                  ),
                  Icon(icon, size: 30, color: AppTheme.primaryBlue),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                message,
                style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text('Please wait...', style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600])),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusCard(Color statusColor, String formattedDate, String formattedTime) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
        border: Border.all(color: Colors.grey.shade300, width: 0.5),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 45,
                height: 45,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [AppTheme.primaryBlue, AppTheme.primaryBlue.withOpacity(0.7)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.medical_services_rounded, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      appointment.serviceName,
                      style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black87),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(appointment.therapistName, style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600])),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(_getStatusIcon(appointment.status), size: 16, color: statusColor),
                    const SizedBox(width: 6),
                    Text(
                      appointment.status.toUpperCase(),
                      style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w700, color: statusColor, letterSpacing: 0.5),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(12)),
            child: Row(
              spacing: 10.0,
              children: [
                Expanded(child: _buildInfoItem(Icons.calendar_today_rounded, 'Date', formattedDate)),
                Expanded(child: _buildInfoItem(Icons.access_time_rounded, 'Time', formattedTime)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(12)),
            child: Row(
              spacing: 10.0,
              children: [
                Expanded(child: _buildInfoItem(Icons.currency_rupee_rounded, 'Fee', '₹${appointment.charge} (${appointment.paymentStatus.capitalizeFirst.toString()})')),
                Expanded(child: _buildInfoItem(Icons.payment_rounded, 'Payment Type', appointment.paymentType.capitalizeFirst.toString())),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: AppTheme.primaryBlue.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, size: 18, color: AppTheme.primaryBlue),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600], fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDoctorCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
        border: Border.all(color: Colors.grey.shade300, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Doctor Information',
                style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black87),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(color: Colors.amber.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                child: Row(
                  children: [
                    const Icon(Icons.star_rounded, color: Colors.amber, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      appointment.rating > 0 ? appointment.rating.toString() : '4.8',
                      style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.amber.shade800),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppTheme.primaryBlue.withOpacity(0.2), width: 2),
                ),
                child: ClipOval(
                  child: CachedNetworkImage(
                    imageUrl: 'https://images.pexels.com/photos/5452201/pexels-photo-5452201.jpeg',
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: Colors.grey[200],
                      child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey[200],
                      child: Icon(Icons.person, color: Colors.grey[400], size: 40),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      appointment.therapistName,
                      style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black87),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${appointment.preferredType} Specialist',
                      style: GoogleFonts.poppins(fontSize: 14, color: AppTheme.primaryBlue, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 4),
                    Text('${appointment.serviceName} Expert', style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[600])),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.work_outline_rounded, size: 16, color: Colors.grey[500]),
                        const SizedBox(width: 4),
                        Text('5+ years experience', style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600])),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentDetails(String formattedDate, String formattedTime) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
        border: Border.all(color: Colors.grey.shade300, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Appointment Details',
            style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black87),
          ),
          const SizedBox(height: 16),
          _buildDetailRow(Icons.calendar_today_rounded, 'Appointment Date', formattedDate),
          const SizedBox(height: 12),
          _buildDetailRow(Icons.access_time_rounded, 'Appointment Time', formattedTime),
          const SizedBox(height: 12),
          _buildDetailRow(Icons.currency_rupee_rounded, 'Consultation Fee', '₹${appointment.charge}'),
          const SizedBox(height: 12),
          _buildDetailRow(Icons.medical_services_rounded, 'Service Type', appointment.serviceName),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: AppTheme.primaryBlue.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, size: 18, color: AppTheme.primaryBlue),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600], fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedbackSection() {
    final hasReview = appointment.rating != 0;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: hasReview ? const Color(0xFF10B981).withOpacity(0.05) : const Color(0xFFF59E0B).withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: hasReview ? const Color(0xFF10B981).withOpacity(0.2) : const Color(0xFFF59E0B).withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.star_rounded, color: hasReview ? const Color(0xFF10B981) : const Color(0xFFF59E0B), size: 20),
              const SizedBox(width: 8),
              Text(
                hasReview ? 'Your Review' : 'Rate Your Experience',
                style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: hasReview ? const Color(0xFF10B981) : const Color(0xFFF59E0B)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildStarRating(appointment.rating.toDouble()),
              const SizedBox(width: 12),
              Text(
                '${appointment.rating}/5',
                style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),
              ),
            ],
          ),
          if (appointment.feedback.isNotEmpty) ...[const SizedBox(height: 12), Text(appointment.feedback, style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[700], height: 1.4))],
        ],
      ),
    );
  }

  Widget _buildReviewSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF59E0B).withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF59E0B).withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Rate your experience',
                  style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),
                ),
                const SizedBox(height: 4),
                Text('Share your feedback about the service', style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600])),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () => _showAddReviewDialog(),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF59E0B),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: Text('Add Review', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => _showCancelDialog(),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFFEF4444),
              side: const BorderSide(color: Color(0xFFEF4444)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.close_rounded, size: 18),
                const SizedBox(width: 8),
                Text('Cancel Appointment', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStarRating(double rating) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return Icon(index < rating.floor() ? Icons.star_rounded : (index < rating.ceil() ? Icons.star_half_rounded : Icons.star_outline_rounded), color: const Color(0xFFF59E0B), size: 24);
      }),
    );
  }

  void _showAddReviewDialog() {
    if (appointmentsCtrl == null) return;
    int rating = 0;
    final commentController = TextEditingController();
    Get.dialog(
      Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: const Color(0xFF2563EB).withOpacity(0.1), shape: BoxShape.circle),
                    child: const Icon(Icons.star_rounded, color: Color(0xFF2563EB), size: 40),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Rate Your Experience',
                    style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.black87),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'How was your service experience?',
                    style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600], height: 1.5),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return IconButton(
                        onPressed: () => setState(() => rating = index + 1),
                        icon: Icon(index < rating ? Icons.star_rounded : Icons.star_outline_rounded, color: const Color(0xFFF59E0B), size: 32),
                      );
                    }),
                  ),
                  const SizedBox(height: 8),
                  Text(rating == 0 ? 'Tap to rate' : '$rating ${rating == 1 ? 'star' : 'stars'}', style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600])),
                  const SizedBox(height: 20),
                  TextField(
                    controller: commentController,
                    minLines: 3,
                    maxLines: 5,
                    decoration: InputDecoration(
                      labelText: 'Your feedback (optional)',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.all(16),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Get.close(1),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.grey[700],
                            side: BorderSide(color: Colors.grey[300]!),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: Text('Cancel', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Obx(
                          () => ElevatedButton(
                            onPressed: rating > 0 && !appointmentsCtrl!.isSubmittingReview.value
                                ? () {
                                    appointmentsCtrl!.submitReview(appointmentId, rating, commentController.text.trim());
                                    Get.close(1);
                                  }
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2563EB),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              elevation: 0,
                            ),
                            child: appointmentsCtrl!.isSubmittingReview.value
                                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                : Text('Submit Review', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
      barrierDismissible: false,
    );
  }

  void _showCancelDialog() {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: ClipRRect(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: const Color(0xFFEF4444).withOpacity(0.1), shape: BoxShape.circle),
                  child: const Icon(Icons.warning_rounded, color: Color(0xFFEF4444), size: 40),
                ),
                const SizedBox(height: 20),
                Text(
                  'Cancel Appointment?',
                  style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.black87),
                ),
                const SizedBox(height: 8),
                Text(
                  'This action cannot be undone. The doctor will be notified about the cancellation.',
                  style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600], height: 1.5),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Get.close(1),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.grey[700],
                          side: BorderSide(color: Colors.grey[300]!),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: Text('Go Back', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          if (isHomeAppoint != null) {
                            homeCtrl.cancelAppointment(appointmentId);
                          } else {
                            appointmentsCtrl?.cancelAppointment(appointmentId);
                          }
                          Get.close(1);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFEF4444),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          elevation: 0,
                        ),
                        child: Text('Yes, Cancel', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600)),
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

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Pending':
        return const Color(0xFFF59E0B);
      case 'Accepted':
        return const Color(0xFF10B981);
      case 'Completed':
        return const Color(0xFF3B82F6);
      case 'Cancelled':
        return const Color(0xFFEF4444);
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'Pending':
        return Icons.pending_rounded;
      case 'Accepted':
        return Icons.check_circle_rounded;
      case 'Completed':
        return Icons.verified_rounded;
      case 'Cancelled':
        return Icons.cancel_rounded;
      default:
        return Icons.calendar_today_rounded;
    }
  }
}
