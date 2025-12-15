import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:patients/views/dashboard/appointments/ui/appointment_card.dart';
import 'package:shimmer/shimmer.dart';
import 'package:patients/utils/theme/light.dart';
import 'package:patients/views/dashboard/appointments/appointments_ctrl.dart';

class Appointments extends StatefulWidget {
  const Appointments({super.key});

  @override
  State<Appointments> createState() => _AppointmentsState();
}

class _AppointmentsState extends State<Appointments> {
  final TextEditingController searchController = TextEditingController();
  final ScrollController scrollController = ScrollController();

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
                  CustomScrollView(
                    controller: scrollController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: [_buildAppBar(ctrl), _buildSearchBar(ctrl), _buildFilterChips(ctrl), _buildAppointmentsList(ctrl)],
                  ),
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
          Obx(() {
            return Text(
              '${ctrl.totalDocs.value} ${ctrl.totalDocs.value == 1 ? 'appointment' : 'appointments'}',
              style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[600], fontWeight: FontWeight.w400),
            );
          }),
        ],
      ),
      actions: [
        Obx(() {
          final hasDateFilter = ctrl.selectedDateRange.value != 'All Time';
          return Badge(
            isLabelVisible: hasDateFilter,
            backgroundColor: AppTheme.primaryBlue,
            child: IconButton(
              style: ButtonStyle(
                shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                padding: WidgetStatePropertyAll(const EdgeInsets.all(8)),
                backgroundColor: WidgetStatePropertyAll(Colors.grey[100]),
              ),
              icon: Icon(hasDateFilter ? Icons.date_range_rounded : Icons.date_range_outlined, color: hasDateFilter ? AppTheme.primaryBlue : Colors.black87, size: 22),
              onPressed: () => ctrl.showDateFilterBottomSheet(context),
              tooltip: 'Filter by Date',
            ),
          );
        }),
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

  Widget _buildSearchBar(AppointmentsCtrl ctrl) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 2))],
          ),
          child: TextField(
            controller: searchController,
            style: GoogleFonts.poppins(fontSize: 15),
            decoration: InputDecoration(
              hintText: 'Search by name, service...',
              hintStyle: GoogleFonts.poppins(color: Colors.grey[400], fontSize: 15),
              prefixIcon: Icon(Icons.search_rounded, color: Colors.grey[500], size: 22),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              suffixIcon: searchController.text.isNotEmpty
                  ? IconButton(
                      icon: Icon(Icons.clear_rounded, color: Colors.grey[500], size: 20),
                      onPressed: () {
                        searchController.clear();
                        ctrl.searchAppointments('');
                      },
                    )
                  : const SizedBox.shrink(),
            ),
            onChanged: (value) {
              ctrl.searchAppointments(value);
              setState(() {});
            },
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChips(AppointmentsCtrl ctrl) {
    return SliverToBoxAdapter(
      child: SizedBox(
        height: 50,
        child: ListView.builder(
          shrinkWrap: true,
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: ctrl.filters.length,
          itemBuilder: (context, index) {
            final filter = ctrl.filters[index];
            final isSelected = ctrl.selectedFilter.value == filter;
            return _buildFilterChip(filter, isSelected, ctrl).paddingOnly(right: 8);
          },
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected, AppointmentsCtrl ctrl) {
    final icon = _getFilterIcon(label);
    return FilterChip(
      avatar: isSelected ? null : Icon(icon, size: 16, color: isSelected ? Colors.white : Colors.grey[600]),
      label: Text(
        label,
        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: isSelected ? Colors.white : Colors.grey[700]),
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
      } else if (ctrl.appointments.isEmpty) {
        return SliverFillRemaining(child: _buildEmptyState(ctrl));
      } else {
        return SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              if (index == ctrl.appointments.length) {
                return ctrl.hasMore.value ? _buildLoadingItem() : const SizedBox(height: 20);
              }
              final appointment = ctrl.appointments[index];
              return AppointmentCard(appointment: appointment).paddingOnly(bottom: 12);
            }, childCount: ctrl.appointments.length + 1),
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
}
