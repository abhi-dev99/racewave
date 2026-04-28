import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../services/f1_api_service.dart';
import '../models/driver.dart';
import '../models/race.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  final F1ApiService _apiService = F1ApiService();
  Driver? _leader;
  Race? _nextRace;
  List<Driver> _topDrivers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final standings = await _apiService.getDriverStandings();
      final races = await _apiService.getCurrentRaces();
      
      if (mounted) {
        setState(() {
          if (standings.isNotEmpty) {
            _leader = standings.first;
            _topDrivers = standings.take(3).toList();
          }
          
          final now = DateTime.now();
          _nextRace = races.firstWhere(
            (race) => DateTime.tryParse(race.date)?.isAfter(now) ?? false,
            orElse: () => races.first,
          );
          
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isCompact = MediaQuery.sizeOf(context).width < 430;
    
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF000000) : const Color(0xFFFAFAFA),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Minimal App Bar
            SliverAppBar(
              expandedHeight: isCompact ? 118 : 140,
              floating: false,
              pinned: true,
              backgroundColor: Colors.transparent,
              elevation: 0,
              flexibleSpace: FlexibleSpaceBar(
                titlePadding: EdgeInsets.only(left: isCompact ? 16 : 24, bottom: 16),
                title: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'F1 Strategy Hub',
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black,
                        fontSize: isCompact ? 20 : 24,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.8,
                      ),
                    ),
                    SizedBox(width: isCompact ? 8 : 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE10600).withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        DateTime.now().year.toString(),
                        style: const TextStyle(
                          color: Color(0xFFE10600),
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            if (_isLoading)
              const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              )
            else
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(isCompact ? 14 : 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Next Race Countdown
                      if (_nextRace != null) _buildNextRaceCard(isCompact),
                      
                      SizedBox(height: isCompact ? 12 : 20),
                      
                      // Championship Leader
                      if (_leader != null) _buildLeaderCard(isCompact),
                      
                      SizedBox(height: isCompact ? 12 : 20),
                      
                      // Quick Stats
                      _buildQuickStats(isCompact),
                      
                      SizedBox(height: isCompact ? 12 : 20),

                      _buildCarGallery(isCompact),

                      SizedBox(height: isCompact ? 12 : 20),
                      
                      // Top 3 Drivers
                      if (_topDrivers.isNotEmpty) _buildTopDrivers(isCompact),
                      
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildNextRaceCard(bool isCompact) {
    final raceDate = DateTime.tryParse(_nextRace!.date);
    final daysUntil = raceDate?.difference(DateTime.now()).inDays ?? 0;
    
    return Container(
      padding: EdgeInsets.all(isCompact ? 16 : 24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFE10600), Color(0xFFFF4444)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(isCompact ? 14 : 20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  daysUntil == 0 ? 'TODAY' : daysUntil == 1 ? 'TOMORROW' : 'IN $daysUntil DAYS',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: isCompact ? 10 : 16),
          Text(
            _nextRace!.raceName,
            style: TextStyle(
              color: Colors.white,
              fontSize: isCompact ? 18 : 24,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.location_on, color: Colors.white70, size: 16),
              const SizedBox(width: 6),
              Text(
                '${_nextRace!.circuit.location.locality}, ${_nextRace!.circuit.location.country}',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.calendar_today, color: Colors.white70, size: 16),
              const SizedBox(width: 6),
              Text(
                _formatDate(_nextRace!.date),
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLeaderCard(bool isCompact) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      padding: EdgeInsets.all(isCompact ? 14 : 20),
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
            'Championship Leader',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.white60 : Colors.black54,
              letterSpacing: 0.5,
            ),
          ),
          SizedBox(height: isCompact ? 10 : 16),
          Row(
            children: [
              Container(
                width: isCompact ? 56 : 70,
                height: isCompact ? 56 : 70,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFFFFD700),
                    width: 3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFFD700).withValues(alpha: 0.3),
                      blurRadius: 12,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: ClipOval(
                  child: CachedNetworkImage(
                    imageUrl: F1ApiService.getDriverPhotoUrl(_leader!.driverId),
                    fit: BoxFit.cover,
                    memCacheWidth: isCompact ? 120 : 180,
                    fadeInDuration: const Duration(milliseconds: 120),
                    placeholder: (context, url) => const Center(
                      child: SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 1.8),
                      ),
                    ),
                    errorWidget: (context, url, error) {
                      return Container(
                        decoration: BoxDecoration(
                          gradient: RadialGradient(
                            colors: [
                              const Color(0xFFFFD700).withValues(alpha: 0.3),
                              const Color(0xFFFFD700).withValues(alpha: 0.1),
                            ],
                          ),
                        ),
                        child: Center(
                          child: Text(
                            _leader!.code ?? _leader!.givenName[0],
                            style: TextStyle(
                              color: Color(0xFFFFD700),
                              fontSize: isCompact ? 18 : 24,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              SizedBox(width: isCompact ? 10 : 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _leader!.fullName,
                      style: TextStyle(
                          fontSize: isCompact ? 16 : 20,
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: F1ApiService.getTeamColor(_leader!.constructor),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            _leader!.constructor,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white.withValues(alpha: 0.7) : Colors.black.withValues(alpha: 0.7),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${_leader!.points}',
                    style: TextStyle(
                      fontSize: isCompact ? 24 : 32,
                      fontWeight: FontWeight.w900,
                      color: isDark ? Colors.white : Colors.black,
                      height: 1,
                      letterSpacing: -1,
                    ),
                  ),
                  Text(
                    'POINTS',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white.withValues(alpha: 0.4) : Colors.black.withValues(alpha: 0.38),
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: isCompact ? 6 : 10),
          Text(
            'Wins: ${_leader!.wins}  |  Nationality: ${_leader!.nationality}',
            style: TextStyle(
              fontSize: isCompact ? 11 : 12,
              color: isDark ? Colors.white.withValues(alpha: 0.6) : Colors.black.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats(bool isCompact) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Drivers',
            '20',
            Icons.person_outline,
            const Color(0xFF007AFF),
            isDark,
            isCompact,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Races',
            '24',
            Icons.flag_outlined,
            const Color(0xFF34C759),
            isDark,
            isCompact,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Teams',
            '10',
            Icons.groups_outlined,
            const Color(0xFFFF9500),
            isDark,
            isCompact,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color, bool isDark, bool isCompact) {
    return Container(
      padding: EdgeInsets.all(isCompact ? 10 : 16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          SizedBox(height: isCompact ? 8 : 12),
          Text(
            value,
            style: TextStyle(
              fontSize: isCompact ? 18 : 24,
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: isCompact ? 10 : 12,
              color: isDark ? Colors.white60 : Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCarGallery(bool isCompact) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cards = [
      {
        'title': 'Pit Lane Energy',
        'subtitle': 'Warm tires. Cold precision.',
        'a': const Color(0xFFE10600),
        'b': const Color(0xFF7A0000),
      },
      {
        'title': 'Racecraft Mode',
        'subtitle': 'Late braking. Clean exits.',
        'a': const Color(0xFF007AFF),
        'b': const Color(0xFF002F66),
      },
      {
        'title': 'Final Stint Push',
        'subtitle': 'One lap pace, every lap.',
        'a': const Color(0xFF34C759),
        'b': const Color(0xFF0B5A28),
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Garage Visuals',
          style: TextStyle(
            fontSize: isCompact ? 16 : 18,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        SizedBox(height: isCompact ? 8 : 12),
        SizedBox(
          height: isCompact ? 132 : 176,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: cards.length,
            separatorBuilder: (_, __) => SizedBox(width: isCompact ? 10 : 14),
            itemBuilder: (context, index) {
              final card = cards[index];
              final a = card['a'] as Color;
              final b = card['b'] as Color;

              return Container(
                width: isCompact ? 230 : 300,
                padding: EdgeInsets.all(isCompact ? 12 : 16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [a, b],
                  ),
                  borderRadius: BorderRadius.circular(isCompact ? 14 : 18),
                  boxShadow: [
                    BoxShadow(
                      color: a.withValues(alpha: 0.3),
                      blurRadius: 14,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: -16,
                      bottom: -10,
                      child: Icon(
                        Icons.sports_motorsports_rounded,
                        size: isCompact ? 88 : 108,
                        color: Colors.white.withValues(alpha: 0.22),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.flash_on_rounded, color: Colors.white, size: isCompact ? 16 : 18),
                            const SizedBox(width: 6),
                            Text(
                              'LIVE MOOD',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.88),
                                fontSize: isCompact ? 10 : 11,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: isCompact ? 10 : 14),
                        Text(
                          card['title'] as String,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: isCompact ? 18 : 22,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.4,
                          ),
                        ),
                        SizedBox(height: isCompact ? 4 : 6),
                        Text(
                          card['subtitle'] as String,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.86),
                            fontSize: isCompact ? 12 : 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Spacer(),
                        Row(
                          children: List.generate(
                            4,
                            (i) => Container(
                              margin: const EdgeInsets.only(right: 6),
                              width: isCompact ? 18 : 22,
                              height: 4,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.75 - (i * 0.12)),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTopDrivers(bool isCompact) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Top 3 Drivers',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        SizedBox(height: isCompact ? 8 : 12),
        ..._topDrivers.asMap().entries.map((entry) {
          final index = entry.key;
          final driver = entry.value;
          final colors = [
            const Color(0xFFFFD700), // Gold
            const Color(0xFFC0C0C0), // Silver
            const Color(0xFFCD7F32), // Bronze
          ];
          
          return Container(
            margin: EdgeInsets.only(bottom: isCompact ? 6 : 8),
            padding: EdgeInsets.all(isCompact ? 10 : 14),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0A0A0A) : Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: colors[index].withValues(alpha: 0.2),
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: colors[index].withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: colors[index].withValues(alpha: 0.5),
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(
                        color: colors[index],
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                // Driver photo
                Container(
                  width: isCompact ? 38 : 45,
                  height: isCompact ? 38 : 45,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: F1ApiService.getTeamColor(driver.constructor).withValues(alpha: 0.4),
                      width: 2,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: CachedNetworkImage(
                      imageUrl: F1ApiService.getDriverPhotoUrl(driver.driverId),
                      fit: BoxFit.cover,
                      memCacheWidth: isCompact ? 100 : 140,
                      fadeInDuration: const Duration(milliseconds: 120),
                      placeholder: (context, url) => const Center(
                        child: SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(strokeWidth: 1.6),
                        ),
                      ),
                      errorWidget: (context, url, error) {
                        return Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                F1ApiService.getTeamColor(driver.constructor).withValues(alpha: 0.3),
                                F1ApiService.getTeamColor(driver.constructor).withValues(alpha: 0.1),
                              ],
                            ),
                          ),
                          child: Center(
                            child: Text(
                              driver.code ?? driver.givenName[0],
                              style: TextStyle(
                                fontSize: isCompact ? 10 : 12,
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
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        driver.fullName,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                      Text(
                        driver.constructor,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.white60 : Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '${driver.points}',
                  style: TextStyle(
                    fontSize: isCompact ? 16 : 18,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  String _formatDate(String dateString) {
    final date = DateTime.tryParse(dateString);
    if (date == null) return dateString;

    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];

    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}
