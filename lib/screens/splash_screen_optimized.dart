import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'dart:math' as math;
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _carController;
  late AnimationController _particleController;
  late AnimationController _logoController;
  
  @override
  void initState() {
    super.initState();
    
    // Ultra-smooth, performance-optimized timing
    _carController = AnimationController(
      duration: const Duration(milliseconds: 2200), // Faster, smoother
      vsync: this,
    );
    
    _particleController = AnimationController(
      duration: const Duration(milliseconds: 2800), // Optimized particles
      vsync: this,
    );
    
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1200), // Snappier logo
      vsync: this,
    );
    
    _startAnimation();
  }
  
  void _startAnimation() async {
    // Immediate start for responsive feel
    _logoController.forward();
    
    await Future.delayed(const Duration(milliseconds: 300));
    _particleController.forward();
    
    await Future.delayed(const Duration(milliseconds: 200));
    _carController.forward();
    
    await Future.delayed(const Duration(milliseconds: 1800));
    
    if (mounted) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) {
            return const HomeScreen();
          },
          transitionDuration: const Duration(milliseconds: 600),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1.0, 0.0),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeInOutCubic,
              )),
              child: child,
            );
          },
        ),
      );
    }
  }
  
  @override
  void dispose() {
    _carController.dispose();
    _particleController.dispose();
    _logoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RepaintBoundary( // Performance optimization
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF1A1A1A),
                Color(0xFF000000),
                Color(0xFF1A1A1A),
              ],
              stops: [0.0, 0.5, 1.0],
            ),
          ),
          child: Stack(
            children: [
              // Enhanced background with multiple layers
              _buildEnhancedBackground(),
              
              // Main content with stunning effects
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Epic F1 Car Animation with trails
                    RepaintBoundary(
                      child: AnimatedBuilder(
                        animation: _carController,
                        builder: (context, child) {
                          return Stack(
                            alignment: Alignment.center,
                            children: [
                              // Speed trail effect
                              ...List.generate(5, (index) {
                                return Transform.translate(
                                  offset: Offset(
                                    (MediaQuery.of(context).size.width + 200) * 
                                    (1 - Curves.easeInOutCubic.transform(_carController.value)) - 100 - (index * 20),
                                    0,
                                  ),
                                  child: Opacity(
                                    opacity: (1.0 - (index * 0.2)) * _carController.value,
                                    child: Container(
                                      width: 110 - (index * 10),
                                      height: 55 - (index * 5),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            Color(0xFFE10600).withOpacity(0.8 - (index * 0.2)),
                                            Color(0xFFFF4444).withOpacity(0.4 - (index * 0.1)),
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                    ),
                                  ),
                                );
                              }),
                              
                              // Main car with enhanced effects
                              Transform.translate(
                                offset: Offset(
                                  (MediaQuery.of(context).size.width + 200) * 
                                  (1 - Curves.easeInOutCubic.transform(_carController.value)) - 100,
                                  math.sin(_carController.value * math.pi * 4) * 8,
                                ),
                                child: Transform.rotate(
                                  angle: math.sin(_carController.value * math.pi * 3) * 0.05,
                                  child: Container(
                                    width: 110,
                                    height: 55,
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [
                                          Color(0xFFE10600),
                                          Color(0xFFFF4444),
                                          Color(0xFFFFAB40),
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      borderRadius: BorderRadius.circular(6),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(0xFFE10600).withOpacity(0.6),
                                          blurRadius: 20,
                                          spreadRadius: 5,
                                        ),
                                        BoxShadow(
                                          color: const Color(0xFFFFAB40).withOpacity(0.4),
                                          blurRadius: 30,
                                          spreadRadius: 10,
                                        ),
                                      ],
                                    ),
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        // Pulsing inner glow
                                        Container(
                                          decoration: BoxDecoration(
                                            gradient: RadialGradient(
                                              colors: [
                                                Colors.white.withOpacity(0.3),
                                                Colors.transparent,
                                              ],
                                            ),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                        ),
                                        const Icon(
                                          Icons.sports_motorsports,
                                          color: Colors.white,
                                          size: 36,
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
                    ),
                    
                    const SizedBox(height: 50),
                    
                    // Optimized Logo Animation
                    RepaintBoundary(
                      child: ScaleTransition(
                        scale: CurvedAnimation(
                          parent: _logoController,
                          curve: Curves.easeOutBack,
                        ),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFE10600), Color(0xFFFF4444)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(2), // Sharp corners for crisp look
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFE10600).withOpacity(0.3),
                                blurRadius: 12,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: const Text(
                            'F1 STRATEGY HUB',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 30),
                    
                    // Smooth Loading Animation
                    RepaintBoundary(
                      child: FadeTransition(
                        opacity: _logoController,
                        child: SizedBox(
                          width: 200,
                          child: AnimatedTextKit(
                            animatedTexts: [
                              TyperAnimatedText(
                                'ANALYZING RACE DATA...',
                                textStyle: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                  letterSpacing: 1.2,
                                ),
                                speed: const Duration(milliseconds: 80),
                              ),
                            ],
                            totalRepeatCount: 1,
                            displayFullTextOnTap: false,
                          ),
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
  
  Widget _buildEnhancedBackground() {
    return Stack(
      children: [
        // Animated geometric patterns
        RepaintBoundary(
          child: AnimatedBuilder(
            animation: _particleController,
            builder: (context, child) {
              return CustomPaint(
                painter: GeometricPatternPainter(_particleController.value),
                size: Size.infinite,
                willChange: true,
              );
            },
          ),
        ),
        
        // Enhanced particle system
        RepaintBoundary(
          child: AnimatedBuilder(
            animation: _particleController,
            builder: (context, child) {
              return CustomPaint(
                painter: EnhancedParticlePainter(_particleController.value),
                size: Size.infinite,
                willChange: true,
              );
            },
          ),
        ),
        
        // Dynamic racing stripes
        RepaintBoundary(
          child: AnimatedBuilder(
            animation: _carController,
            builder: (context, child) {
              return CustomPaint(
                painter: DynamicRacingStripesPainter(_carController.value),
                size: Size.infinite,
                willChange: true,
              );
            },
          ),
        ),
      ],
    );
}

class ParticlePainter extends CustomPainter {
  final double animationValue;
  
  ParticlePainter(this.animationValue);
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFE10600).withOpacity(0.2)
      ..style = PaintingStyle.fill;
    
    final random = math.Random(42); // Fixed seed for consistent animation
    
    // Reduced particle count for better performance
    for (int i = 0; i < 30; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final radius = (random.nextDouble() * 2 + 0.5) * animationValue;
      
      final offset = math.sin(animationValue * math.pi * 1.5 + i) * 15;
      
      canvas.drawCircle(
        Offset(x + offset, y),
        radius,
        paint,
      );
    }
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class RacingStripesPainter extends CustomPainter {
  final double animationValue;
  
  RacingStripesPainter(this.animationValue);
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFE10600).withOpacity(0.08)
      ..style = PaintingStyle.fill;
    
    final stripeWidth = 3.0;
    final stripeSpacing = 25.0;
    
    // Reduced stripe count for performance
    for (double i = -size.width; i < size.width * 1.5; i += stripeSpacing) {
      final path = Path();
      final offset = (animationValue * 80) % stripeSpacing;
      
      path.moveTo(i + offset, 0);
      path.lineTo(i + offset + size.height * 0.8, size.height);
      path.lineTo(i + offset + size.height * 0.8 + stripeWidth, size.height);
      path.lineTo(i + offset + stripeWidth, 0);
      path.close();
      
      canvas.drawPath(path, paint);
    }
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Enhanced geometric pattern painter
class GeometricPatternPainter extends CustomPainter {
  final double animationValue;
  
  GeometricPatternPainter(this.animationValue);
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    
    // Animated hexagon pattern
    for (int i = 0; i < 8; i++) {
      final centerX = (size.width / 4) + (i % 4) * (size.width / 4);
      final centerY = (size.height / 3) + (i ~/ 4) * (size.height / 3);
      final radius = 30 + math.sin(animationValue * math.pi * 2 + i) * 10;
      
      paint.color = Color.lerp(
        const Color(0xFFE10600),
        const Color(0xFFFFAB40),
        (math.sin(animationValue * math.pi + i) + 1) / 2,
      )!.withOpacity(0.3);
      
      _drawHexagon(canvas, Offset(centerX, centerY), radius, paint);
    }
  }
  
  void _drawHexagon(Canvas canvas, Offset center, double radius, Paint paint) {
    final path = Path();
    for (int i = 0; i < 6; i++) {
      final angle = (i * math.pi) / 3;
      final x = center.dx + radius * math.cos(angle);
      final y = center.dy + radius * math.sin(angle);
      
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Enhanced particle system
class EnhancedParticlePainter extends CustomPainter {
  final double animationValue;
  
  EnhancedParticlePainter(this.animationValue);
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    
    final random = math.Random(123);
    
    // Multiple particle systems
    for (int layer = 0; layer < 3; layer++) {
      final layerOpacity = 0.4 - (layer * 0.1);
      final layerSize = 1.0 - (layer * 0.3);
      
      for (int i = 0; i < 20; i++) {
        final x = random.nextDouble() * size.width;
        final y = random.nextDouble() * size.height;
        final radius = (random.nextDouble() * 4 + 1) * layerSize;
        
        final offset = math.sin(animationValue * math.pi * (2 + layer) + i) * (30 - layer * 10);
        final colorLerp = (math.sin(animationValue * math.pi * 2 + i + layer) + 1) / 2;
        
        paint.color = Color.lerp(
          const Color(0xFFE10600),
          const Color(0xFFFFAB40),
          colorLerp,
        )!.withOpacity(layerOpacity);
        
        canvas.drawCircle(
          Offset(x + offset, y + math.sin(animationValue * math.pi + i) * 15),
          radius * animationValue,
          paint,
        );
      }
    }
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Dynamic racing stripes with speed effect
class DynamicRacingStripesPainter extends CustomPainter {
  final double animationValue;
  
  DynamicRacingStripesPainter(this.animationValue);
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    
    // Multiple stripe layers for depth
    for (int layer = 0; layer < 3; layer++) {
      final stripeWidth = 4.0 - (layer * 1.0);
      final stripeSpacing = 30.0 + (layer * 10);
      final speed = 100 + (layer * 50);
      final opacity = 0.15 - (layer * 0.05);
      
      paint.color = Color.lerp(
        const Color(0xFFE10600),
        const Color(0xFFFF6B47),
        layer / 2,
      )!.withOpacity(opacity);
      
      for (double i = -size.width; i < size.width * 2; i += stripeSpacing) {
        final path = Path();
        final offset = (animationValue * speed) % stripeSpacing;
        final skew = size.height * 0.6;
        
        path.moveTo(i + offset, 0);
        path.lineTo(i + offset + skew, size.height);
        path.lineTo(i + offset + skew + stripeWidth, size.height);
        path.lineTo(i + offset + stripeWidth, 0);
        path.close();
        
        canvas.drawPath(path, paint);
      }
    }
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
