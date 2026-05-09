import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shortzz/screen/splash_screen/splash_screen_controller.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  // Main title animation
  late AnimationController _titleController;
  late Animation<double> _titleScaleAnimation;
  late Animation<double> _titleOpacityAnimation;

  // Glow pulse
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;

  // Subtitle slide up
  late AnimationController _subtitleController;
  late Animation<double> _subtitleOpacityAnimation;
  late Animation<Offset> _subtitleSlideAnimation;

  // Dev text
  late AnimationController _devController;
  late Animation<double> _devOpacityAnimation;

  // Line expand
  late AnimationController _lineController;
  late Animation<double> _lineWidthAnimation;

  @override
  void initState() {
    super.initState();
    Get.put(SplashScreenController());
    _initAnimations();
    _startAnimations();
  }

  void _initAnimations() {
    // Title: scale + fade
    _titleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _titleScaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _titleController, curve: Curves.elasticOut),
    );
    _titleOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
          parent: _titleController,
          curve: const Interval(0.0, 0.5, curve: Curves.easeIn)),
    );

    // Glow pulse
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    _glowAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    // Line expand
    _lineController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _lineWidthAnimation = Tween<double>(begin: 0.0, end: 160.0).animate(
      CurvedAnimation(parent: _lineController, curve: Curves.easeOut),
    );

    // Subtitle
    _subtitleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _subtitleOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _subtitleController, curve: Curves.easeIn),
    );
    _subtitleSlideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(
      CurvedAnimation(parent: _subtitleController, curve: Curves.easeOut),
    );

    // Dev text
    _devController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _devOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _devController, curve: Curves.easeIn),
    );
  }

  void _startAnimations() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _titleController.forward();
    await Future.delayed(const Duration(milliseconds: 700));
    _lineController.forward();
    await Future.delayed(const Duration(milliseconds: 400));
    _subtitleController.forward();
    await Future.delayed(const Duration(milliseconds: 400));
    _devController.forward();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _glowController.dispose();
    _lineController.dispose();
    _subtitleController.dispose();
    _devController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Background glow behind text
          AnimatedBuilder(
            animation: _glowAnimation,
            builder: (context, child) {
              return Center(
                child: Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF00C8FF)
                            .withOpacity(0.07 * _glowAnimation.value),
                        blurRadius: 100,
                        spreadRadius: 60,
                      ),
                      BoxShadow(
                        color: const Color(0xFFFF0088)
                            .withOpacity(0.05 * _glowAnimation.value),
                        blurRadius: 120,
                        spreadRadius: 40,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          // Main content
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // FLAYR title
                AnimatedBuilder(
                  animation: _titleController,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _titleOpacityAnimation.value,
                      child: Transform.scale(
                        scale: _titleScaleAnimation.value,
                        child: AnimatedBuilder(
                          animation: _glowController,
                          builder: (context, child) {
                            return Stack(
                              children: [
                                // Glow shadow behind text
                                Text(
                                  'FLAYR',
                                  style: TextStyle(
                                    fontSize: 72,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 12,
                                    foreground: Paint()
                                      ..maskFilter = MaskFilter.blur(
                                        BlurStyle.normal,
                                        20 * _glowAnimation.value,
                                      )
                                      ..color = const Color(0xFF00C8FF)
                                          .withOpacity(
                                              0.6 * _glowAnimation.value),
                                  ),
                                ),
                                // Main gradient text
                                ShaderMask(
                                  shaderCallback: (bounds) =>
                                      const LinearGradient(
                                    colors: [
                                      Color(0xFF00C8FF),
                                      Color(0xFF8B5CF6),
                                      Color(0xFFFF0088),
                                    ],
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                  ).createShader(bounds),
                                  child: const Text(
                                    'FLAYR',
                                    style: TextStyle(
                                      fontSize: 72,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 12,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 12),

                // Expanding line
                AnimatedBuilder(
                  animation: _lineController,
                  builder: (context, child) {
                    return Container(
                      width: _lineWidthAnimation.value,
                      height: 1.5,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            Color(0xFF00C8FF),
                            Color(0xFFFF0088),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 14),

                // Egypt subtitle
                AnimatedBuilder(
                  animation: _subtitleController,
                  builder: (context, child) {
                    return FadeTransition(
                      opacity: _subtitleOpacityAnimation,
                      child: SlideTransition(
                        position: _subtitleSlideAnimation,
                        child: const Text(
                          'E G Y P T',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w300,
                            color: Color(0xFF777777),
                            letterSpacing: 6,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          // Dev text at bottom
          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: AnimatedBuilder(
              animation: _devController,
              builder: (context, child) {
                return Opacity(
                  opacity: _devOpacityAnimation.value,
                  child: const Column(
                    children: [
                      Text(
                        'Developed by',
                        style: TextStyle(
                          fontSize: 11,
                          color: Color(0xFF444444),
                          letterSpacing: 1,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Abdullah Mabrouk',
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF666666),
                          fontWeight: FontWeight.w500,
                          letterSpacing: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
