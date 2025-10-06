import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:patients/models/models.dart';
import 'therapists_ctrl.dart';

class Therapists extends StatelessWidget {
  const Therapists({super.key});

  @override
  Widget build(BuildContext context) {
    final TherapistsCtrl ctrl = Get.put(TherapistsCtrl());
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'All Therapists',
          style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Get.back(),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Column(
              children: [
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Search therapists or specialties',
                    hintStyle: GoogleFonts.poppins(color: Colors.grey[600]),
                    prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                  style: GoogleFonts.poppins(fontSize: 14),
                  onChanged: ctrl.searchTherapists,
                ),
                const SizedBox(height: 12),
                Obx(
                  () => DropdownButtonFormField<String>(
                    value: ctrl.selectedSpecialty.value,
                    items: ctrl.getSpecialties().map((specialty) {
                      return DropdownMenuItem<String>(
                        value: specialty,
                        child: Text(specialty, style: GoogleFonts.poppins(fontSize: 14)),
                      );
                    }).toList(),
                    onChanged: (value) => ctrl.filterBySpecialty(value!),
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
          Expanded(
            child: Obx(() {
              if (ctrl.isLoading.value) {
                return Center(child: CircularProgressIndicator(color: Color(0xFF2563EB)));
              }
              if (ctrl.filteredTherapists.isEmpty) {
                return _buildEmptyState();
              }
              return ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                itemCount: ctrl.filteredTherapists.length,
                itemBuilder: (context, index) {
                  final therapist = ctrl.filteredTherapists[index];
                  return _buildTherapistCard(therapist, ctrl);
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildTherapistCard(TherapistModel therapist, TherapistsCtrl ctrl) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.only(top: 16, bottom: 16, left: 16, right: 5),
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
            child: therapist.image != null && therapist.image!.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(25),
                    child: CachedNetworkImage(
                      imageUrl: therapist.image!,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => CircularProgressIndicator(color: Color(0xFF2563EB)),
                      errorWidget: (context, url, error) => Icon(Icons.person, color: Color(0xFF2563EB), size: 24),
                    ),
                  )
                : Icon(Icons.person, color: Color(0xFF2563EB), size: 24),
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

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          Icon(Icons.people_outline, size: 48, color: Colors.grey[300]),
          const SizedBox(height: 8),
          Text(
            'No Therapists Found',
            style: GoogleFonts.poppins(color: Colors.grey[600], fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 4),
          Text('Try adjusting your search or filters', style: GoogleFonts.poppins(color: Colors.grey[500], fontSize: 12)),
        ],
      ),
    );
  }
}
