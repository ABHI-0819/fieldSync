import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

import '../../core/config/route/app_route.dart';
import '../widgets/app_version_text.dart';

@RoutePage()
class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _pulseController;
  late AnimationController _gpsController;
  
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _logoRotation;

  @override
  void initState() {
    super.initState();
    
    // Main animation controller
    _mainController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    // Pulse animation for background
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    )..repeat(reverse: true);

    // GPS ring animation
    _gpsController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    )..repeat();

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.2, 0.8, curve: Curves.elasticOut),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.3, 0.9, curve: Curves.easeOutCubic),
      ),
    );

    _logoRotation = Tween<double>(begin: -0.1, end: 0.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.2, 0.8, curve: Curves.easeOut),
      ),
    );

    _mainController.forward();

    // Navigate after animation
    Future.delayed(const Duration(seconds: 3), () {
      context.router.replaceAll([const LoginRoute()]);
    });
  }

  @override
  void dispose() {
    _mainController.dispose();
    _pulseController.dispose();
    _gpsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFF8F5ED),
              Color(0xFFEDE7DC),
              Color(0xFFE8E2D5),
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // Animated background pattern
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  return CustomPaint(
                    painter: BackgroundPatternPainter(
                      animationValue: _pulseController.value,
                    ),
                  );
                },
              ),
            ),

            // Ambient glow top right
            Positioned(
              top: -100,
              right: -100,
              child: AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  return Container(
                    width: 400,
                    height: 400,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          Color(0xFF6B9B6A).withOpacity(0.1 * _pulseController.value),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // Ambient glow bottom left
            Positioned(
              bottom: -80,
              left: -80,
              child: AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  return Container(
                    width: 350,
                    height: 350,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          Color(0xFFD4A853).withOpacity(0.08 * (1 - _pulseController.value)),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // Main content
            FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo with GPS rings
                      ScaleTransition(
                        scale: _scaleAnimation,
                        child: AnimatedBuilder(
                          animation: _logoRotation,
                          builder: (context, child) {
                            return Transform.rotate(
                              angle: _logoRotation.value,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  // Expanding GPS rings
                                  AnimatedBuilder(
                                    animation: _gpsController,
                                    builder: (context, child) {
                                      return CustomPaint(
                                        size: const Size(280, 280),
                                        painter: GPSRingsPainter(
                                          animationValue: _gpsController.value,
                                        ),
                                      );
                                    },
                                  ),

                                  // Main logo
                                  Container(
                                    width: 220,
                                    height: 220,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: RadialGradient(
                                        colors: [
                                          Colors.white.withOpacity(0.4),
                                          Colors.white.withOpacity(0.1),
                                          Colors.transparent,
                                        ],
                                        stops: const [0.0, 0.6, 1.0],
                                      ),
                                    ),
                                  ),

                                  // Logo illustration
                                  SizedBox(
                                    width: 200,
                                    height: 200,
                                    child: CustomPaint(
                                      painter: BuilTreeLogoPainter(),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 56),

                      // App name with gradient text
                      ShaderMask(
                        shaderCallback: (bounds) => const LinearGradient(
                          colors: [
                            Color(0xFF234F1E),
                            Color(0xFF5C8A5A),
                          ],
                        ).createShader(bounds),
                        child: const Text(
                          'BuilTree',
                          style: TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.5,
                            color: Colors.white,
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Animated divider
                      TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0.0, end: 100.0),
                        duration: const Duration(milliseconds: 1200),
                        curve: Curves.easeOut,
                        builder: (context, width, child) {
                          return Container(
                            width: width,
                            height: 3,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  Colors.transparent,
                                  Color(0xFFD4A853),
                                  Colors.transparent,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 16),

                      // Tagline
                      const Text(
                        'Tree & Fauna Survey',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 2.0,
                          color: Color(0xFF5C8A5A),
                        ),
                      ),

                      const SizedBox(height: 8),

                      // Sub-tagline
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.location_on_rounded,
                            size: 16,
                            color: const Color(0xFFD4A853),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'GPS-Enabled',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                              letterSpacing: 1.0,
                              color: const Color(0xFF234F1E).withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Loading indicator
            Positioned(
              bottom: 100,
              left: 0,
              right: 0,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: const AnimatedLoadingDots(),
              ),
            ),

            // Version
            Positioned(
              bottom: 50,
              left: 0,
              right: 0,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: const AppVersionText()
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class BackgroundPatternPainter extends CustomPainter {
  final double animationValue;

  BackgroundPatternPainter({required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF234F1E).withOpacity(0.02 + (0.02 * animationValue))
      ..style = PaintingStyle.fill;

    for (double x = 0; x < size.width; x += 50) {
      for (double y = 0; y < size.height; y += 50) {
        canvas.drawCircle(Offset(x, y), 1.5, paint);
      }
    }
  }

  @override
  bool shouldRepaint(BackgroundPatternPainter oldDelegate) =>
      oldDelegate.animationValue != animationValue;
}

// GPS rings painter
class GPSRingsPainter extends CustomPainter {
  final double animationValue;

  GPSRingsPainter({required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    
    // Draw multiple expanding rings
    for (int i = 0; i < 3; i++) {
      final progress = (animationValue + (i * 0.33)) % 1.0;
      final radius = 60 + (progress * 80);
      final opacity = 1.0 - progress;

      final paint = Paint()
        ..color = const Color(0xFFD4A853).withOpacity(opacity * 0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;

      canvas.drawCircle(center, radius, paint);
    }

    // Draw dashed circle
    final dashedPaint = Paint()
      ..color = const Color(0xFF234F1E).withOpacity(0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    const dashCount = 24;
    const dashAngle = (2 * math.pi) / dashCount;

    for (int i = 0; i < dashCount; i += 2) {
      final startAngle = i * dashAngle - math.pi / 2;
      final sweepAngle = dashAngle * 0.5;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: 100),
        startAngle,
        sweepAngle,
        false,
        dashedPaint,
      );
    }
  }

  @override
  bool shouldRepaint(GPSRingsPainter oldDelegate) =>
      oldDelegate.animationValue != animationValue;
}

// BuilTree logo painter
class BuilTreeLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;

    // Tree trunk
    final trunkPaint = Paint()
      ..color = const Color(0xFF234F1E)
      ..style = PaintingStyle.fill;

    final trunkPath = Path()
      ..moveTo(centerX - 10, centerY + 40)
      ..lineTo(centerX - 10, centerY - 10)
      ..quadraticBezierTo(centerX - 10, centerY - 15, centerX, centerY - 15)
      ..quadraticBezierTo(centerX + 10, centerY - 15, centerX + 10, centerY - 10)
      ..lineTo(centerX + 10, centerY + 40)
      ..quadraticBezierTo(centerX + 10, centerY + 45, centerX, centerY + 45)
      ..quadraticBezierTo(centerX - 10, centerY + 45, centerX - 10, centerY + 40)
      ..close();

    canvas.drawPath(trunkPath, trunkPaint);

    // Canopy layers
    final canopyPaint1 = Paint()..color = const Color(0xFF6B9B6A).withOpacity(0.6);
    canvas.drawCircle(Offset(centerX - 25, centerY - 20), 22, canopyPaint1);
    canvas.drawCircle(Offset(centerX + 25, centerY - 20), 22, canopyPaint1);

    final canopyPaint2 = Paint()..color = const Color(0xFF5C8A5A);
    canvas.drawCircle(Offset(centerX, centerY - 30), 28, canopyPaint2);

    final canopyPaint3 = Paint()..color = const Color(0xFF234F1E);
    canvas.drawCircle(Offset(centerX - 12, centerY - 35), 16, canopyPaint3);
    canvas.drawCircle(Offset(centerX + 12, centerY - 35), 16, canopyPaint3);
    canvas.drawCircle(Offset(centerX, centerY - 42), 18, canopyPaint3);

    // GPS pin overlay
    final pinPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFFD4A853),
          const Color(0xFFC39643),
        ],
      ).createShader(Rect.fromLTWH(centerX - 12, centerY - 10, 24, 40));

    final pinPath = Path()
      ..moveTo(centerX, centerY - 10)
      ..quadraticBezierTo(centerX - 12, centerY - 10, centerX - 12, centerY)
      ..quadraticBezierTo(centerX - 12, centerY + 10, centerX, centerY + 25)
      ..quadraticBezierTo(centerX + 12, centerY + 10, centerX + 12, centerY)
      ..quadraticBezierTo(centerX + 12, centerY - 10, centerX, centerY - 10)
      ..close();

    canvas.drawPath(pinPath, pinPaint);

    // Pin center
    final pinCenterPaint = Paint()..color = Colors.white;
    canvas.drawCircle(Offset(centerX, centerY), 5, pinCenterPaint);

    final pinDotPaint = Paint()..color = const Color(0xFF234F1E);
    canvas.drawCircle(Offset(centerX, centerY), 3, pinDotPaint);

    // Small fauna silhouette (bird)
    final birdPaint = Paint()
      ..color = const Color(0xFF234F1E)
      ..style = PaintingStyle.fill;

    final birdPath = Path()
      ..moveTo(centerX + 35, centerY - 50)
      ..quadraticBezierTo(centerX + 38, centerY - 52, centerX + 41, centerY - 50)
      ..quadraticBezierTo(centerX + 39, centerY - 48, centerX + 38, centerY - 47)
      ..quadraticBezierTo(centerX + 37, centerY - 48, centerX + 35, centerY - 50)
      ..close();

    canvas.drawPath(birdPath, birdPaint);

    // GPS coordinates indicator
    final coordPaint = Paint()
      ..color = const Color(0xFFD4A853).withOpacity(0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    canvas.drawLine(
      Offset(centerX - 50, centerY),
      Offset(centerX - 35, centerY),
      coordPaint,
    );
    canvas.drawLine(
      Offset(centerX + 35, centerY),
      Offset(centerX + 50, centerY),
      coordPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Animated loading dots
class AnimatedLoadingDots extends StatefulWidget {
  const AnimatedLoadingDots({Key? key}) : super(key: key);

  @override
  State<AnimatedLoadingDots> createState() => _AnimatedLoadingDotsState();
}

class _AnimatedLoadingDotsState extends State<AnimatedLoadingDots>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1400),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        return AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final value = math.sin(
              (_controller.value * 2 * math.pi) - (index * math.pi / 3),
            );
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 5),
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF6B9B6A),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF6B9B6A).withOpacity(value.abs() * 0.5),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ],
              ),
              transform: Matrix4.identity()
                ..scale(0.7 + (value.abs() * 0.5)),
            );
          },
        );
      }),
    );
  }
}

