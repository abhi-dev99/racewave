import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/f1_api_service.dart';
import '../models/driver.dart';
import '../models/race.dart';
import 'f1_data_test_screen.dart';
import 'dart:math' as math;

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with TickerProviderStateMixin {
  final F1ApiService _apiService = F1ApiService();
  
  // Multiple animation controllers for complex animations
  late AnimationController _primaryController;
  late AnimationController _particleController;
  late AnimationController _speedController;
  late AnimationController _morphController;
  late AnimationController _heroController;
  
  // Animation values
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _slideAnimation;
  late Animation<Color?> _colorAnimation;
  
  List<Driver> _standings = [];
  List<Race> _upcomingRaces = [];
  bool _dataLoaded = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadData();
  }

  void _initializeAnimations() {
    // Primary animation controller for main content
    _primaryController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    // Particle system animation
    _particleController = AnimationController(
      duration: const Duration(milliseconds: 4000),
      vsync: this,
    )..repeat();
    
    // Speed lines animation
    _speedController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
    
    // Morphing shapes animation
    _morphController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    )..repeat(reverse: true);
    
    // Hero entrance animation
    _heroController = AnimationController(
      duration: const Duration(milliseconds: 1800),
      vsync: this,
    );
    
    // Initialize animation curves
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _primaryController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    ));
    
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _primaryController,
      curve: const Interval(0.2, 0.8, curve: Curves.elasticOut),
    ));
    
    _slideAnimation = Tween<double>(
      begin: 50.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _primaryController,
      curve: const Interval(0.3, 0.9, curve: Curves.easeOutCubic),
    ));
    
    _colorAnimation = ColorTween(
      begin: const Color(0xFFE10600),
      end: const Color(0xFFFF6B47),
    ).animate(CurvedAnimation(
      parent: _morphController,
      curve: Curves.easeInOut,
    ));
    
    // Start animations
    _heroController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      _primaryController.forward();
    });
  }

  void _loadData() async {
    try {
      final standings = await _apiService.getDriverStandings();
      final races = await _apiService.getCurrentRaces();
      
      if (mounted) {
        setState(() {
          _standings = standings.take(3).toList();
          _upcomingRaces = races.where((race) => 
            DateTime.parse(race.date).isAfter(DateTime.now())
          ).take(2).toList();
          _dataLoaded = true;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _dataLoaded = true;
        });
      }
    }
  }

  @override
  void dispose() {
    _primaryController.dispose();
    _particleController.dispose();
    _speedController.dispose();
    _morphController.dispose();
    _heroController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          // Animated background with particles and speed lines
          _buildAnimatedBackground(screenSize),
          
          // Main scrollable content
          SafeArea(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // Hero section with stunning graphics
                SliverToBoxAdapter(
                  child: _buildHeroSection(screenSize),
                ),
                
                // Animated stats cards
                SliverToBoxAdapter(
                  child: _buildStatsSection(),
                ),
                
                // Top drivers with animations
                SliverToBoxAdapter(
                  child: _buildTopDriversSection(),
                ),
                
                // Upcoming races
                SliverToBoxAdapter(
                  child: _buildUpcomingRacesSection(),
                ),
                
                // Bottom padding for tab bar
                const SliverToBoxAdapter(
                  child: SizedBox(height: 120),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedBackground(Size screenSize) {
    return RepaintBoundary(
      child: Stack(
        children: [
          // Moving particle system
          AnimatedBuilder(
            animation: _particleController,
            builder: (context, child) {
              return CustomPaint(
                painter: ParticleSystemPainter(
                  animationValue: _particleController.value,
                  isDark: Theme.of(context).brightness == Brightness.dark,
                ),
                size: screenSize,
              );
            },
          ),
          
          // Speed lines effect
          AnimatedBuilder(
            animation: _speedController,
            builder: (context, child) {
              return CustomPaint(
                painter: SpeedLinesPainter(
                  animationValue: _speedController.value,
                  isDark: Theme.of(context).brightness == Brightness.dark,
                ),
                size: screenSize,
              );
            },
          ),
          
          // Morphing geometric shapes
          AnimatedBuilder(
            animation: _morphController,
            builder: (context, child) {
              return CustomPaint(
                painter: MorphingShapesPainter(
                  animationValue: _morphController.value,
                  color: _colorAnimation.value ?? const Color(0xFFE10600),
                ),
                size: screenSize,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHeroSection(Size screenSize) {
    return Container(
      height: screenSize.height * 0.5,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: AnimatedBuilder(
        animation: _heroController,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, _slideAnimation.value),
            child: Transform.scale(
              scale: _scaleAnimation.value,
              child: Opacity(
                opacity: _fadeAnimation.value,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Animated F1 logo with crazy effects
                    _buildAnimatedLogo(),
                    
                    const SizedBox(height: 32),
                    
                    // Title with stunning typography
                    _buildAnimatedTitle(),
                    
                    const SizedBox(height: 16),
                    
                    // Subtitle with typewriter effect
                    _buildAnimatedSubtitle(),
                    
                    const SizedBox(height: 40),
                    
                    // Action button with morphing effects
                    _buildActionButton(),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAnimatedLogo() {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: Listenable.merge([_heroController, _morphController]),
        builder: (context, child) {
          return Stack(
            alignment: Alignment.center,
            children: [
              // Pulsing glow effect
              Container(
                width: 120 + (math.sin(_morphController.value * math.pi * 2) * 20),
                height: 120 + (math.sin(_morphController.value * math.pi * 2) * 20),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      _colorAnimation.value?.withOpacity(0.3) ?? const Color(0xFFE10600).withOpacity(0.3),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
              
              // Rotating outer ring
              Transform.rotate(
                angle: _heroController.value * math.pi * 4,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _colorAnimation.value ?? const Color(0xFFE10600),
                      width: 3,
                    ),
                    gradient: LinearGradient(
                      colors: [
                        _colorAnimation.value ?? const Color(0xFFE10600),
                        _colorAnimation.value?.withOpacity(0.5) ?? const Color(0xFFE10600).withOpacity(0.5),
                      ],
                      stops: const [0.0, 1.0],
                    ),
                  ),
                ),
              ),
              
              // Center logo with scale animation
              Transform.scale(
                scale: 1.0 + (math.sin(_morphController.value * math.pi * 2) * 0.1),
                child: Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _colorAnimation.value ?? const Color(0xFFE10600),
                    boxShadow: [
                      BoxShadow(
                        color: (_colorAnimation.value ?? const Color(0xFFE10600)).withOpacity(0.5),
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
            ],
          );
        },
      ),
    );
  }

  Widget _buildAnimatedTitle() {
    return RepaintBoundary(
      child: ShaderMask(
        shaderCallback: (bounds) => LinearGradient(
          colors: [
            _colorAnimation.value ?? const Color(0xFFE10600),
            const Color(0xFFFF6B47),
            const Color(0xFFFFAB40),
          ],
          stops: const [0.0, 0.5, 1.0],
        ).createShader(bounds),
        child: Text(
          'F1 STRATEGY HUB',
          style: Theme.of(context).textTheme.displayLarge?.copyWith(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            letterSpacing: -1.0,
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildAnimatedSubtitle() {
    return AnimatedBuilder(
      animation: _primaryController,
      builder: (context, child) {
        return Text(
          'Real-time analytics & race strategy',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Theme.of(context).textTheme.bodyMedium?.color,
            letterSpacing: 0.5,
          ),
          textAlign: TextAlign.center,
        );
      },
    );
  }

  Widget _buildActionButton() {
    return AnimatedBuilder(
      animation: _morphController,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            gradient: LinearGradient(
              colors: [
                _colorAnimation.value ?? const Color(0xFFE10600),
                const Color(0xFFFF6B47),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: (_colorAnimation.value ?? const Color(0xFFE10600)).withOpacity(0.4),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(30),
              onTap: () {
                HapticFeedback.lightImpact();
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const F1StrategyAnalysisScreen(),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.play_arrow,
                      color: Colors.white,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'F1 STRATEGY HUB',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatsSection() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: AnimatedBuilder(
        animation: _primaryController,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, _slideAnimation.value * 0.5),
            child: Opacity(
              opacity: _fadeAnimation.value,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Live Statistics',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(child: _buildStatCard('Drivers', '20', Icons.person, 0)),
                      const SizedBox(width: 12),
                      Expanded(child: _buildStatCard('Races', '24', Icons.sports_motorsports, 1)),
                      const SizedBox(width: 12),
                      Expanded(child: _buildStatCard('Teams', '10', Icons.groups, 2)),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, int index) {
    return AnimatedBuilder(
      animation: _primaryController,
      builder: (context, child) {
        final delay = index * 0.1;
        final delayedAnimation = Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(CurvedAnimation(
          parent: _primaryController,
          curve: Interval(delay, delay + 0.6, curve: Curves.elasticOut),
        ));
        
        return Transform.scale(
          scale: delayedAnimation.value,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
              ),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).shadowColor.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Icon(
                  icon,
                  color: _colorAnimation.value ?? const Color(0xFFE10600),
                  size: 32,
                ),
                const SizedBox(height: 12),
                Text(
                  value,
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    color: _colorAnimation.value ?? const Color(0xFFE10600),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTopDriversSection() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Championship Leaders',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 16),
          if (!_dataLoaded)
            _buildLoadingCard()
          else if (_standings.isEmpty)
            _buildEmptyCard('No standings data available')
          else
            ..._standings.asMap().entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildDriverCard(entry.value, entry.key + 1, entry.key),
              );
            }).toList(),
        ],
      ),
    );
  }

  Widget _buildDriverCard(Driver driver, int position, int index) {
    return AnimatedBuilder(
      animation: _primaryController,
      builder: (context, child) {
        final delay = index * 0.1;
        final delayedAnimation = Tween<double>(
          begin: 50.0,
          end: 0.0,
        ).animate(CurvedAnimation(
          parent: _primaryController,
          curve: Interval(delay, delay + 0.8, curve: Curves.easeOutCubic),
        ));
        
        return Transform.translate(
          offset: Offset(delayedAnimation.value, 0),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _getPositionColor(position),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      '$position',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        driver.fullName,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${driver.nationality} • ${driver.constructor}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${driver.points}',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: _getPositionColor(position),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'points',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildUpcomingRacesSection() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Upcoming Races',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 16),
          if (!_dataLoaded)
            _buildLoadingCard()
          else if (_upcomingRaces.isEmpty)
            _buildEmptyCard('No upcoming races available')
          else
            ..._upcomingRaces.asMap().entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildRaceCard(entry.value, entry.key),
              );
            }).toList(),
        ],
      ),
    );
  }

  Widget _buildRaceCard(Race race, int index) {
    return AnimatedBuilder(
      animation: _primaryController,
      builder: (context, child) {
        final delay = index * 0.15;
        final delayedAnimation = Tween<double>(
          begin: -50.0,
          end: 0.0,
        ).animate(CurvedAnimation(
          parent: _primaryController,
          curve: Interval(delay, delay + 0.8, curve: Curves.easeOutCubic),
        ));
        
        return Transform.translate(
          offset: Offset(delayedAnimation.value, 0),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: (_colorAnimation.value ?? const Color(0xFFE10600)).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.flag,
                    color: _colorAnimation.value ?? const Color(0xFFE10600),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        race.raceName,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        race.circuit.location.locality,
                        style: Theme.of(context).textTheme.bodyMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  _formatDate(race.date),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoadingCard() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
        ),
      ),
      child: Center(
        child: Column(
          children: [
            AnimatedBuilder(
              animation: _morphController,
              builder: (context, child) {
                return Transform.rotate(
                  angle: _morphController.value * math.pi * 2,
                  child: CircularProgressIndicator(
                    color: _colorAnimation.value ?? const Color(0xFFE10600),
                    strokeWidth: 3,
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            Text(
              'Loading F1 data...',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyCard(String message) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
        ),
      ),
      child: Center(
        child: Text(
          message,
          style: Theme.of(context).textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Color _getPositionColor(int position) {
    switch (position) {
      case 1:
        return const Color(0xFFFFD700); // Gold
      case 2:
        return const Color(0xFFC0C0C0); // Silver
      case 3:
        return const Color(0xFFCD7F32); // Bronze
      default:
        return _colorAnimation.value ?? const Color(0xFFE10600);
    }
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                     'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      return '${months[date.month - 1]} ${date.day}';
    } catch (e) {
      return dateStr;
    }
  }
}

// Custom painter for particle system
class ParticleSystemPainter extends CustomPainter {
  final double animationValue;
  final bool isDark;
  
  ParticleSystemPainter({required this.animationValue, required this.isDark});
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill;
    
    final random = math.Random(42);
    
    for (int i = 0; i < 50; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final radius = (random.nextDouble() * 3 + 1) * math.sin(animationValue * math.pi + i);
      
      final color = isDark 
          ? const Color(0xFFE10600).withOpacity(0.3)
          : const Color(0xFFE10600).withOpacity(0.1);
      
      paint.color = color;
      
      canvas.drawCircle(
        Offset(x, y + math.sin(animationValue * math.pi * 2 + i) * 20),
        radius.abs(),
        paint,
      );
    }
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Custom painter for speed lines
class SpeedLinesPainter extends CustomPainter {
  final double animationValue;
  final bool isDark;
  
  SpeedLinesPainter({required this.animationValue, required this.isDark});
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    
    final color = isDark 
        ? const Color(0xFFE10600).withOpacity(0.2)
        : const Color(0xFFE10600).withOpacity(0.1);
    
    paint.color = color;
    
    for (int i = 0; i < 10; i++) {
      final startX = -100 + (animationValue * (size.width + 200)) + (i * 50);
      final startY = 50.0 + (i * (size.height / 10));
      
      final endX = startX + 100;
      final endY = startY;
      
      canvas.drawLine(
        Offset(startX, startY),
        Offset(endX, endY),
        paint,
      );
    }
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Custom painter for morphing shapes
class MorphingShapesPainter extends CustomPainter {
  final double animationValue;
  final Color color;
  
  MorphingShapesPainter({required this.animationValue, required this.color});
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.1)
      ..style = PaintingStyle.fill;
    
    // Morphing circle
    final centerX = size.width * 0.8;
    final centerY = size.height * 0.3;
    final radius = 50 + (math.sin(animationValue * math.pi * 2) * 20);
    
    canvas.drawCircle(Offset(centerX, centerY), radius, paint);
    
    // Morphing triangle
    final path = Path();
    final triangleSize = 60 + (math.cos(animationValue * math.pi * 2) * 15);
    final triangleX = size.width * 0.2;
    final triangleY = size.height * 0.7;
    
    path.moveTo(triangleX, triangleY - triangleSize);
    path.lineTo(triangleX - triangleSize, triangleY + triangleSize);
    path.lineTo(triangleX + triangleSize, triangleY + triangleSize);
    path.close();
    
    canvas.drawPath(path, paint);
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
