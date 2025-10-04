import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:patients/models/models.dart';
import 'package:patients/views/dashboard/home/home_ctrl.dart';

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
                onPressed: () {},
              ),
            ),
          ],
        ),
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [const SizedBox(height: 20), _buildBannerSection(), const SizedBox(height: 32), _buildUpcomingAppointments(), const SizedBox(height: 10), _buildFeaturedTherapists()],
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
                    Positioned(
                      bottom: 8,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          banners.length,
                          (i) => Container(
                            width: 8,
                            height: 8,
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            decoration: BoxDecoration(shape: BoxShape.circle, color: i == index ? Colors.white : Colors.white.withOpacity(0.5)),
                          ),
                        ),
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

  Widget _buildUpcomingAppointments() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Upcoming Appointments',
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
            if (ctrl.upcomingAppointments.isEmpty) {
              return _buildEmptyState('No upcoming appointments', 'Book your first session to get started', Icons.calendar_today_outlined);
            }
            return Column(children: ctrl.upcomingAppointments.take(2).map((appointment) => _buildAppointmentCard(appointment)).toList());
          }),
        ],
      ),
    );
  }

  Widget _buildAppointmentCard(PatientRequestModel appointment) {
    Color statusColor = appointment.status == 'confirmed'
        ? Colors.green
        : appointment.status == 'pending'
        ? Colors.orange
        : Colors.grey;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
            decoration: BoxDecoration(color: Color(0xFF2563EB).withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
            child: Icon(Icons.calendar_today, color: Color(0xFF2563EB), size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  appointment.serviceName,
                  style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87),
                ),
                const SizedBox(height: 4),
                Text('${appointment.date} • ${appointment.time}', style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600])),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
            child: Text(
              appointment.status.toUpperCase(),
              style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w600, color: statusColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturedTherapists() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Featured Therapists',
                style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black87),
              ),
              const Spacer(),
              TextButton(
                onPressed: ctrl.viewAllTherapists,
                child: Text(
                  'See All',
                  style: GoogleFonts.poppins(color: Color(0xFF2563EB), fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Obx(() {
            if (ctrl.featuredTherapists.isEmpty) {
              return _buildEmptyState('No therapists available', 'Check back later for featured therapists', Icons.people_outline);
            }
            return Column(children: ctrl.featuredTherapists.take(2).map((therapist) => _buildTherapistCard(therapist)).toList());
          }),
        ],
      ),
    );
  }

  Widget _buildTherapistCard(TherapistModel therapist) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(color: Color(0xFF2563EB).withOpacity(0.1), borderRadius: BorderRadius.circular(25)),
            child: Icon(Icons.person, color: Color(0xFF2563EB), size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  therapist.name,
                  style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87),
                ),
                const SizedBox(height: 2),
                Text(therapist.specialty, style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600])),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.star, color: Colors.amber, size: 14),
                    const SizedBox(width: 4),
                    Text(therapist.rating.toString(), style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500)),
                    const SizedBox(width: 8),
                    Icon(Icons.people_outline, color: Colors.grey[500], size: 14),
                    const SizedBox(width: 4),
                    Text('${therapist.totalPatients}+ patients', style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600])),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => ctrl.viewTherapistProfile(therapist),
            icon: Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey),
          ),
        ],
      ),
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
}
