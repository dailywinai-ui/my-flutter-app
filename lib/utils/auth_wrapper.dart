import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../services/auth_service.dart';
import '../presentation/authentication_screen/authentication_screen.dart';

/// Wrapper widget that handles authentication state
class AuthWrapper extends StatelessWidget {
  final Widget child;
  final bool requireAuth;

  const AuthWrapper({
    super.key,
    required this.child,
    this.requireAuth = true,
  });

  @override
  Widget build(BuildContext context) {
    if (!requireAuth) {
      return child;
    }

    return StreamBuilder<AuthState>(
      stream: AuthService.instance.authStateChanges,
      builder: (context, snapshot) {
        // Show loading while auth state is being determined
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // Check if user is authenticated
        final session = snapshot.data?.session;
        if (session != null) {
          return child;
        }

        // Show authentication screen if not logged in
        return const AuthenticationScreen();
      },
    );
  }
}

/// Extension to wrap any widget with authentication
extension AuthWrapperExtension on Widget {
  Widget requireAuth() {
    return AuthWrapper(
      requireAuth: true,
      child: this,
    );
  }

  Widget optionalAuth() {
    return AuthWrapper(
      requireAuth: false,
      child: this,
    );
  }
}
