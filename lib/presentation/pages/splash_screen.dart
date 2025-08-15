import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  AnimationController? _logoController;
  AnimationController? _fadeController;
  
  Animation<double>? _logoAnimation;
  Animation<double>? _fadeAnimation;
  
  bool _isInitialized = false;

  // Atlas dark theme color
  static const Color atlasTheme = Color(0xFF1F2428);

  @override
  void initState() {
    super.initState();
    
    if (kDebugMode) {
      print('🎬 SplashScreen initialized');
    }
    
    _startAnimation();
  }

  /// تهيئة الرسوم المتحركة
  void _initializeAnimations() {
    if (kDebugMode) {
      print('🎬 Initializing splash animations...');
    }
    
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    // تهيئة الرسوم المتحركة
    _logoAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController!,
      curve: Curves.elasticOut,
    ));
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController!,
      curve: Curves.easeInOut,
    ));
    
    if (kDebugMode) {
      print('✅ Splash animations initialized successfully');
    }
  }

  /// بدء الرسوم المتحركة
  void _startAnimation() {
    if (kDebugMode) {
      print('🎬 Starting splash animations...');
    }
    
    _initializeAnimations();
    _startSplashSequence();
  }

  /// بدء تسلسل السبلاش
  Future<void> _startSplashSequence() async {
    if (kDebugMode) {
      print('🎬 Starting splash sequence...');
    }
    
    // تأكد من التهيئة
    if (_logoController != null && _fadeController != null) {
      // بدء الرسوم المتحركة
      _logoController!.forward();
      _fadeController!.forward();
      
      // تحديث حالة التهيئة
      setState(() {
        _isInitialized = true;
      });
    }
    
    // Navigate to main screen main_chat_page_enhanced.dart  after splash duration (reduced to 2 seconds)
    if (kDebugMode) {
      print('⏱️ Waiting 2 seconds before navigation...');
    }
    
    await Future.delayed(const Duration(milliseconds: 2000));
    if (mounted) {
      if (kDebugMode) {
        print('🚀 Navigating to main chat page...');
      }
      Navigator.of(context).pushReplacementNamed('/mainChatPage');
    }
  }

  @override
  void dispose() {
    if (kDebugMode) {
      print('🧹 Disposing SplashScreen...');
    }
    
    _logoController?.dispose();
    _fadeController?.dispose();
    
    if (kDebugMode) {
      print('✅ SplashScreen disposed successfully');
    }
    
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (kDebugMode) {
      print('🎨 Building SplashScreen...');
    }
    
    // فحص الجاهزية
    if (!_isInitialized || _fadeAnimation == null || _logoAnimation == null) {
      return Scaffold(
        backgroundColor: atlasTheme,
        body: const Center(
          child: CircularProgressIndicator(
            color: Colors.white,
          ),
        ),
      );
    }
    
    // Set status bar to match splash screen
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: atlasTheme,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: atlasTheme,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );

    return Scaffold(
      backgroundColor: atlasTheme,
      body: FadeTransition(
        opacity: _fadeAnimation!,
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.center,
              radius: 1.0,
              colors: [
                Color(0xFF2A3038), // Slightly lighter for depth
                atlasTheme,
                Color(0xFF171B20), // Darker for edges
              ],
              stops: [0.0, 0.7, 1.0],
            ),
          ),
          child: Stack(
            children: [
              // Skip button
              Positioned(
                top: 50,
                right: 20,
                child: TextButton(
                  onPressed: () {
                    if (kDebugMode) {
                      print('⏭️ Skip button pressed - navigating immediately...');
                    }
                    Navigator.of(context).pushReplacementNamed('/mainChatPage');
                  },
                  child: const Text(
                    'تخطي',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              
              // Main content
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo with scale animation
                    ScaleTransition(
                      scale: _logoAnimation!,
                      child: Container(
                        width: 280,
                        height: 280,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 25,
                              spreadRadius: 8,
                              offset: const Offset(0, 15),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(30),
                          child: Image.asset(
                            'assets/icons/no-bg-icon1.png',
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              // Fallback if image not found
                              return Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(30),
                                  gradient: const LinearGradient(
                                    colors: [
                                      Colors.white,
                                      Color(0xFFF0F0F0),
                                    ],
                                  ),
                                ),
                                child: const Icon(
                                  Icons.auto_awesome,
                                  size: 90,
                                  color: atlasTheme,
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
                      opacity: _fadeAnimation!,
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

                    // Ball animation GIF
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(60),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.white.withOpacity(0.2),
                            blurRadius: 20,
                            spreadRadius: 5,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(60),
                        child: Image.asset(
                          'assets/icons/ball_ani.gif',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            // Fallback if GIF not found
                            return Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(60),
                                gradient: const LinearGradient(
                                  colors: [
                                    Colors.white,
                                    Color(0xFFE0E0E0),
                                  ],
                                ),
                              ),
                              child: const Icon(
                                Icons.sports_soccer,
                                size: 60,
                                color: atlasTheme,
                              ),
                            );
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Loading text
                    FadeTransition(
                      opacity: _fadeAnimation!,
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
            ],
          ),
        ),
      ),
    );
  }
}


