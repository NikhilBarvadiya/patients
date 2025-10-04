import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:patients/views/splash/splash_ctrl.dart';

class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation, _scaleAnimation, _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: const Duration(milliseconds: 2000), vsync: this);
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
      ),
    );
    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
      ),
    );
    _slideAnimation = Tween<double>(begin: 50.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 0.8, curve: Curves.easeOut),
      ),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SplashCtrl>(
      init: SplashCtrl(),
      builder: (context) {
        return Scaffold(
          backgroundColor: const Color(0xFF2563EB),
          body: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [const Color(0xFF2563EB), const Color(0xFF1D4ED8), const Color(0xFF1E40AF)]),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      top: 100,
                      right: 50,
                      child: Opacity(
                        opacity: _fadeAnimation.value * 0.3,
                        child: Icon(Icons.favorite_rounded, size: 80, color: Colors.white.withOpacity(0.2)),
                      ),
                    ),
                    Positioned(
                      bottom: 150,
                      left: 40,
                      child: Opacity(
                        opacity: _fadeAnimation.value * 0.2,
                        child: Icon(Icons.medical_services_rounded, size: 60, color: Colors.white.withOpacity(0.15)),
                      ),
                    ),
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Opacity(
                            opacity: _fadeAnimation.value,
                            child: Transform.translate(
                              offset: Offset(0, _slideAnimation.value),
                              child: Transform.scale(
                                scale: _scaleAnimation.value,
                                child: Container(
                                  width: 120,
                                  height: 120,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(30),
                                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 40, offset: const Offset(0, 15))],
                                  ),
                                  child: Stack(
                                    children: [
                                      Center(child: Icon(Icons.health_and_safety_rounded, size: 56, color: const Color(0xFF2563EB))),
                                      if (_controller.status == AnimationStatus.forward)
                                        Positioned.fill(
                                          child: AnimatedContainer(
                                            duration: const Duration(milliseconds: 1000),
                                            margin: EdgeInsets.all(_controller.value * 20),
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              border: Border.all(color: Colors.white.withOpacity(0.5), width: 2),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 40),
                          Opacity(
                            opacity: _fadeAnimation.value,
                            child: Transform.translate(
                              offset: Offset(0, _slideAnimation.value * 0.5),
                              child: const Text(
                                'HealSync',
                                style: TextStyle(fontSize: 36, fontWeight: FontWeight.w700, color: Colors.white, letterSpacing: 0.8),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Opacity(
                            opacity: _fadeAnimation.value * 0.9,
                            child: Transform.translate(
                              offset: Offset(0, _slideAnimation.value * 0.3),
                              child: const Text(
                                'Your Journey to Better Health',
                                style: TextStyle(fontSize: 16, color: Colors.white70, letterSpacing: 0.3, fontWeight: FontWeight.w400),
                              ),
                            ),
                          ),
                          const SizedBox(height: 80),
                          Opacity(
                            opacity: _fadeAnimation.value,
                            child: Column(
                              children: [
                                Container(
                                  width: 120,
                                  height: 4,
                                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.3), borderRadius: BorderRadius.circular(2)),
                                  child: AnimatedBuilder(
                                    animation: _controller,
                                    builder: (context, child) {
                                      return Container(
                                        width: 120 * _controller.value,
                                        height: 4,
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(colors: [Colors.white, Colors.white.withOpacity(0.8)]),
                                          borderRadius: BorderRadius.circular(2),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                const SizedBox(height: 12),
                                const Text('Loading your healing journey...', style: TextStyle(fontSize: 12, color: Colors.white60)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      bottom: 40,
                      left: 0,
                      right: 0,
                      child: Opacity(
                        opacity: _fadeAnimation.value * 0.7,
                        child: const Column(
                          children: [
                            Text('Trusted by Thousands of Patients', style: TextStyle(fontSize: 12, color: Colors.white54)),
                            SizedBox(height: 8),
                            Text('Safe • Secure • Professional', style: TextStyle(fontSize: 10, color: Colors.white38)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}
