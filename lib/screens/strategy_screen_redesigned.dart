import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fl_chart/fl_chart.dart';

class StrategyScreen extends StatefulWidget {
  const StrategyScreen({super.key});

  @override
  State<StrategyScreen> createState() => _StrategyScreenState();
}

class _StrategyScreenState extends State<StrategyScreen> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  // Strategy variables
  int _raceLaps = 58;
  String _selectedTire = 'Medium';
  int _pitStopLap = 25;
  double _fuelLoad = 100;
  
  final Map<String, Map<String, dynamic>> _tireData = {
    'Soft': {
      'color': const Color(0xFFFF0000),
      'degradation': 1.5,
      'lapTime': 82.5,
      'durability': 15
    },
    'Medium': {
      'color': const Color(0xFFFFD700),
      'degradation': 1.0,
      'lapTime': 83.2,
      'durability': 25
    },
    'Hard': {
      'color': const Color(0xFFEEEEEE),
      'degradation': 0.6,
      'lapTime': 84.0,
      'durability': 40
    },
  };

  List<Map<String, dynamic>> _strategyResults = [];

  @override
  void initState() {
    super.initState();
    _calculateStrategy();
  }

  void _calculateStrategy() {
    _strategyResults.clear();
    
    // Simulate race with current strategy
    final tire = _tireData[_selectedTire]!;
    double totalTime = 0;
    
    for (int lap = 1; lap <= _raceLaps; lap++) {
      double lapTime = tire['lapTime'] as double;
      
      // Add degradation
      if (lap > _pitStopLap) {
        // After pit stop - fresh tires
        lapTime += (lap - _pitStopLap) * (tire['degradation'] as double) * 0.1;
      } else {
        // Before pit stop
        lapTime += lap * (tire['degradation'] as double) * 0.1;
      }
      
      // Fuel effect (lighter = faster)
      lapTime -= (_fuelLoad / 100) * (1 - (lap / _raceLaps)) * 0.3;
      
      totalTime += lapTime;
      
      if (lap == _pitStopLap || lap % 10 == 0) {
        _strategyResults.add({
          'lap': lap,
          'lapTime': lapTime,
          'totalTime': totalTime,
          'isPitStop': lap == _pitStopLap,
        });
      }
    }
    
    // Add pit stop time
    if (_pitStopLap > 0 && _pitStopLap <= _raceLaps) {
      totalTime += 22.5; // Average pit stop time
    }
    
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF000000) : const Color(0xFFFAFAFA),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Minimal App Bar
          SliverAppBar(
            expandedHeight: 100,
            floating: false,
            pinned: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 24, bottom: 16),
              title: Text(
                'Strategy',
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black,
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -1,
                ),
              ),
            ),
          ),
          
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Race Configuration Card
                  _buildCleanCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Race Configuration',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white : Colors.black,
                          ),
                        ),
                        const SizedBox(height: 24),
                        
                        // Race Laps
                        _buildSlider(
                          label: 'Race Laps',
                          value: _raceLaps.toDouble(),
                          min: 20,
                          max: 70,
                          divisions: 50,
                          displayValue: '$_raceLaps laps',
                          onChanged: (value) {
                            setState(() {
                              _raceLaps = value.toInt();
                              if (_pitStopLap > _raceLaps) {
                                _pitStopLap = (_raceLaps * 0.4).toInt();
                              }
                            });
                            _calculateStrategy();
                          },
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Fuel Load
                        _buildSlider(
                          label: 'Starting Fuel',
                          value: _fuelLoad,
                          min: 50,
                          max: 110,
                          divisions: 60,
                          displayValue: '${_fuelLoad.toInt()}kg',
                          onChanged: (value) {
                            setState(() => _fuelLoad = value);
                            _calculateStrategy();
                          },
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Tire Selection Card
                  _buildCleanCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tire Compound',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white : Colors.black,
                          ),
                        ),
                        const SizedBox(height: 20),
                        
                        Row(
                          children: _tireData.keys.map((tire) {
                            final isSelected = tire == _selectedTire;
                            final data = _tireData[tire]!;
                            
                            return Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 4),
                                child: GestureDetector(
                                  onTap: () {
                                    HapticFeedback.selectionClick();
                                    setState(() => _selectedTire = tire);
                                    _calculateStrategy();
                                  },
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? (data['color'] as Color).withValues(alpha: 0.15)
                                          : (isDark ? const Color(0xFF111111) : const Color(0xFFF0F0F0)),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: isSelected
                                            ? (data['color'] as Color)
                                            : Colors.transparent,
                                        width: 2,
                                      ),
                                    ),
                                    child: Column(
                                      children: [
                                        Container(
                                          width: 40,
                                          height: 40,
                                          decoration: BoxDecoration(
                                            color: data['color'] as Color,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          tire,
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: isDark ? Colors.white : Colors.black,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '${data['durability']} laps',
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: isDark ? Colors.white60 : Colors.black54,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Pit Stop Strategy
                  _buildCleanCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Pit Stop Strategy',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white : Colors.black,
                          ),
                        ),
                        const SizedBox(height: 24),
                        
                        _buildSlider(
                          label: 'Pit Stop Lap',
                          value: _pitStopLap.toDouble(),
                          min: 5,
                          max: _raceLaps.toDouble() - 5,
                          divisions: (_raceLaps - 10).toInt(),
                          displayValue: 'Lap $_pitStopLap',
                          onChanged: (value) {
                            setState(() => _pitStopLap = value.toInt());
                            _calculateStrategy();
                          },
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Pit window recommendation
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF007AFF).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.lightbulb_outline,
                                color: Color(0xFF007AFF),
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Optimal window: Lap ${(_raceLaps * 0.35).toInt()}-${(_raceLaps * 0.55).toInt()}',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: isDark ? Colors.white : Colors.black87,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Results Section
                  if (_strategyResults.isNotEmpty) ...[
                    Text(
                      'Race Simulation',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : Colors.black,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Lap time chart
                    _buildCleanCard(
                      child: SizedBox(
                        height: 200,
                        child: LineChart(
                          LineChartData(
                            gridData: FlGridData(
                              show: true,
                              drawVerticalLine: false,
                              horizontalInterval: 1,
                              getDrawingHorizontalLine: (value) {
                                return FlLine(
                                  color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.05),
                                  strokeWidth: 1,
                                );
                              },
                            ),
                            titlesData: FlTitlesData(
                              show: true,
                              rightTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              topTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 30,
                                  interval: 10,
                                  getTitlesWidget: (value, meta) {
                                    return Text(
                                      value.toInt().toString(),
                                      style: TextStyle(
                                        color: isDark ? Colors.white60 : Colors.black54,
                                        fontSize: 10,
                                      ),
                                    );
                                  },
                                ),
                              ),
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 40,
                                  getTitlesWidget: (value, meta) {
                                    return Text(
                                      '${value.toInt()}s',
                                      style: TextStyle(
                                        color: isDark ? Colors.white60 : Colors.black54,
                                        fontSize: 10,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                            borderData: FlBorderData(show: false),
                            lineBarsData: [
                              LineChartBarData(
                                spots: _strategyResults.map((result) {
                                  return FlSpot(
                                    (result['lap'] as int).toDouble(),
                                    result['lapTime'] as double,
                                  );
                                }).toList(),
                                isCurved: true,
                                color: const Color(0xFF007AFF),
                                barWidth: 3,
                                isStrokeCapRound: true,
                                dotData: FlDotData(
                                  show: true,
                                  getDotPainter: (spot, percent, barData, index) {
                                    final result = _strategyResults[index];
                                    final isPitStop = result['isPitStop'] as bool;
                                    
                                    return FlDotCirclePainter(
                                      radius: isPitStop ? 6 : 3,
                                      color: isPitStop ? const Color(0xFFE10600) : const Color(0xFF007AFF),
                                      strokeWidth: isPitStop ? 2 : 0,
                                      strokeColor: Colors.white,
                                    );
                                  },
                                ),
                                belowBarData: BarAreaData(
                                  show: true,
                                  color: const Color(0xFF007AFF).withValues(alpha: 0.1),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Summary stats
                    _buildCleanCard(
                      child: Column(
                        children: [
                          _buildStatRow(
                            'Estimated Race Time',
                            _formatTime(_strategyResults.last['totalTime'] as double),
                            Icons.timer_outlined,
                          ),
                          const Divider(height: 24),
                          _buildStatRow(
                            'Pit Stop',
                            'Lap $_pitStopLap (+22.5s)',
                            Icons.build_circle_outlined,
                          ),
                          const Divider(height: 24),
                          _buildStatRow(
                            'Tire Compound',
                            _selectedTire,
                            Icons.circle,
                            iconColor: _tireData[_selectedTire]!['color'] as Color,
                          ),
                        ],
                      ),
                    ),
                  ],
                  
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCleanCard({required Widget child}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0A0A0A) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.05)
              : Colors.black.withValues(alpha: 0.05),
          width: 1,
        ),
      ),
      child: child,
    );
  }

  Widget _buildSlider({
    required String label,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required String displayValue,
    required ValueChanged<double> onChanged,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.white70 : Colors.black87,
              ),
            ),
            Text(
              displayValue,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: const Color(0xFF007AFF),
            inactiveTrackColor: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.1),
            thumbColor: const Color(0xFF007AFF),
            overlayColor: const Color(0xFF007AFF).withValues(alpha: 0.2),
            trackHeight: 4,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
          ),
          child: Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildStatRow(String label, String value, IconData icon, {Color? iconColor}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: (iconColor ?? const Color(0xFF007AFF)).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: iconColor ?? const Color(0xFF007AFF),
            size: 20,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? Colors.white60 : Colors.black54,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatTime(double seconds) {
    final minutes = (seconds / 60).floor();
    final secs = (seconds % 60).floor();
    final millis = ((seconds - seconds.floor()) * 1000).floor();
    return '${minutes}:${secs.toString().padLeft(2, '0')}.${millis.toString().padLeft(3, '0')}';
  }
}
