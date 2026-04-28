import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
            onTap: () => _showDriverDetails(driver),
          );
        },
      ),
    );
  }

  void _showDriverDetails(Driver driver) {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _DriverProfileSheet(driver: driver),
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
  final VoidCallback onTap;

  const _DriverStandingCard({
    required this.driver,
    required this.isDark,
    required this.rank,
    required this.isCompact,
    required this.onTap,
  });

  Color get _rankColor {
    switch (rank) {
      case 1:
        return const Color(0xFFFFD700);
      case 2:
        return const Color(0xFFC0C0C0);
      case 3:
        return const Color(0xFFCD7F32);
      default:
        return isDark ? Colors.white.withValues(alpha: 0.3) : Colors.black.withValues(alpha: 0.3);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: isCompact ? 8 : 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0A0A0A) : Colors.white,
        borderRadius: BorderRadius.circular(isCompact ? 12 : 16),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(isCompact ? 12 : 16),
          child: Padding(
            padding: EdgeInsets.all(isCompact ? 12 : 16),
            child: Row(
              children: [
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
          ),
        ),
      ),
    );
  }
}

class _DriverProfileSheet extends StatelessWidget {
  final Driver driver;

  const _DriverProfileSheet({required this.driver});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final teamColor = F1ApiService.getTeamColor(driver.constructor);

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            children: [
              Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(24),
                  children: [
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            teamColor.withValues(alpha: 0.20),
                            teamColor.withValues(alpha: 0.06),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                          color: teamColor.withValues(alpha: 0.45),
                          width: 1.3,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 92,
                            height: 92,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: teamColor.withValues(alpha: 0.7), width: 2),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(18),
                              child: CachedNetworkImage(
                                imageUrl: F1ApiService.getDriverPhotoUrl(driver.driverId),
                                fit: BoxFit.cover,
                                memCacheWidth: 220,
                                placeholder: (context, url) => Center(
                                  child: SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation(teamColor),
                                    ),
                                  ),
                                ),
                                errorWidget: (context, url, error) => Center(
                                  child: Text(
                                    driver.code ?? driver.givenName[0],
                                    style: TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.w900,
                                      color: teamColor,
                                    ),
                                  ),
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
                                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                                        fontSize: 24,
                                        fontWeight: FontWeight.w800,
                                      ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '#${driver.number ?? 'N/A'} • ${driver.nationality}',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 14),
                                ),
                                const SizedBox(height: 8),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 6,
                                  children: [
                                    _buildTag(driver.constructor.isNotEmpty ? driver.constructor : 'Free Agent', teamColor),
                                    _buildTag('P${driver.position == 0 ? '-' : driver.position}', const Color(0xFFE10600)),
                                    _buildTag('${driver.points} pts', const Color(0xFF007AFF)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    _buildStatsGrid(context, isDark, teamColor),
                    const SizedBox(height: 20),
                    _buildInfoSection(context, 'Driver Information', [
                      _InfoRow('Driver ID', driver.driverId.replaceAll('_', ' ')),
                      _InfoRow('Date of Birth', driver.dateOfBirth),
                      _InfoRow('Nationality', driver.nationality),
                      _InfoRow('Team', driver.constructor.isEmpty ? 'Unknown' : driver.constructor),
                    ]),
                    const SizedBox(height: 24),
                    _buildPerformanceCard(context, teamColor),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildStatsGrid(BuildContext context, bool isDark, Color teamColor) {
    return Row(
      children: [
        Expanded(child: _buildMiniStat('Points', '${driver.points}', const Color(0xFF007AFF), isDark)),
        const SizedBox(width: 10),
        Expanded(child: _buildMiniStat('Wins', '${driver.wins}', const Color(0xFFE10600), isDark)),
        const SizedBox(width: 10),
        Expanded(child: _buildMiniStat('Rank', driver.position == 0 ? '-' : 'P${driver.position}', const Color(0xFF34C759), isDark)),
      ],
    );
  }

  Widget _buildMiniStat(String label, String value, Color accent, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0A0A0A) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: accent.withValues(alpha: 0.25), width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: accent),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: isDark ? Colors.white.withValues(alpha: 0.65) : Colors.black.withValues(alpha: 0.65),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(BuildContext context, String title, List<_InfoRow> rows) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: rows.asMap().entries.map((entry) {
              final index = entry.key;
              final row = entry.value;
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: BoxDecoration(
                  border: index < rows.length - 1
                      ? Border(
                          bottom: BorderSide(
                            color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                            width: 0.5,
                          ),
                        )
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      row.label,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    Text(
                      row.value,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildPerformanceCard(BuildContext context, Color teamColor) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dna = driver.wins >= 10
        ? 'Aggressive title contender with race-winning consistency and front-row pace.'
        : driver.wins >= 1
            ? 'Clinical racer with proven conversion when opportunity opens up.'
            : 'Rising threat building points momentum through consistency and race craft.';

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            teamColor.withValues(alpha: 0.18),
            teamColor.withValues(alpha: 0.06),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: teamColor.withValues(alpha: 0.32),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.analytics_rounded,
                color: teamColor,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Racing DNA',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: teamColor,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            dna,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: isDark ? Colors.white.withValues(alpha: 0.8) : Colors.black.withValues(alpha: 0.75),
                ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.flash_on_rounded, size: 16, color: teamColor),
              const SizedBox(width: 6),
              Text(
                'Estimated pace tier: ${driver.position > 0 && driver.position <= 5 ? 'Elite' : 'Competitive'}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white.withValues(alpha: 0.7) : Colors.black.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoRow {
  final String label;
  final String value;

  _InfoRow(this.label, this.value);
}
