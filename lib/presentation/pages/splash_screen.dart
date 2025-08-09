import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _waveController;
  late AnimationController _logoController;
  late AnimationController _fadeController;
  
  late Animation<double> _waveAnimation;
  late Animation<double> _logoAnimation;
  late Animation<double> _fadeAnimation;

  // Atlas red color from the image
  static const Color atlasRed = Color(0xFF871121);

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startSplashSequence();
  }

  void _initializeAnimations() {
    // Wave animation controller
    _waveController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // Logo animation controller
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    // Fade animation controller
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // Wave animation (continuous)
    _waveAnimation = Tween<double>(
      begin: 0.0,
      end: 2 * math.pi,
    ).animate(CurvedAnimation(
      parent: _waveController,
      curve: Curves.linear,
    ));

    // Logo scale animation
    _logoAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: Curves.elasticOut,
    ));

    // Fade in animation
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));
  }

  void _startSplashSequence() async {
    // Start fade in
    _fadeController.forward();
    
    // Wait a bit then start logo animation
    await Future.delayed(const Duration(milliseconds: 300));
    _logoController.forward();
    
    // Start wave animation (repeating)
    await Future.delayed(const Duration(milliseconds: 500));
    _waveController.repeat();
    
    // Navigate to main screen after splash duration
    await Future.delayed(const Duration(milliseconds: 3000));
    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/mainChatPage');
    }
  }

  @override
  void dispose() {
    _waveController.dispose();
    _logoController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Set status bar to match splash screen
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: atlasRed,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: atlasRed,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );

    return Scaffold(
      backgroundColor: atlasRed,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.center,
              radius: 1.0,
              colors: [
                Color(0xFF9A1A2A), // Slightly lighter red for depth
                atlasRed,
                Color(0xFF6B0E1A), // Darker red for edges
              ],
              stops: [0.0, 0.7, 1.0],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo with scale animation
              ScaleTransition(
                scale: _logoAnimation,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 20,
                        spreadRadius: 5,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.asset(
                      'assets/icons/atlas2.png',
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        // Fallback if image not found
                        return Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            gradient: const LinearGradient(
                              colors: [
                                Colors.white,
                                Color(0xFFF0F0F0),
                              ],
                            ),
                          ),
                          child: const Icon(
                            Icons.auto_awesome,
                            size: 60,
                            color: atlasRed,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // App name with fade animation
              FadeTransition(
                opacity: _fadeAnimation,
                child: const Text(
                  'ATLAS AI',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 4,
                    shadows: [
                      Shadow(
                        color: Colors.black26,
                        offset: Offset(0, 2),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 60),

              // Wave loader animation
              AnimatedBuilder(
                animation: _waveAnimation,
                builder: (context, child) {
                  return SizedBox(
                    width: 200,
                    height: 60,
                    child: CustomPaint(
                      painter: WaveLoaderPainter(
                        animationValue: _waveAnimation.value,
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 20),

              // Loading text
              FadeTransition(
                opacity: _fadeAnimation,
                child: const Text(
                  'جاري التحميل...',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class WaveLoaderPainter extends CustomPainter {
  final double animationValue;

  WaveLoaderPainter({required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 3
      ..style = PaintingStyle.fill;

    final path = Path();
    final waveHeight = 15.0;
    final waveLength = size.width / 3;

    // Create multiple wave bars with different phases
    for (int i = 0; i < 8; i++) {
      final x = (size.width / 8) * i + (size.width / 16);
      final phase = (i * 0.5) + animationValue;
      final height = waveHeight * (0.5 + 0.5 * math.sin(phase));
      
      // Create rounded rectangle for each wave bar
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(
          x - 8,
          size.height / 2 - height / 2,
          16,
          height,
        ),
        const Radius.circular(8),
      );

      // Add glow effect
      final glowPaint = Paint()
        ..color = Colors.white.withOpacity(0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
      
      canvas.drawRRect(rect, glowPaint);
      canvas.drawRRect(rect, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
