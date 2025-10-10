import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:patients/utils/theme/light.dart';
import 'package:patients/views/dashboard/appointments/appointments_ctrl.dart';
import '../../../models/patient_request_model.dart';

class Appointments extends StatefulWidget {
  const Appointments({super.key});

  @override
  State<Appointments> createState() => _AppointmentsState();
}

class _AppointmentsState extends State<Appointments> {
  final ScrollController scrollController = ScrollController();
  final RxSet<String> expandedCards = <String>{}.obs;

  @override
  void initState() {
    super.initState();
    scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final ctrl = Get.find<AppointmentsCtrl>();
    if (scrollController.position.pixels >= scrollController.position.maxScrollExtent - 200) {
      if (ctrl.hasMore.value && !ctrl.isLoading.value) {
        ctrl.loadMoreAppointments();
      }
    }
  }

  void _toggleCardExpansion(String appointmentId) {
    if (expandedCards.contains(appointmentId)) {
      expandedCards.remove(appointmentId);
    } else {
      expandedCards.add(appointmentId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AppointmentsCtrl>(
      init: AppointmentsCtrl(),
      builder: (ctrl) {
        return Scaffold(
          backgroundColor: Colors.grey[50],
          body: SafeArea(
            child: RefreshIndicator(
              color: AppTheme.primaryBlue,
              onRefresh: ctrl.refreshAppointments,
              child: Stack(
                children: [
                  CustomScrollView(controller: scrollController, physics: const AlwaysScrollableScrollPhysics(), slivers: [_buildAppBar(ctrl), _buildFilterChips(ctrl), _buildAppointmentsList(ctrl)]),
                  Obx(() {
                    if (ctrl.isCancelling.value || ctrl.isSubmittingReview.value) {
                      return _buildFullScreenLoading(
                        ctrl.isCancelling.value ? 'Cancelling Appointment...' : 'Submitting Review...',
                        ctrl.isCancelling.value ? Icons.cancel_outlined : Icons.star_outlined,
                      );
                    }
                    return const SizedBox.shrink();
                  }),
                ],
              ),
            ),
          ),
        );
      },
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

  Widget _buildAppBar(AppointmentsCtrl ctrl) {
    return SliverAppBar(
      elevation: 0,
      toolbarHeight: 70,
      backgroundColor: Colors.white,
      pinned: true,
      floating: true,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'My Appointments',
            style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          Text(
            '${ctrl.filteredAppointments.length} ${ctrl.filteredAppointments.length == 1 ? 'appointment' : 'appointments'}',
            style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[600], fontWeight: FontWeight.w400),
          ),
        ],
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: IconButton(
            style: ButtonStyle(
              shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              padding: WidgetStatePropertyAll(const EdgeInsets.all(8)),
              backgroundColor: WidgetStatePropertyAll(Colors.grey[100]),
            ),
            icon: const Icon(Icons.refresh, color: Colors.black87, size: 22),
            onPressed: () => ctrl.refreshAppointments(),
            tooltip: 'Refresh Services',
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChips(AppointmentsCtrl ctrl) {
    return SliverToBoxAdapter(
      child: SizedBox(
        height: 50,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: ctrl.filters.length,
          itemBuilder: (context, index) {
            final filter = ctrl.filters[index];
            final isSelected = ctrl.selectedFilter.value == filter;
            return Padding(padding: const EdgeInsets.only(right: 8), child: _buildFilterChip(filter, isSelected, ctrl));
          },
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected, AppointmentsCtrl ctrl) {
    final icon = _getFilterIcon(label);
    return FilterChip(
      avatar: Icon(icon, size: 16, color: isSelected ? Colors.white : Colors.grey[600]),
      label: Text(
        label,
        style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: isSelected ? Colors.white : Colors.grey[700]),
      ),
      selected: isSelected,
      onSelected: (selected) => ctrl.changeFilter(label),
      backgroundColor: Colors.white,
      selectedColor: AppTheme.primaryBlue,
      checkmarkColor: Colors.white,
      elevation: isSelected ? 2 : 0,
      shadowColor: AppTheme.primaryBlue.withOpacity(0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: isSelected ? AppTheme.primaryBlue : Colors.grey[300]!),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
    );
  }

  IconData _getFilterIcon(String filter) {
    switch (filter) {
      case 'All':
        return Icons.grid_view_rounded;
      case 'Pending':
        return Icons.pending_outlined;
      case 'Accepted':
        return Icons.check_circle_outline;
      case 'Completed':
        return Icons.verified_outlined;
      case 'Cancelled':
        return Icons.cancel_outlined;
      default:
        return Icons.calendar_today_outlined;
    }
  }

  Widget _buildAppointmentsList(AppointmentsCtrl ctrl) {
    return Obx(() {
      if (ctrl.isLoading.value && ctrl.appointments.isEmpty) {
        return _buildAppointmentsShimmer();
      } else if (ctrl.filteredAppointments.isEmpty) {
        return SliverFillRemaining(child: _buildEmptyState(ctrl));
      } else {
        return SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              if (index == ctrl.filteredAppointments.length) {
                return ctrl.hasMore.value ? _buildLoadingItem() : const SizedBox(height: 20);
              }
              final appointment = ctrl.filteredAppointments[index];
              return Padding(padding: const EdgeInsets.only(bottom: 12), child: _buildAppointmentCard(appointment, ctrl));
            }, childCount: ctrl.filteredAppointments.length + 1),
          ),
        );
      }
    });
  }

  Widget _buildAppointmentsShimmer() {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          return Padding(padding: const EdgeInsets.only(bottom: 12), child: _buildAppointmentCardShimmer());
        }, childCount: 6),
      ),
    );
  }

  Widget _buildAppointmentCardShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade200,
      highlightColor: Colors.grey.shade50,
      child: Container(
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 150,
                          height: 17,
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          width: 100,
                          height: 13,
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        width: 80,
                        height: 24,
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: 24,
                        height: 24,
                        decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                child: Row(
                  children: [
                    Container(
                      width: 16,
                      height: 16,
                      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      width: 80,
                      height: 13,
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)),
                    ),
                    const SizedBox(width: 16),
                    Container(
                      width: 16,
                      height: 16,
                      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      width: 60,
                      height: 13,
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)),
                    ),
                    const Spacer(),
                    Container(
                      width: 70,
                      height: 11,
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppointmentCard(PatientRequestModel appointment, AppointmentsCtrl ctrl) {
    final formattedDate = DateFormat('dd MMM yyyy').format(appointment.requestedAt);
    final formattedTime = DateFormat('hh:mm a').format(appointment.requestedAt);
    final statusColor = _getStatusColor(appointment.status);
    final statusIcon = _getStatusIcon(appointment.status);

    return Obx(() {
      final isExpanded = expandedCards.contains(appointment.id);
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
                            style: GoogleFonts.poppins(fontSize: 17, fontWeight: FontWeight.w600, color: Colors.black87),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            appointment.therapistName,
                            style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[600]),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(statusIcon, size: 14, color: statusColor),
                              const SizedBox(width: 4),
                              Text(
                                appointment.status.toUpperCase(),
                                style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w700, color: statusColor, letterSpacing: 0.5),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Icon(isExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded, color: Colors.grey[600], size: 24),
                      ],
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
                          style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[700], fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(width: 16),
                        Icon(Icons.access_time_rounded, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 6),
                        Text(
                          formattedTime,
                          style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[700], fontWeight: FontWeight.w500),
                        ),
                        const Spacer(),
                        Text(
                          'Tap for details',
                          style: GoogleFonts.poppins(fontSize: 11, color: AppTheme.primaryBlue, fontWeight: FontWeight.w600),
                        ),
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
                                Expanded(child: _buildInfoTile(Icons.currency_rupee_rounded, 'Charge', '₹${appointment.charge} (${appointment.paymentStatus.capitalizeFirst.toString()})')),
                                const SizedBox(width: 12),
                                Expanded(child: _buildInfoTile(Icons.payment_rounded, 'Payment Type', appointment.paymentType.capitalizeFirst.toString())),
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

  Widget _buildLoadingItem() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Center(child: CircularProgressIndicator(color: AppTheme.primaryBlue, strokeWidth: 2.5)),
    );
  }

  Widget _buildEmptyState(AppointmentsCtrl ctrl) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(color: Colors.grey[100], shape: BoxShape.circle),
              child: Icon(Icons.event_busy_rounded, size: 64, color: Colors.grey[400]),
            ),
            const SizedBox(height: 24),
            Text(
              'No Appointments Found',
              style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.grey[700]),
            ),
            const SizedBox(height: 8),
            Text(
              'Try adjusting your filters to find what you\'re looking for.',
              style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[500], height: 1.5),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
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
                        onPressed: Get.back,
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
                          Get.back();
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
                            onPressed: () => Get.back(),
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
}
