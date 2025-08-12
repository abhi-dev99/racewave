import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import '../services/f1_api_service.dart';
import '../services/notification_service.dart';
import '../models/driver.dart';
import '../models/race.dart';
import 'dart:math' as math;

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with TickerProviderStateMixin {
  final F1ApiService _apiService = F1ApiService();
  late AnimationController _rotationController;
  late AnimationController _pulseController;
  late AnimationController _counterController;
  
  List<Driver> _standings = [];
  List<Race> _upcomingRaces = [];

  @override
  void initState() {
    super.initState();
    
    // Softer, iOS-style animations
    _rotationController = AnimationController(
      duration: const Duration(seconds: 12), // Much slower rotation
      vsync: this,
    )..repeat();
    
    _pulseController = AnimationController(
      duration: const Duration(seconds: 4), // Gentler pulse
      vsync: this,
    )..repeat(reverse: true);
    
    _counterController = AnimationController(
      duration: const Duration(milliseconds: 3000), // Smoother counting
      vsync: this,
    );
    
    _loadData();
  }
  
  @override
  void dispose() {
    _rotationController.dispose();
    _pulseController.dispose();
    _counterController.dispose();
    super.dispose();
  }
  
  Future<void> _loadData() async {
    try {
      final standings = await _apiService.getDriverStandings();
      final races = await _apiService.getCurrentRaces();
      
      setState(() {
        _standings = standings.take(3).toList();
        _upcomingRaces = races.take(3).toList();
      });
      
      _counterController.forward();
      
      // Show sample notifications after data loads
      Future.delayed(const Duration(seconds: 2), () {
        F1NotificationService.showDataRefresh();
      });
      
      Future.delayed(const Duration(seconds: 5), () {
        if (_standings.isNotEmpty) {
          F1NotificationService.showChampionshipUpdate(
            '${_standings[0].givenName} ${_standings[0].familyName}',
            _standings[0].points,
          );
        }
      });
      
      Future.delayed(const Duration(seconds: 8), () {
        if (_upcomingRaces.isNotEmpty) {
          F1NotificationService.showRaceUpdate(_upcomingRaces[0].raceName);
        }
      });
      
      Future.delayed(const Duration(seconds: 12), () {
        F1NotificationService.showStrategyTip();
      });
    } catch (e) {
      print('Welcome screen load error: $e');
      // Handle error silently, sample data will be used
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.topCenter,
          radius: 2.0,
          colors: [
            Color(0xFF1A1A2E),
            Color(0xFF16213E),
            Color(0xFF0F0F23),
            Color(0xFF000000),
          ],
        ),
      ),
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildWelcomeHeader(),
          SliverToBoxAdapter(
            child: Column(
              children: [
                _buildChampionshipPreview(),
                const SizedBox(height: 20),
                _buildUpcomingRacesPreview(),
                const SizedBox(height: 20),
                _buildQuickStats(),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildWelcomeHeader() {
    return SliverAppBar.large(
      expandedHeight: 300,
      floating: false,
      pinned: false,
      backgroundColor: Colors.transparent,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFE10600),
                Color(0xFFFF6B47),
                Color(0xFFFF8E72),
                Color(0xFFFFA500),
              ],
            ),
          ),
          child: Stack(
            children: [
              // Animated background particles
              AnimatedBuilder(
                animation: _rotationController,
                builder: (context, child) {
                  return CustomPaint(
                    painter: WelcomeParticlesPainter(_rotationController.value),
                    size: Size.infinite,
                  );
                },
              ),
              
              // Main content
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40), // Reduced from 60
                    
                    // Animated F1 logo
                    AnimatedBuilder(
                      animation: _pulseController,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: 1.0 + (_pulseController.value * 0.1),
                          child: Container(
                            width: 100, // Reduced from 120
                            height: 100, // Reduced from 120
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.white.withOpacity(0.9),
                                  Colors.white.withOpacity(0.7),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.white.withOpacity(0.3),
                                  blurRadius: 30,
                                  spreadRadius: 10,
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                'F1',
                                style: TextStyle(
                                  
                                  fontSize: 48,
                                  fontWeight: FontWeight.w900,
                                  color: const Color(0xFFE10600),
                                  letterSpacing: 2,
                                  shadows: [
                                    Shadow(
                                      color: const Color(0xFFE10600).withOpacity(0.3),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    
                    const SizedBox(height: 20), // Reduced from 30
                    
                    // Animated welcome text
                    AnimatedTextKit(
                      animatedTexts: [
                        TypewriterAnimatedText(
                          'WELCOME TO',
                          textStyle: const TextStyle(
                            
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 2,
                          ),
                          speed: const Duration(milliseconds: 200), // Slower typing
                        ),
                      ],
                      totalRepeatCount: 1,
                    ),
                    
                    const SizedBox(height: 8), // Reduced from 10
                    
                    const Text(
                      'STRATEGY HUB',
                      style: TextStyle(
                        
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 3,
                      ),
                    )
                      .animate()
                      .fadeIn(delay: 2500.ms, duration: 1500.ms) // Softer timing
                      .shimmer(duration: 3000.ms, color: Colors.white),
                    
                    const SizedBox(height: 12), // Reduced from 15
                    
                    Text(
                      'Your Ultimate F1 Experience',
                      style: TextStyle(
                        
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 1,
                      ),
                    )
                      .animate(delay: 4000.ms) // Much softer timing
                      .fadeIn(duration: 1500.ms)
                      .slideY(begin: 0.3),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildChampionshipPreview() {
    if (_standings.isEmpty) return const SizedBox();
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: GlassmorphicContainer(
        width: double.infinity,
        height: 200,
        borderRadius: 25,
        blur: 20,
        alignment: Alignment.center,
        border: 2,
        linearGradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.15),
            Colors.white.withOpacity(0.05),
          ],
        ),
        borderGradient: LinearGradient(
          colors: [
            const Color(0xFFFFD700).withOpacity(0.6),
            const Color(0xFFE10600).withOpacity(0.4),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(24), // Improved padding
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                      ),
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFFD700).withOpacity(0.5),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.emoji_events,
                      color: Colors.white,
                      size: 25,
                    ),
                  ),
                  const SizedBox(width: 15),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Championship Leader',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          'Current Season Standings',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 25),
              
              Row(
                children: [
                  // Leader info
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${_standings[0].givenName} ${_standings[0].familyName}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          _standings[0].constructor,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Animated points
                  AnimatedBuilder(
                    animation: _counterController,
                    builder: (context, child) {
                      final animatedPoints = (_standings[0].points * _counterController.value).round();
                      return Column(
                        children: [
                          Text(
                            '$animatedPoints',
                            style: const TextStyle(
                              color: Color(0xFFFFD700),
                              fontSize: 32,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          Text(
                            'POINTS',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
              
              const SizedBox(height: 15),
              
              // Top 3 mini preview
              Row(
                children: [
                  for (int i = 0; i < math.min(3, _standings.length); i++)
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: i == 0 
                            ? const Color(0xFFFFD700).withOpacity(0.2)
                            : Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: i == 0 
                              ? const Color(0xFFFFD700).withOpacity(0.5)
                              : Colors.white.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(
                              '${i + 1}',
                              style: TextStyle(
                                color: i == 0 ? const Color(0xFFFFD700) : Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              _standings[i].code ?? '',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    )
      .animate()
      .fadeIn(delay: 500.ms, duration: 800.ms)
      .slideY(begin: 0.3);
  }
  
  Widget _buildUpcomingRacesPreview() {
    if (_upcomingRaces.isEmpty) return const SizedBox();
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: GlassmorphicContainer(
        width: double.infinity,
        height: 300,
        borderRadius: 25,
        blur: 20,
        alignment: Alignment.center,
        border: 2,
        linearGradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.1),
            Colors.white.withOpacity(0.05),
          ],
        ),
        borderGradient: LinearGradient(
          colors: [
            const Color(0xFFE10600).withOpacity(0.5),
            const Color(0xFFFF6B47).withOpacity(0.3),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFE10600), Color(0xFFFF6B47)],
                      ),
                      borderRadius: BorderRadius.circular(15),
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
                      size: 25,
                    ),
                  ),
                  const SizedBox(width: 15),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Upcoming Races',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          '2024 Season Calendar',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 20),
              
              Expanded(
                child: ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: math.min(3, _upcomingRaces.length),
                  itemBuilder: (context, index) {
                    final race = _upcomingRaces[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: const Color(0xFFE10600).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Text(
                                race.round,
                                style: const TextStyle(
                                  color: Color(0xFFE10600),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  race.raceName,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  '${race.circuit.location.locality}, ${race.circuit.location.country}',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.7),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            race.date.split('-').reversed.join('/'),
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    )
                      .animate(delay: ((index + 1) * 200).ms)
                      .slideX(begin: 1, duration: 600.ms)
                      .fadeIn();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    )
      .animate()
      .fadeIn(delay: 800.ms, duration: 800.ms)
      .slideY(begin: 0.3);
  }
  
  Widget _buildQuickStats() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              'Total Drivers',
              '20',
              Icons.person,
              const Color(0xFF007AFF),
              0,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: _buildStatCard(
              'Races',
              '24',
              Icons.sports_motorsports,
              const Color(0xFFFF9500),
              200,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: _buildStatCard(
              'Teams',
              '10',
              Icons.groups,
              const Color(0xFF34C759),
              400,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildStatCard(String label, String value, IconData icon, Color color, int delay) {
    return GlassmorphicContainer(
      width: double.infinity,
      height: 120,
      borderRadius: 20,
      blur: 15,
      alignment: Alignment.center,
      border: 2,
      linearGradient: LinearGradient(
        colors: [
          Colors.white.withOpacity(0.1),
          Colors.white.withOpacity(0.05),
        ],
      ),
      borderGradient: LinearGradient(
        colors: [
          color.withOpacity(0.5),
          color.withOpacity(0.2),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: color,
              size: 30,
            ),
            const SizedBox(height: 10),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w900,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    )
      .animate(delay: (1200 + delay).ms)
      .fadeIn(duration: 600.ms)
      .scale(begin: const Offset(0.8, 0.8));
  }
}

class WelcomeParticlesPainter extends CustomPainter {
  final double animationValue;
  
  WelcomeParticlesPainter(this.animationValue);
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..style = PaintingStyle.fill;
    
    final random = math.Random(42);
    
    for (int i = 0; i < 30; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final radius = (random.nextDouble() * 4 + 2);
      
      final offsetY = math.sin(animationValue * 2 * math.pi + i) * 40;
      final offsetX = math.cos(animationValue * 2 * math.pi + i) * 20;
      
      canvas.drawCircle(
        Offset(x + offsetX, y + offsetY),
        radius,
        paint,
      );
    }
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
