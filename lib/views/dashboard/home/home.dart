import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:patients/utils/decoration.dart';
import 'package:patients/views/dashboard/profile/ui/settings.dart';
import 'package:shimmer/shimmer.dart';
import 'package:patients/views/dashboard/home/home_ctrl.dart';
import 'package:patients/views/dashboard/services/ui/service_card.dart';
import '../../../models/patient_request_model.dart';

class Home extends StatelessWidget {
  Home({super.key});

  final HomeCtrl ctrl = Get.put(HomeCtrl());

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => ctrl.loadHomeData(),
      child: Stack(
        children: [
          CustomScrollView(
            slivers: [
              _buildAppBar(ctrl),
              _buildBannerSection(),
              const SliverToBoxAdapter(child: SizedBox(height: 10)),
              SliverToBoxAdapter(
                child: Padding(
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
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 16)),
              _buildRegularServices(),
              const SliverToBoxAdapter(child: SizedBox(height: 5)),
              _buildPendingAppointments(),
              const SliverToBoxAdapter(child: SizedBox(height: 20)),
            ],
          ),
          Obx(() {
            if (ctrl.isDeleteLoading.value) {
              return _buildFullScreenLoading('Declining Request...', Icons.cancel_outlined);
            }
            return const SizedBox.shrink();
          }),
        ],
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
                    decoration: BoxDecoration(color: decoration.colorScheme.primary.withOpacity(0.1), shape: BoxShape.circle),
                    child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(decoration.colorScheme.primary), strokeWidth: 3),
                  ),
                  Icon(icon, size: 30, color: decoration.colorScheme.primary),
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

  Widget _buildAppBar(HomeCtrl ctrl) {
    return SliverAppBar(
      elevation: 0,
      toolbarHeight: 80,
      backgroundColor: Colors.white,
      pinned: true,
      floating: true,
      centerTitle: false,
      expandedHeight: 120,
      automaticallyImplyLeading: false,
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: false,
        collapseMode: CollapseMode.pin,
        background: Container(color: Colors.white),
        titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
        title: Obx(
          () => ctrl.isLoading.value
              ? _buildAppBarShimmer()
              : Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Hello,', style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600])),
                    Text(
                      ctrl.userName.value.capitalizeFirst.toString(),
                      style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                  ],
                ),
        ),
      ),
      actions: [
        IconButton(
          style: ButtonStyle(
            shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            padding: WidgetStatePropertyAll(const EdgeInsets.all(8)),
            backgroundColor: WidgetStatePropertyAll(Colors.grey[100]),
          ),
          icon: Icon(Icons.settings_outlined, color: decoration.colorScheme.primary, size: 20),
          onPressed: () => Get.to(() => const Settings()),
          tooltip: 'Settings',
        ).paddingOnly(right: 8.0),
      ],
    );
  }

  Widget _buildBannerSection() {
    return SliverToBoxAdapter(
      child: Obx(() {
        if (ctrl.isLoading.value) {
          return _buildBannerShimmer();
        }
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
                            gradient: LinearGradient(
                              colors: [Colors.black.withOpacity(0.6), Colors.transparent],
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                            ),
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
      }),
    );
  }

  Widget _buildRegularServices() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Regular Services',
              style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black87),
            ),
            const SizedBox(height: 12),
            Obx(() {
              if (ctrl.isLoading.value) {
                return _buildServicesShimmer();
              }
              if (ctrl.regularServices.isEmpty) {
                return _buildEmptyState('No regular appointments', 'Book your first session to get started', Icons.calendar_today_outlined);
              }
              return SizedBox(
                height: 155,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
                  itemCount: ctrl.regularServices.length > 5 ? 5 : ctrl.regularServices.length,
                  itemBuilder: (context, index) {
                    return ServiceCard(width: Get.width - 60, margin: const EdgeInsets.only(right: 15), service: ctrl.regularServices[index]);
                  },
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildPendingAppointments() {
    return SliverToBoxAdapter(
      child: Padding(
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
                Obx(() {
                  return TextButton(
                    onPressed: ctrl.viewAllAppointments,
                    child: Text(
                      'View All (${ctrl.pendingAppointments.length})',
                      style: GoogleFonts.poppins(color: Color(0xFF2563EB), fontWeight: FontWeight.w600),
                    ),
                  );
                }),
              ],
            ),
            const SizedBox(height: 12),
            Obx(() {
              if (ctrl.isAppointmentLoading.value) {
                return _buildAppointmentsShimmer();
              }
              if (ctrl.pendingAppointments.isEmpty) {
                return _buildEmptyState('No pending appointments', 'Book your first session to get started', Icons.calendar_today_outlined);
              }
              return SizedBox(
                height: 185,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
                  itemCount: ctrl.pendingAppointments.length > 5 ? 5 : ctrl.pendingAppointments.length,
                  itemBuilder: (context, index) {
                    return _buildAppointmentCard(ctrl.pendingAppointments[index]);
                  },
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBarShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade200,
      highlightColor: Colors.grey.shade50,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 100,
            height: 14,
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)),
          ),
          const SizedBox(height: 8),
          Container(
            width: 150,
            height: 20,
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)),
          ),
        ],
      ),
    );
  }

  Widget _buildBannerShimmer() {
    return SizedBox(
      height: 160,
      child: PageView.builder(
        itemCount: 2,
        padEnds: false,
        controller: PageController(viewportFraction: 0.85),
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Shimmer.fromColors(
              baseColor: Colors.grey.shade200,
              highlightColor: Colors.grey.shade50,
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                child: Container(
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildServicesShimmer() {
    return SizedBox(
      height: 155,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
        itemCount: 3,
        itemBuilder: (context, index) {
          return Shimmer.fromColors(
            baseColor: Colors.grey.shade200,
            highlightColor: Colors.grey.shade50,
            child: Container(
              width: Get.width - 60,
              margin: const EdgeInsets.only(right: 15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade300, width: .3),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 2))],
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                                width: 120,
                                height: 16,
                                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                width: 80,
                                height: 14,
                                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      height: 12,
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      width: 150,
                      height: 12,
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)),
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

  Widget _buildAppointmentsShimmer() {
    return SizedBox(
      height: 180,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 2),
        itemCount: 3,
        itemBuilder: (context, index) {
          return Shimmer.fromColors(
            baseColor: Colors.grey.shade200,
            highlightColor: Colors.grey.shade50,
            child: Container(
              width: Get.width - 60,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAppointmentCard(PatientRequestModel appointment) {
    return Container(
      width: Get.width - 60,
      margin: const EdgeInsets.only(right: 15),
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
                          Text(
                            appointment.therapistName.toString(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildDetailRow(appointment),
                const SizedBox(height: 12),
                Divider(color: Colors.grey[200]),
                const SizedBox(height: 8),
                _buildActionButtons(appointment.id, appointment.status),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(PatientRequestModel appointment) {
    final formattedDate = DateFormat('dd MMM yyyy').format(appointment.requestedAt);
    final formattedTime = DateFormat('hh:mm a').format(appointment.requestedAt);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [_buildDetailItem(Icons.calendar_today_outlined, formattedDate), _buildDetailItem(Icons.access_time_outlined, formattedTime)],
    );
  }

  Widget _buildDetailItem(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Colors.grey[500]),
        const SizedBox(width: 4),
        Text(
          text,
          style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildEmptyState(String title, String subtitle, IconData icon) {
    return Container(
      width: double.infinity,
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
        Expanded(
          child: ElevatedButton(
            onPressed: () => ctrl.viewAppointmentDetails(appointmentId),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF2563EB),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(vertical: 8),
            ),
            child: Text('View Details', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600)),
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
                      onPressed: () => Get.close(1),
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
                        Get.close(1);
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
}
