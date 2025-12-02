import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:patients/utils/decoration.dart';
import 'package:patients/utils/network/api_config.dart';
import 'package:patients/views/dashboard/services/ui/booking_appointment.dart';
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
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _showImagesDialog(context),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.service.images.isNotEmpty && widget.width == null) ...[_buildServiceImages(), const SizedBox(height: 12)],
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
                          Row(
                            spacing: 10.0,
                            children: [
                              _buildRateDisplay(widget.service),
                              if (widget.service.images.isNotEmpty && widget.width != null)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(color: Colors.blueGrey.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.photo_library, size: 12, color: Colors.blueGrey),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${widget.service.images.length}',
                                        style: GoogleFonts.poppins(fontSize: 11, color: Colors.blueGrey, fontWeight: FontWeight.w500),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
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
                      ElevatedButton(
                        onPressed: () => bookService(widget.service),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2563EB),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                        child: Text('Book Now', style: GoogleFonts.poppins(fontWeight: FontWeight.w500, fontSize: 12)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildServiceImages() {
    return GestureDetector(
      onTap: () => _showImagesDialog(context),
      child: Container(
        height: 120,
        width: double.infinity,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: Colors.grey[100]),
        child: Stack(
          children: [
            if (widget.service.images.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  APIConfig.resourceBaseURL + widget.service.images.first,
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Center(
                      child: Container(
                        color: Colors.grey[200],
                        child: const Icon(Icons.broken_image, color: Colors.grey),
                      ),
                    );
                  },
                ),
              ),
            if (widget.service.images.length > 1)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: Colors.black.withOpacity(0.6), borderRadius: BorderRadius.circular(20)),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.photo_library, size: 12, color: Colors.white),
                      const SizedBox(width: 4),
                      Text(
                        '${widget.service.images.length}',
                        style: GoogleFonts.poppins(fontSize: 11, color: Colors.white, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              ),
            Positioned(
              bottom: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.9), borderRadius: BorderRadius.circular(20)),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.remove_red_eye, size: 12, color: Colors.blue[700]),
                    const SizedBox(width: 4),
                    Text(
                      'View',
                      style: GoogleFonts.poppins(fontSize: 11, color: Colors.blue[700], fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showImagesDialog(BuildContext context) {
    if (widget.service.images.isEmpty) return;
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(20),
          child: Container(
            height: 400,
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.service.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),
                            ),
                            Text(
                              "See how it's done",
                              style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w400, color: Colors.black87),
                            ),
                          ],
                        ),
                      ),
                      IconButton(icon: const Icon(Icons.close, size: 22), onPressed: () => Get.close(1)),
                    ],
                  ),
                ),
                Expanded(
                  child: PageView.builder(
                    itemCount: widget.service.images.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            APIConfig.resourceBaseURL + widget.service.images[index],
                            width: double.infinity,
                            height: double.infinity,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey[200],
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.broken_image, size: 40, color: Colors.grey),
                                    const SizedBox(height: 8),
                                    Text('Image not available', style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600])),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
                if (widget.service.images.length > 1)
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        widget.service.images.length,
                        (index) => Container(
                          width: 8,
                          height: 8,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(shape: BoxShape.circle, color: index == 0 ? Colors.blue : Colors.grey[300]),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
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
    Get.to(() => BookingAppointment(service: service));
  }
}
