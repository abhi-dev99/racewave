import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/race.dart';
import '../services/f1_api_service.dart';

class RacesScreen extends StatefulWidget {
  const RacesScreen({super.key});

  @override
  State<RacesScreen> createState() => _RacesScreenState();
}

class _RacesScreenState extends State<RacesScreen>
    with AutomaticKeepAliveClientMixin {
  final F1ApiService _apiService = F1ApiService();
  List<Race> _races = [];
  bool _isLoading = true;
  String? _error;
  dynamic _standings;

  @override
  bool get wantKeepAlive => true;

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
      final standings = await _apiService.getDriverStandings();

      setState(() {
        _races = races;
        _standings = standings;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          if (_isLoading)
            const SliverFillRemaining(
              child: Center(child: _LoadingWidget()),
            )
          else if (_error != null)
            SliverFillRemaining(
              child: _ErrorWidget(
                error: _error!,
                onRetry: _loadRaces,
              ),
            )
          else ...[
            _buildRacesList(),
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
        title: Text(
          'Races',
          style: Theme.of(context).textTheme.displayLarge?.copyWith(
                fontSize: 34,
                fontWeight: FontWeight.bold,
              ),
        ),
        expandedTitleScale: 1.0,
      ),
      actions: [
        IconButton(
          onPressed: () {
            HapticFeedback.lightImpact();
            _loadRaces();
          },
          icon: const Icon(Icons.refresh_rounded),
          tooltip: 'Refresh',
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildRacesList() {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 24), // Better margins
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final race = _races[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 20), // Better spacing
              child: _RaceCard(
                race: race,
                standings: _standings,
                onTap: () => _showRaceDetails(race),
              ),
            );
          },
          childCount: _races.length,
        ),
      ),
    );
  }

  void _showRaceDetails(Race race) {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _RaceDetailSheet(race: race),
    );
  }
}

class _RaceCard extends StatelessWidget {
  final Race race;
  final dynamic standings;
  final VoidCallback onTap;

  const _RaceCard({
    required this.race,
    this.standings,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final raceDate = DateTime.tryParse(race.date);
    final isUpcoming = raceDate?.isAfter(DateTime.now()) ?? false;
    final statusColor = isUpcoming ? const Color(0xFF34C759) : const Color(0xFF8E8E93);
    
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24), // More rounded
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08), // Better shadow
            blurRadius: 24,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(28), // Better padding
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
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
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: statusColor,
                              
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      isUpcoming ? Icons.schedule_rounded : Icons.flag_rounded,
                      color: statusColor,
                      size: 20,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  race.raceName,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.location_on_rounded,
                      size: 16,
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        '${race.circuit.location.locality}, ${race.circuit.location.country}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontSize: 14,
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
                      size: 16,
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _formatDate(race.date),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontSize: 14,
                          ),
                    ),
                    if (race.time != null) ...[
                      const SizedBox(width: 16),
                      Icon(
                        Icons.access_time_rounded,
                        size: 16,
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        race.time!,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontSize: 14,
                            ),
                      ),
                    ],
                  ],
                ),
                if (standings != null) ...[
                  const SizedBox(height: 16),
                  Divider(
                    height: 1,
                    color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Championship Leaders',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 8),
                  _buildStandingsPreview(context),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStandingsPreview(BuildContext context) {
    try {
      final driverStandings = standings?['DriverStandings'] as List? ?? [];
      final top3 = driverStandings.take(3).toList();

      if (top3.isEmpty) {
        return const SizedBox.shrink();
      }

      return Column(
        children: List.generate(top3.length, (index) {
          final standing = top3[index] as Map?;
          final driver = standing?['Driver'] as Map?;
          final points = standing?['points'];
          final position = standing?['position'];
          final driverName = driver?['givenName'] ?? '';
          final driverSurname = driver?['familyName'] ?? '';
          final fullName = '$driverName $driverSurname'.trim();

          return Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              children: [
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: index == 0
                        ? const Color(0xFFFFD700)
                        : index == 1
                            ? const Color(0xFFC0C0C0)
                            : const Color(0xFFCD7F32),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Center(
                    child: Text(
                      position?.toString() ?? '${index + 1}',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    fullName.isNotEmpty ? fullName : 'Driver',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  '$points pts',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFFE10600),
                      ),
                ),
              ],
            ),
          );
        }),
      );
    } catch (e) {
      return const SizedBox.shrink();
    }
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

class _RaceDetailSheet extends StatelessWidget {
  final Race race;

  const _RaceDetailSheet({required this.race});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.8,
      maxChildSize: 0.95,
      minChildSize: 0.6,
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
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(24),
                  children: [
                    _buildHeader(context),
                    const SizedBox(height: 32),
                    _buildInfoSection(context, 'Circuit Information', [
                      _InfoRow('Circuit Name', race.circuit.circuitName),
                      _InfoRow('Location', '${race.circuit.location.locality}, ${race.circuit.location.country}'),
                      _InfoRow('Coordinates', '${race.circuit.location.lat}, ${race.circuit.location.long}'),
                    ]),
                    const SizedBox(height: 24),
                    _buildInfoSection(context, 'Race Schedule', [
                      _InfoRow('Date', _formatDate(race.date)),
                      if (race.time != null) _InfoRow('Time', race.time!),
                      _InfoRow('Season', race.season),
                    ]),
                    const SizedBox(height: 24),
                    _buildStrategyCard(context),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    final raceDate = DateTime.tryParse(race.date);
    final isUpcoming = raceDate?.isAfter(DateTime.now()) ?? false;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: (isUpcoming ? const Color(0xFF34C759) : const Color(0xFF8E8E93)).withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            'Round ${race.round} • ${race.season}',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isUpcoming ? const Color(0xFF34C759) : const Color(0xFF8E8E93),
              
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          race.raceName,
          style: Theme.of(context).textTheme.displayMedium?.copyWith(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          '${race.circuit.location.locality}, ${race.circuit.location.country}',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontSize: 16,
              ),
        ),
      ],
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
                    Flexible(
                      child: Text(
                        row.value,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                        textAlign: TextAlign.end,
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

  Widget _buildStrategyCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFFF9500).withOpacity(0.1),
            const Color(0xFFFF9500).withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.sports_motorsports_rounded,
                color: Color(0xFFFF9500),
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Race Strategy',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: const Color(0xFFFF9500),
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Race strategy analysis, weather predictions, and pit stop recommendations coming soon.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String dateString) {
    final date = DateTime.tryParse(dateString);
    if (date == null) return dateString;

    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];

    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}

class _InfoRow {
  final String label;
  final String value;

  _InfoRow(this.label, this.value);
}

class _LoadingWidget extends StatelessWidget {
  const _LoadingWidget();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const CircularProgressIndicator(),
        const SizedBox(height: 16),
        Text(
          'Loading race calendar...',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ],
    );
  }
}

class _ErrorWidget extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;

  const _ErrorWidget({
    required this.error,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                size: 40,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Something went wrong',
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try Again'),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFFF9500),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
