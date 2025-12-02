import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:patients/utils/decoration.dart';
import 'package:patients/utils/network/api_config.dart';
import 'package:patients/utils/toaster.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:patients/views/auth/auth_service.dart';
import 'package:patients/views/dashboard/home/home_ctrl.dart';
import '../../../../models/service_model.dart';

class BookingAppointment extends StatefulWidget {
  final ServiceModel service;

  const BookingAppointment({super.key, required this.service});

  @override
  State<BookingAppointment> createState() => _BookingAppointmentState();
}

class _BookingAppointmentState extends State<BookingAppointment> {
  final _razorpay = Razorpay();
  String _selectedPaymentMethod = 'online', _selectedBookingType = 'Regular';
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    setState(() => _isProcessing = false);
    _confirmBooking(response.paymentId ?? 'N/A', 'paid');
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    setState(() => _isProcessing = false);
    Get.snackbar('Payment Failed', 'Please try again or choose another payment method', backgroundColor: Colors.red, colorText: Colors.white, snackPosition: SnackPosition.BOTTOM);
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    Get.snackbar('Payment Failed', 'External Wallet: ${response.walletName}', backgroundColor: Colors.red, colorText: Colors.white, snackPosition: SnackPosition.BOTTOM);
  }

  Future<void> _initiateRazorpayPayment() async {
    final options = {
      'key': 'rzp_test_RHRLTvT4Rm3WOP',
      'amount': (widget.service.charge! * 100).toInt(),
      'name': 'PhysioCare Clinic',
      'description': widget.service.name,
      'prefill': {'contact': '9876543210', 'email': 'patient@example.com'},
      'external': {
        'wallets': ['paytm'],
      },
    };
    try {
      _razorpay.open(options);
    } catch (e) {
      setState(() => _isProcessing = false);
      Get.snackbar('Payment Error', 'Failed to initiate payment: $e', backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  void _processBooking() {
    if (_selectedPaymentMethod == 'online') {
      setState(() => _isProcessing = true);
      _initiateRazorpayPayment();
    } else {
      _confirmBooking('OFFLINE_${DateTime.now().millisecondsSinceEpoch}', 'paid');
    }
  }

  Future<void> _confirmBooking(String transactionId, String status) async {
    setState(() => _isProcessing = true);
    final bookingData = {
      'serviceId': widget.service.id,
      'preferredType': _selectedBookingType,
      'payment': {'service': widget.service.name, 'amount': widget.service.charge, 'paymentMethod': _selectedPaymentMethod, 'transactionId': transactionId, 'status': status},
    };
    bool isCheck = await Get.find<AuthService>().createRequests(bookingData);
    if (isCheck == true) {
      Get.find<HomeCtrl>().loadPendingAppointments();
      Get.close(1);
      toaster.success("Booking Confirmed! 🎉");
    }
    setState(() => _isProcessing = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text('Book Appointment', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        leading: IconButton(
          style: ButtonStyle(
            shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            padding: WidgetStatePropertyAll(const EdgeInsets.all(8)),
            backgroundColor: WidgetStatePropertyAll(Colors.grey[100]),
          ),
          icon: const Icon(Icons.arrow_back, color: Colors.black87, size: 20),
          onPressed: () => Get.close(1),
        ),
      ),
      body: _isProcessing
          ? _buildLoadingState()
          : Padding(
              padding: const EdgeInsets.all(20),
              child: ListView(children: [_buildServiceInfo(), const SizedBox(height: 24), _buildBookingTypeSection(), const SizedBox(height: 24), _buildPaymentSection()]),
            ),
      bottomNavigationBar: _buildBookButton(),
    );
  }

  Widget _buildLoadingState() {
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
                  Icon(Icons.check_circle_rounded, size: 30, color: decoration.colorScheme.primary),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                'Processing Payment',
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

  Widget _buildServiceInfo() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: const Color(0xFF2563EB).withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
                child: Icon(widget.service.icon, color: const Color(0xFF2563EB), size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.service.name,
                      style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black87),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '₹${widget.service.charge!.toStringAsFixed(0)}',
                      style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600], fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (widget.service.images.isNotEmpty) ...[const SizedBox(height: 12), _buildServiceImages()],
        ],
      ),
    );
  }

  Widget _buildServiceImages() {
    return GestureDetector(
      onTap: () => _showImagesDialog(context),
      child: Container(
        height: 130,
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
                      Text(
                        '${widget.service.name} - Images',
                        style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),
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

  Widget _buildBookingTypeSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Booking Type',
            style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black87),
          ),
          const SizedBox(height: 8),
          Text('Choose your preferred doctor type', style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600])),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildBookingTypeOption(
                  title: 'Regular Doctor',
                  subtitle: 'Experienced medical professionals',
                  value: 'Regular',
                  icon: Icons.medical_services,
                  color: Color(0xFF2563EB),
                  isSelected: _selectedBookingType == 'Regular',
                  onTap: () => setState(() => _selectedBookingType = 'Regular'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildBookingTypeOption(
                  title: 'Intern Doctor',
                  subtitle: 'Under supervision, more affordable',
                  value: 'Intern',
                  icon: Icons.school,
                  color: Color(0xFF2563EB),
                  isSelected: _selectedBookingType == 'Intern',
                  onTap: () => setState(() => _selectedBookingType = 'Intern'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBookingTypeOption({
    required String title,
    required String subtitle,
    required String value,
    required IconData icon,
    required Color color,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? color : Colors.grey[300]!, width: isSelected ? 1.5 : 1),
        ),
        child: Column(
          children: [
            Icon(icon, color: isSelected ? color : Colors.grey[600], size: 24),
            const SizedBox(height: 8),
            Text(
              title,
              style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: isSelected ? color : Colors.black87),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: GoogleFonts.poppins(fontSize: 10, color: isSelected ? color.withOpacity(0.8) : Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Payment Method',
            style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black87),
          ),
          const SizedBox(height: 8),
          Text('Choose how you want to pay', style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600])),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildPaymentOption(
                  title: 'Online',
                  subtitle: 'Pay with Razorpay',
                  icon: Icons.credit_card,
                  isSelected: _selectedPaymentMethod == 'online',
                  onTap: () => setState(() => _selectedPaymentMethod = 'online'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildPaymentOption(
                  title: 'COD',
                  subtitle: 'Pay at clinic',
                  icon: Icons.payments_outlined,
                  isSelected: _selectedPaymentMethod == 'offline',
                  onTap: () => setState(() => _selectedPaymentMethod = 'offline'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentOption({required String title, required String subtitle, required IconData icon, required bool isSelected, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? Color(0xFF2563EB).withOpacity(0.1) : Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? Color(0xFF2563EB) : Colors.grey[300]!, width: isSelected ? 1.5 : 1),
        ),
        child: Column(
          children: [
            Icon(icon, color: isSelected ? Color(0xFF2563EB) : Colors.grey[600], size: 24),
            const SizedBox(height: 8),
            Text(
              title,
              style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: isSelected ? Color(0xFF2563EB) : Colors.black87),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: GoogleFonts.poppins(fontSize: 10, color: isSelected ? Color(0xFF2563EB).withOpacity(0.8) : Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookButton() {
    final isFormValid = (_selectedPaymentMethod == 'online' || _selectedPaymentMethod == 'offline') && (_selectedBookingType == 'Regular' || _selectedBookingType == 'Intern');
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, -2))],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          spacing: 20.0,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Total Amount', style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600])),
                Text(
                  '₹${widget.service.charge!.toStringAsFixed(0)}',
                  style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF2563EB)),
                ),
              ],
            ),
            Expanded(
              child: ElevatedButton(
                onPressed: isFormValid ? _processBooking : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF2563EB),
                  disabledBackgroundColor: Colors.grey[400],
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(
                  _selectedPaymentMethod == 'online' ? 'Pay Now' : 'Confirm Booking',
                  style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
