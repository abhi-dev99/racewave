import 'package:flutter/material.dart';
import '../services/f1_api_service.dart';
import '../models/driver.dart';
import '../models/race.dart';
import 'dart:math' as math;

class F1StrategyAnalysisScreen extends StatefulWidget {
  const F1StrategyAnalysisScreen({super.key});

  @override
  State<F1StrategyAnalysisScreen> createState() => _F1StrategyAnalysisScreenState();
}

class _F1StrategyAnalysisScreenState extends State<F1StrategyAnalysisScreen> 
    with TickerProviderStateMixin {
  final F1ApiService _apiService = F1ApiService();
  List<Driver> _drivers = [];
  List<Race> _races = [];
  bool _isLoading = true;
  
  // Analysis data
  late Map<String, dynamic> _championshipAnalysis;
  late Map<String, dynamic> _teamBattles;
  late Map<String, dynamic> _raceStrategy;
  late Map<String, dynamic> _driverInsights;
  
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadF1DataAndAnalyze();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadF1DataAndAnalyze() async {
    try {
      setState(() => _isLoading = true);
      
      final drivers = await _apiService.getDriverStandings();
      final races = await _apiService.getCurrentRaces();
      
      setState(() {
        _drivers = drivers;
        _races = races;
        _isLoading = false;
      });
      
      // Perform comprehensive analysis
      _analyzeChampionshipBattle();
      _analyzeTeamBattles();
      _analyzeRaceStrategy();
      _analyzeDriverInsights();
      
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  // 🏆 CHAMPIONSHIP BATTLE ANALYSIS
  void _analyzeChampionshipBattle() {
    if (_drivers.length < 2) return;
    
    final leader = _drivers.first;
    final challenger = _drivers[1];
    final pointsGap = leader.points - challenger.points;
    final remainingRaces = _races.where((r) => DateTime.parse(r.date).isAfter(DateTime.now())).length;
    final maxPointsAvailable = remainingRaces * 25; // 25 points per win
    
    _championshipAnalysis = {
      'leader': leader,
      'challenger': challenger,
      'pointsGap': pointsGap,
      'remainingRaces': remainingRaces,
      'maxPointsAvailable': maxPointsAvailable,
      'mathematicallyDecided': pointsGap > maxPointsAvailable,
      'racesMustWin': (pointsGap / 25).ceil(),
      'tensionLevel': _calculateTensionLevel(pointsGap, maxPointsAvailable),
      'prediction': _predictChampionship(pointsGap, remainingRaces),
    };
  }
  
  // 🏁 TEAM BATTLES ANALYSIS  
  void _analyzeTeamBattles() {
    final teamPoints = <String, Map<String, dynamic>>{};
    
    for (final driver in _drivers) {
      if (!teamPoints.containsKey(driver.constructor)) {
        teamPoints[driver.constructor] = {
          'points': 0,
          'wins': 0,
          'drivers': <Driver>[],
        };
      }
      teamPoints[driver.constructor]!['points'] += driver.points;
      teamPoints[driver.constructor]!['wins'] += driver.wins;
      teamPoints[driver.constructor]!['drivers'].add(driver);
    }
    
    final sortedTeams = teamPoints.entries.toList()
      ..sort((a, b) => b.value['points'].compareTo(a.value['points']));
    
    _teamBattles = {
      'constructorsRace': sortedTeams,
      'closestBattle': _findClosestTeamBattle(sortedTeams),
      'dominantTeam': sortedTeams.first,
      'rocketShip': _findFormTeam(sortedTeams),
      'underperformer': _findUnderperformingTeam(sortedTeams),
    };
  }
  
  // 🎯 RACE STRATEGY ANALYSIS
  void _analyzeRaceStrategy() {
    final nextRace = _races.firstWhere(
      (r) => DateTime.parse(r.date).isAfter(DateTime.now()),
      orElse: () => _races.last,
    );
    
    _raceStrategy = {
      'nextRace': nextRace,
      'trackType': _analyzeTrackType(nextRace),
      'weatherThreat': _getWeatherThreat(nextRace),
      'keyFactors': _getKeyFactors(nextRace),
      'tireStrategy': _recommendTireStrategy(nextRace),
      'overtakingDifficulty': _getOvertakingDifficulty(nextRace),
      'strategicImportance': _getStrategicImportance(nextRace),
    };
  }
  
  // 🔥 DRIVER INSIGHTS ANALYSIS
  void _analyzeDriverInsights() {
    _driverInsights = {
      'hotStreak': _findDriverOnHotStreak(),
      'underPressure': _findDriverUnderPressure(),
      'darkHorse': _findDarkHorse(),
      'veteranWatch': _findVeteranPerformance(),
      'rookieRising': _findRookieRising(),
      'teammateBattles': _analyzeTeammateBattles(),
    };
  }

  // Helper methods for analysis
  String _calculateTensionLevel(int gap, int maxPoints) {
    final percentage = (gap / maxPoints) * 100;
    if (percentage < 20) return "🔥 EXPLOSIVE";
    if (percentage < 40) return "⚡ HIGH TENSION";
    if (percentage < 60) return "📈 COMPETITIVE";
    return "😴 DECIDED";
  }
  
  String _predictChampionship(int gap, int races) {
    if (gap == 0) return "DEAD HEAT - Anyone's game!";
    if (gap < races * 10) return "GOING TO THE WIRE!";
    if (gap < races * 20) return "Still possible upset";
    return "Mathematical certainty approaching";
  }
  
  Map<String, dynamic> _findClosestTeamBattle(List<MapEntry<String, Map<String, dynamic>>> teams) {
    if (teams.length < 2) return {};
    
    int smallestGap = 1000;
    Map<String, dynamic> closestBattle = {};
    
    for (int i = 0; i < teams.length - 1; i++) {
      final gap = teams[i].value['points'] - teams[i + 1].value['points'];
      if (gap < smallestGap) {
        smallestGap = gap;
        closestBattle = {
          'team1': teams[i].key,
          'team2': teams[i + 1].key,
          'gap': gap,
          'position1': i + 1,
          'position2': i + 2,
        };
      }
    }
    return closestBattle;
  }
  
  Map<String, dynamic> _findFormTeam(List<MapEntry<String, Map<String, dynamic>>> teams) {
    // Simplified: team with most wins recently
    return teams.reduce((a, b) => 
      a.value['wins'] > b.value['wins'] ? a : b
    ).value;
  }
  
  Map<String, dynamic> _findUnderperformingTeam(List<MapEntry<String, Map<String, dynamic>>> teams) {
    // Simplified: last place team
    return teams.last.value;
  }
  
  Map<String, String> _analyzeTrackType(Race race) {
    final trackTypes = {
      'monaco': {'type': 'Street Circuit', 'difficulty': 'EXTREME', 'key': 'Qualifying crucial'},
      'spa': {'type': 'Power Circuit', 'difficulty': 'HIGH', 'key': 'DRS battles expected'},
      'silverstone': {'type': 'High-Speed', 'difficulty': 'MEDIUM', 'key': 'Tire degradation'},
      'hungaroring': {'type': 'Twisty', 'difficulty': 'HIGH', 'key': 'Track position vital'},
    };
    
    final circuitId = race.circuit.circuitId.toLowerCase();
    return trackTypes[circuitId] ?? {'type': 'Mixed Layout', 'difficulty': 'MEDIUM', 'key': 'Balanced approach'};
  }
  
  String _getWeatherThreat(Race race) {
    // Simplified weather analysis based on location/season
    final month = DateTime.parse(race.date).month;
    final location = race.circuit.location.country.toLowerCase();
    
    if (location.contains('belgium') || location.contains('britain')) return "🌧️ RAIN LIKELY";
    if (month >= 6 && month <= 8 && location.contains('hungary')) return "🌡️ EXTREME HEAT";
    if (location.contains('bahrain') || location.contains('saudi')) return "🌙 NIGHT RACE";
    return "☀️ CLEAR CONDITIONS";
  }
  
  List<String> _getKeyFactors(Race race) {
    final factors = <String>[];
    final trackName = race.circuit.circuitName.toLowerCase();
    
    if (trackName.contains('monaco')) {
      factors.addAll(['Qualifying position crucial', 'Safety car likely', 'Tire management']);
    } else if (trackName.contains('spa')) {
      factors.addAll(['DRS battles', 'Weather wildcards', 'Engine power']);
    } else if (trackName.contains('silverstone')) {
      factors.addAll(['High-speed corners', 'Tire degradation', 'British weather']);
    } else {
      factors.addAll(['Strategic pit windows', 'Tire compound choice', 'Track evolution']);
    }
    return factors;
  }
  
  String _recommendTireStrategy(Race race) {
    final degradation = _assessTireDegradation(race);
    final overtaking = _assessOvertakingDifficulty(race);
    
    if (degradation.contains('HIGH')) {
      return "Two-stop mandatory - Medium → Hard → Medium";
    } else if (overtaking.contains('VERY HIGH')) {
      return "One-stop crucial - Soft → Hard (track position key)";
    } else if (overtaking.contains('LOW')) {
      return "Aggressive strategy - Soft → Medium → Soft";
    } else {
      return "Flexible approach - Medium → Hard (one-stop preferred)";
    }
  }
  
  String _getOvertakingDifficulty(Race race) {
    final trackName = race.circuit.circuitName.toLowerCase();
    if (trackName.contains('monaco')) return "NEARLY IMPOSSIBLE";
    if (trackName.contains('hungaroring')) return "VERY DIFFICULT";
    if (trackName.contains('spa') || trackName.contains('monza')) return "EASY";
    return "MODERATE";
  }
  
  String _getStrategicImportance(Race race) {
    final round = int.tryParse(race.round) ?? 1;
    final totalRaces = _races.length;
    
    if (round == 1) return "🏁 SEASON OPENER - Sets the tone";
    if (round == totalRaces) return "🏆 SEASON FINALE - Championship decider";
    if (round > totalRaces * 0.8) return "🔥 CRUCIAL - Every point counts";
    if (round < totalRaces * 0.3) return "📈 MOMENTUM BUILDER";
    return "⚖️ CHAMPIONSHIP IMPACT";
  }
  
  Map<String, String> _findDriverOnHotStreak() {
    // Find driver with most wins or consistent points
    final topScorer = _drivers.first;
    return {
      'driver': '${topScorer.givenName} ${topScorer.familyName}',
      'reason': 'Leading championship with ${topScorer.wins} wins',
      'momentum': 'UNSTOPPABLE',
    };
  }
  
  Map<String, String> _findDriverUnderPressure() {
    // Find driver losing championship battle
    if (_drivers.length > 1) {
      final challenger = _drivers[1];
      return {
        'driver': '${challenger.givenName} ${challenger.familyName}',
        'reason': 'Trailing by ${_drivers.first.points - challenger.points} points',
        'pressure': 'MUST WIN SOON',
      };
    }
    return {'driver': 'None', 'reason': 'Season well balanced', 'pressure': 'LOW'};
  }
  
  Map<String, String> _findDarkHorse() {
    // Find driver in 3rd-5th position with potential
    final darkHorse = _drivers.length > 2 ? _drivers[2] : _drivers.last;
    return {
      'driver': '${darkHorse.givenName} ${darkHorse.familyName}',
      'reason': 'Consistent points scorer in P${darkHorse.position}',
      'potential': 'OUTSIDER THREAT',
    };
  }
  
  Map<String, String> _findVeteranPerformance() {
    // Look for experienced drivers (simplified by checking known veterans)
    final veteran = _drivers.firstWhere(
      (d) => d.familyName == 'Hamilton' || d.familyName == 'Alonso',
      orElse: () => _drivers.first,
    );
    return {
      'driver': '${veteran.givenName} ${veteran.familyName}',
      'age': 'Veteran',
      'status': veteran.position <= 3 ? 'PROVING DOUBTERS WRONG' : 'EXPERIENCE SHOWING',
    };
  }
  
  Map<String, String> _findRookieRising() {
    // Look for young drivers (simplified)
    final rookie = _drivers.firstWhere(
      (d) => d.familyName == 'Piastri' || d.givenName == 'Oscar',
      orElse: () => _drivers.last,
    );
    return {
      'driver': '${rookie.givenName} ${rookie.familyName}',
      'status': 'Rising Star',
      'trajectory': rookie.position <= 5 ? 'RAPID ASCENT' : 'LEARNING CURVE',
    };
  }
  
  List<Map<String, String>> _analyzeTeammateBattles() {
    final battles = <Map<String, String>>[];
    final teamDrivers = <String, List<Driver>>{};
    
    // Group drivers by team
    for (final driver in _drivers) {
      teamDrivers.putIfAbsent(driver.constructor, () => []).add(driver);
    }
    
    // Analyze each team's internal battle
    teamDrivers.forEach((team, drivers) {
      if (drivers.length == 2) {
        final gap = (drivers[0].points - drivers[1].points).abs();
        battles.add({
          'team': team,
          'leader': drivers[0].position < drivers[1].position ? drivers[0].familyName : drivers[1].familyName,
          'trailer': drivers[0].position > drivers[1].position ? drivers[0].familyName : drivers[1].familyName,
          'gap': '$gap points',
          'intensity': gap < 20 ? 'FIERCE' : gap < 50 ? 'COMPETITIVE' : 'ONE-SIDED',
        });
      }
    });
    
    return battles;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('🏎️ F1 Strategy Analysis Hub'),
        backgroundColor: const Color(0xFFE10600),
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(icon: Icon(Icons.emoji_events), text: 'Championship'),
            Tab(icon: Icon(Icons.groups), text: 'Team Battles'),
            Tab(icon: Icon(Icons.flag), text: 'Race Strategy'),
            Tab(icon: Icon(Icons.person), text: 'Driver Intel'),
          ],
        ),
      ),
      body: _isLoading 
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Color(0xFFE10600)),
                  SizedBox(height: 16),
                  Text('Analyzing F1 Data...', style: TextStyle(fontSize: 16)),
                ],
              ),
            )
          : TabBarView(
              controller: _tabController,
              children: [
                _buildChampionshipAnalysis(),
                _buildTeamBattlesAnalysis(),
                _buildRaceStrategyAnalysis(),
                _buildDriverInsightsAnalysis(),
              ],
            ),
    );
  }

  // 🏆 CHAMPIONSHIP ANALYSIS TAB
  Widget _buildChampionshipAnalysis() {
    if (_drivers.isEmpty) return _buildEmptyState();
    
    return RefreshIndicator(
      onRefresh: _loadF1DataAndAnalyze,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Championship Battle Header
            _buildSectionCard(
              title: '🏆 Championship Battle',
              child: Column(
                children: [
                  // Leader vs Challenger
                  Row(
                    children: [
                      Expanded(
                        child: _buildDriverCard(_drivers[0], isLeader: true),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.red.shade100,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${_drivers[0].points - (_drivers.length > 1 ? _drivers[1].points : 0)} pts',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                      ),
                      Expanded(
                        child: _drivers.length > 1 
                            ? _buildDriverCard(_drivers[1], isLeader: false)
                            : Container(),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Championship Tension Meter
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.red.shade50, Colors.orange.shade50],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Text(
                          _calculateTensionLevel(
                            _drivers[0].points - (_drivers.length > 1 ? _drivers[1].points : 0),
                            _races.where((r) => DateTime.parse(r.date).isAfter(DateTime.now())).length * 25,
                          ),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _predictChampionship(
                            _drivers[0].points - (_drivers.length > 1 ? _drivers[1].points : 0),
                            _races.where((r) => DateTime.parse(r.date).isAfter(DateTime.now())).length,
                          ),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Top 5 Standings
            _buildSectionCard(
              title: '� Current Standings',
              child: Column(
                children: _drivers.take(5).map((driver) => 
                  _buildStandingItem(driver)
                ).toList(),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Championship Math
            _buildSectionCard(
              title: '🧮 Championship Math',
              child: _buildChampionshipMath(),
            ),
          ],
        ),
      ),
    );
  }

  // 🏁 TEAM BATTLES ANALYSIS TAB
  Widget _buildTeamBattlesAnalysis() {
    return RefreshIndicator(
      onRefresh: _loadF1DataAndAnalyze,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionCard(
              title: '🏁 Constructors Championship',
              child: _buildConstructorsStandings(),
            ),
            
            const SizedBox(height: 16),
            
            _buildSectionCard(
              title: '⚔️ Fiercest Team Battles',
              child: _buildTeammateBattles(),
            ),
            
            const SizedBox(height: 16),
            
            _buildSectionCard(
              title: '🚀 Form Guide',
              child: _buildTeamFormGuide(),
            ),
          ],
        ),
      ),
    );
  }

  // 🎯 RACE STRATEGY ANALYSIS TAB - COMPLETELY REBUILT
  Widget _buildRaceStrategyAnalysis() {
    final nextRace = _races.isNotEmpty ? _races.firstWhere(
      (r) => DateTime.parse(r.date).isAfter(DateTime.now()),
      orElse: () => _races.last,
    ) : null;
    
    return RefreshIndicator(
      onRefresh: _loadF1DataAndAnalyze,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (nextRace != null) ...[
              // 🏁 NEXT RACE COMMAND CENTER
              _buildSectionCard(
                title: '🏁 Race Command Center: ${nextRace.raceName}',
                child: _buildRaceCommandCenter(nextRace),
              ),
              
              const SizedBox(height: 16),
              
              // 🎮 STRATEGIC SIMULATOR
              _buildSectionCard(
                title: '� Strategic Simulator',
                child: _buildStrategicSimulator(nextRace),
              ),
              
              const SizedBox(height: 16),
              
              // 🛞 TIRE STRATEGY WAR ROOM
              _buildSectionCard(
                title: '🛞 Tire Strategy War Room',
                child: _buildTireStrategyWarRoom(nextRace),
              ),
              
              const SizedBox(height: 16),
              
              // 🌦️ WEATHER & CHAOS FACTORS
              _buildSectionCard(
                title: '🌦️ Weather & Chaos Analysis',
                child: _buildWeatherChaosAnalysis(nextRace),
              ),
              
              const SizedBox(height: 16),
              
              // 🎯 CHAMPIONSHIP IMPLICATIONS
              _buildSectionCard(
                title: '🎯 Championship Strategy Impact',
                child: _buildChampionshipImpactAnalysis(nextRace),
              ),
              
              const SizedBox(height: 16),
              
              // ⚡ TEAM STRATEGIC BATTLES
              _buildSectionCard(
                title: '⚡ Team Strategic Battles',
                child: _buildTeamStrategicBattles(nextRace),
              ),
              
            ] else
              _buildEmptyState(message: 'No upcoming races found'),
          ],
        ),
      ),
    );
  }

  // 🔥 DRIVER INSIGHTS TAB
  Widget _buildDriverInsightsAnalysis() {
    return RefreshIndicator(
      onRefresh: _loadF1DataAndAnalyze,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionCard(
              title: '🔥 Driver Spotlight',
              child: _buildDriverSpotlight(),
            ),
            
            const SizedBox(height: 16),
            
            _buildSectionCard(
              title: '⚔️ Teammate Battles',
              child: _buildDetailedTeammateBattles(),
            ),
            
            const SizedBox(height: 16),
            
            _buildSectionCard(
              title: '📈 Performance Trends',
              child: _buildPerformanceTrends(),
            ),
          ],
        ),
      ),
    );
  }

  // 🔧 UI HELPER METHODS
  Widget _buildSectionCard({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFE10600).withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFE10600),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: child,
          ),
        ],
      ),
    );
  }

  Widget _buildDriverCard(Driver driver, {required bool isLeader}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isLeader 
              ? [Colors.amber.shade50, Colors.amber.shade100]
              : [Colors.grey.shade50, Colors.grey.shade100],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isLeader ? Colors.amber.shade300 : Colors.grey.shade300,
          width: 2,
        ),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundColor: isLeader ? Colors.amber.shade200 : Colors.grey.shade300,
            child: Text(
              '${driver.familyName.substring(0, 2).toUpperCase()}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isLeader ? Colors.amber.shade800 : Colors.grey.shade700,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${driver.givenName} ${driver.familyName}',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            '${driver.points} pts',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStandingItem(Driver driver) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: driver.position <= 3 ? Colors.amber.shade100 : Colors.grey.shade200,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Center(
              child: Text(
                '${driver.position}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: driver.position <= 3 ? Colors.amber.shade800 : Colors.grey.shade700,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${driver.givenName} ${driver.familyName}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                Text(
                  driver.constructor,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
              ],
            ),
          ),
          Text(
            '${driver.points}',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildChampionshipMath() {
    if (_drivers.length < 2) return const Text('Insufficient data');
    
    final leader = _drivers[0];
    final challenger = _drivers[1];
    final pointsGap = leader.points - challenger.points;
    final remainingRaces = _races.where((r) => DateTime.parse(r.date).isAfter(DateTime.now())).length;
    final maxPointsAvailable = remainingRaces * 25; // Assuming 25 points per race win
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildMathRow('Points Gap', '$pointsGap points'),
        _buildMathRow('Remaining Races', '$remainingRaces races'),
        _buildMathRow('Max Points Available', '$maxPointsAvailable points'),
        const Divider(),
        _buildMathRow(
          'Champion if gap > available',
          pointsGap > maxPointsAvailable ? '✅ ${leader.familyName} CHAMPION!' : '❌ Still in play',
          isHighlight: pointsGap > maxPointsAvailable,
        ),
      ],
    );
  }

  Widget _buildMathRow(String label, String value, {bool isHighlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: isHighlight ? FontWeight.bold : FontWeight.normal,
              color: isHighlight ? const Color(0xFFE10600) : Colors.black,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConstructorsStandings() {
    final constructors = <String, int>{};
    for (final driver in _drivers) {
      constructors[driver.constructor] = (constructors[driver.constructor] ?? 0) + driver.points;
    }
    
    final sortedConstructors = constructors.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    return Column(
      children: sortedConstructors.take(5).map((entry) => 
        Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                entry.key,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                '${entry.value} pts',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        )
      ).toList(),
    );
  }

  Widget _buildTeammateBattles() {
    final teamBattles = <String, List<Driver>>{};
    for (final driver in _drivers) {
      teamBattles.putIfAbsent(driver.constructor, () => []).add(driver);
    }
    
    final closestBattles = teamBattles.entries
        .where((entry) => entry.value.length == 2)
        .map((entry) => {
          'team': entry.key,
          'driver1': entry.value[0],
          'driver2': entry.value[1],
          'gap': (entry.value[0].points - entry.value[1].points).abs(),
        })
        .toList()
      ..sort((a, b) => (a['gap'] as int).compareTo(b['gap'] as int));
    
    return Column(
      children: closestBattles.take(3).map((battle) => 
        Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.orange.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.orange.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                battle['team'] as String,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('${(battle['driver1'] as Driver).familyName} vs ${(battle['driver2'] as Driver).familyName}'),
                  Text(
                    '${battle['gap']} pts gap',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.orange),
                  ),
                ],
              ),
            ],
          ),
        )
      ).toList(),
    );
  }

  Widget _buildTeamFormGuide() {
    return Column(
      children: [
        Text(
          'Recent form analysis based on current standings',
          style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
        ),
        const SizedBox(height: 12),
        ...(_drivers.take(3).map((driver) => 
          Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(driver.constructor),
                Row(
                  children: [
                    ...List.generate(5, (index) => Container(
                      width: 8,
                      height: 8,
                      margin: const EdgeInsets.only(left: 2),
                      decoration: BoxDecoration(
                        color: index < 3 ? Colors.green : Colors.grey.shade300,
                        shape: BoxShape.circle,
                      ),
                    )),
                  ],
                ),
              ],
            ),
          )
        )),
      ],
    );
  }

  // 🏁 RACE COMMAND CENTER - Complete race overview (FIXED OVERFLOW)
  Widget _buildRaceCommandCenter(Race race) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Race Header with key info
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.red.shade50, Colors.orange.shade50],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.location_on, color: Colors.red.shade600, size: 16),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      '${race.circuit.location.locality}, ${race.circuit.location.country}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(Icons.schedule, color: Colors.orange.shade600, size: 16),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      '${race.date} • ${race.time}',
                      style: const TextStyle(fontSize: 12),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.red.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'R${race.round}',
                      style: TextStyle(
                        color: Colors.red.shade700,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 12),
        
        // Strategic Overview Grid (FIXED RESPONSIVE)
        Row(
          children: [
            Expanded(
              child: _buildStrategyMetric(
                '🏎️ Track',
                _getTrackType(race),
                Colors.blue.shade50,
                Colors.blue.shade700,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildStrategyMetric(
                '⚡ Overtaking',
                _getOvertakingLevel(race),
                Colors.green.shade50,
                Colors.green.shade700,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 8),
        
        Row(
          children: [
            Expanded(
              child: _buildStrategyMetric(
                '🛞 Tire Stress',
                _getTireStressLevel(race),
                Colors.orange.shade50,
                Colors.orange.shade700,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildStrategyMetric(
                '🌦️ Weather',
                _getWeatherRisk(race),
                Colors.purple.shade50,
                Colors.purple.shade700,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // 🎮 STRATEGIC SIMULATOR - Interactive strategy options (FIXED OVERFLOW)
  Widget _buildStrategicSimulator(Race race) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '🎯 Strategy Scenarios',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 12),
        
        // Strategy Option Cards (COMPACT)
        _buildStrategyOption(
          '🏆 Championship Defense',
          'Conservative approach',
          'One-stop, avoid risks, secure points',
          Colors.amber.shade50,
          Colors.amber.shade700,
        ),
        
        const SizedBox(height: 8),
        
        _buildStrategyOption(
          '⚔️ Championship Attack',
          'Aggressive approach',
          'Two-stop aggression, track position',
          Colors.red.shade50,
          Colors.red.shade700,
        ),
        
        const SizedBox(height: 8),
        
        _buildStrategyOption(
          '🎲 Chaos Strategy',
          'High-risk, high-reward',
          'Alternative tires, unusual pit windows',
          Colors.purple.shade50,
          Colors.purple.shade700,
        ),
        
        const SizedBox(height: 12),
        
        // Strategic Recommendations (COMPACT)
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.psychology, color: Colors.blue.shade700, size: 16),
                  const SizedBox(width: 6),
                  const Expanded(
                    child: Text(
                      'AI Strategic Recommendation',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                _getAIRecommendation(race),
                style: const TextStyle(fontSize: 11),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // 🛞 TIRE STRATEGY WAR ROOM - Comprehensive tire analysis (FIXED OVERFLOW)
  Widget _buildTireStrategyWarRoom(Race race) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Tire Compound Analysis (RESPONSIVE)
        Row(
          children: [
            Expanded(
              child: _buildTireCompoundCard(
                '🔴 Soft',
                'C5 - Fast',
                '8-12 laps',
                Colors.red.shade100,
                Colors.red.shade700,
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: _buildTireCompoundCard(
                '🟡 Medium',
                'C4 - Balance',
                '18-25 laps',
                Colors.yellow.shade100,
                Colors.yellow.shade700,
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: _buildTireCompoundCard(
                '⚪ Hard',
                'C3 - Distance',
                '30+ laps',
                Colors.grey.shade100,
                Colors.grey.shade700,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 12),
        
        // Strategic Pit Windows (COMPACT)
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.indigo.shade50, Colors.blue.shade50],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '⏱️ Optimal Pit Windows',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 8),
              _buildPitWindow('Early', 'L8-12', 'Undercut'),
              _buildPitWindow('Standard', 'L18-22', 'Balanced'),
              _buildPitWindow('Late', 'L28-32', 'Overcut'),
            ],
          ),
        ),
        
        const SizedBox(height: 12),
        
        // Championship Tire Strategy (COMPACT)
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.amber.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.amber.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.emoji_events, color: Colors.amber.shade700, size: 16),
                  const SizedBox(width: 6),
                  const Expanded(
                    child: Text(
                      'Championship Tire Strategy',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                _getChampionshipTireStrategy(),
                style: const TextStyle(fontSize: 11),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // 🌦️ WEATHER & CHAOS ANALYSIS (FIXED OVERFLOW)
  Widget _buildWeatherChaosAnalysis(Race race) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Weather Threat Level (COMPACT)
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue.shade50, Colors.cyan.shade50],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.cloud, color: Colors.blue.shade700, size: 16),
                  const SizedBox(width: 6),
                  const Expanded(
                    child: Text(
                      'Weather Intelligence',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                _getWeatherAnalysis(race),
                style: const TextStyle(fontSize: 11),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 12),
        
        // Chaos Factors (COMPACT)
        const Text(
          '🌪️ Chaos Factor Analysis',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 8),
        
        _buildChaosFactorCard('Safety Car Probability', _getSafetyCarProbability(race), Icons.warning),
        const SizedBox(height: 6),
        _buildChaosFactorCard('Red Flag Risk', _getRedFlagRisk(race), Icons.flag),
        const SizedBox(height: 6),
        _buildChaosFactorCard('Strategic Surprise Factor', _getStrategicSurpriseFactor(race), Icons.psychology),
      ],
    );
  }

  // 🎯 CHAMPIONSHIP IMPACT ANALYSIS (FIXED OVERFLOW)
  Widget _buildChampionshipImpactAnalysis(Race race) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Championship Stakes (COMPACT)
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.amber.shade50, Colors.orange.shade50],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.emoji_events, color: Colors.amber.shade700, size: 16),
                  const SizedBox(width: 6),
                  const Expanded(
                    child: Text(
                      'Championship Stakes',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                _getChampionshipStakes(),
                style: const TextStyle(fontSize: 11),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 12),
        
        // Strategic Importance by Position (COMPACT)
        const Text(
          '🎯 Strategic Importance by Position',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        ),
        const SizedBox(height: 8),
        
        if (_drivers.isNotEmpty) ...[
          _buildChampionshipPositionStrategy(_drivers[0], 'LEADER', Colors.amber),
          const SizedBox(height: 6),
          if (_drivers.length > 1)
            _buildChampionshipPositionStrategy(_drivers[1], 'CHALLENGER', Colors.grey),
          const SizedBox(height: 6),
          if (_drivers.length > 2)
            _buildChampionshipPositionStrategy(_drivers[2], 'DARK HORSE', Colors.orange),
        ],
      ],
    );
  }

  // ⚡ TEAM STRATEGIC BATTLES
  Widget _buildTeamStrategicBattles(Race race) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '⚔️ Strategic Team Battles',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 16),
        
        // Get team battles
        ..._getTeamBattleCards(),
        
        const SizedBox(height: 16),
        
        // Strategic Wild Cards
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.purple.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.purple.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.casino, color: Colors.purple.shade700),
                  const SizedBox(width: 8),
                  const Text(
                    'Strategic Wild Cards',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(_getStrategicWildCards()),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDriverSpotlight() {
    if (_drivers.isEmpty) return const Text('No driver data available');
    
    final topDriver = _drivers[0];
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.amber.shade50, Colors.orange.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: Colors.amber.shade200,
                child: Text(
                  '${topDriver.familyName.substring(0, 2).toUpperCase()}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.amber.shade800,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${topDriver.givenName} ${topDriver.familyName}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    Text(
                      topDriver.constructor,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      '${topDriver.points} points • P${topDriver.position}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFE10600),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            _analyzeDriverMomentum(topDriver),
            style: TextStyle(color: Colors.grey.shade700),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedTeammateBattles() {
    return _buildTeammateBattles(); // Reuse the same logic for now
  }

  Widget _buildPerformanceTrends() {
    return Column(
      children: _drivers.take(5).map((driver) => 
        Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${driver.givenName} ${driver.familyName}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                _analyzePressureLevel(driver),
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: driver.points / (_drivers.isNotEmpty ? _drivers[0].points : 1),
                backgroundColor: Colors.grey.shade300,
                valueColor: AlwaysStoppedAnimation<Color>(
                  driver.position <= 3 ? Colors.green : Colors.blue,
                ),
              ),
            ],
          ),
        )
      ).toList(),
    );
  }

  Widget _buildEmptyState({String message = 'No data available'}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.sports_motorsports,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Pull down to refresh',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  // 🧠 MISSING ANALYSIS HELPER METHODS
  String _assessOvertakingDifficulty(Race race) {
    final trackName = race.circuit.circuitName.toLowerCase();
    
    if (trackName.contains('monaco')) {
      return "🔴 VERY HIGH - Qualifying position crucial";
    } else if (trackName.contains('hungary') || trackName.contains('singapore')) {
      return "🟡 HIGH - Strategy more important than pace";
    } else if (trackName.contains('monza') || trackName.contains('spa') || trackName.contains('bahrain')) {
      return "🟢 LOW - Multiple overtaking opportunities";
    } else if (trackName.contains('silverstone') || trackName.contains('austin')) {
      return "🟡 MEDIUM - Good overtaking with DRS zones";
    } else {
      return "🟡 MEDIUM - Standard overtaking difficulty";
    }
  }

  String _assessTireDegradation(Race race) {
    final trackName = race.circuit.circuitName.toLowerCase();
    
    if (trackName.contains('silverstone') || trackName.contains('spa')) {
      return "🔴 HIGH - Fast corners stress tires heavily";
    } else if (trackName.contains('monaco') || trackName.contains('hungary')) {
      return "🟢 LOW - Slow speeds preserve tire life";
    } else if (trackName.contains('bahrain') || trackName.contains('austin')) {
      return "🟡 MEDIUM-HIGH - Hot conditions accelerate wear";
    } else {
      return "🟡 MEDIUM - Standard tire degradation expected";
    }
  }

  String _analyzeDriverMomentum(Driver driver) {
    final momentum = <String>[];
    
    // Championship position analysis
    if (driver.position == 1) {
      momentum.add("🏆 Championship leader with commanding presence");
    } else if (driver.position <= 3) {
      momentum.add("🥇 Podium contender with strong championship position");
    } else if (driver.position <= 10) {
      momentum.add("📈 Points contender fighting for better position");
    } else {
      momentum.add("🎯 Outside points, needs breakthrough performance");
    }
    
    // Team dynamics
    final teammates = _drivers.where((d) => d.constructor == driver.constructor && d.driverId != driver.driverId).toList();
    if (teammates.isNotEmpty) {
      final teammate = teammates.first;
      if (driver.points > teammate.points) {
        momentum.add("⚡ Leading teammate battle (+${driver.points - teammate.points} pts)");
      } else {
        momentum.add("🔄 Trailing teammate (-${teammate.points - driver.points} pts)");
      }
    }
    
    return momentum.join('\n');
  }

  String _analyzePressureLevel(Driver driver) {
    final pressureFactors = <String>[];
    
    if (driver.position == 1) {
      pressureFactors.add("Target on back as championship leader");
    } else if (driver.position <= 3) {
      pressureFactors.add("Must maintain podium challenge");
    } else if (driver.position >= 15) {
      pressureFactors.add("Under pressure to score points");
    }
    
    // Contract situation (simplified)
    if (driver.familyName == 'Hamilton' && driver.constructor == 'Ferrari') {
      pressureFactors.add("High expectations in Ferrari debut");
    }
    
    return pressureFactors.isNotEmpty 
        ? pressureFactors.join(' • ')
        : "Moderate pressure level";
  }

  // 🚀 NEW COMPREHENSIVE STRATEGY HELPER METHODS
  
  Widget _buildStrategyMetric(String label, String value, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: textColor.withOpacity(0.8),
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              color: textColor,
              fontWeight: FontWeight.bold,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  String _getTrackType(Race race) {
    final trackName = race.circuit.circuitName.toLowerCase();
    if (trackName.contains('monaco')) return 'Street Circuit';
    if (trackName.contains('monza') || trackName.contains('spa')) return 'High Speed';
    if (trackName.contains('hungary') || trackName.contains('singapore')) return 'Twisty';
    return 'Balanced';
  }

  String _getOvertakingLevel(Race race) {
    final trackName = race.circuit.circuitName.toLowerCase();
    if (trackName.contains('monaco')) return 'MINIMAL';
    if (trackName.contains('monza') || trackName.contains('bahrain')) return 'HIGH';
    if (trackName.contains('silverstone')) return 'GOOD';
    return 'MEDIUM';
  }

  String _getTireStressLevel(Race race) {
    final trackName = race.circuit.circuitName.toLowerCase();
    if (trackName.contains('silverstone') || trackName.contains('spa')) return 'EXTREME';
    if (trackName.contains('monaco')) return 'LOW';
    if (trackName.contains('bahrain') || trackName.contains('austin')) return 'HIGH';
    return 'MEDIUM';
  }

  String _getWeatherRisk(Race race) {
    final location = race.circuit.location.country.toLowerCase();
    if (location.contains('singapore') || location.contains('malaysia')) return 'VERY HIGH';
    if (location.contains('united kingdom') || location.contains('belgium')) return 'HIGH';
    if (location.contains('spain') || location.contains('bahrain')) return 'LOW';
    return 'MEDIUM';
  }

  Widget _buildStrategyOption(String title, String subtitle, String description, Color bgColor, Color textColor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: textColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: textColor,
              fontSize: 13,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: TextStyle(
              color: textColor.withOpacity(0.8),
              fontSize: 10,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: TextStyle(
              color: textColor.withOpacity(0.9),
              fontSize: 11,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  String _getAIRecommendation(Race race) {
    final trackType = _getTrackType(race);
    final overtaking = _getOvertakingLevel(race);
    final weather = _getWeatherRisk(race);
    
    if (weather == 'VERY HIGH') {
      return "🌧️ Wet weather wildcard strategy recommended. Start on intermediates, aggressive pit timing for advantage.";
    } else if (overtaking == 'MINIMAL') {
      return "🎯 Track position is everything. Qualify high, one-stop preferred, defend position aggressively.";
    } else if (trackType == 'High Speed') {
      return "🚀 Slipstream battles expected. Two-stop strategy, fresh tires for final stint attacks.";
    } else {
      return "⚖️ Balanced approach optimal. Monitor tire degradation, flexible pit window strategy.";
    }
  }

  Widget _buildTireCompoundCard(String compound, String spec, String duration, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        children: [
          Text(
            compound,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: textColor,
              fontSize: 10,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            spec,
            style: TextStyle(
              color: textColor.withOpacity(0.8),
              fontSize: 8,
            ),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 1),
          Text(
            duration,
            style: TextStyle(
              color: textColor,
              fontSize: 8,
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildPitWindow(String window, String laps, String strategy) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 50,
            child: Text(
              window,
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 10),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(
            width: 40,
            child: Text(
              laps,
              style: TextStyle(color: Colors.blue.shade700, fontSize: 10),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            child: Text(
              strategy,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 10),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  String _getChampionshipTireStrategy() {
    if (_drivers.isEmpty) return 'No championship data available';
    
    final leader = _drivers[0];
    final gap = _drivers.length > 1 ? leader.points - _drivers[1].points : 0;
    
    if (gap > 50) {
      return "🛡️ CONSERVATIVE: Leader should prioritize points finish over pace. One-stop with hard tires recommended.";
    } else if (gap < 20) {
      return "⚔️ AGGRESSIVE: Close championship battle demands risk-taking. Two-stop with soft tire advantage plays.";
    } else {
      return "⚖️ BALANCED: Moderate lead allows flexible strategy. Monitor competitors and react accordingly.";
    }
  }

  String _getWeatherAnalysis(Race race) {
    final location = race.circuit.location.country.toLowerCase();
    final month = DateTime.parse(race.date).month;
    
    if (location.contains('singapore')) {
      return "🌧️ TROPICAL STORM RISK: 70% chance of rain during race window. Intermediate tires essential preparation.";
    } else if (location.contains('united kingdom') && month >= 6 && month <= 8) {
      return "🌦️ UNPREDICTABLE BRITISH WEATHER: 40% rain probability. Teams must prepare for quick weather changes.";
    } else if (location.contains('spain') && month >= 6 && month <= 8) {
      return "☀️ STABLE CONDITIONS: 95% dry race probability. Focus on tire degradation management.";
    } else {
      return "🌤️ VARIABLE CONDITIONS: 25% rain chance. Standard wet weather preparations sufficient.";
    }
  }

  Widget _buildChaosFactorCard(String factor, String probability, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.orange.shade700, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              factor,
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            probability,
            style: TextStyle(
              color: Colors.orange.shade700,
              fontWeight: FontWeight.bold,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  String _getSafetyCarProbability(Race race) {
    final trackName = race.circuit.circuitName.toLowerCase();
    if (trackName.contains('monaco') || trackName.contains('singapore')) return 'HIGH (80%)';
    if (trackName.contains('bahrain') || trackName.contains('australia')) return 'MEDIUM (40%)';
    return 'LOW (20%)';
  }

  String _getRedFlagRisk(Race race) {
    final trackName = race.circuit.circuitName.toLowerCase();
    if (trackName.contains('monaco')) return 'HIGH (25%)';
    if (trackName.contains('singapore') || trackName.contains('azerbaijan')) return 'MEDIUM (15%)';
    return 'LOW (5%)';
  }

  String _getStrategicSurpriseFactor(Race race) {
    final weather = _getWeatherRisk(race);
    if (weather == 'VERY HIGH') return 'EXTREME (90%)';
    if (weather == 'HIGH') return 'HIGH (60%)';
    return 'MEDIUM (30%)';
  }

  String _getChampionshipStakes() {
    if (_drivers.length < 2) return 'Championship data loading...';
    
    final leader = _drivers[0];
    final challenger = _drivers[1];
    final gap = leader.points - challenger.points;
    final remainingRaces = _races.where((r) => DateTime.parse(r.date).isAfter(DateTime.now())).length;
    
    if (gap > remainingRaces * 25) {
      return "🏆 CHAMPIONSHIP DECIDED: ${leader.familyName} has mathematically secured the title!";
    } else if (gap < 25) {
      return "🔥 TITLE FIGHT ON FIRE: ${gap} points separate ${leader.familyName} and ${challenger.familyName}. Every point crucial!";
    } else {
      return "⚡ CHAMPIONSHIP PRESSURE: ${leader.familyName} leads by ${gap} points. ${challenger.familyName} needs consistent results.";
    }
  }

  Widget _buildChampionshipPositionStrategy(Driver driver, String role, Color color) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 12,
            backgroundColor: color.withOpacity(0.2),
            child: Text(
              '${driver.position}',
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 10,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${driver.familyName} ($role)',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  _getDriverStrategy(driver, role),
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 10),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getDriverStrategy(Driver driver, String role) {
    switch (role) {
      case 'LEADER':
        return 'Defensive strategy: Secure points, avoid unnecessary risks';
      case 'CHALLENGER':
        return 'Attack mode: Maximum points needed, risk-taking justified';
      case 'DARK HORSE':
        return 'Opportunistic: Capitalize on leader mistakes, consistent podiums';
      default:
        return 'Points focus: Every position matters for championship';
    }
  }

  List<Widget> _getTeamBattleCards() {
    final teamBattles = <String, List<Driver>>{};
    for (final driver in _drivers) {
      teamBattles.putIfAbsent(driver.constructor, () => []).add(driver);
    }
    
    return teamBattles.entries
        .where((entry) => entry.value.length == 2)
        .take(3)
        .map((entry) {
      final driver1 = entry.value[0];
      final driver2 = entry.value[1];
      final gap = (driver1.points - driver2.points).abs();
      
      return Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.indigo.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.indigo.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${entry.key} Internal Battle',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.indigo.shade700,
                fontSize: 12,
              ),
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    '${driver1.familyName} vs ${driver2.familyName}',
                    style: const TextStyle(fontSize: 11),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  '$gap pts',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo.shade700,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              _getTeamBattleStrategy(gap),
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 10,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      );
    }).toList();
  }

  String _getTeamBattleStrategy(int gap) {
    if (gap < 10) {
      return "🔥 Intense battle: Team orders unlikely, drivers free to race";
    } else if (gap < 25) {
      return "⚖️ Moderate gap: Strategic team coordination possible";
    } else {
      return "🛡️ Clear hierarchy: Team focus on leading driver";
    }
  }

  String _getStrategicWildCards() {
    return "🎲 Potential game-changers: Weather disruption, safety car timing, tire degradation surprises, strategic undercuts/overcuts, and championship desperation moves.";
  }
}
