import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/splash_screen_final.dart';
import 'services/notification_service.dart';

void main() {
  // Performance optimizations for smooth UI
  WidgetsFlutterBinding.ensureInitialized();
  
  // Enable hardware acceleration and optimize rendering
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  
  // Optimize for 60fps smooth animations
  WidgetsBinding.instance.addPostFrameCallback((_) {
    // Pre-cache critical fonts for instant rendering
    GoogleFonts.workSans();
  });
  
  runApp(const F1StrategyApp());
}

class F1StrategyApp extends StatelessWidget {
  const F1StrategyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'F1 Strategy Hub',
      theme: _buildLightTheme(),
      darkTheme: _buildDarkTheme(),
      themeMode: ThemeMode.system,
      home: const SplashScreen(),
      debugShowCheckedModeBanner: false,
      scaffoldMessengerKey: F1NotificationService.messengerKey,
      // Performance optimizations for smooth experience
      builder: (context, child) {
        return MediaQuery(
          // Disable text scaling to maintain design integrity
          data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
          child: child!,
        );
      },
      // Enable smooth transitions
      onGenerateRoute: (settings) {
        return PageRouteBuilder(
          settings: settings,
          pageBuilder: (context, animation, secondaryAnimation) {
            return const SplashScreen();
          },
          transitionDuration: const Duration(milliseconds: 200),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.0, 0.03),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              )),
              child: FadeTransition(
                opacity: animation,
                child: child,
              ),
            );
          },
        );
      },
    );
  }

  ThemeData _buildLightTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      // Using Work Sans - closest to Neue Haas Grotesk Pro
      textTheme: GoogleFonts.workSansTextTheme(
        const TextTheme(
          // Ultra-crisp display text
          displayLarge: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w700,
            color: Color(0xFF000000), // Pure black for maximum contrast
            letterSpacing: -0.8, // Tight spacing for precision
            height: 1.05, // Ultra-compact line height
          ),
          displayMedium: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: Color(0xFF000000),
            letterSpacing: -0.6,
            height: 1.1,
          ),
          headlineMedium: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF000000),
            letterSpacing: -0.4,
            height: 1.15,
          ),
          // Clean body text
          bodyLarge: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: Color(0xFF000000),
            letterSpacing: -0.2,
            height: 1.4,
          ),
          bodyMedium: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: Color(0xFF666666), // Sharp gray for hierarchy
            letterSpacing: -0.1,
            height: 1.35,
          ),
        ),
      ),
      colorScheme: const ColorScheme.light(
        primary: Color(0xFF000000), // Pure black primary
        secondary: Color(0xFFE10600), // F1 Red as accent only
        surface: Color(0xFFFFFFFF), // Pure white surfaces
        surfaceContainerHighest: Color(0xFFF8F8F8), // Subtle gray
        onSurface: Color(0xFF000000),
        outline: Color(0xFFE0E0E0), // Clean separator lines
      ),
      scaffoldBackgroundColor: const Color(0xFFFFFFFF), // Pure white background
      appBarTheme: AppBarTheme(
        backgroundColor: const Color(0xFFFFFFFF),
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        titleTextStyle: GoogleFonts.workSans(
          color: const Color(0xFF000000),
          fontSize: 20,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.5,
        ),
        surfaceTintColor: Colors.transparent,
      ),
      cardTheme: const CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(2)), // Sharp, minimal corners
        ),
        color: Color(0xFFFFFFFF),
        surfaceTintColor: Colors.transparent,
      ),
    );
  }

  ThemeData _buildDarkTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      textTheme: GoogleFonts.workSansTextTheme(
        const TextTheme(
          // Ultra-crisp display text for dark mode
          displayLarge: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w700,
            color: Color(0xFFFFFFFF), // Pure white for maximum contrast
            letterSpacing: -0.8,
            height: 1.05,
          ),
          displayMedium: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: Color(0xFFFFFFFF),
            letterSpacing: -0.6,
            height: 1.1,
          ),
          headlineMedium: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFFFFFFFF),
            letterSpacing: -0.4,
            height: 1.15,
          ),
          bodyLarge: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: Color(0xFFFFFFFF),
            letterSpacing: -0.2,
            height: 1.4,
          ),
          bodyMedium: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: Color(0xFF999999), // Clean gray for hierarchy
            letterSpacing: -0.1,
            height: 1.35,
          ),
        ),
      ),
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFFFFFFFF), // Pure white primary
        secondary: Color(0xFFE10600), // F1 Red as accent
        surface: Color(0xFF000000), // Pure black surfaces
        surfaceContainerHighest: Color(0xFF111111), // Subtle dark gray
        onSurface: Color(0xFFFFFFFF),
        outline: Color(0xFF333333), // Clean dark separator lines
      ),
      scaffoldBackgroundColor: const Color(0xFF000000), // Pure black background
      appBarTheme: AppBarTheme(
        backgroundColor: const Color(0xFF000000),
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: GoogleFonts.workSans(
          color: const Color(0xFFFFFFFF),
          fontSize: 20,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.5,
        ),
        surfaceTintColor: Colors.transparent,
      ),
      cardTheme: const CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(2)), // Sharp, minimal corners
        ),
        color: Color(0xFF000000),
        surfaceTintColor: Colors.transparent,
      ),
    );
  }
}
