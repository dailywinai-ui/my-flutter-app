import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import './services/auth_service.dart';
import './services/supabase_service.dart';
import './widgets/custom_error_widget.dart';
import 'core/app_export.dart';

// Global navigator key for deep link navigation
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  try {
    await SupabaseService.initialize();
    debugPrint('✅ Supabase initialized successfully');
  } catch (e) {
    debugPrint('❌ Failed to initialize Supabase: $e');
    // Continue with the app even if Supabase fails to initialize
  }

  // Set up deep link listener for password recovery
  _setupDeepLinkListener();

  bool _hasShownError = false;

  // 🚨 CRITICAL: Custom error handling - DO NOT REMOVE
  ErrorWidget.builder = (FlutterErrorDetails details) {
    if (!_hasShownError) {
      _hasShownError = true;

      // Reset flag after 3 seconds to allow error widget on new screens
      Future.delayed(Duration(seconds: 5), () {
        _hasShownError = false;
      });

      return CustomErrorWidget(errorDetails: details);
    }
    return SizedBox.shrink();
  };

  // 🚨 CRITICAL: Device orientation lock - DO NOT REMOVE
  Future.wait([
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]),
  ]).then((value) {
    runApp(MyApp());
  });
}

// Deep link listener for password recovery
void _setupDeepLinkListener() {
  try {
    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      final event = data.event;
      
      debugPrint('🔐 Auth event: $event');
      
      // Handle password recovery
      if (event == AuthChangeEvent.passwordRecovery) {
        debugPrint('🔥 Password recovery detected - navigating to reset screen');
        
        // Use a slight delay to ensure navigator is ready
        Future.delayed(Duration(milliseconds: 500), () {
          navigatorKey.currentState?.pushNamed(AppRoutes.resetPassword);
        });
      }
    });
    debugPrint('✅ Deep link listener set up successfully');
  } catch (e) {
    debugPrint('❌ Failed to set up deep link listener: $e');
  }
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _initialRoute = AppRoutes.splash;

  @override
  void initState() {
    super.initState();
    _determineInitialRoute();
  }

  Future<void> _determineInitialRoute() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final hasSeenOnboarding = prefs.getBool('seen_onboarding') ?? false;
      final isSignedIn = AuthService.instance.isSignedIn;

      String initialRoute;

      if (isSignedIn) {
        // Signed-in user: go directly to main app
        initialRoute = AppRoutes.today;
      } else if (hasSeenOnboarding) {
        // Returning user who completed onboarding but isn't signed in: go to authentication
        initialRoute = AppRoutes.authentication;
      } else {
        // First-time user: start with authentication, then onboarding after account creation
        initialRoute = AppRoutes.authentication;
      }

      if (mounted) {
        setState(() {
          _initialRoute = initialRoute;
        });
      }
    } catch (e) {
      debugPrint('Error determining initial route: $e');
      // Fallback to authentication screen on error
      if (mounted) {
        setState(() {
          _initialRoute = AppRoutes.authentication;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (context, orientation, screenType) {
        return MaterialApp(
          title: 'WinDaily - Track Your Daily Wins',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.light,
          navigatorKey: navigatorKey, // ← ADDED: Navigator key for deep links
          // 🚨 CRITICAL: NEVER REMOVE OR MODIFY
          builder: (context, child) {
            return MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(textScaler: TextScaler.linear(1.0)),
              child: child!,
            );
          },
          // 🚨 END CRITICAL SECTION
          debugShowCheckedModeBanner: false,
          routes: AppRoutes.routes,
          initialRoute: _initialRoute,
        );
      },
    );
  }
}