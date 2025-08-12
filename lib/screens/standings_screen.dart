import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/f1_api_service.dart';
import '../models/driver.dart';
import 'dart:math' as math;

class StandingsScreen extends StatefulWidget {
  const StandingsScreen({super.key});

  @override
  State<StandingsScreen> createState() => _StandingsScreenState();
}

class _StandingsScreenState extends State<StandingsScreen>
    with TickerProviderStateMixin {
  final F1ApiService _apiService = F1ApiService();
  List<Driver> _standings = [];
  bool _isLoading = true;
  String? _error;
  
  late AnimationController _floatingController;
  late AnimationController _chartController;
  late AnimationController _counterController;
  late Animation<Offset> _floatingAnimation;

  @override
  void initState() {
    super.initState();
    
    _floatingController = AnimationController(
      duration: const Duration(seconds: 10), // Much slower floating
      vsync: this,
    )..repeat(reverse: true);
    
    _floatingAnimation = Tween<Offset>(
      begin: const Offset(0, -0.05), // Gentler movement
      end: const Offset(0, 0.05),
    ).animate(CurvedAnimation(
      parent: _floatingController,
      curve: Curves.easeInOut,
    ));
    
    _chartController = AnimationController(
      duration: const Duration(milliseconds: 3000), // Slower chart animation
      vsync: this,
    );
    
    _counterController = AnimationController(
      duration: const Duration(milliseconds: 2500), // Smoother counting
      vsync: this,
    );
    
    _loadStandings();
  }
  
  @override
  void dispose() {
    _floatingController.dispose();
    _chartController.dispose();
    _counterController.dispose();
    super.dispose();
  }

  Future<void> _loadStandings() async {
    try {
      if (mounted) {
        setState(() {
          _isLoading = true;
          _error = null;
        });
      }
      
      final standings = await _apiService.getDriverStandings();
      
      if (mounted) {
        setState(() {
          _standings = standings;
          _isLoading = false;
        });
        
        // Start animations after data loads
        await Future.delayed(const Duration(milliseconds: 300));
        if (mounted) _chartController.forward();
        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) _counterController.forward();
      }
      
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topLeft,
            radius: 2.0,
            colors: [
              Color(0xFF1A1A2E),
              Color(0xFF16213E),
              Color(0xFF0F0F23),
              Color(0xFF000000),
            ],
          ),
        ),
        child: Stack(
          children: [
            // Floating particles background
            AnimatedBuilder(
              animation: _floatingAnimation,
              builder: (context, child) {
                return CustomPaint(
                  painter: FloatingParticlesPainter(_floatingAnimation.value),
                  size: Size.infinite,
                );
              },
            ),
            
            // Main content
            SafeArea(
              child: Column(
                children: [
                  _buildHeader(),
                  Expanded(
                    child: _isLoading
                        ? _buildLoadingState()
                        : _error != null
                            ? _buildErrorState()
                            : _buildStandingsContent(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(25),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF34C759), Color(0xFF30D158)],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF34C759).withOpacity(0.5),
                  blurRadius: 30,
                  spreadRadius: 10,
                ),
              ],
            ),
            child: const Icon(
              Icons.leaderboard,
              color: Colors.white,
              size: 30,
            ),
          ),
          const SizedBox(width: 20),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Championship',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.3,
                    
                  ),
                ),
                Text(
                  'Standings',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    letterSpacing: -0.1,
                    
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    )
      .animate()
      .fadeIn(duration: 800.ms)
      .slideY(begin: -0.3);
  }
  
  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF34C759), Color(0xFF30D158)],
              ),
              borderRadius: BorderRadius.circular(25),
            ),
            child: const Center(
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 3,
              ),
            ),
          )
            .animate(onPlay: (controller) => controller.repeat())
            .rotate(duration: 2000.ms),
          
          const SizedBox(height: 30),
          
          const Text(
            'Loading Championship Data...',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.2,
              
            ),
          )
            .animate()
            .fadeIn(delay: 500.ms)
            .shimmer(duration: 2000.ms, color: Colors.white),
        ],
      ),
    );
  }
  
  Widget _buildErrorState() {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(30),
        padding: const EdgeInsets.all(30),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.red.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 60,
            ),
            const SizedBox(height: 20),
            const Text(
              'Error Loading Data',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.2,
                
              ),
            ),
            const SizedBox(height: 10),
            Text(
              _error ?? 'Unknown error occurred',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 14,
                
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 25),
            ElevatedButton.icon(
              onPressed: _loadStandings,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF34C759),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildStandingsContent() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          _buildChampionshipChart(),
          const SizedBox(height: 30),
          _buildStandingsList(),
          const SizedBox(height: 100),
        ],
      ),
    );
  }
  
  Widget _buildChampionshipChart() {
    if (_standings.isEmpty) return const SizedBox();
    
    final topDrivers = _standings.take(5).toList();
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24), // Improved margins
      child: GlassmorphicContainer(
        width: double.infinity,
        height: 280,
        borderRadius: 28, // Slightly more rounded
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
            const Color(0xFF34C759).withOpacity(0.6),
            const Color(0xFF30D158).withOpacity(0.4),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(28), // Better padding
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Top 5 Championship Battle',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: topDrivers.first.points.toDouble() * 1.2,
                    barTouchData: BarTouchData(enabled: false),
                    titlesData: FlTitlesData(
                      show: true,
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (double value, TitleMeta meta) {
                            if (value.toInt() < topDrivers.length) {
                              return Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  topDrivers[value.toInt()].code ?? '',
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    
                                  ),
                                ),
                              );
                            }
                            return const Text('');
                          },
                        ),
                      ),
                      leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    borderData: FlBorderData(show: false),
                    gridData: const FlGridData(show: false),
                    barGroups: List.generate(
                      topDrivers.length,
                      (index) => BarChartGroupData(
                        x: index,
                        barRods: [
                          BarChartRodData(
                            toY: topDrivers[index].points.toDouble(),
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                                const Color(0xFF34C759).withOpacity(0.8),
                                const Color(0xFF30D158),
                              ],
                            ),
                            width: 30,
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
                  .animate(controller: _chartController)
                  .scaleY(begin: 0, duration: 1000.ms, curve: Curves.elasticOut),
              ),
            ],
          ),
        ),
      ),
    )
      .animate()
      .fadeIn(delay: 300.ms, duration: 800.ms)
      .slideY(begin: 0.3);
  }
  
  Widget _buildStandingsList() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24), // Improved margins
      child: Column(
        children: List.generate(
          _standings.length,
          (index) => _buildDriverCard(_standings[index], index + 1)
            .animate(delay: ((index + 1) * 100).ms)
            .slideX(begin: 1, duration: 600.ms, curve: Curves.easeOutBack)
            .fadeIn(),
        ),
      ),
    );
  }
  
  Widget _buildDriverCard(Driver driver, int position) {
    Color positionColor = position == 1
        ? const Color(0xFFFFD700)
        : position == 2
            ? const Color(0xFFC0C0C0)
            : position == 3
                ? const Color(0xFFCD7F32)
                : const Color(0xFF007AFF);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 18), // Better spacing
      child: GlassmorphicContainer(
        width: double.infinity,
        height: 105, // Slightly taller
        borderRadius: 24, // More rounded
        blur: 15,
        alignment: Alignment.center,
        border: 2,
        linearGradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(position <= 3 ? 0.2 : 0.1),
            Colors.white.withOpacity(0.05),
          ],
        ),
        borderGradient: LinearGradient(
          colors: [
            positionColor.withOpacity(0.6),
            positionColor.withOpacity(0.2),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(24), // Better internal padding
          child: Row(
            children: [
              // Position indicator
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [positionColor, positionColor.withOpacity(0.7)],
                  ),
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: positionColor.withOpacity(0.4),
                      blurRadius: 15,
                      spreadRadius: 3,
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    '$position',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      
                    ),
                  ),
                ),
              ),
              
              const SizedBox(width: 20),
              
              // Driver info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${driver.givenName} ${driver.familyName}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.2,
                        
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      driver.constructor,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        
                      ),
                    ),
                  ],
                ),
              ),
              
              // Animated points counter
              AnimatedBuilder(
                animation: _counterController,
                builder: (context, child) {
                  final animatedPoints = (driver.points * _counterController.value).round();
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '$animatedPoints',
                        style: TextStyle(
                          color: positionColor,
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          
                        ),
                      ),
                      Text(
                        'POINTS',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                          fontSize: 10,
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
        ),
      ),
    );
  }
}

class FloatingParticlesPainter extends CustomPainter {
  final Offset animationValue;
  
  FloatingParticlesPainter(this.animationValue);
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF34C759).withOpacity(0.1)
      ..style = PaintingStyle.fill;
    
    final random = math.Random(42);
    
    for (int i = 0; i < 25; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final radius = (random.nextDouble() * 3 + 1);
      
      final offsetY = animationValue.dy * 30;
      final offsetX = math.sin(i * 0.5) * animationValue.dx * 20;
      
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
