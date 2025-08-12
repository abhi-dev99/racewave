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
  late AnimationController _morphController;
  
  @override
  void initState() {
    super.initState();
    
    // Ultra-smooth, performance-optimized timing
    _carController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    );
    
    _particleController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );
    
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _morphController = AnimationController(
      duration: const Duration(milliseconds: 4000),
      vsync: this,
    )..repeat();
    
    _startAnimation();
  }
  
  void _startAnimation() async {
    // Immediate start for responsive feel
    _logoController.forward();
    
    await Future.delayed(const Duration(milliseconds: 200));
    _particleController.forward();
    
    await Future.delayed(const Duration(milliseconds: 300));
    _carController.forward();
    
    await Future.delayed(const Duration(milliseconds: 2000));
    
    if (mounted) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) {
            return const HomeScreen();
          },
          transitionDuration: const Duration(milliseconds: 800),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1.0, 0.0),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeInOutCubic,
              )),
              child: FadeTransition(
                opacity: animation,
                child: child,
              ),
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
    _morphController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RepaintBoundary(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF1A1A1A),
                Color(0xFF000000),
                Color(0xFF0D0D0D),
              ],
              stops: [0.0, 0.6, 1.0],
            ),
          ),
          child: Stack(
            children: [
              // Enhanced background layers
              _buildEnhancedBackground(),
              
              // Main content
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Epic F1 Car with trail effects
                    _buildEpicCarAnimation(),
                    
                    const SizedBox(height: 60),
                    
                    // Enhanced logo with morphing effects
                    _buildEnhancedLogo(),
                    
                    const SizedBox(height: 40),
                    
                    // Stunning loading animation
                    _buildStunningLoader(),
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
        // Geometric patterns
        RepaintBoundary(
          child: AnimatedBuilder(
            animation: _morphController,
            builder: (context, child) {
              return CustomPaint(
                painter: GeometricPatternPainter(_morphController.value),
                size: Size.infinite,
              );
            },
          ),
        ),
        
        // Enhanced particles
        RepaintBoundary(
          child: AnimatedBuilder(
            animation: _particleController,
            builder: (context, child) {
              return CustomPaint(
                painter: EnhancedParticlePainter(_particleController.value),
                size: Size.infinite,
              );
            },
          ),
        ),
        
        // Dynamic speed lines
        RepaintBoundary(
          child: AnimatedBuilder(
            animation: _carController,
            builder: (context, child) {
              return CustomPaint(
                painter: SpeedLinesPainter(_carController.value),
                size: Size.infinite,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEpicCarAnimation() {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _carController,
        builder: (context, child) {
          return Stack(
            alignment: Alignment.center,
            children: [
              // Speed trail effects
              ...List.generate(6, (index) {
                final delay = index * 0.1;
                final trailOpacity = (1.0 - delay) * _carController.value;
                
                return Transform.translate(
                  offset: Offset(
                    (MediaQuery.of(context).size.width + 250) * 
                    (1 - Curves.easeInOutCubic.transform(math.max(0, _carController.value - delay))) - 125 - (index * 15),
                    math.sin((_carController.value - delay) * math.pi * 3) * (8 - index),
                  ),
                  child: Opacity(
                    opacity: trailOpacity.clamp(0.0, 1.0),
                    child: Container(
                      width: 120 - (index * 8),
                      height: 60 - (index * 4),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Color.lerp(
                              const Color(0xFFE10600),
                              const Color(0xFFFFAB40),
                              index / 6,
                            )!.withOpacity(0.8 - (index * 0.15)),
                            Colors.transparent,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                );
              }),
              
              // Main car with enhanced effects
              Transform.translate(
                offset: Offset(
                  (MediaQuery.of(context).size.width + 250) * 
                  (1 - Curves.easeInOutCubic.transform(_carController.value)) - 125,
                  math.sin(_carController.value * math.pi * 3) * 8,
                ),
                child: Transform.rotate(
                  angle: math.sin(_carController.value * math.pi * 2) * 0.05,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Outer glow
                      Container(
                        width: 140,
                        height: 70,
                        decoration: BoxDecoration(
                          gradient: RadialGradient(
                            colors: [
                              const Color(0xFFE10600).withOpacity(0.4),
                              const Color(0xFFFFAB40).withOpacity(0.2),
                              Colors.transparent,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      
                      // Main car body
                      Container(
                        width: 120,
                        height: 60,
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
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFE10600).withOpacity(0.8),
                              blurRadius: 25,
                              spreadRadius: 5,
                            ),
                            BoxShadow(
                              color: const Color(0xFFFFAB40).withOpacity(0.6),
                              blurRadius: 35,
                              spreadRadius: 8,
                            ),
                          ],
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Inner highlight
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.white.withOpacity(0.3),
                                    Colors.transparent,
                                  ],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            
                            // Car icon
                            const Icon(
                              Icons.sports_motorsports,
                              color: Colors.white,
                              size: 40,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEnhancedLogo() {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: Listenable.merge([_logoController, _morphController]),
        builder: (context, child) {
          return Stack(
            alignment: Alignment.center,
            children: [
              // Pulsing background
              Transform.scale(
                scale: 1.0 + math.sin(_morphController.value * math.pi * 2) * 0.1,
                child: Container(
                  width: 200,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      colors: [
                        const Color(0xFFE10600).withOpacity(0.3),
                        const Color(0xFFFFAB40).withOpacity(0.1),
                        Colors.transparent,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(40),
                  ),
                ),
              ),
              
              // Main logo container
              Transform.scale(
                scale: Curves.elasticOut.transform(_logoController.value),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color.lerp(
                          const Color(0xFFE10600),
                          const Color(0xFFFF6B47),
                          (math.sin(_morphController.value * math.pi * 2) + 1) / 2,
                        )!,
                        Color.lerp(
                          const Color(0xFFFF6B47),
                          const Color(0xFFFFAB40),
                          (math.sin(_morphController.value * math.pi * 2) + 1) / 2,
                        )!,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(2),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFE10600).withOpacity(0.5),
                        blurRadius: 20,
                        spreadRadius: 3,
                      ),
                    ],
                  ),
                  child: ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [Colors.white, Colors.white70],
                    ).createShader(bounds),
                    child: const Text(
                      'F1 STRATEGY HUB',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
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

  Widget _buildStunningLoader() {
    return RepaintBoundary(
      child: FadeTransition(
        opacity: _logoController,
        child: Column(
          children: [
            SizedBox(
              width: 250,
              child: AnimatedTextKit(
                animatedTexts: [
                  TyperAnimatedText(
                    'INITIALIZING RACE SYSTEMS...',
                    textStyle: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 1.5,
                    ),
                    speed: const Duration(milliseconds: 60),
                  ),
                ],
                totalRepeatCount: 1,
                displayFullTextOnTap: false,
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Custom loading indicator
            AnimatedBuilder(
              animation: _morphController,
              builder: (context, child) {
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    // Outer ring
                    Transform.rotate(
                      angle: _morphController.value * math.pi * 2,
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFFE10600).withOpacity(0.3),
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                    
                    // Inner rotating element
                    Transform.rotate(
                      angle: -_morphController.value * math.pi * 4,
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFE10600), Color(0xFFFFAB40)],
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFE10600).withOpacity(0.5),
                              blurRadius: 10,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// Custom painter for geometric patterns
class GeometricPatternPainter extends CustomPainter {
  final double animationValue;
  
  GeometricPatternPainter(this.animationValue);
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    
    // Hexagonal grid pattern
    for (int i = 0; i < 12; i++) {
      final centerX = (size.width / 6) + (i % 6) * (size.width / 6);
      final centerY = (size.height / 4) + (i ~/ 6) * (size.height / 2);
      final radius = 25 + math.sin(animationValue * math.pi * 2 + i * 0.5) * 8;
      
      final colorLerp = (math.sin(animationValue * math.pi + i) + 1) / 2;
      paint.color = Color.lerp(
        const Color(0xFFE10600),
        const Color(0xFFFFAB40),
        colorLerp,
      )!.withOpacity(0.2);
      
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
    
    final random = math.Random(456);
    
    // Multiple particle layers
    for (int layer = 0; layer < 4; layer++) {
      final layerOpacity = 0.5 - (layer * 0.1);
      final layerSpeed = 1.0 + (layer * 0.5);
      final particleCount = 15 - (layer * 2);
      
      for (int i = 0; i < particleCount; i++) {
        final x = random.nextDouble() * size.width;
        final y = random.nextDouble() * size.height;
        final radius = (random.nextDouble() * 3 + 1) * (1 - layer * 0.2);
        
        final offset = math.sin(animationValue * math.pi * layerSpeed + i) * (40 - layer * 8);
        final colorPhase = (animationValue + i * 0.1 + layer * 0.2) % 1.0;
        
        paint.color = Color.lerp(
          const Color(0xFFE10600),
          const Color(0xFFFFAB40),
          colorPhase,
        )!.withOpacity(layerOpacity * animationValue);
        
        canvas.drawCircle(
          Offset(
            x + offset,
            y + math.sin(animationValue * math.pi * layerSpeed + i + layer) * 20,
          ),
          radius * animationValue,
          paint,
        );
      }
    }
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Speed lines painter
class SpeedLinesPainter extends CustomPainter {
  final double animationValue;
  
  SpeedLinesPainter(this.animationValue);
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    
    // Multiple speed line layers
    for (int layer = 0; layer < 3; layer++) {
      final lineCount = 8 - layer * 2;
      final speed = 120 + layer * 40;
      final opacity = 0.3 - layer * 0.08;
      
      paint.strokeWidth = 3.0 - layer * 0.5;
      
      for (int i = 0; i < lineCount; i++) {
        final y = (size.height / lineCount) * i + (size.height / lineCount / 2);
        final startX = -200 + (animationValue * speed * (1 + layer * 0.2)) % (size.width + 400);
        final endX = startX + 80 + layer * 20;
        
        final colorLerp = (i / lineCount + layer * 0.3) % 1.0;
        paint.color = Color.lerp(
          const Color(0xFFE10600),
          const Color(0xFFFFAB40),
          colorLerp,
        )!.withOpacity(opacity * animationValue);
        
        canvas.drawLine(
          Offset(startX, y),
          Offset(endX, y),
          paint,
        );
      }
    }
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
