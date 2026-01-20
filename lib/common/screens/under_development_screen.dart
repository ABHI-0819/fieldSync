import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

@RoutePage()
class UnderDevelopmentScreen extends StatefulWidget {
  static const String route = '/under-development';
  final String? featureName;
  final String? message;
  
  const UnderDevelopmentScreen({
    super.key,
    this.featureName,
    this.message,
  });

  @override
  State<UnderDevelopmentScreen> createState() => _UnderDevelopmentScreenState();
}

class _UnderDevelopmentScreenState extends State<UnderDevelopmentScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
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

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F5ED),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF234F1E)),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Animated Icon
                        ScaleTransition(
                          scale: _scaleAnimation,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Background circle
                              Container(
                                width: 180,
                                height: 180,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: const Color(0xFF6B9B6A).withOpacity(0.1),
                                ),
                              ),
                              
                              // Rotating border
                              TweenAnimationBuilder<double>(
                                tween: Tween(begin: 0, end: 1),
                                duration: const Duration(seconds: 2),
                                builder: (context, value, child) {
                                  return Transform.rotate(
                                    angle: value * 2 * math.pi,
                                    child: Container(
                                      width: 160,
                                      height: 160,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: const Color(0xFF234F1E).withOpacity(0.2),
                                          width: 2,
                                        ),
                                      ),
                                      child: CustomPaint(
                                        painter: DashedCirclePainter(),
                                      ),
                                    ),
                                  );
                                },
                                onEnd: () {
                                  // Restart animation
                                  setState(() {});
                                },
                              ),
                              // Main icon
                              Container(
                                width: 140,
                                height: 140,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: const Color(0xFF234F1E),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF234F1E).withOpacity(0.2),
                                      blurRadius: 20,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.construction_rounded,
                                  size: 64,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 48),

                        // Title
                        Text(
                          widget.featureName ?? 'Under Development',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF234F1E),
                            letterSpacing: 0.5,
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Subtitle
                        Text(
                          widget.message ?? 
                          'We\'re working hard to bring you this feature.\nStay tuned!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: const Color(0xFF234F1E).withOpacity(0.6),
                            height: 1.6,
                            letterSpacing: 0.2,
                          ),
                        ),

                        const SizedBox(height: 40),

                        // Progress indicators
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(3, (index) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 6),
                              child: _buildProgressDot(index),
                            );
                          }),
                        ),

                        const SizedBox(height: 48),

                        // Info card
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              _buildInfoRow(
                                Icons.schedule_rounded,
                                'Coming Soon',
                                'Expected in next update',
                              ),
                              const SizedBox(height: 16),
                              _buildInfoRow(
                                Icons.notifications_active_rounded,
                                'Get Notified',
                                'We\'ll inform you when ready',
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Back button
              Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF234F1E),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'Go Back',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressDot(int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.3, end: 1.0),
      duration: const Duration(milliseconds: 1400),
      curve: Curves.easeInOut,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.scale(
            scale: 0.8 + (value * 0.4),
            child: Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF6B9B6A),
              ),
            ),
          ),
        );
      },
      onEnd: () {
        Future.delayed(Duration(milliseconds: index * 200), () {
          if (mounted) setState(() {});
        });
      },
    );
  }

  Widget _buildInfoRow(IconData icon, String title, String subtitle) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF234F1E).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: const Color(0xFF234F1E),
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF234F1E),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 14,
                  color: const Color(0xFF234F1E).withOpacity(0.6),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// Custom painter for dashed circle
class DashedCirclePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFD4A853).withOpacity(0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final radius = size.width / 2;
    final center = Offset(size.width / 2, size.height / 2);

    const dashCount = 12;
    const dashAngle = (2 * math.pi) / dashCount;

    for (int i = 0; i < dashCount; i += 2) {
      final startAngle = i * dashAngle - math.pi / 2;
      final sweepAngle = dashAngle * 0.6;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}


// ============================================
// ALTERNATIVE VERSION: Simpler Design
// ============================================

class SimpleUnderDevelopmentScreen extends StatelessWidget {
  final String? title;
  final String? message;

  const SimpleUnderDevelopmentScreen({
    Key? key,
    this.title,
    this.message,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F5ED),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF234F1E)),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF234F1E),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF234F1E).withOpacity(0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.build_circle_rounded,
                  size: 60,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 32),

              // Title
              Text(
                title ?? 'Coming Soon',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF234F1E),
                ),
              ),

              const SizedBox(height: 12),

              // Message
              Text(
                message ?? 'This feature is under development.\nWe\'ll notify you when it\'s ready!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: const Color(0xFF234F1E).withOpacity(0.6),
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 48),

              // Back button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF234F1E),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Go Back',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
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


// ============================================
// USAGE EXAMPLES
// ============================================

// Example 1: Navigate to under development screen
void navigateToUnderDevelopment(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => const UnderDevelopmentScreen(
        featureName: 'Analytics Dashboard',
        message: 'We\'re building an amazing analytics experience for you.\nCheck back soon!',
      ),
    ),
  );
}

// Example 2: Simple version
void navigateToSimpleVersion(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => const SimpleUnderDevelopmentScreen(
        title: 'Feature Coming Soon',
        message: 'This feature is currently under development.',
      ),
    ),
  );
}

// Example 3: Use as a route
// In your routing setup:
class UnderDevelopmentRoute {
  static const String routeName = '/under-development';
  
  static Route<dynamic> route({String? featureName, String? message}) {
    return MaterialPageRoute(
      builder: (_) => UnderDevelopmentScreen(
        featureName: featureName,
        message: message,
      ),
    );
  }
}