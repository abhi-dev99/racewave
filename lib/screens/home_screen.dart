import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import 'welcome_screen_redesigned.dart';
import 'drivers_screen.dart';
import 'races_screen.dart';
import 'strategy_screen_redesigned.dart';
import 'standings_screen_redesigned.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late PageController _pageController;
  int _currentIndex = 0;
  late AnimationController _fabAnimationController;
  late Animation<double> _fabAnimation;

  // Cache screens for better performance
  late final List<Widget> _screens;

  final List<TabItem> _tabItems = [
    TabItem(
      icon: Icons.home_rounded,
      activeIcon: Icons.home,
      label: 'Home',
      color: const Color(0xFFE10600),
    ),
    TabItem(
      icon: Icons.person_rounded,
      activeIcon: Icons.person,
      label: 'Drivers',
      color: const Color(0xFF007AFF),
    ),
    TabItem(
      icon: Icons.sports_motorsports_rounded,
      activeIcon: Icons.sports_motorsports,
      label: 'Races',
      color: const Color(0xFFFF9500),
    ),
    TabItem(
      icon: Icons.leaderboard_rounded,
      activeIcon: Icons.leaderboard,
      label: 'Standings',
      color: const Color(0xFF34C759),
    ),
    TabItem(
      icon: Icons.analytics_rounded,
      activeIcon: Icons.analytics,
      label: 'Strategy',
      color: const Color(0xFFAF52DE),
    ),
  ];

  @override
  void initState() {
    super.initState();
    
    // Initialize cached screens for better performance
    _screens = const [
      WelcomeScreen(),
      DriversScreen(),
      RacesScreen(),
      StandingsScreenRedesigned(),
      StrategyScreen(),
    ];
    
    _pageController = PageController();
    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200), // Faster animations
      vsync: this,
    );
    _fabAnimation = CurvedAnimation(
      parent: _fabAnimationController,
      curve: Curves.easeOutCubic, // Smoother curve
    );
    _fabAnimationController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fabAnimationController.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    if (_currentIndex != index) {
      HapticFeedback.selectionClick(); // Lighter haptic feedback
      setState(() {
        _currentIndex = index;
      });
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 200), // Faster transitions
        curve: Curves.easeOutCubic, // Smoother curve
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: RepaintBoundary( // Performance optimization
        child: PageView(
          controller: _pageController,
          onPageChanged: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          physics: const BouncingScrollPhysics(), // iOS-style physics
          children: _screens,
        ),
      ),
      bottomNavigationBar: _buildCustomTabBar(),
      floatingActionButton: _currentIndex == 4
          ? ScaleTransition(
              scale: _fabAnimation,
              child: FloatingActionButton.extended(
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Strategy tab active. Adjust laps, tire, and pit window to simulate race pace.'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                backgroundColor: const Color(0xFFE10600),
                foregroundColor: Colors.white,
                elevation: 4,
                icon: const Icon(Icons.flash_on),
                label: const Text(
                  'Strategy Tip',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildCustomTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withOpacity(0.8),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
          width: 0.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            height: 80,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: _tabItems.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                final isSelected = _currentIndex == index;
                
                return Expanded(
                  child: GestureDetector(
                    onTap: () => _onTabTapped(index),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeInOut,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? item.color.withOpacity(0.15)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            isSelected ? item.activeIcon : item.icon,
                            color: isSelected
                                ? item.color
                                : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                            size: 24,
                          ),
                          const SizedBox(height: 4),
                          AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 200),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                              color: isSelected
                                  ? item.color
                                  : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                            ),
                            child: Text(item.label),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}

class TabItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final Color color;

  TabItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.color,
  });
}
