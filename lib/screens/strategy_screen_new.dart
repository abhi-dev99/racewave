import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:particles_flutter/particles_flutter.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math' as math;

class StrategyScreen extends StatefulWidget {
  const StrategyScreen({super.key});

  @override
  State<StrategyScreen> createState() => _StrategyScreenState();
}

class _StrategyScreenState extends State<StrategyScreen>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _pulseController;
  late AnimationController _waveController;
  late AnimationController _particleController;
  
  String _selectedTyreCompound = 'Soft';
  double _fuelLoad = 50.0;
  double _downforce = 75.0;
  bool _isSimulating = false;
  
  final List<String> _tyreCompounds = ['Soft', 'Medium', 'Hard', 'Intermediate', 'Wet'];
  final Map<String, Color> _tyreColors = {
    'Soft': const Color(0xFFFF0000),
    'Medium': const Color(0xFFFFFF00),
    'Hard': const Color(0xFFFFFFFF),
    'Intermediate': const Color(0xFF00FF00),
    'Wet': const Color(0xFF0000FF),
  };

  @override
  void initState() {
    super.initState();
    
    _rotationController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat();
    
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    
    _waveController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();
    
    _particleController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat();
  }
  
  @override
  void dispose() {
    _rotationController.dispose();
    _pulseController.dispose();
    _waveController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.5,
            colors: [
              Color(0xFF0F0F23),
              Color(0xFF1A1A2E),
              Color(0xFF16213E),
              Color(0xFF000000),
            ],
          ),
        ),
        child: Stack(
          children: [
            // Particle effects background
            CircularParticle(
              awayRadius: 80,
              numberOfParticles: 200,
              speedOfParticles: 1,
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              onTapAnimation: true,
              particleColor: Colors.white.withOpacity(0.1),
              awayAnimationDuration: const Duration(milliseconds: 600),
              maxParticleSize: 8,
              isRandSize: true,
              isRandomColor: true,
              randColorList: [
                const Color(0xFFE10600).withOpacity(0.3),
                const Color(0xFFFF6B47).withOpacity(0.3),
                Colors.white.withOpacity(0.1),
              ],
            ),
            
            // Main content
            CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                _buildAnimatedAppBar(),
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      _buildStrategyOverview(),
                      const SizedBox(height: 20),
                      _buildTyreStrategySection(),
                      const SizedBox(height: 20),
                      _buildSetupSection(),
                      const SizedBox(height: 20),
                      _buildSimulationSection(),
                      const SizedBox(height: 20),
                      _buildPerformanceChart(),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildAnimatedAppBar() {
    return SliverAppBar.large(
      expandedHeight: 250,
      floating: false,
      pinned: true,
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
              // Animated wave effect
              AnimatedBuilder(
                animation: _waveController,
                builder: (context, child) {
                  return CustomPaint(
                    painter: WavePainter(_waveController.value),
                    size: Size.infinite,
                  );
                },
              ),
              
              // 3D rotating element
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 60),
                    
                    // Animated 3D car icon
                    AnimatedBuilder(
                      animation: _rotationController,
                      builder: (context, child) {
                        return Transform(
                          alignment: Alignment.center,
                          transform: Matrix4.identity()
                            ..setEntry(3, 2, 0.001) // perspective
                            ..rotateY(_rotationController.value * 2 * math.pi)
                            ..rotateX(math.sin(_rotationController.value * 2 * math.pi) * 0.3),
                          child: Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                              ),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFFFD700).withOpacity(0.5),
                                  blurRadius: 30,
                                  spreadRadius: 10,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.sports_motorsports,
                              color: Colors.white,
                              size: 50,
                            ),
                          ),
                        );
                      },
                    ),
                    
                    const SizedBox(height: 30),
                    
                    // Animated title
                    AnimatedBuilder(
                      animation: _pulseController,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: 1.0 + (_pulseController.value * 0.1),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.4),
                                width: 2,
                              ),
                            ),
                            child: AnimatedTextKit(
                              animatedTexts: [
                                ScaleAnimatedText(
                                  'STRATEGY CENTER',
                                  textStyle: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 3,
                                  ),
                                  duration: const Duration(milliseconds: 2000),
                                ),
                              ],
                              totalRepeatCount: 1,
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
        ),
      ),
    );
  }
  
  Widget _buildStrategyOverview() {
    return Container(
      margin: const EdgeInsets.all(20),
      child: GlassmorphicContainer(
        width: double.infinity,
        height: 180,
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
            const Color(0xFFE10600).withOpacity(0.6),
            const Color(0xFFFF6B47).withOpacity(0.4),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  AnimatedBuilder(
                    animation: _pulseController,
                    builder: (context, child) {
                      return Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            colors: [Color(0xFFE10600), Color(0xFFFF6B47)],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFE10600).withOpacity(0.5 + _pulseController.value * 0.3),
                              blurRadius: 20 + _pulseController.value * 10,
                              spreadRadius: 5 + _pulseController.value * 3,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.trending_up,
                          color: Colors.white,
                          size: 25,
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 20),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Race Strategy Optimizer',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          'AI-Powered Performance Analysis',
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
                  Expanded(child: _buildQuickStat('Lap Time', '1:23.456', Icons.timer)),
                  const SizedBox(width: 15),
                  Expanded(child: _buildQuickStat('Track Temp', '45°C', Icons.thermostat)),
                  const SizedBox(width: 15),
                  Expanded(child: _buildQuickStat('Pit Window', 'Lap 35', Icons.build)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildQuickStat(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: const Color(0xFFE10600), size: 20),
          const SizedBox(height: 5),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildTyreStrategySection() {
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
            Colors.white.withOpacity(0.3),
            Colors.white.withOpacity(0.1),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Tyre Strategy',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 20),
              
              // Tyre compound selector
              Row(
                children: _tyreCompounds.map((compound) {
                  final isSelected = compound == _selectedTyreCompound;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        setState(() {
                          _selectedTyreCompound = compound;
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: isSelected 
                            ? _tyreColors[compound]!.withOpacity(0.3)
                            : Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            color: isSelected 
                              ? _tyreColors[compound]!
                              : Colors.white.withOpacity(0.2),
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Column(
                          children: [
                            Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                color: _tyreColors[compound],
                                shape: BoxShape.circle,
                                boxShadow: isSelected ? [
                                  BoxShadow(
                                    color: _tyreColors[compound]!.withOpacity(0.5),
                                    blurRadius: 10,
                                    spreadRadius: 2,
                                  ),
                                ] : [],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              compound,
                              style: TextStyle(
                                color: isSelected ? Colors.white : Colors.white70,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                      .animate(delay: (_tyreCompounds.indexOf(compound) * 100).ms)
                      .slideY(begin: 1, duration: 400.ms)
                      .fadeIn(),
                  );
                }).toList(),
              ),
              
              const SizedBox(height: 30),
              
              // Tyre performance visualization
              Expanded(
                child: AnimatedBuilder(
                  animation: _rotationController,
                  builder: (context, child) {
                    return CustomPaint(
                      painter: TyrePerformancePainter(
                        _rotationController.value,
                        _selectedTyreCompound,
                        _tyreColors,
                      ),
                      size: Size.infinite,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildSetupSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: GlassmorphicContainer(
        width: double.infinity,
        height: 250,
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
            Colors.white.withOpacity(0.3),
            Colors.white.withOpacity(0.1),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Car Setup',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 30),
              
              // Fuel load slider
              _buildSetupSlider(
                'Fuel Load',
                '${_fuelLoad.round()}L',
                _fuelLoad,
                0,
                100,
                (value) => setState(() => _fuelLoad = value),
                Icons.local_gas_station,
              ),
              
              const SizedBox(height: 25),
              
              // Downforce slider
              _buildSetupSlider(
                'Downforce',
                '${_downforce.round()}%',
                _downforce,
                0,
                100,
                (value) => setState(() => _downforce = value),
                Icons.speed,
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildSetupSlider(
    String label,
    String value,
    double currentValue,
    double min,
    double max,
    Function(double) onChanged,
    IconData icon,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: const Color(0xFFE10600), size: 20),
            const SizedBox(width: 10),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            Text(
              value,
              style: const TextStyle(
                color: Color(0xFFE10600),
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: const Color(0xFFE10600),
            inactiveTrackColor: Colors.white.withOpacity(0.2),
            thumbColor: const Color(0xFFE10600),
            overlayColor: const Color(0xFFE10600).withOpacity(0.2),
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
          ),
          child: Slider(
            value: currentValue,
            min: min,
            max: max,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
  
  Widget _buildSimulationSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: GlassmorphicContainer(
        width: double.infinity,
        height: 150,
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
            children: [
              const Text(
                'Race Simulation',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 20),
              
              GestureDetector(
                onTap: () {
                  HapticFeedback.mediumImpact();
                  _startSimulation();
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: double.infinity,
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: _isSimulating
                        ? [Colors.grey, Colors.grey.shade700]
                        : [const Color(0xFFE10600), const Color(0xFFFF6B47)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: _isSimulating ? [] : [
                      BoxShadow(
                        color: const Color(0xFFE10600).withOpacity(0.5),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Center(
                    child: _isSimulating
                      ? const SizedBox(
                          width: 30,
                          height: 30,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 3,
                          ),
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.play_arrow,
                              color: Colors.white,
                              size: 28,
                            ),
                            SizedBox(width: 10),
                            Text(
                              'START SIMULATION',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1,
                              ),
                            ),
                          ],
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
  
  Widget _buildPerformanceChart() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: GlassmorphicContainer(
        width: double.infinity,
        height: 350,
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
            Colors.white.withOpacity(0.3),
            Colors.white.withOpacity(0.1),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Performance Analysis',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 20),
              
              Expanded(
                child: LineChart(
                  LineChartData(
                    gridData: const FlGridData(show: false),
                    titlesData: const FlTitlesData(show: false),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      LineChartBarData(
                        spots: List.generate(20, (index) {
                          return FlSpot(
                            index.toDouble(),
                            math.sin(index * 0.5) * 50 + 100 + (math.Random().nextDouble() * 20),
                          );
                        }),
                        isCurved: true,
                        gradient: const LinearGradient(
                          colors: [Color(0xFFE10600), Color(0xFFFF6B47)],
                        ),
                        barWidth: 4,
                        belowBarData: BarAreaData(
                          show: true,
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFFE10600).withOpacity(0.3),
                              const Color(0xFFFF6B47).withOpacity(0.1),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                        dotData: const FlDotData(show: false),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  void _startSimulation() async {
    setState(() {
      _isSimulating = true;
    });
    
    // Simulate processing time
    await Future.delayed(const Duration(seconds: 3));
    
    setState(() {
      _isSimulating = false;
    });
    
    // Show results
    if (mounted) {
      _showSimulationResults();
    }
  }
  
  void _showSimulationResults() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.8,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) {
          return Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF1A1A2E),
                  Color(0xFF16213E),
                  Color(0xFF0F0F23),
                ],
              ),
              borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
            ),
            child: SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.all(25),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 50,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  
                  const Text(
                    'Simulation Results',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 30),
                  
                  _buildResultCard('Optimal Lap Time', '1:19.847', Icons.timer, Colors.green),
                  const SizedBox(height: 15),
                  _buildResultCard('Fuel Efficiency', '2.8L/lap', Icons.local_gas_station, Colors.blue),
                  const SizedBox(height: 15),
                  _buildResultCard('Tyre Degradation', 'Low', Icons.circle, Colors.orange),
                  const SizedBox(height: 15),
                  _buildResultCard('Pit Strategy', '2 Stops', Icons.build, Colors.purple),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildResultCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(icon, color: color, size: 25),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class WavePainter extends CustomPainter {
  final double animationValue;
  
  WavePainter(this.animationValue);
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..style = PaintingStyle.fill;
    
    final path = Path();
    
    for (double i = 0; i <= size.width; i++) {
      final y = math.sin((i / size.width * 2 * math.pi) + (animationValue * 2 * math.pi)) * 30 + size.height * 0.7;
      if (i == 0) {
        path.moveTo(i, y);
      } else {
        path.lineTo(i, y);
      }
    }
    
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    
    canvas.drawPath(path, paint);
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class TyrePerformancePainter extends CustomPainter {
  final double animationValue;
  final String selectedCompound;
  final Map<String, Color> tyreColors;
  
  TyrePerformancePainter(this.animationValue, this.selectedCompound, this.tyreColors);
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = tyreColors[selectedCompound]!.withOpacity(0.3)
      ..style = PaintingStyle.fill;
    
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 4;
    
    // Draw performance rings
    for (int i = 0; i < 3; i++) {
      final ringRadius = radius + (i * 20) + (math.sin(animationValue * 2 * math.pi) * 5);
      paint.color = tyreColors[selectedCompound]!.withOpacity(0.2 - (i * 0.05));
      canvas.drawCircle(center, ringRadius, paint);
    }
    
    // Draw performance indicators
    final indicatorPaint = Paint()
      ..color = tyreColors[selectedCompound]!
      ..style = PaintingStyle.fill;
    
    for (int i = 0; i < 8; i++) {
      final angle = (i * math.pi / 4) + (animationValue * 2 * math.pi);
      final x = center.dx + math.cos(angle) * radius;
      final y = center.dy + math.sin(angle) * radius;
      
      canvas.drawCircle(Offset(x, y), 4, indicatorPaint);
    }
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
