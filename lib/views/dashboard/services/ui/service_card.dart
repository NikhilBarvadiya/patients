import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:patients/utils/decoration.dart';
import 'package:patients/views/auth/auth_service.dart';
import '../../../../models/service_model.dart';

class ServiceCard extends StatefulWidget {
  final double? width;
  final EdgeInsetsGeometry? margin;
  final ServiceModel service;

  const ServiceCard({super.key, required this.service, this.width, this.margin});

  @override
  State<ServiceCard> createState() => _ServiceCardState();
}

class _ServiceCardState extends State<ServiceCard> {
  final AuthService _authService = Get.find<AuthService>();

  RxBool isBooking = false.obs;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      margin: widget.margin ?? const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300, width: .3),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Material(
        color: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: decoration.colorScheme.primary.withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
                    child: Icon(widget.service.icon ?? Icons.miscellaneous_services, color: decoration.colorScheme.primary, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.service.name,
                          style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        _buildRateDisplay(widget.service),
                      ],
                    ),
                  ),
                  _buildStatusBadge(widget.service.isActive),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(12)),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.service.description ?? 'Professional service with customized treatment plans.',
                        style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600], height: 1.4),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ).paddingOnly(left: 12),
                    ),
                    Obx(() {
                      return ElevatedButton(
                        onPressed: () => bookService(widget.service),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2563EB),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                        child: isBooking.value
                            ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : Text('Book Now', style: GoogleFonts.poppins(fontWeight: FontWeight.w500, fontSize: 12)),
                      );
                    }),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRateDisplay(ServiceModel service) {
    final charge = service.charge ?? 0;
    final lowCharge = service.lowCharge ?? 0;
    final highCharge = service.highCharge ?? 0;
    String rateText;
    if (charge > 0) {
      rateText = '₹$charge/session';
    } else if (lowCharge > 0 && highCharge > 0) {
      rateText = '₹$lowCharge - ₹$highCharge';
    } else {
      rateText = 'Contact for pricing';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
      child: Text(
        rateText,
        style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.blue[700]),
      ),
    );
  }

  Widget _buildStatusBadge(bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: isActive ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: isActive ? Colors.green : Colors.orange, shape: BoxShape.circle),
          ),
          const SizedBox(width: 4),
          Text(
            isActive ? 'Active' : 'Inactive',
            style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w500, color: isActive ? Colors.green : Colors.orange),
          ),
        ],
      ),
    );
  }

  Future<void> bookService(ServiceModel service) async {
    final preferredType = await _showBookingTypeDialog(service);
    if (preferredType != null) {
      isBooking.value = true;
      await _authService.createRequests({"serviceId": service.id, "preferredType": preferredType});
      isBooking.value = false;
    }
  }

  Future<String?> _showBookingTypeDialog(ServiceModel service) async {
    return await Get.dialog<String>(
      AlertDialog(
        title: Text('Book ${service.name}', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        content: ClipRRect(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Select booking type', style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[700])),
              const SizedBox(height: 16),
              _buildBookingTypeOption(title: 'Regular Doctor', subtitle: 'Experienced medical professionals', value: 'Regular', icon: Icons.medical_services, color: Colors.blue),
              const SizedBox(height: 12),
              _buildBookingTypeOption(title: 'Intern Doctor', subtitle: 'Under supervision, more affordable', value: 'Intern', icon: Icons.school, color: Colors.green),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Cancel', style: GoogleFonts.poppins(color: Colors.grey)),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingTypeOption({required String title, required String subtitle, required String value, required IconData icon, required Color color}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => Get.back(result: value),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87),
                    ),
                    Text(subtitle, style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600])),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }
}
