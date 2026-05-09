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
  late AnimationController _logoScaleController;
  late Animation<double> _logoScaleAnimation;

  late AnimationController _logoOpacityController;
  late Animation<double> _logoOpacityAnimation;

  late AnimationController _glowController;
  late Animation<double> _glowAnimation;

  late AnimationController _textController;
  late Animation<double> _textOpacityAnimation;
  late Animation<Offset> _textSlideAnimation;

  late AnimationController _shineController;
  late Animation<double> _shineAnimation;

  @override
  void initState() {
    super.initState();
    Get.put(SplashScreenController());
    _initAnimations();
    _startAnimations();
  }

  void _initAnimations() {
    _logoScaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _logoScaleAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _logoScaleController, curve: Curves.elasticOut),
    );

    _logoOpacityController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _logoOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoOpacityController, curve: Curves.easeIn),
    );

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _glowAnimation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _textOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeIn),
    );
    _textSlideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.4), end: Offset.zero).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeOut),
    );

    _shineController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _shineAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _shineController, curve: Curves.easeOut),
    );
  }

  void _startAnimations() async {
    await Future.delayed(const Duration(milliseconds: 200));
    _logoOpacityController.forward();
    _logoScaleController.forward();
    await Future.delayed(const Duration(milliseconds: 700));
    _shineController.forward();
    await Future.delayed(const Duration(milliseconds: 400));
    _textController.forward();
  }

  @override
  void dispose() {
    _logoScaleController.dispose();
    _logoOpacityController.dispose();
    _glowController.dispose();
    _textController.dispose();
    _shineController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Background glow
          AnimatedBuilder(
            animation: _glowAnimation,
            builder: (context, child) {
              return Center(
                child: Container(
                  width: 350,
                  height: 350,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF00D4FF)
                            .withOpacity(0.08 * _glowAnimation.value),
                        blurRadius: 120,
                        spreadRadius: 60,
                      ),
                      BoxShadow(
                        color: const Color(0xFFFF0099)
                            .withOpacity(0.06 * _glowAnimation.value),
                        blurRadius: 140,
                        spreadRadius: 40,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo
                AnimatedBuilder(
                  animation: Listenable.merge([
                    _logoScaleAnimation,
                    _logoOpacityAnimation,
                    _glowAnimation,
                    _shineAnimation,
                  ]),
                  builder: (context, child) {
                    return Opacity(
                      opacity: _logoOpacityAnimation.value,
                      child: Transform.scale(
                        scale: _logoScaleAnimation.value,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Glow ring
                            Container(
                              width: 180,
                              height: 180,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF00D4FF).withOpacity(
                                        0.3 * _glowAnimation.value),
                                    blurRadius: 40,
                                    spreadRadius: 10,
                                  ),
                                  BoxShadow(
                                    color: const Color(0xFFFF0099).withOpacity(
                                        0.2 * _glowAnimation.value),
                                    blurRadius: 50,
                                    spreadRadius: 5,
                                  ),
                                ],
                              ),
                            ),

                            // Logo image
                            ClipRRect(
                              borderRadius: BorderRadius.circular(32),
                              child: Image.asset(
                                'assets/images/ic_launcher.png',
                                width: 150,
                                height: 150,
                                fit: BoxFit.cover,
                              ),
                            ),

                            // Shine flash
                            if (_shineAnimation.value > 0 &&
                                _shineAnimation.value < 1)
                              ClipRRect(
                                borderRadius: BorderRadius.circular(32),
                                child: Container(
                                  width: 150,
                                  height: 150,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        Colors.white.withOpacity(0.4 *
                                            (1 - _shineAnimation.value)),
                                        Colors.transparent,
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 32),

                // Text
                AnimatedBuilder(
                  animation: _textController,
                  builder: (context, child) {
                    return FadeTransition(
                      opacity: _textOpacityAnimation,
                      child: SlideTransition(
                        position: _textSlideAnimation,
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: [
                                ShaderMask(
                                  shaderCallback: (bounds) =>
                                      const LinearGradient(
                                    colors: [
                                      Color(0xFF00D4FF),
                                      Color(0xFFFF0099),
                                    ],
                                  ).createShader(bounds),
                                  child: const Text(
                                    'Flayr',
                                    style: TextStyle(
                                      fontSize: 42,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.white,
                                      letterSpacing: 2,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'Egypt',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w400,
                                    color: Color(0xFF888888),
                                    letterSpacing: 1,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Container(
                              width: 120,
                              height: 1,
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.transparent,
                                    Color(0xFF00D4FF),
                                    Color(0xFFFF0099),
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              'Developed by Abdullah Mabrouk',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w300,
                                color: Color(0xFF555555),
                                letterSpacing: 0.8,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
