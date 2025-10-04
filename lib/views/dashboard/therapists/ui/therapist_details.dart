import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:patients/models/models.dart';

class TherapistDetails extends StatelessWidget {
  final TherapistModel therapist;

  const TherapistDetails({super.key, required this.therapist});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Therapist Profile',
          style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(50),
                      child: therapist.image != null && therapist.image!.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: therapist.image!,
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => CircularProgressIndicator(color: Color(0xFF2563EB)),
                              errorWidget: (context, url, error) => Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(color: Color(0xFF2563EB).withOpacity(0.1), shape: BoxShape.circle),
                                child: Icon(Icons.person, color: Color(0xFF2563EB), size: 50),
                              ),
                            )
                          : Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(color: Color(0xFF2563EB).withOpacity(0.1), shape: BoxShape.circle),
                              child: Icon(Icons.person, color: Color(0xFF2563EB), size: 50),
                            ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      therapist.name,
                      style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                    Text(therapist.specialty, style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey[600])),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.star, color: Colors.amber, size: 18),
                        const SizedBox(width: 4),
                        Text(therapist.rating.toString(), style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500)),
                        const SizedBox(width: 12),
                        Icon(Icons.people_outline, color: Colors.grey[500], size: 18),
                        const SizedBox(width: 4),
                        Text('${therapist.totalPatients}+ patients', style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600])),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _buildInfoCard('Experience', '${therapist.experienceYears} years'),
              _buildInfoCard('Clinic', '${therapist.clinicName}\n${therapist.clinicAddress}'),
              _buildInfoCard('Contact', therapist.email),
              const SizedBox(height: 24),
              Center(
                child: ElevatedButton(
                  onPressed: () {}, //ctrl.bookAppointment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF2563EB),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  ),
                  child: Text(
                    'Book Appointment',
                    style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, String content) {
    return Container(
      width: double.infinity,
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
          Text(
            title,
            style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),
          ),
          const SizedBox(height: 8),
          Text(content, style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600])),
        ],
      ),
    );
  }
}
