
import 'package:flutter/material.dart';

import '../services/supabase_service.dart';
import '../style/app_assets.dart';
import '../style/app_colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() =>
      _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {

  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    // Animation Controller
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    // Fade Animation
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );

    // Slide Animation
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ),
    );

    _controller.forward();

    // Navigate after splash screen
    _navigateToNextScreen();
  }

  // Check login session
  Future<void> _navigateToNextScreen() async {
    await Future.delayed(
      const Duration(seconds: 3),
    );

    if (!mounted) return;

    final isLoggedIn =
        SupabaseService.currentUser != null;

    Navigator.pushReplacementNamed(
      context,
      isLoggedIn ? '/home' : '/login',
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // App title with outline effect
  Widget _buildTitle() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Text(
          'Rick & Morty',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w900,
            letterSpacing: -1,
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 4
              ..color = const Color(0xFF493B32),
          ),
        ),

        const Text(
          'Rick & Morty',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w900,
            letterSpacing: -1,
            color: Color(0xFFF7C873),
            shadows: [
              Shadow(
                color: Color(0xFF493B32),
                offset: Offset(2, 3),
                blurRadius: 0,
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      body: LayoutBuilder(
        builder: (context, constraints) {

          final screenWidth = constraints.maxWidth;
          final screenHeight = constraints.maxHeight;

          return Stack(
            fit: StackFit.expand,
            children: [
              // BACKGROUND LANDSCAPE
              Image.asset(
                AppAssets.splashBackground,
                fit: BoxFit.cover,
                filterQuality: FilterQuality.none,

                errorBuilder: (
                  context,
                  error,
                  stackTrace,
                ) {
                  return const ColoredBox(
                    color: AppColors.background,
                  );
                },
              ),
              // ANIMATED CONTENT
              SafeArea(
                child: FadeTransition(
                  opacity: _fadeAnimation,

                  child: SlideTransition(
                    position: _slideAnimation,

                    child: Stack(
                      children: [
                        // UFO
                        Positioned(
                          top: screenHeight * 0.09,
                          left: screenWidth * 0.5 - 55,

                          child: Image.asset(
                            AppAssets.ufo,
                            width: 110,
                            height: 75,
                            fit: BoxFit.contain,
                            filterQuality:
                                FilterQuality.none,
                          ),
                        ),
                        // APP TITLE
                        Positioned(
                          top: screenHeight * 0.245,
                          left: 10,
                          right: 10,

                          child: Column(
                            children: [

                              _buildTitle(),

                              const SizedBox(height: 2),

                              const Text(
                                'Character Explorer',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF302522),
                                  shadows: [
                                    Shadow(
                                      color: Colors.white70,
                                      offset: Offset(1, 1),
                                      blurRadius: 1,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        // RICK & MORTY
                        Positioned(
                          bottom: screenHeight * 0.045,
                          left: 0,
                          right: 0,

                          child: Row(
                            mainAxisAlignment:
                                MainAxisAlignment.center,

                            crossAxisAlignment:
                                CrossAxisAlignment.end,

                            children: [

                              // Rick
                              Image.asset(
                                AppAssets.rick,
                                width: screenWidth * 0.23,
                                height: screenHeight * 0.13,
                                fit: BoxFit.contain,
                                filterQuality:
                                    FilterQuality.none,
                              ),

                              SizedBox(
                                width: screenWidth * 0.015,
                              ),

                              // Morty
                              Image.asset(
                                AppAssets.morty,
                                width: screenWidth * 0.21,
                                height: screenHeight * 0.115,
                                fit: BoxFit.contain,
                                filterQuality:
                                    FilterQuality.none,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
