import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../routes/app_routes.dart';

class AuthGuard {
  static void checkAuthStatus(BuildContext context) {
    if (!AuthService.instance.isSignedIn) {
      Navigator.pushReplacementNamed(context, AppRoutes.authentication);
    }
  }

  static Future<bool> requireAuth(BuildContext context) async {
    if (!AuthService.instance.isSignedIn) {
      Navigator.pushReplacementNamed(context, AppRoutes.authentication);
      return false;
    }
    return true;
  }
}

/// Mixin to add authentication guard to any screen
mixin AuthMixin<T extends StatefulWidget> on State<T> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AuthGuard.checkAuthStatus(context);
    });
  }
}
