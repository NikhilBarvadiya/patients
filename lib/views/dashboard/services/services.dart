import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:patients/views/dashboard/services/ui/service_card.dart';
import 'services_ctrl.dart';

class Services extends StatelessWidget {
  Services({super.key});

  final TextEditingController searchController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ServicesCtrl>(
      init: ServicesCtrl(),
      builder: (ctrl) {
        scrollController.addListener(() {
          if (scrollController.position.pixels >= scrollController.position.maxScrollExtent - 200) {
            ctrl.loadMoreServices();
          }
        });
        return Scaffold(
          backgroundColor: Colors.grey[50],
          body: RefreshIndicator(
            onRefresh: () => ctrl.refreshServices(),
            child: CustomScrollView(
              controller: scrollController,
              slivers: [
                SliverAppBar(
                  elevation: 0,
                  toolbarHeight: 65,
                  backgroundColor: Colors.white,
                  pinned: true,
                  floating: true,
                  automaticallyImplyLeading: false,
                  title: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Services',
                        style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
                      ),
                      Obx(() => Text('${ctrl.filteredServices.length} services available', style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600]))),
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
                        onPressed: () => ctrl.refreshServices(),
                        tooltip: 'Refresh Services',
                      ),
                    ),
                  ],
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20, right: 20, top: 16),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
                      ),
                      child: TextField(
                        controller: searchController,
                        decoration: InputDecoration(
                          hintText: 'Search services...',
                          hintStyle: GoogleFonts.poppins(color: Colors.grey[600]),
                          prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                          suffixIcon: searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: Icon(Icons.clear, color: Colors.grey[600]),
                                  onPressed: () {
                                    searchController.clear();
                                    ctrl.clearSearch();
                                  },
                                )
                              : null,
                        ),
                        onChanged: (value) => ctrl.searchServices(value),
                      ),
                    ),
                  ),
                ),
                Obx(() {
                  if (ctrl.isLoading.value && ctrl.filteredServices.isEmpty) {
                    return SliverFillRemaining(child: _buildLoadingState());
                  }
                  if (ctrl.filteredServices.isEmpty && !ctrl.isLoading.value) {
                    return SliverFillRemaining(child: _buildEmptyState(ctrl));
                  }
                  return SliverPadding(
                    padding: const EdgeInsets.all(20),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        if (index == ctrl.filteredServices.length) {
                          return _buildLoadMoreIndicator(ctrl);
                        }
                        final service = ctrl.filteredServices[index];
                        return ServiceCard(service: service);
                      }, childCount: ctrl.filteredServices.length + (ctrl.hasMore.value ? 1 : 0)),
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

  Widget _buildLoadingState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const CircularProgressIndicator(color: Color(0xFF6C63FF)),
        const SizedBox(height: 20),
        Text(
          'Loading Services...',
          style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildEmptyState(ServicesCtrl ctrl) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.medical_services_outlined, size: 80, color: Colors.grey[300]),
        const SizedBox(height: 20),
        Text(
          'No Services Found',
          style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.grey[600]),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Text(
            ctrl.searchQuery.value.isEmpty ? 'No services available at the moment. Check back later.' : 'No services found for "${ctrl.searchQuery.value}". Try different keywords.',
            style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 20),
        if (ctrl.searchQuery.value.isNotEmpty)
          ElevatedButton(
            onPressed: () {
              searchController.clear();
              ctrl.clearSearch();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6C63FF),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(
              'Clear Search',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w500, color: Colors.white),
            ),
          ),
      ],
    );
  }

  Widget _buildLoadMoreIndicator(ServicesCtrl ctrl) {
    return Obx(() {
      if (ctrl.isLoadMoreLoading.value) {
        return const Padding(
          padding: EdgeInsets.all(16.0),
          child: Center(child: CircularProgressIndicator(color: Color(0xFF6C63FF))),
        );
      }
      return const SizedBox();
    });
  }
}
