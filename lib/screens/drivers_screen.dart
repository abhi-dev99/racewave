import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/driver.dart';
import '../services/f1_api_service.dart';

class DriversScreen extends StatefulWidget {
  const DriversScreen({super.key});

  @override
  State<DriversScreen> createState() => _DriversScreenState();
}

class _DriversScreenState extends State<DriversScreen>
    with AutomaticKeepAliveClientMixin {
  final F1ApiService _apiService = F1ApiService();
  List<Driver> _drivers = [];
  bool _isLoading = true;
  String? _error;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadDrivers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadDrivers() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final drivers = await _apiService.getCurrentDrivers();
      setState(() {
        _drivers = drivers;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  List<Driver> get _filteredDrivers {
    if (_searchQuery.isEmpty) return _drivers;
    return _drivers.where((driver) {
      final query = _searchQuery.toLowerCase();
      return driver.fullName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          driver.nationality.toLowerCase().contains(query) ||
          (driver.code?.toLowerCase().contains(query) ?? false) ||
          driver.constructor.toLowerCase().contains(query) ||
          (driver.number?.contains(_searchQuery) ?? false);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      body: RefreshIndicator.adaptive(
        onRefresh: _loadDrivers,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
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
                  onRetry: _loadDrivers,
                ),
              )
            else ...[
              _buildSearchBar(),
              _buildDriversGrid(),
              const SliverToBoxAdapter(
                child: SizedBox(height: 100),
              ),
            ],
          ],
        ),
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
          'Drivers',
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
            _loadDrivers();
          },
          icon: const Icon(Icons.refresh_rounded),
          tooltip: 'Refresh',
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildSearchBar() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF0A0A0A) : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : Colors.black.withValues(alpha: 0.05),
              width: 1,
            ),
          ),
          child: TextField(
            controller: _searchController,
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black,
              fontSize: 15,
            ),
            decoration: InputDecoration(
              hintText: 'Search by name, team, number, nationality, or code...',
              hintStyle: TextStyle(
                color: isDark ? Colors.white.withValues(alpha: 0.4) : Colors.black.withValues(alpha: 0.4),
                fontSize: 15,
              ),
              prefixIcon: Icon(
                Icons.search_rounded,
                color: isDark ? Colors.white.withValues(alpha: 0.6) : Colors.black.withValues(alpha: 0.6),
                size: 22,
              ),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          _searchQuery = '';
                        });
                      },
                      icon: Icon(
                        Icons.clear_rounded,
                        color: isDark ? Colors.white.withValues(alpha: 0.6) : Colors.black.withValues(alpha: 0.6),
                        size: 20,
                      ),
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDriversGrid() {
    final filteredDrivers = _filteredDrivers;
    
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final driver = filteredDrivers[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 16), // Better spacing
              child: _DriverCard(
                driver: driver,
                onTap: () => _showDriverDetails(driver),
              ),
            );
          },
          childCount: filteredDrivers.length,
        ),
      ),
    );
  }

  void _showDriverDetails(Driver driver) {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _DriverDetailSheet(driver: driver),
    );
  }
}

class _DriverCard extends StatelessWidget {
  final Driver driver;
  final VoidCallback onTap;

  const _DriverCard({
    required this.driver,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isCompact = MediaQuery.sizeOf(context).width < 430;
    
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
          onTap: onTap,
          borderRadius: BorderRadius.circular(isCompact ? 12 : 16),
          child: Padding(
            padding: EdgeInsets.all(isCompact ? 12 : 16),
            child: Row(
              children: [
                // Driver Photo
                Container(
                  width: isCompact ? 54 : 70,
                  height: isCompact ? 54 : 70,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        F1ApiService.getTeamColor(driver.constructor).withValues(alpha: 0.2),
                        F1ApiService.getTeamColor(driver.constructor).withValues(alpha: 0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(isCompact ? 10 : 12),
                    border: Border.all(
                      color: F1ApiService.getTeamColor(driver.constructor).withValues(alpha: 0.3),
                      width: 2,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(isCompact ? 8 : 10),
                    child: CachedNetworkImage(
                      imageUrl: F1ApiService.getDriverPhotoUrl(driver.driverId),
                      fit: BoxFit.cover,
                      memCacheWidth: isCompact ? 120 : 180,
                      fadeInDuration: const Duration(milliseconds: 120),
                      placeholder: (context, url) {
                        return Center(
                          child: SizedBox(
                            width: isCompact ? 16 : 20,
                            height: isCompact ? 16 : 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation(
                                F1ApiService.getTeamColor(driver.constructor),
                              ),
                            ),
                          ),
                        );
                      },
                      errorWidget: (context, url, error) {
                        return Center(
                          child: Text(
                            driver.code ?? driver.givenName[0],
                            style: TextStyle(
                              fontSize: isCompact ? 16 : 20,
                              fontWeight: FontWeight.w900,
                              color: F1ApiService.getTeamColor(driver.constructor),
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
                        driver.fullName,
                        style: TextStyle(
                          fontSize: isCompact ? 14 : 16,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: isCompact ? 2 : 4),
                      Row(
                        children: [
                          if (driver.number != null) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: F1ApiService.getTeamColor(driver.constructor).withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '#${driver.number}',
                                style: TextStyle(
                                    fontSize: isCompact ? 10 : 11,
                                  fontWeight: FontWeight.w700,
                                  color: F1ApiService.getTeamColor(driver.constructor),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                          ],
                          Flexible(
                            child: Text(
                              driver.nationality,
                              style: TextStyle(
                                fontSize: isCompact ? 11 : 13,
                                color: isDark ? Colors.white.withValues(alpha: 0.6) : Colors.black.withValues(alpha: 0.6),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      if (driver.constructor.isNotEmpty) ...[
                        SizedBox(height: isCompact ? 2 : 4),
                        Row(
                          children: [
                            Container(
                              width: isCompact ? 10 : 12,
                              height: isCompact ? 10 : 12,
                              decoration: BoxDecoration(
                                color: F1ApiService.getTeamColor(driver.constructor),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                driver.constructor,
                                style: TextStyle(
                                  fontSize: isCompact ? 10 : 12,
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? Colors.white.withValues(alpha: 0.8) : Colors.black.withValues(alpha: 0.8),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: isDark ? Colors.white.withValues(alpha: 0.2) : Colors.black.withValues(alpha: 0.2),
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DriverDetailSheet extends StatelessWidget {
  final Driver driver;

  const _DriverDetailSheet({required this.driver});

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

                    _buildStatsGrid(isDark),
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

  Widget _buildStatsGrid(bool isDark) {
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
          'Loading F1 drivers...',
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
                backgroundColor: const Color(0xFFE10600),
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
