import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
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
      duration: const Duration(milliseconds: 2800), // Faster, smoother
      vsync: this,
    );
    
    _particleController = AnimationController(
      duration: const Duration(milliseconds: 3200), // Optimized particles
      vsync: this,
    );
    
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1400), // Snappier logo
      vsync: this,
    );
    
    _startAnimation();
  }
  
  void _startAnimation() async {
    // Immediate start for responsive feel
    _logoController.forward();
    
    await Future.delayed(const Duration(milliseconds: 400));
    _particleController.forward();
    
    await Future.delayed(const Duration(milliseconds: 300));
    _carController.forward();
    
    await Future.delayed(const Duration(seconds: 4));
    if (mounted) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const HomeScreen(),
          transitionDuration: const Duration(milliseconds: 1000),
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
            gradient: RadialGradient(
              center: Alignment.center,
              radius: 1.2, // Tighter gradient for better performance
              colors: [
                Color(0xFF111111),
                Color(0xFF000000),
              ],
            ),
          ),
          child: Stack(
            children: [
              // Optimized particles background
              RepaintBoundary(
                child: AnimatedBuilder(
                  animation: _particleController,
                  builder: (context, child) {
                    return CustomPaint(
                      painter: ParticlePainter(_particleController.value),
                      size: Size.infinite,
                      willChange: true, // Hint for GPU acceleration
                    );
                  },
                ),
              ),
              
              // Racing stripes with better performance
              RepaintBoundary(child: _buildRacingStripes()),
              
              // Main content with optimized rendering
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // F1 Car Animation with GPU optimization
                    RepaintBoundary(
                      child: AnimatedBuilder(
                        animation: _carController,
                        builder: (context, child) {
                          return Transform.translate(
                            offset: Offset(
                              (MediaQuery.of(context).size.width + 200) * 
                              (1 - Curves.easeInOutCubic.transform(_carController.value)) - 100,
                              0,
                            ),
                            child: Transform.rotate(
                              angle: math.sin(_carController.value * math.pi * 4) * 0.1,
                              child: Container(
                                width: 120,
                                height: 60,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFFE10600), Color(0xFFFF6B47)],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFFE10600).withOpacity(0.5),
                                      blurRadius: 20,
                                      spreadRadius: 5,
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.sports_motorsports,
                                  color: Colors.white,
                                  size: 40,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  
                  const SizedBox(height: 60),
                  
                  // Animated Logo
                  ScaleTransition(
                    scale: CurvedAnimation(
                      parent: _logoController,
                      curve: Curves.elasticOut,
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFE10600), Color(0xFFFF6B47)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFE10600).withOpacity(0.3),
                            blurRadius: 30,
                            spreadRadius: 10,
                          ),
                        ],
                      ),
                      child: const Text(
                        'F1',
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 4,
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 30),
                  
                  // Animated text
                  AnimatedTextKit(
                    animatedTexts: [
                      TypewriterAnimatedText(
                        'STRATEGY HUB',
                        textStyle: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 8,
                        ),
                        speed: const Duration(milliseconds: 100),
                      ),
                    ],
                    totalRepeatCount: 1,
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Subtitle with glow effect
                  Text(
                    'Race • Analyze • Dominate',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.7),
                      letterSpacing: 2,
                    ),
                  )
                    .animate(delay: 2000.ms)
                    .fadeIn(duration: 1000.ms)
                    .shimmer(duration: 2000.ms, color: const Color(0xFFE10600)),
                ],
              ),
            ),
            
            // Loading indicator
            Positioned(
              bottom: 80,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  width: 200,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: AnimatedBuilder(
                    animation: _carController,
                    builder: (context, child) {
                      return FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: _carController.value,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFE10600), Color(0xFFFF6B47)],
                            ),
                            borderRadius: BorderRadius.circular(2),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFE10600).withOpacity(0.5),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
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
  
  Widget _buildRacingStripes() {
    return Positioned.fill(
      child: AnimatedBuilder(
        animation: _carController,
        builder: (context, child) {
          return CustomPaint(
            painter: RacingStripesPainter(_carController.value),
            size: Size.infinite,
          );
        },
      ),
    );
  }
}

class ParticlePainter extends CustomPainter {
  final double animationValue;
  
  ParticlePainter(this.animationValue);
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFE10600).withOpacity(0.3)
      ..style = PaintingStyle.fill;
    
    final random = math.Random(42); // Fixed seed for consistent animation
    
    for (int i = 0; i < 50; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final radius = (random.nextDouble() * 3 + 1) * animationValue;
      
      final offset = math.sin(animationValue * math.pi * 2 + i) * 20;
      
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
      ..color = const Color(0xFFE10600).withOpacity(0.1)
      ..style = PaintingStyle.fill;
    
    final stripeWidth = 4.0;
    final stripeSpacing = 20.0;
    
    for (double i = -size.width; i < size.width * 2; i += stripeSpacing) {
      final path = Path();
      final offset = (animationValue * 100) % stripeSpacing;
      
      path.moveTo(i + offset, 0);
      path.lineTo(i + offset + size.height, size.height);
      path.lineTo(i + offset + size.height + stripeWidth, size.height);
      path.lineTo(i + offset + stripeWidth, 0);
      path.close();
      
      canvas.drawPath(path, paint);
    }
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
