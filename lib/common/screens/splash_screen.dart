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
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.8, curve: Curves.elasticOut),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.8, curve: Curves.easeOut),
      ),
    );

    _controller.forward();

    // Navigate to home after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      context.router.replaceAll([const LoginRoute()]);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
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
            // Subtle texture overlay
            Positioned.fill(
              child: Opacity(
                opacity: 0.04,
                child: CustomPaint(
                  painter: TexturePainter(),
                ),
              ),
            ),

            // Ambient glow effects
            Positioned(
              top: -100,
              right: -100,
              child: Container(
                width: 400,
                height: 400,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFF6B9B6A).withOpacity(0.08),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.7],
                  ),
                ),
              ),
            ),

            Positioned(
              bottom: -80,
              left: -80,
              child: Container(
                width: 350,
                height: 350,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFFD4A853).withOpacity(0.06),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.7],
                  ),
                ),
              ),
            ),

            // Main content
            Center(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo with animation
                      ScaleTransition(
                        scale: _scaleAnimation,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Pulsing background circle
                            TweenAnimationBuilder<double>(
                              tween: Tween(begin: 0.95, end: 1.05),
                              duration: const Duration(seconds: 3),
                              curve: Curves.easeInOut,
                              builder: (context, scale, child) {
                                return Transform.scale(
                                  scale: scale,
                                  child: Container(
                                    width: 220,
                                    height: 220,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: RadialGradient(
                                        colors: [
                                          Colors.white.withOpacity(0.6),
                                          Colors.white.withOpacity(0.1),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),

                            // Main logo
                            Container(
                              width: 200,
                              height: 200,
                              decoration: BoxDecoration(
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF234F1E)
                                        .withOpacity(0.15),
                                    blurRadius: 32,
                                    offset: const Offset(0, 12),
                                  ),
                                ],
                              ),
                              child: CustomPaint(
                                painter: EcoLogoPainter(),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 48),

                      // App name
                      RichText(
                        text: const TextSpan(
                          style: TextStyle(
                            fontSize: 42,
                            fontWeight: FontWeight.w300,
                            letterSpacing: 4.8,
                            color: Color(0xFF234F1E),
                            fontFamily: 'sans-serif',
                          ),
                          children: [
                            TextSpan(text: 'Eco'),
                            TextSpan(
                              text: 'Track',
                              style: TextStyle(fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Divider line
                      TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0.0, end: 80.0),
                        duration: const Duration(milliseconds: 1000),
                        curve: Curves.easeOut,
                        builder: (context, width, child) {
                          return Container(
                            width: width,
                            height: 2,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.transparent,
                                  const Color(0xFFD4A853),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 16),

                      // Tagline
                      const Text(
                        'CONSERVATION TECHNOLOGY',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w400,
                          letterSpacing: 2.75,
                          color: Color(0xFF5C8A5A),
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Loading indicator
            Positioned(
              bottom: 80,
              left: 0,
              right: 0,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: const LoadingDots(),
              ),
            ),

            // Version
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child:  AppVersionText()
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Custom painter for the eco logo
class EcoLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;

    // GPS tracking circles
    final gpsPaint = Paint()
      ..color = const Color(0xFF234F1E).withOpacity(0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    // canvas.drawCircle(
    //   Offset(centerX, centerY),
    //   75,
    //   gpsPaint..pathEffect = const DashPathEffect([3, 5]),
    // );

    // canvas.drawCircle(
    //   Offset(centerX, centerY),
    //   88,
    //   gpsPaint
    //     ..color = const Color(0xFF6B9B6A).withOpacity(0.12)
    //     ..pathEffect = const DashPathEffect([5, 8]),
    // );

    // Tree trunk
    final trunkPaint = Paint()
      ..color = const Color(0xFF234F1E)
      ..style = PaintingStyle.fill;

    final trunkPath = Path()
      ..moveTo(centerX - 8, 130)
      ..lineTo(centerX - 8, 78)
      ..quadraticBezierTo(centerX - 8, 72, centerX, 72)
      ..quadraticBezierTo(centerX + 8, 72, centerX + 8, 78)
      ..lineTo(centerX + 8, 130)
      ..quadraticBezierTo(centerX + 8, 136, centerX, 136)
      ..quadraticBezierTo(centerX - 8, 136, centerX - 8, 130)
      ..close();

    canvas.drawPath(trunkPath, trunkPaint);

    // Tree canopy - layered circles
    final canopyPaint1 = Paint()
      ..color = const Color(0xFF6B9B6A).withOpacity(0.5);
    canvas.drawOval(
      Rect.fromCenter(center: Offset(centerX, 68), width: 84, height: 76),
      canopyPaint1,
    );

    final canopyPaint2 = Paint()
      ..color = const Color(0xFF5C8A5A).withOpacity(0.8);
    canvas.drawCircle(Offset(centerX - 22, 65), 18, canopyPaint2);
    canvas.drawCircle(Offset(centerX + 22, 65), 18, canopyPaint2);

    final canopyPaint3 = Paint()..color = const Color(0xFF5C8A5A);
    canvas.drawCircle(Offset(centerX, 55), 22, canopyPaint3);

    final canopyPaint4 = Paint()..color = const Color(0xFF6B9B6A);
    canvas.drawCircle(Offset(centerX - 10, 52), 12, canopyPaint4);
    canvas.drawCircle(Offset(centerX + 10, 52), 12, canopyPaint4);

    final canopyPaint5 = Paint()..color = const Color(0xFF234F1E);
    canvas.drawCircle(Offset(centerX, 48), 14, canopyPaint5);

    // GPS Pin
    final pinPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFFD4A853).withOpacity(0.9),
          const Color(0xFFC39643),
        ],
      ).createShader(Rect.fromLTWH(centerX - 10, centerY - 15, 20, 37));

    final pinPath = Path()
      ..moveTo(centerX, centerY - 15)
      ..quadraticBezierTo(centerX - 10, centerY - 15, centerX - 10, centerY - 5)
      ..quadraticBezierTo(centerX - 10, centerY + 8, centerX, centerY + 22)
      ..quadraticBezierTo(centerX + 10, centerY + 8, centerX + 10, centerY - 5)
      ..quadraticBezierTo(centerX + 10, centerY - 15, centerX, centerY - 15)
      ..close();

    canvas.drawPath(pinPath, pinPaint);

    // Pin center
    final pinCenterPaint1 = Paint()..color = const Color(0xFFF8F5ED);
    canvas.drawCircle(Offset(centerX, centerY - 5), 4, pinCenterPaint1);

    final pinCenterPaint2 = Paint()..color = const Color(0xFFD4A853);
    canvas.drawCircle(Offset(centerX, centerY - 5), 2.5, pinCenterPaint2);

    // Digital nodes
    final nodePaint = Paint()..color = const Color(0xFFD4A853).withOpacity(0.6);
    canvas.drawCircle(Offset(centerX - 20, centerY + 10), 2.5, nodePaint);
    canvas.drawCircle(Offset(centerX + 20, centerY + 10), 2.5, nodePaint);
    canvas.drawCircle(Offset(centerX, centerY + 28), 2.5, nodePaint);

    // Connection lines
    final linePaint = Paint()
      ..color = const Color(0xFFD4A853).withOpacity(0.3)
      ..strokeWidth = 1;

    canvas.drawLine(
        Offset(centerX - 20, centerY + 10), Offset(centerX, centerY + 20), linePaint);
    canvas.drawLine(
        Offset(centerX + 20, centerY + 10), Offset(centerX, centerY + 20), linePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Texture painter
class TexturePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xFF234F1E);

    for (double x = 0; x < size.width; x += 40) {
      for (double y = 0; y < size.height; y += 40) {
        canvas.drawCircle(Offset(x + 1, y + 1), 1, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Loading dots animation
class LoadingDots extends StatefulWidget {
  const LoadingDots({Key? key}) : super(key: key);

  @override
  State<LoadingDots> createState() => _LoadingDotsState();
}

class _LoadingDotsState extends State<LoadingDots>
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
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF6B9B6A),
              ),
              transform: Matrix4.identity()
                ..scale(0.8 + (value.abs() * 0.4)),
            );
          },
        );
      }),
    );
  }
}

// Dash path effect helper
class DashPathEffect implements PathEffect {
  final List<double> intervals;

  const DashPathEffect(this.intervals);

  @override
  Path apply(Path path) {
    final dashPath = Path();
    double distance = 0.0;
    bool draw = true;
    int index = 0;

    for (final metric in path.computeMetrics()) {
      while (distance < metric.length) {
        final length = intervals[index % intervals.length];
        if (draw) {
          dashPath.addPath(
            metric.extractPath(distance, distance + length),
            Offset.zero,
          );
        }
        distance += length;
        draw = !draw;
        index++;
      }
    }
    return dashPath;
  }
}

abstract class PathEffect {
  Path apply(Path path);
}