import 'dart:async';
import 'package:flutter/material.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInCubic),
    );

    _fadeController.forward();

    Timer(const Duration(seconds: 4), () {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const LoginScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 1000),
        ),
      );
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0A0B),
      body: FadeTransition(
        opacity: _opacityAnimation,
        child: Stack(
          children: [
            Positioned(
              top: -100,
              right: -50,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.transparent,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF3A1F23).withOpacity(0.25),
                      blurRadius: 120,
                      spreadRadius: 40,
                    ),
                  ],
                ),
              ),
            ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 130,
                    height: 200,
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.6), width: 1),
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(100),
                        bottom: Radius.circular(12),
                      ),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(100),
                          bottom: Radius.circular(8),
                        ),
                        child: Image.asset(
                          'assets/images/logo.png',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            color: const Color(0xFF161213),
                            child: const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.auto_awesome_outlined,
                                  size: 45,
                                  color: Color(0xFFD4AF37),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  "Maison",
                                  style: TextStyle(
                                    fontFamily: 'Serif',
                                    fontSize: 12,
                                    color: Color(0xFFD4AF37),
                                    letterSpacing: 3,
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  const Text(
                    "VALENTINE",
                    style: TextStyle(
                      fontFamily: 'Serif',
                      fontSize: 34,
                      fontWeight: FontWeight.w200,
                      color: Colors.white,
                      letterSpacing: 8.0,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: 40,
                    height: 1,
                    color: const Color(0xFFD4AF37),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "HAUTE PARFUMERIE & BEAUTÉ",
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w400,
                      color: Colors.white54,
                      letterSpacing: 4.0,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}