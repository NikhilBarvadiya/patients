import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:patients/models/patient_request_model.dart';
import 'package:patients/utils/theme/light.dart';
import 'package:patients/views/dashboard/appointments/appointments_ctrl.dart';

class AppointmentCard extends StatefulWidget {
  final PatientRequestModel appointment;

  const AppointmentCard({super.key, required this.appointment});

  @override
  State<AppointmentCard> createState() => _AppointmentCardState();
}

class _AppointmentCardState extends State<AppointmentCard> {
  final ctrl = Get.find<AppointmentsCtrl>();

  void _toggleCardExpansion(String appointmentId) {
    if (ctrl.expandedCards.contains(appointmentId)) {
      ctrl.expandedCards.clear();
    } else {
      ctrl.expandedCards.clear();
      ctrl.expandedCards.add(appointmentId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final appointment = widget.appointment;
    final formattedDate = DateFormat('dd MMM yyyy').format(appointment.updatedAt.toLocal());
    final formattedTime = DateFormat('hh:mm a').format(appointment.updatedAt.toLocal());
    final statusColor = _getStatusColor(appointment.status);
    final statusIcon = _getStatusIcon(appointment.status);
    final hasMultipleDoctors = appointment.doctors.length > 1;
    final primaryDoctor = appointment.doctors.isNotEmpty ? appointment.doctors.first : null;
    return Obx(() {
      final isExpanded = ctrl.expandedCards.contains(appointment.id);
      return GestureDetector(
        onTap: () => _toggleCardExpansion(appointment.id),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade300, width: isExpanded ? .8 : .3),
            boxShadow: [BoxShadow(color: isExpanded ? AppTheme.primaryBlue.withOpacity(0.1) : Colors.black.withOpacity(0.02), blurRadius: isExpanded ? 12 : 8, offset: const Offset(0, 2))],
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [AppTheme.primaryBlue, AppTheme.primaryBlue.withOpacity(0.7)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.medical_services_rounded, color: Colors.white, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            appointment.serviceName,
                            style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Icon(Icons.person_outline_rounded, size: 14, color: Colors.grey.shade600),
                              const SizedBox(width: 2),
                              if (appointment.doctors.isEmpty)
                                Expanded(
                                  child: Text('No doctor assigned', style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade600)),
                                ),
                              if (!hasMultipleDoctors && primaryDoctor != null)
                                Expanded(
                                  child: Text(
                                    _getDoctorName(primaryDoctor),
                                    style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade700),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              if (appointment.doctors.isNotEmpty && hasMultipleDoctors && primaryDoctor != null)
                                Expanded(
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          _getDoctorName(primaryDoctor),
                                          style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade700),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      Container(
                                        margin: const EdgeInsets.only(left: 4, right: 4),
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(color: AppTheme.primaryBlue.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                                        child: Text(
                                          '+${appointment.doctors.length - 1} more',
                                          style: GoogleFonts.poppins(fontSize: 9, fontWeight: FontWeight.w600, color: AppTheme.primaryBlue),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(statusIcon, size: 14, color: statusColor),
                                  const SizedBox(width: 2),
                                  Text(
                                    appointment.status.toUpperCase(),
                                    style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w700, color: statusColor, letterSpacing: 0.5),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (!isExpanded)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(12)),
                    child: Row(
                      children: [
                        Icon(Icons.calendar_today_rounded, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 6),
                        Text(
                          formattedDate,
                          style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[700], fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(width: 16),
                        Icon(Icons.access_time_rounded, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 6),
                        Text(
                          formattedTime,
                          style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[700], fontWeight: FontWeight.w500),
                        ),
                        const Spacer(),
                        Icon(isExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded, color: Colors.grey[600], size: 24),
                      ],
                    ),
                  ),
                ),
              AnimatedSize(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                child: isExpanded
                    ? Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(16), bottomRight: Radius.circular(16)),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(child: _buildInfoTile(Icons.calendar_today_rounded, 'Date', formattedDate)),
                                const SizedBox(width: 12),
                                Expanded(child: _buildInfoTile(Icons.access_time_rounded, 'Time', formattedTime)),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(child: _buildInfoTile(Icons.currency_rupee_rounded, 'Charge', '₹${appointment.charge}')),
                                const SizedBox(width: 12),
                                Expanded(child: _buildInfoTile(Icons.payment_rounded, 'Payment Status', appointment.paymentStatus.capitalizeFirst.toString())),
                              ],
                            ),
                            if (appointment.status == 'Completed' && appointment.rating > 0) ...[const SizedBox(height: 12), _buildReviewInfo(appointment)],
                            const SizedBox(height: 16),
                            Divider(color: Colors.grey[300], height: 1),
                            const SizedBox(height: 16),
                            _buildActionSection(appointment, ctrl),
                            if (appointment.status == 'Completed' && appointment.rating == 0) ...[
                              const SizedBox(height: 16),
                              Divider(color: Colors.grey[300], height: 1),
                              const SizedBox(height: 16),
                              _buildAddReviewSection(appointment),
                            ],
                          ],
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildInfoTile(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(color: AppTheme.primaryBlue.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, size: 16, color: AppTheme.primaryBlue),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey[600], fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: GoogleFonts.poppins(fontSize: 13, color: Colors.black87, fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewInfo(PatientRequestModel appointment) {
    final hasReview = appointment.rating != 0;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: hasReview ? Color(0xFF10B981).withOpacity(0.05) : Color(0xFFF59E0B).withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: hasReview ? Color(0xFF10B981).withOpacity(0.2) : Color(0xFFF59E0B).withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hasReview ? 'You reviewed this session' : 'Rate your experience',
                  style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: hasReview ? Color(0xFF10B981) : Color(0xFFF59E0B)),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    _buildStarRating(appointment.rating.toDouble()),
                    const SizedBox(width: 8),
                    Text(
                      '${appointment.rating}/5',
                      style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black87),
                    ),
                  ],
                ),
                if (appointment.feedback.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    appointment.feedback,
                    style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey[600]),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionSection(PatientRequestModel appointment, AppointmentsCtrl ctrl) {
    return Row(
      spacing: 10.0,
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => ctrl.viewAppointmentDetails(appointment.id),
            icon: const Icon(Icons.visibility_rounded, size: 18),
            label: Text('View Details', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600)),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.primaryBlue,
              side: BorderSide(color: AppTheme.primaryBlue),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
        if (appointment.status != 'Completed' && appointment.status != 'Cancelled')
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => _showCancelDialog(appointment.id, ctrl),
              icon: const Icon(Icons.close_rounded, size: 18),
              label: Text('Cancel', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600)),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFEF4444),
                side: const BorderSide(color: Color(0xFFEF4444)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildAddReviewSection(PatientRequestModel appointment) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => _showAddReviewDialog(appointment.id),
        icon: const Icon(Icons.star_outline_rounded, size: 18),
        label: Text('Add Review', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600)),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFF59E0B),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }

  Widget _buildStarRating(double rating) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return Icon(index < rating.floor() ? Icons.star_rounded : (index < rating.ceil() ? Icons.star_half_rounded : Icons.star_outline_rounded), color: const Color(0xFFF59E0B), size: 16);
      }),
    );
  }

  void _showCancelDialog(String appointmentId, AppointmentsCtrl ctrl) {
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
                          ctrl.cancelAppointment(appointmentId);
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

  void _showAddReviewDialog(String appointmentId) {
    int rating = 0;
    final commentController = TextEditingController();
    final ctrl = Get.find<AppointmentsCtrl>();
    Get.dialog(
      Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: StatefulBuilder(
          builder: (context, setState) {
            return ClipRRect(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: const Color(0xFF2563EB).withOpacity(0.1), shape: BoxShape.circle),
                      child: const Icon(Icons.star_rounded, color: Color(0xFF2563EB), size: 40),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Rate Your Experience',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.black87),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'How was your service experience?',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600], height: 1.5),
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
                              onPressed: rating > 0 && !ctrl.isSubmittingReview.value ? () => ctrl.submitReview(appointmentId, rating, commentController.text.trim()) : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF2563EB),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                elevation: 0,
                              ),
                              child: ctrl.isSubmittingReview.value
                                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                  : Text('Submit Review', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      barrierDismissible: false,
    );
  }

  String _getDoctorName(Doctor doctor) {
    if (doctor.doctorId is String) {
      return doctor.doctorId;
    } else if (doctor.doctorId is Map) {
      return doctor.doctorId['name']?.toString() ?? 'Doctor';
    }
    return 'Doctor';
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
