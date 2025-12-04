import 'package:flutter/material.dart';
import '../presentation/win_detail_screen/win_detail_screen.dart';
import '../presentation/settings_screen/settings_screen.dart';
import '../presentation/today_screen/today_screen.dart';
import '../presentation/history_screen/history_screen.dart';
import '../presentation/authentication_screen/authentication_screen.dart';
import '../presentation/authentication_screen/reset_password_screen.dart';
import '../presentation/add_win_modal/add_win_modal.dart';
import '../presentation/splash_screen/splash_screen.dart';
import '../presentation/privacy_policy_screen/privacy_policy_screen.dart';
import '../presentation/reflection_screen/reflection_screen.dart';
import '../presentation/insights_screen/insights_screen.dart';
import '../presentation/onboarding_screen/onboarding_intro_screen.dart';
import '../presentation/welcome_screen/welcome_screen.dart';

class AppRoutes {
  // Splash screen route
  static const String splash = '/splash';
  static const String initial = splash;

  // Authentication routes
  static const String authentication = '/authentication-screen';
  static const String resetPassword = '/reset-password-screen';

  // Onboarding routes
  static const String onboardingIntro = '/onboarding-intro';
  static const String welcome = '/welcome-screen';

  // Main app routes
  static const String winDetail = '/win-detail-screen';
  static const String settings = '/settings-screen';
  static const String today = '/today-screen';
  static const String history = '/history-screen';
  static const String insights = '/insights-screen';
  static const String addWinModal = '/add-win-modal';
  static const String privacyPolicy = '/privacy-policy';
  static const String reflectionScreen = '/reflection-screen';

  static Map<String, WidgetBuilder> routes = {
    splash: (context) => const SplashScreen(),
    authentication: (context) => const AuthenticationScreen(),
    resetPassword: (context) => const ResetPasswordScreen(),
    onboardingIntro: (context) => const OnboardingIntroScreen(),
    welcome: (context) => const WelcomeScreen(),
    winDetail: (context) => const WinDetailScreen(),
    settings: (context) => const SettingsScreen(),
    today: (context) => const TodayScreen(),
    history: (context) => const HistoryScreen(),
    insights: (context) => const InsightsScreen(),
    addWinModal: (context) => const AddWinModal(),
    privacyPolicy: (context) => const PrivacyPolicyScreen(),
    reflectionScreen: (context) => const ReflectionScreen(),
  };
}
