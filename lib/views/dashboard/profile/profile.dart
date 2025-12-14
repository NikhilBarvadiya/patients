import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:patients/utils/network/api_config.dart';
import 'package:shimmer/shimmer.dart';
import 'package:patients/utils/decoration.dart';
import 'package:patients/views/dashboard/profile/profile_ctrl.dart';
import 'package:patients/views/dashboard/profile/ui/edit_profile.dart';
import 'package:patients/views/dashboard/profile/ui/settings.dart';

class Profile extends StatelessWidget {
  const Profile({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ProfileCtrl>(
      init: ProfileCtrl(),
      builder: (ctrl) {
        return Scaffold(
          backgroundColor: Colors.grey[50],
          body: RefreshIndicator(
            onRefresh: () => ctrl.loadProfile(),
            child: CustomScrollView(
              slivers: [
                SliverAppBar(
                  elevation: 0,
                  backgroundColor: Colors.white,
                  pinned: true,
                  floating: true,
                  automaticallyImplyLeading: false,
                  title: Text(
                    'Profile',
                    style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                  actions: [
                    IconButton(
                      style: ButtonStyle(
                        shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                        padding: const WidgetStatePropertyAll(EdgeInsets.all(8)),
                        backgroundColor: WidgetStatePropertyAll(Colors.grey[100]),
                      ),
                      icon: Icon(Icons.settings_outlined, color: decoration.colorScheme.primary, size: 20),
                      onPressed: () => Get.to(() => const Settings()),
                      tooltip: 'Settings',
                    ),
                    const SizedBox(width: 4),
                    IconButton(
                      style: ButtonStyle(
                        shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                        padding: const WidgetStatePropertyAll(EdgeInsets.all(8)),
                        backgroundColor: WidgetStatePropertyAll(Colors.grey[100]),
                      ),
                      icon: Icon(Icons.edit_outlined, color: decoration.colorScheme.primary, size: 20),
                      onPressed: () => Get.to(() => const EditProfile()),
                      tooltip: 'Edit Profile',
                    ),
                    const SizedBox(width: 8.0),
                  ],
                ),
                Obx(() {
                  if (ctrl.isLoading.value) {
                    return _buildProfileShimmer();
                  }
                  return SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(children: [_buildProfileHeader(ctrl), const SizedBox(height: 24), _buildLocationStatus(ctrl), const SizedBox(height: 24), _buildPersonalInfoSection(ctrl)]),
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfileShimmer() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(spacing: 24.0, children: [_buildProfileHeaderShimmer(), _buildLocationStatusShimmer(), _buildPersonalInfoSectionShimmer()]),
      ),
    );
  }

  Widget _buildProfileHeaderShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade200,
      highlightColor: Colors.grey.shade50,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
        child: Row(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 150,
                    height: 20,
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 120,
                    height: 14,
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationStatusShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade200,
      highlightColor: Colors.grey.shade50,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 100,
                    height: 12,
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    width: 180,
                    height: 10,
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)),
                  ),
                ],
              ),
            ),
            Container(
              width: 80,
              height: 30,
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalInfoSectionShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade200,
      highlightColor: Colors.grey.shade50,
      child: Container(
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 150,
                height: 18,
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)),
              ),
              const SizedBox(height: 16),
              ...List.generate(
                2,
                (index) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 80,
                              height: 12,
                              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              width: 120,
                              height: 14,
                              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(ProfileCtrl ctrl) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [decoration.colorScheme.primary, decoration.colorScheme.primary.withOpacity(0.8)], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: Row(
        children: [
          Obx(() {
            return Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
                image: ctrl.user.value.avatar.isNotEmpty ? DecorationImage(image: NetworkImage(APIConfig.resourceBaseURL + ctrl.user.value.avatar), fit: BoxFit.cover) : null,
              ),
              child: ctrl.user.value.avatar.isEmpty ? const Icon(Icons.person, size: 40, color: Colors.white) : null,
            );
          }),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Obx(
                  () => Text(
                    ctrl.user.value.name,
                    style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 8),
                Obx(() => Text(ctrl.user.value.email, style: GoogleFonts.poppins(fontSize: 14, color: Colors.white.withOpacity(0.9)))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationStatus(ProfileCtrl ctrl) {
    return Obx(() {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: ctrl.locationStatus.value.contains('successfully')
              ? const Color(0xFFD1FAE5)
              : ctrl.locationStatus.value.contains('Failed') || ctrl.locationStatus.value.contains('denied')
              ? const Color(0xFFFEE2E2)
              : const Color(0xFFFEF3C7),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: ctrl.locationStatus.value.contains('successfully')
                ? const Color(0xFF10B981)
                : ctrl.locationStatus.value.contains('Failed') || ctrl.locationStatus.value.contains('denied')
                ? const Color(0xFFEF4444)
                : const Color(0xFFF59E0B),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              ctrl.locationStatus.value.contains('successfully')
                  ? Icons.check_circle_rounded
                  : ctrl.locationStatus.value.contains('Failed') || ctrl.locationStatus.value.contains('denied')
                  ? Icons.error_outline_rounded
                  : Icons.location_searching_rounded,
              color: ctrl.locationStatus.value.contains('successfully')
                  ? const Color(0xFF10B981)
                  : ctrl.locationStatus.value.contains('Failed') || ctrl.locationStatus.value.contains('denied')
                  ? const Color(0xFFEF4444)
                  : const Color(0xFFF59E0B),
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ctrl.isGettingLocation.value ? 'Getting Location...' : 'Location Status',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF374151)),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    ctrl.locationStatus.value,
                    style: TextStyle(fontSize: 11, color: const Color(0xFF6B7280), fontWeight: ctrl.locationStatus.value.contains('successfully') ? FontWeight.w600 : FontWeight.normal),
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: ctrl.isGettingLocation.value ? null : ctrl.retryLocation,
              style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), minimumSize: Size.zero),
              child: Text(
                'Update Location',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: ctrl.isGettingLocation.value ? const Color(0xFFF59E0B) : const Color(0xFF2563EB)),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildPersonalInfoSection(ProfileCtrl ctrl) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 6),
            child: Row(
              children: [
                Icon(Icons.person_outline, color: decoration.colorScheme.primary, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Personal Information',
                  style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black87),
                ),
              ],
            ),
          ),
          _buildInfoTile(Icons.phone_outlined, 'Mobile', ctrl.user.value.mobile),
          _buildInfoTile(Icons.home_outlined, 'Address', ctrl.user.value.address),
        ],
      ),
    );
  }

  Widget _buildInfoTile(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: decoration.colorScheme.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: decoration.colorScheme.primary, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600], fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 6),
                Text(
                  value,
                  style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w500, color: Colors.black87),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
