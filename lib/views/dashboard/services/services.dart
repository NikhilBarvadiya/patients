import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:patients/models/models.dart';
import 'services_ctrl.dart';

class Services extends StatelessWidget {
  const Services({super.key});

  @override
  Widget build(BuildContext context) {
    final ServicesCtrl ctrl = Get.put(ServicesCtrl());
    final TextEditingController searchController = TextEditingController();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            elevation: 0,
            toolbarHeight: 65,
            backgroundColor: Colors.white,
            pinned: true,
            floating: true,
            automaticallyImplyLeading: false,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Services',
                  style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
                Obx(() => Text('${ctrl.filteredServices.length} services available', style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600]))),
              ],
            ),
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.black87),
              onPressed: () => Get.back(),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Column(
                children: [
                  TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      hintText: 'Search services...',
                      hintStyle: GoogleFonts.poppins(color: Colors.grey[600]),
                      prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      suffixIcon: searchController.text.isNotEmpty
                          ? IconButton(
                              icon: Icon(Icons.clear, color: Colors.grey[600]),
                              onPressed: () {
                                searchController.clear();
                                ctrl.searchServices('');
                              },
                            )
                          : SizedBox.shrink(),
                    ),
                    style: GoogleFonts.poppins(fontSize: 14),
                    onChanged: ctrl.searchServices,
                  ),
                  const SizedBox(height: 12),
                  Obx(
                    () => DropdownButtonFormField<String>(
                      value: ctrl.selectedTherapist.value,
                      items: ctrl.getTherapists().map((therapistId) {
                        return DropdownMenuItem<String>(
                          value: therapistId,
                          child: Text(therapistId == 'All' ? 'All Therapists' : ctrl.getTherapistName(therapistId), style: GoogleFonts.poppins(fontSize: 14)),
                        );
                      }).toList(),
                      onChanged: (value) => ctrl.filterByTherapist(value!),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.grey[100],
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Obx(
            () => ctrl.isLoading.value
                ? SliverToBoxAdapter(
                    child: Center(child: CircularProgressIndicator(color: Color(0xFF2563EB))),
                  )
                : ctrl.filteredServices.isEmpty
                ? SliverFillRemaining(child: _buildEmptyState())
                : SliverPadding(
                    padding: const EdgeInsets.all(20),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final service = ctrl.filteredServices[index];
                        return _buildServiceCard(context, service, ctrl);
                      }, childCount: ctrl.filteredServices.length),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceCard(BuildContext context, ServiceModel service, ServicesCtrl ctrl) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: Color(0xFF2563EB).withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
                child: Icon(service.icon, color: Color(0xFF2563EB), size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      service.name,
                      style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(service.therapistName, style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600])),
                  ],
                ),
              ),
              Text(
                '₹${service.price.toStringAsFixed(0)}',
                style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF2563EB)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            service.description,
            style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600], height: 1.4),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              onPressed: () => ctrl.bookService(service.id.toString(), service.therapistId),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF2563EB),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              child: Text(
                'Book Now',
                style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
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
            'Try adjusting your search or therapist filter',
            style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () {
            final ctrl = Get.find<ServicesCtrl>();
            ctrl.searchServices('');
            ctrl.filterByTherapist('All');
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF2563EB),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: Text(
            'Clear Filters',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w500, color: Colors.white),
          ),
        ),
      ],
    );
  }
}
