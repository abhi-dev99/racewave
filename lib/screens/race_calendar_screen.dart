import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/race.dart';
import '../services/f1_api_service.dart';

class RaceCalendarScreen extends StatefulWidget {
  const RaceCalendarScreen({super.key});

  @override
  State<RaceCalendarScreen> createState() => _RaceCalendarScreenState();
}

class _RaceCalendarScreenState extends State<RaceCalendarScreen> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  final F1ApiService _apiService = F1ApiService();
  List<Race> _races = [];
  bool _isLoading = true;
  String? _error;
  String _viewMode = 'calendar'; // 'calendar' or 'list'
  DateTime _selectedMonth = DateTime.now();
  String _seasonLabel = 'Current';

  @override
  void initState() {
    super.initState();
    _loadRaces();
  }

  Future<void> _loadRaces() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final races = await _apiService.getCurrentRaces();

      if (!mounted) return;
      setState(() {
        _races = races;
        if (_races.isNotEmpty && _races.first.season.isNotEmpty) {
          _seasonLabel = _races.first.season;
        }
        final firstRaceDate = DateTime.tryParse(_races.isNotEmpty ? _races.first.date : '');
        if (firstRaceDate != null) {
          _selectedMonth = DateTime(firstRaceDate.year, firstRaceDate.month);
        }
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

  List<Race> _getRacesForMonth(DateTime month) {
    return _races.where((race) {
      final raceDate = DateTime.tryParse(race.date);
      return raceDate != null &&
          raceDate.year == month.year &&
          raceDate.month == month.month;
    }).toList();
  }

  void _changeMonth(int delta) {
    setState(() {
      _selectedMonth = DateTime(
        _selectedMonth.year,
        _selectedMonth.month + delta,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
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
                        onPressed: _loadRaces,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              )
            else
              Expanded(
                child: _viewMode == 'calendar'
                    ? _buildCalendarView(isDark, isCompact)
                    : _buildListView(isDark, isCompact),
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
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Race Calendar',
                      style: TextStyle(
                        fontSize: isCompact ? 26 : 32,
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white : Colors.black,
                        letterSpacing: -1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_races.length} races in $_seasonLabel season',
                      style: TextStyle(
                        fontSize: isCompact ? 12 : 14,
                        color: isDark ? Colors.white.withValues(alpha: 0.6) : Colors.black.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
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
                    _ViewModeButton(
                      icon: Icons.calendar_month_rounded,
                      isSelected: _viewMode == 'calendar',
                      isDark: isDark,
                      onTap: () => setState(() => _viewMode = 'calendar'),
                    ),
                    const SizedBox(width: 4),
                    _ViewModeButton(
                      icon: Icons.list_rounded,
                      isSelected: _viewMode == 'list',
                      isDark: isDark,
                      onTap: () => setState(() => _viewMode = 'list'),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (_viewMode == 'calendar') ...[
            SizedBox(height: isCompact ? 12 : 20),
            _buildMonthSelector(isDark),
          ],
        ],
      ),
    );
  }

  Widget _buildMonthSelector(bool isDark) {
    return Row(
      children: [
        IconButton(
          onPressed: () => _changeMonth(-1),
          icon: const Icon(Icons.chevron_left_rounded),
          color: isDark ? Colors.white : Colors.black,
        ),
        Expanded(
          child: Center(
            child: Text(
              DateFormat('MMMM yyyy').format(_selectedMonth),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
          ),
        ),
        IconButton(
          onPressed: () => _changeMonth(1),
          icon: const Icon(Icons.chevron_right_rounded),
          color: isDark ? Colors.white : Colors.black,
        ),
      ],
    );
  }

  Widget _buildCalendarView(bool isDark, bool isCompact) {
    final racesThisMonth = _getRacesForMonth(_selectedMonth);
    final firstDayOfMonth = DateTime(_selectedMonth.year, _selectedMonth.month, 1);
    final daysInMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1, 0).day;
    final firstWeekday = firstDayOfMonth.weekday % 7; // 0 = Sunday

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // Calendar grid
          Container(
            padding: EdgeInsets.all(isCompact ? 10 : 16),
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
            child: Column(
              children: [
                // Weekday headers
                Row(
                  children: ['S', 'M', 'T', 'W', 'T', 'F', 'S'].map((day) {
                    return Expanded(
                      child: Center(
                        child: Text(
                          day,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.5)
                                : Colors.black.withValues(alpha: 0.5),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 12),
                // Calendar days
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 7,
                    childAspectRatio: 1,
                  ),
                  itemCount: firstWeekday + daysInMonth,
                  itemBuilder: (context, index) {
                    if (index < firstWeekday) {
                      return const SizedBox();
                    }

                    final day = index - firstWeekday + 1;
                    final date = DateTime(_selectedMonth.year, _selectedMonth.month, day);
                    final race = racesThisMonth.firstWhere(
                      (r) => DateTime.tryParse(r.date)?.day == day,
                      orElse: () => Race(
                        season: '',
                        round: '',
                        raceName: '',
                        circuit: Circuit(
                          circuitId: '',
                          circuitName: '',
                          location: Location(
                            locality: '',
                            country: '',
                            lat: '',
                            long: '',
                          ),
                        ),
                        date: '',
                        time: null,
                      ),
                    );

                    final hasRace = race.round.isNotEmpty;
                    final isToday = date.day == DateTime.now().day &&
                        date.month == DateTime.now().month &&
                        date.year == DateTime.now().year;

                    return GestureDetector(
                      onTap: hasRace ? () => _showRaceDetails(race) : null,
                      child: Container(
                        margin: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: hasRace
                              ? const Color(0xFFE10600).withValues(alpha: 0.15)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isToday
                                ? const Color(0xFF007AFF)
                                : hasRace
                                    ? const Color(0xFFE10600).withValues(alpha: 0.3)
                                    : Colors.transparent,
                            width: isToday ? 2 : 1,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '$day',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: hasRace ? FontWeight.w800 : FontWeight.w500,
                                color: hasRace
                                    ? const Color(0xFFE10600)
                                    : (isDark ? Colors.white : Colors.black),
                              ),
                            ),
                            if (hasRace)
                              Container(
                                margin: const EdgeInsets.only(top: 2),
                                width: 4,
                                height: 4,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFE10600),
                                  shape: BoxShape.circle,
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Races this month
          if (racesThisMonth.isNotEmpty) ...[
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Races This Month',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
            ),
            const SizedBox(height: 12),
            ...racesThisMonth.map((race) => _buildRaceCard(race, isDark, isCompact: isCompact)),
          ],
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildListView(bool isDark, bool isCompact) {
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: isCompact ? 12 : 20),
      itemCount: _races.length,
      itemBuilder: (context, index) {
        return _buildRaceCard(_races[index], isDark, isCompact: isCompact);
      },
    );
  }

  Widget _buildRaceCard(Race race, bool isDark, {bool isCompact = false}) {
    final raceDate = DateTime.tryParse(race.date);
    final isUpcoming = raceDate?.isAfter(DateTime.now()) ?? false;
    final statusColor = isUpcoming ? const Color(0xFF34C759) : const Color(0xFF8E8E93);
    final daysUntil = raceDate?.difference(DateTime.now()).inDays ?? 0;

    return Container(
      margin: EdgeInsets.only(bottom: isCompact ? 8 : 12),
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showRaceDetails(race),
          borderRadius: BorderRadius.circular(isCompact ? 12 : 16),
          child: Padding(
            padding: EdgeInsets.all(isCompact ? 14 : 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: statusColor,
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Round ${race.round}',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: statusColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isUpcoming && daysUntil > 0 && daysUntil <= 30)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE10600).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '$daysUntil day${daysUntil != 1 ? 's' : ''} to go',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFFE10600),
                          ),
                        ),
                      ),
                  ],
                ),
                SizedBox(height: isCompact ? 10 : 14),
                Text(
                  race.raceName,
                  style: TextStyle(
                    fontSize: isCompact ? 15 : 18,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.location_on_rounded,
                      size: 14,
                      color: isDark ? Colors.white.withValues(alpha: 0.5) : Colors.black.withValues(alpha: 0.5),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        '${race.circuit.location.locality}, ${race.circuit.location.country}',
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? Colors.white.withValues(alpha: 0.6) : Colors.black.withValues(alpha: 0.6),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today_rounded,
                      size: 14,
                      color: isDark ? Colors.white.withValues(alpha: 0.5) : Colors.black.withValues(alpha: 0.5),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _formatDate(race.date),
                      style: TextStyle(
                        fontSize: isCompact ? 11 : 13,
                        color: isDark ? Colors.white.withValues(alpha: 0.6) : Colors.black.withValues(alpha: 0.6),
                      ),
                    ),
                    if (race.time != null) ...[
                      const SizedBox(width: 12),
                      Icon(
                        Icons.access_time_rounded,
                        size: 14,
                        color: isDark ? Colors.white.withValues(alpha: 0.5) : Colors.black.withValues(alpha: 0.5),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        race.time!.substring(0, 5),
                        style: TextStyle(
                          fontSize: isCompact ? 11 : 13,
                          color: isDark ? Colors.white.withValues(alpha: 0.6) : Colors.black.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('MMM d, yyyy').format(date);
    } catch (e) {
      return dateStr;
    }
  }

  void _showRaceDetails(Race race) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF0A0A0A) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white.withValues(alpha: 0.2) : Colors.black.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              race.raceName,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 20),
            _buildDetailRow(Icons.stadium_rounded, 'Circuit', race.circuit.circuitName, isDark),
            _buildDetailRow(Icons.location_city_rounded, 'Location',
                '${race.circuit.location.locality}, ${race.circuit.location.country}', isDark),
            _buildDetailRow(Icons.calendar_month_rounded, 'Date', _formatDate(race.date), isDark),
            if (race.time != null)
              _buildDetailRow(Icons.schedule_rounded, 'Time', race.time!.substring(0, 5), isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFE10600).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: const Color(0xFFE10600),
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
                    fontSize: 12,
                    color: isDark ? Colors.white.withValues(alpha: 0.6) : Colors.black.withValues(alpha: 0.6),
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
      ),
    );
  }
}

class _ViewModeButton extends StatelessWidget {
  final IconData icon;
  final bool isSelected;
  final bool isDark;
  final VoidCallback onTap;

  const _ViewModeButton({
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
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? Colors.white : Colors.black)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          size: 18,
          color: isSelected
              ? (isDark ? Colors.black : Colors.white)
              : (isDark ? Colors.white.withValues(alpha: 0.5) : Colors.black.withValues(alpha: 0.5)),
        ),
      ),
    );
  }
}
