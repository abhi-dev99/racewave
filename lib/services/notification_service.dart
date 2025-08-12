import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class F1NotificationService {
  static final GlobalKey<ScaffoldMessengerState> _messengerKey = 
    GlobalKey<ScaffoldMessengerState>();
  
  static GlobalKey<ScaffoldMessengerState> get messengerKey => _messengerKey;
  
  static void showLiveUpdate({
    required String title,
    required String message,
    Color color = const Color(0xFFE10600),
    IconData icon = Icons.speed,
    Duration duration = const Duration(seconds: 4),
  }) {
    _messengerKey.currentState?.showSnackBar(
      SnackBar(
        duration: duration,
        backgroundColor: Colors.transparent,
        elevation: 0,
        content: Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                color.withOpacity(0.9),
                color.withOpacity(0.7),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 20,
                spreadRadius: 5,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 25,
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      message,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.notifications_active,
                color: Colors.white.withOpacity(0.8),
                size: 20,
              ),
            ],
          ),
        )
          .animate()
          .slideX(begin: 1, duration: 600.ms, curve: Curves.elasticOut)
          .fadeIn(duration: 400.ms),
      ),
    );
  }
  
  static void showDataRefresh() {
    showLiveUpdate(
      title: 'Data Updated',
      message: 'Latest F1 standings and race data loaded',
      icon: Icons.refresh,
      color: const Color(0xFF34C759),
    );
  }
  
  static void showRaceUpdate(String raceName) {
    showLiveUpdate(
      title: 'Race Alert',
      message: 'Next up: $raceName',
      icon: Icons.sports_motorsports,
      color: const Color(0xFFFF9500),
    );
  }
  
  static void showChampionshipUpdate(String driverName, int points) {
    showLiveUpdate(
      title: 'Championship Update',
      message: '$driverName leads with $points points!',
      icon: Icons.emoji_events,
      color: const Color(0xFFFFD700),
    );
  }
  
  static void showStrategyTip() {
    final tips = [
      'Hard tires perform better in hot conditions',
      'Pit stop windows are crucial for race strategy',
      'Weather changes can completely alter strategy',
      'Undercut vs Overcut - timing is everything',
      'Tire degradation varies by track surface',
    ];
    
    tips.shuffle();
    
    showLiveUpdate(
      title: 'Strategy Tip',
      message: tips.first,
      icon: Icons.lightbulb,
      color: const Color(0xFFAF52DE),
    );
  }
}
