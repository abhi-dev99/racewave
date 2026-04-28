import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../services/f1_api_service.dart';
import '../models/driver.dart';

class StandingsScreenRedesigned extends StatefulWidget {
  const StandingsScreenRedesigned({super.key});

  @override
  State<StandingsScreenRedesigned> createState() => _StandingsScreenRedesignedState();
}

class _StandingsScreenRedesignedState extends State<StandingsScreenRedesigned> {
  final F1ApiService _apiService = F1ApiService();
  List<Driver> _standings = [];
  bool _isLoading = true;
  String? _error;
  String _selectedView = 'list'; // 'list' or 'chart'
  bool _isLegacyMode = false;
  String? _selectedSeason;

  @override
  void initState() {
    super.initState();
    _loadStandings();
  }

  Future<void> _loadStandings() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });
      
      final standings = await _apiService.getDriverStandings(
        season: _isLegacyMode ? _selectedSeason : null,
      );

      if (!mounted) return;
      setState(() {
        _standings = standings;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _pickLegacySeason() async {
    final currentYear = DateTime.now().year;
    final years = List<int>.generate(currentYear - 1949, (index) => currentYear - index);

    final selectedYear = await showModalBottomSheet<int>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: ListView.builder(
            itemCount: years.length,
            itemBuilder: (context, index) {
              final year = years[index];
              return ListTile(
                title: Text('$year Season'),
                trailing: _selectedSeason == '$year'
                    ? const Icon(Icons.check_rounded)
                    : null,
                onTap: () => Navigator.pop(context, year),
              );
            },
          ),
        );
      },
    );

    if (selectedYear == null) return;

    setState(() {
      _isLegacyMode = true;
      _selectedSeason = '$selectedYear';
    });
    _loadStandings();
  }

  void _switchToCurrentSeason() {
    setState(() {
      _isLegacyMode = false;
      _selectedSeason = null;
    });
    _loadStandings();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isCompact = MediaQuery.sizeOf(context).width < 430;
    
    return Scaffold(
      backgroundColor: isDark ? Colors.black : const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(isDark, isCompact),
            if (_isLoading)
              const Expanded(
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_error != null)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 48, color: Colors.red),
                      const SizedBox(height: 16),
                      Text('Error: $_error'),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: _loadStandings,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              )
            else
              Expanded(
                child: _selectedView == 'list'
                    ? _buildListView(isDark, isCompact)
                    : _buildChartView(isDark),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark, bool isCompact) {
    return Container(
      padding: EdgeInsets.all(isCompact ? 14 : 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Championship',
            style: TextStyle(
              fontSize: isCompact ? 26 : 32,
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : Colors.black,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _isLegacyMode
                ? '${_selectedSeason ?? ''} Season Standings'
                : 'Current Season Standings',
            style: TextStyle(
              fontSize: isCompact ? 12 : 14,
              color: isDark ? Colors.white.withValues(alpha: 0.6) : Colors.black.withValues(alpha: 0.6),
            ),
          ),
          SizedBox(height: isCompact ? 8 : 12),
          Row(
            children: [
              OutlinedButton.icon(
                onPressed: _pickLegacySeason,
                icon: const Icon(Icons.history_rounded, size: 16),
                label: const Text('Legacy Data'),
              ),
              const SizedBox(width: 10),
              if (_isLegacyMode)
                TextButton.icon(
                  onPressed: _switchToCurrentSeason,
                  icon: const Icon(Icons.refresh_rounded, size: 16),
                  label: const Text('Current Season'),
                ),
            ],
          ),
          SizedBox(height: isCompact ? 12 : 20),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0A0A0A) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.05)
                    : Colors.black.withValues(alpha: 0.05),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _ViewToggleButton(
                    label: 'List',
                    icon: Icons.format_list_bulleted_rounded,
                    isSelected: _selectedView == 'list',
                    isDark: isDark,
                    onTap: () => setState(() => _selectedView = 'list'),
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: _ViewToggleButton(
                    label: 'Chart',
                    icon: Icons.bar_chart_rounded,
                    isSelected: _selectedView == 'chart',
                    isDark: isDark,
                    onTap: () => setState(() => _selectedView = 'chart'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListView(bool isDark, bool isCompact) {
    return RefreshIndicator(
      onRefresh: _loadStandings,
      child: ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: isCompact ? 12 : 20),
        itemCount: _standings.length,
        itemBuilder: (context, index) {
          final driver = _standings[index];
          return _DriverStandingCard(
            driver: driver,
            isDark: isDark,
            rank: index + 1,
            isCompact: isCompact,
          );
        },
      ),
    );
  }

  Widget _buildChartView(bool isDark) {
    if (_standings.isEmpty) {
      return const Center(child: Text('No data available'));
    }

    final top10 = _standings.take(10).toList();
    final maxPoints = top10.first.points.toDouble();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Top 10 Drivers',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  height: 400,
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: maxPoints * 1.1,
                      barTouchData: BarTouchData(enabled: false),
                      titlesData: FlTitlesData(
                        show: true,
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              if (value.toInt() >= 0 && value.toInt() < top10.length) {
                                final driver = top10[value.toInt()];
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text(
                                    driver.code ?? '',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: isDark
                                          ? Colors.white.withValues(alpha: 0.6)
                                          : Colors.black.withValues(alpha: 0.6),
                                    ),
                                  ),
                                );
                              }
                              return const Text('');
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 40,
                            getTitlesWidget: (value, meta) {
                              return Text(
                                value.toInt().toString(),
                                style: TextStyle(
                                  fontSize: 11,
                                  color: isDark
                                      ? Colors.white.withValues(alpha: 0.6)
                                      : Colors.black.withValues(alpha: 0.6),
                                ),
                              );
                            },
                          ),
                        ),
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                      ),
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        horizontalInterval: maxPoints / 5,
                        getDrawingHorizontalLine: (value) {
                          return FlLine(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.05)
                                : Colors.black.withValues(alpha: 0.05),
                            strokeWidth: 1,
                          );
                        },
                      ),
                      borderData: FlBorderData(show: false),
                      barGroups: top10.asMap().entries.map((entry) {
                        final index = entry.key;
                        final driver = entry.value;
                        
                        Color barColor;
                        if (index == 0) {
                          barColor = const Color(0xFFFFD700); // Gold
                        } else if (index == 1) {
                          barColor = const Color(0xFFC0C0C0); // Silver
                        } else if (index == 2) {
                          barColor = const Color(0xFFCD7F32); // Bronze
                        } else {
                          barColor = const Color(0xFF007AFF); // Blue
                        }

                        return BarChartGroupData(
                          x: index,
                          barRods: [
                            BarChartRodData(
                              toY: driver.points.toDouble(),
                              color: barColor,
                              width: 24,
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(6),
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
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

class _ViewToggleButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final bool isDark;
  final VoidCallback onTap;

  const _ViewToggleButton({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? Colors.white : Colors.black)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected
                  ? (isDark ? Colors.black : Colors.white)
                  : (isDark ? Colors.white.withValues(alpha: 0.5) : Colors.black.withValues(alpha: 0.5)),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isSelected
                    ? (isDark ? Colors.black : Colors.white)
                    : (isDark ? Colors.white.withValues(alpha: 0.5) : Colors.black.withValues(alpha: 0.5)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DriverStandingCard extends StatelessWidget {
  final Driver driver;
  final bool isDark;
  final int rank;
  final bool isCompact;

  const _DriverStandingCard({
    required this.driver,
    required this.isDark,
    required this.rank,
    required this.isCompact,
  });

  Color get _rankColor {
    switch (rank) {
      case 1:
        return const Color(0xFFFFD700); // Gold
      case 2:
        return const Color(0xFFC0C0C0); // Silver
      case 3:
        return const Color(0xFFCD7F32); // Bronze
      default:
        return isDark ? Colors.white.withValues(alpha: 0.3) : Colors.black.withValues(alpha: 0.3);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: isCompact ? 8 : 12),
      padding: EdgeInsets.all(isCompact ? 12 : 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0A0A0A) : Colors.white,
        borderRadius: BorderRadius.circular(isCompact ? 12 : 16),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.05)
              : Colors.black.withValues(alpha: 0.05),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Rank badge
          Container(
            width: isCompact ? 34 : 40,
            height: isCompact ? 34 : 40,
            decoration: BoxDecoration(
              color: _rankColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(isCompact ? 9 : 12),
              border: Border.all(
                color: _rankColor.withValues(alpha: 0.3),
                width: 2,
              ),
            ),
            child: Center(
              child: Text(
                '$rank',
                style: TextStyle(
                  fontSize: isCompact ? 15 : 18,
                  fontWeight: FontWeight.w900,
                  color: _rankColor,
                ),
              ),
            ),
          ),
          SizedBox(width: isCompact ? 8 : 12),
          // Driver photo
          Container(
            width: isCompact ? 42 : 50,
            height: isCompact ? 42 : 50,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(isCompact ? 8 : 10),
              border: Border.all(
                color: F1ApiService.getTeamColor(driver.constructor).withValues(alpha: 0.5),
                width: 2,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(isCompact ? 6 : 8),
              child: CachedNetworkImage(
                imageUrl: F1ApiService.getDriverPhotoUrl(driver.driverId),
                fit: BoxFit.cover,
                memCacheWidth: isCompact ? 100 : 150,
                fadeInDuration: const Duration(milliseconds: 150),
                placeholder: (context, url) => Container(
                  color: F1ApiService.getTeamColor(driver.constructor).withValues(alpha: 0.1),
                  child: const Center(
                    child: SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 1.8),
                    ),
                  ),
                ),
                errorWidget: (context, url, error) {
                  return Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          F1ApiService.getTeamColor(driver.constructor).withValues(alpha: 0.2),
                          F1ApiService.getTeamColor(driver.constructor).withValues(alpha: 0.05),
                        ],
                      ),
                    ),
                    child: Center(
                      child: Text(
                        driver.code ?? '',
                        style: TextStyle(
                          fontSize: isCompact ? 12 : 14,
                          fontWeight: FontWeight.w900,
                          color: F1ApiService.getTeamColor(driver.constructor),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          SizedBox(width: isCompact ? 8 : 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${driver.givenName} ${driver.familyName}',
                  style: TextStyle(
                    fontSize: isCompact ? 13 : 15,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: isCompact ? 2 : 3),
                Row(
                  children: [
                    Container(
                      width: isCompact ? 8 : 10,
                      height: isCompact ? 8 : 10,
                      decoration: BoxDecoration(
                        color: F1ApiService.getTeamColor(driver.constructor),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    SizedBox(width: isCompact ? 4 : 6),
                    Flexible(
                      child: Text(
                        driver.constructor.isNotEmpty ? driver.constructor : driver.nationality,
                        style: TextStyle(
                          fontSize: isCompact ? 10 : 11,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white.withValues(alpha: 0.6) : Colors.black.withValues(alpha: 0.6),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: isCompact ? 2 : 4),
                Text(
                  'Wins ${driver.wins} • ${driver.nationality}',
                  style: TextStyle(
                    fontSize: isCompact ? 10 : 11,
                    color: isDark ? Colors.white.withValues(alpha: 0.55) : Colors.black.withValues(alpha: 0.55),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${driver.points}',
                style: TextStyle(
                  fontSize: isCompact ? 20 : 24,
                  fontWeight: FontWeight.w900,
                  color: isDark ? Colors.white : Colors.black,
                  letterSpacing: -0.8,
                ),
              ),
              Text(
                'PTS',
                style: TextStyle(
                  fontSize: isCompact ? 9 : 10,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white.withValues(alpha: 0.4) : Colors.black.withValues(alpha: 0.4),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
