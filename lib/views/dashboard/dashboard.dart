import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:patients/views/dashboard/appointments/appointments.dart';
import 'package:patients/views/dashboard/dashboard_ctrl.dart';
import 'package:patients/views/dashboard/home/home.dart';
import 'package:patients/views/dashboard/profile/profile.dart';
import 'package:patients/views/dashboard/services/services.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  final List<BottomNavigationBarItem> _navItems = [
    const BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home_rounded), label: 'Home'),
    const BottomNavigationBarItem(icon: Icon(Icons.medical_services_outlined), activeIcon: Icon(Icons.medical_services_rounded), label: 'Services'),
    const BottomNavigationBarItem(icon: Icon(Icons.calendar_today_outlined), activeIcon: Icon(Icons.calendar_today_rounded), label: 'Appointments'),
    const BottomNavigationBarItem(icon: Icon(Icons.person_outlined), activeIcon: Icon(Icons.person_rounded), label: 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DashboardCtrl>(
      init: DashboardCtrl(),
      builder: (ctrl) {
        return Obx(() {
          return PopScope(
            canPop: false,
            child: Scaffold(
              backgroundColor: Colors.grey[50],
              body: IndexedStack(index: ctrl.currentIndex.value, children: [Home(), Services(), Appointments(), Profile()]),
              bottomNavigationBar: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, -2))],
                ),
                child: BottomNavigationBar(
                  currentIndex: ctrl.currentIndex.value,
                  onTap: ctrl.changeTab,
                  type: BottomNavigationBarType.fixed,
                  backgroundColor: Colors.white,
                  selectedItemColor: const Color(0xFF2563EB),
                  unselectedItemColor: const Color(0xFF6B7280),
                  selectedLabelStyle: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500),
                  unselectedLabelStyle: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500),
                  items: _navItems,
                ),
              ),
            ),
          );
        });
      },
    );
  }
}
