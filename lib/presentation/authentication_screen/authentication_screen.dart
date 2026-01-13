import 'package:win_daily/widgets/responsive_app_logo.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';


import '../../core/app_export.dart';
import '../../routes/app_routes.dart';
import '../../services/auth_service.dart';
import 'package:win_daily/theme/wddl_design_system.dart';
import '../../utils/brand_assets.dart';
import './widgets/forgot_password_modal.dart';


class AuthenticationScreen extends StatefulWidget {
  const AuthenticationScreen({super.key});

  @override
  State<AuthenticationScreen> createState() => _AuthenticationScreenState();
}

class _AuthenticationScreenState extends State<AuthenticationScreen>
    with TickerProviderStateMixin {
  bool _isLoading = false;
  String? _errorMessage;
  bool _isSignUpMode = false;

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late AnimationController _formController;
  late Animation<Offset> _formSlideAnimation;

  // Form controllers and validation
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  final _confirmPasswordFocusNode = FocusNode();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isFormValid = false;

  // Demo credentials for testing (kept for development)
  final Map<String, String> _demoCredentials = {
    'admin@windaily.com': 'admin123',
    'user@windaily.com': 'user123',
    'demo@windaily.com': 'demo123',
  };

  @override
  void initState() {
    super.initState();
    _checkAuthState();

    // Add listeners for form validation
    _emailController.addListener(_validateForm);
    _passwordController.addListener(_validateForm);
    _confirmPasswordController.addListener(_validateForm);

    // Initialize animation controllers
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));

    _formController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _formSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _formController, curve: Curves.easeOut));

    // Start sequential animations
    _startAnimations();
  }

  void _startAnimations() async {
    // Start logo/tagline fade-in first
    await _fadeController.forward();
    // Then slide form up from below after delay
    await Future.delayed(const Duration(milliseconds: 100));
    _formController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _formController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    super.dispose();
  }

  void _validateForm() {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    bool isValid =
        email.isNotEmpty && password.isNotEmpty && _isValidEmail(email);

    if (_isSignUpMode) {
      isValid = isValid && password.length >= 6 && password == confirmPassword;
    }

    setState(() {
      _isFormValid = isValid;
    });
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email);
  }

  void _checkAuthState() {
    // Check if user is already signed in when screen loads
    if (AuthService.instance.isSignedIn) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, AppRoutes.today);
      });
    }
  }

  Future<void> _handleSignUp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await AuthService.instance.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (mounted) {
        // For new sign-ups, always show onboarding first
        // The onboarding screen will handle navigation to main app after completion
        Navigator.pushReplacementNamed(context, AppRoutes.onboardingIntro);
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error.toString().replaceAll('Exception: ', '')),
            backgroundColor: WDDLDesignSystem.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleSignIn() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await AuthService.instance.signIn(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (mounted) {
        // Existing users always go to main app after sign in
        Navigator.pushReplacementNamed(context, AppRoutes.today);
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error.toString().replaceAll('Exception: ', '')),
            backgroundColor: WDDLDesignSystem.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: WDDLDesignSystem.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _toggleAuthMode() {
    setState(() {
      _isSignUpMode = !_isSignUpMode;
      _errorMessage = null;
    });
  }

  void _dismissKeyboard() {
    FocusScope.of(context).unfocus();
  }

  void _showForgotPasswordModal() {
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.transparent,
      builder: (context) => const ForgotPasswordModal(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Container(
        // Uniform calm background
        color: isDark ? const Color(0xFF1A1F2A) : const Color(0xFFEBE8E3),
        child: Stack(
          children: [
            // Top brand header zone with subtle overlay
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 160,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors:
                        isDark
                            ? [
                              const Color(0xFF2B3442).withValues(
                                alpha: 0.6,
                              ), // Darker overlay for dark theme
                              Colors.transparent,
                            ]
                            : [
                              const Color(0xFF96C5C2).withValues(
                                alpha: 0.4,
                              ), // Slightly darker overlay
                              Colors.transparent,
                            ],
                  ),
                ),
              ),
            ),
            // Main content
            SafeArea(
              child: GestureDetector(
                onTap: _dismissKeyboard,
                child: SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight:
                          MediaQuery.of(context).size.height -
                          MediaQuery.of(context).padding.top -
                          MediaQuery.of(context).padding.bottom,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 32), // Top safe area padding
                          // Logo + tagline block with fade animation
                          AnimatedBuilder(
                            animation: _fadeAnimation,
                            builder: (context, child) {
                              return Opacity(
                                opacity: _fadeAnimation.value,
                                child: Column(
                                  children: [
                                    // Responsive wordmark logo (scales automatically)
                                    const ResponsiveAppLogo(),


                                    const SizedBox(
                                      height: 12,
                                    ), // 12px between logo and tagline
                                    // "One win at a time." subtext
                                    Text(
                                      'One win at a time.',
                                      style: TextStyle(
                                        fontFamily: 'Inter',
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color:
                                            isDark
                                                ? const Color(
                                                  0xFFFFFFFF,
                                                ).withValues(alpha: 0.8)
                                                : const Color(
                                                  0xFF6B8B7F,
                                                ).withValues(alpha: 0.8),
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),

                          const SizedBox(
                            height: 24,
                          ), // 24px between tagline and sign-in card
                          // Form with slide-up animation wrapped in floating card
                          AnimatedBuilder(
                            animation: _formSlideAnimation,
                            builder: (context, child) {
                              return Transform.translate(
                                offset: Offset(
                                  0,
                                  _formSlideAnimation.value.dy * 8,
                                ),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(
                                      alpha: 0.9,
                                    ), // rgba(255,255,255,0.9)
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(
                                          alpha: 0.08,
                                        ), // 0 8px 24px rgba(0,0,0,0.08)
                                        blurRadius: 24,
                                        offset: const Offset(0, 8),
                                      ),
                                    ],
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 20,
                                    horizontal: 16,
                                  ), // 20px top/bottom, 16px left/right
                                  child: Form(
                                    key: _formKey,
                                    child: Column(
                                      children: [
                                        // Email field with improved tap handling
                                        GestureDetector(
                                          onTap: () {
                                            // Ensure keyboard appears when tapping field area
                                            Future.delayed(
                                              const Duration(milliseconds: 50),
                                              () {
                                                if (mounted &&
                                                    _emailFocusNode
                                                        .canRequestFocus) {
                                                  _emailFocusNode
                                                      .requestFocus();
                                                }
                                              },
                                            );
                                          },
                                          child: TextFormField(
                                            controller: _emailController,
                                            focusNode: _emailFocusNode,
                                            keyboardType:
                                                TextInputType.emailAddress,
                                            textInputAction:
                                                TextInputAction.next,
                                            enabled: !_isLoading,
                                            onFieldSubmitted: (_) {
                                              _passwordFocusNode.requestFocus();
                                            },
                                            onTap: () {
                                              // Additional focus request on tap
                                              Future.delayed(
                                                const Duration(
                                                  milliseconds: 50,
                                                ),
                                                () {
                                                  if (mounted &&
                                                      !_emailFocusNode
                                                          .hasFocus) {
                                                    _emailFocusNode
                                                        .requestFocus();
                                                  }
                                                },
                                              );
                                            },
                                            decoration: InputDecoration(
                                              hintText: 'Email address',
                                              hintStyle: TextStyle(
                                                fontFamily: 'Inter',
                                                fontSize: 14,
                                                fontWeight: FontWeight.w400,
                                                color:
                                                    WDDLDesignSystem
                                                        .textSecondary,
                                              ),
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                borderSide: BorderSide(
                                                  color: WDDLDesignSystem
                                                      .textSecondary
                                                      .withValues(alpha: 0.3),
                                                  width: 1,
                                                ),
                                              ),
                                              enabledBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                borderSide: BorderSide(
                                                  color: WDDLDesignSystem
                                                      .textSecondary
                                                      .withValues(alpha: 0.3),
                                                  width: 1,
                                                ),
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                borderSide: const BorderSide(
                                                  color:
                                                      WDDLDesignSystem
                                                          .secondary,
                                                  width: 1,
                                                ),
                                              ),
                                              contentPadding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 16,
                                                    vertical: 16,
                                                  ),
                                            ),
                                            style: TextStyle(
                                              fontFamily: 'Inter',
                                              fontSize: 14,
                                              fontWeight: FontWeight.w400,
                                            ),
                                            autocorrect: false,
                                            textCapitalization:
                                                TextCapitalization.none,
                                          ),
                                        ),

                                        const SizedBox(height: 16),

                                        // Password field with improved tap handling
                                        GestureDetector(
                                          onTap: () {
                                            // Ensure keyboard appears when tapping field area
                                            Future.delayed(
                                              const Duration(milliseconds: 50),
                                              () {
                                                if (mounted &&
                                                    _passwordFocusNode
                                                        .canRequestFocus) {
                                                  _passwordFocusNode
                                                      .requestFocus();
                                                }
                                              },
                                            );
                                          },
                                          child: TextFormField(
                                            controller: _passwordController,
                                            focusNode: _passwordFocusNode,
                                            textInputAction:
                                                _isSignUpMode
                                                    ? TextInputAction.next
                                                    : TextInputAction.done,
                                            obscureText: _obscurePassword,
                                            enabled: !_isLoading,
                                            onFieldSubmitted: (_) {
                                              if (_isSignUpMode) {
                                                _confirmPasswordFocusNode
                                                    .requestFocus();
                                              } else {
                                                _handleSignIn();
                                              }
                                            },
                                            onTap: () {
                                              // Additional focus request on tap
                                              Future.delayed(
                                                const Duration(
                                                  milliseconds: 50,
                                                ),
                                                () {
                                                  if (mounted &&
                                                      !_passwordFocusNode
                                                          .hasFocus) {
                                                    _passwordFocusNode
                                                        .requestFocus();
                                                  }
                                                },
                                              );
                                            },
                                            decoration: InputDecoration(
                                              hintText: 'Password',
                                              hintStyle: TextStyle(
                                                fontFamily: 'Inter',
                                                fontSize: 14,
                                                fontWeight: FontWeight.w400,
                                                color:
                                                    WDDLDesignSystem
                                                        .textSecondary,
                                              ),
                                              suffixIcon: IconButton(
                                                onPressed:
                                                    _isLoading
                                                        ? null
                                                        : () => setState(
                                                          () =>
                                                              _obscurePassword =
                                                                  !_obscurePassword,
                                                        ),
                                                icon: Icon(
                                                  _obscurePassword
                                                      ? Icons.visibility_off
                                                      : Icons.visibility,
                                                  color:
                                                      WDDLDesignSystem
                                                          .textSecondary,
                                                  size: 20,
                                                ),
                                              ),
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                borderSide: BorderSide(
                                                  color: WDDLDesignSystem
                                                      .textSecondary
                                                      .withValues(alpha: 0.3),
                                                  width: 1,
                                                ),
                                              ),
                                              enabledBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                borderSide: BorderSide(
                                                  color: WDDLDesignSystem
                                                      .textSecondary
                                                      .withValues(alpha: 0.3),
                                                  width: 1,
                                                ),
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                borderSide: const BorderSide(
                                                  color:
                                                      WDDLDesignSystem
                                                          .secondary,
                                                  width: 1,
                                                ),
                                              ),
                                              contentPadding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 16,
                                                    vertical: 16,
                                                  ),
                                            ),
                                            style: TextStyle(
                                              fontFamily: 'Inter',
                                              fontSize: 14,
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                        ),

                                        // Confirm password field for sign up with improved tap handling
                                        if (_isSignUpMode) ...[
                                          const SizedBox(height: 16),
                                          GestureDetector(
                                            onTap: () {
                                              // Ensure keyboard appears when tapping field area
                                              Future.delayed(
                                                const Duration(
                                                  milliseconds: 50,
                                                ),
                                                () {
                                                  if (mounted &&
                                                      _confirmPasswordFocusNode
                                                          .canRequestFocus) {
                                                    _confirmPasswordFocusNode
                                                        .requestFocus();
                                                  }
                                                },
                                              );
                                            },
                                            child: TextFormField(
                                              controller:
                                                  _confirmPasswordController,
                                              focusNode:
                                                  _confirmPasswordFocusNode,
                                              textInputAction:
                                                  TextInputAction.done,
                                              obscureText:
                                                  _obscureConfirmPassword,
                                              enabled: !_isLoading,
                                              onFieldSubmitted:
                                                  (_) => _handleSignUp(),
                                              onTap: () {
                                                // Additional focus request on tap
                                                Future.delayed(
                                                  const Duration(
                                                    milliseconds: 50,
                                                  ),
                                                  () {
                                                    if (mounted &&
                                                        !_confirmPasswordFocusNode
                                                            .hasFocus) {
                                                      _confirmPasswordFocusNode
                                                          .requestFocus();
                                                    }
                                                  },
                                                );
                                              },
                                              decoration: InputDecoration(
                                                hintText: 'Confirm password',
                                                hintStyle: TextStyle(
                                                  fontFamily: 'Inter',
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w400,
                                                  color:
                                                      WDDLDesignSystem
                                                          .textSecondary,
                                                ),
                                                suffixIcon: IconButton(
                                                  onPressed:
                                                      _isLoading
                                                          ? null
                                                          : () => setState(
                                                            () =>
                                                                _obscureConfirmPassword =
                                                                    !_obscureConfirmPassword,
                                                          ),
                                                  icon: Icon(
                                                    _obscureConfirmPassword
                                                        ? Icons.visibility_off
                                                        : Icons.visibility,
                                                    color:
                                                        WDDLDesignSystem
                                                            .textSecondary,
                                                    size: 20,
                                                  ),
                                                ),
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  borderSide: BorderSide(
                                                    color: WDDLDesignSystem
                                                        .textSecondary
                                                        .withValues(alpha: 0.3),
                                                    width: 1,
                                                  ),
                                                ),
                                                enabledBorder:
                                                    OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            8,
                                                          ),
                                                      borderSide: BorderSide(
                                                        color: WDDLDesignSystem
                                                            .textSecondary
                                                            .withValues(
                                                              alpha: 0.3,
                                                            ),
                                                        width: 1,
                                                      ),
                                                    ),
                                                focusedBorder:
                                                    OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            8,
                                                          ),
                                                      borderSide:
                                                          const BorderSide(
                                                            color:
                                                                WDDLDesignSystem
                                                                    .secondary,
                                                            width: 1,
                                                          ),
                                                    ),
                                                contentPadding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 16,
                                                      vertical: 16,
                                                    ),
                                              ),
                                              style: TextStyle(
                                                fontFamily: 'Inter',
                                                fontSize: 14,
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                          ),
                                        ],

                                        const SizedBox(
                                          height: 12,
                                        ), // ~12px top margin from Password
                                        // Sign In button
                                        SizedBox(
                                          width: double.infinity,
                                          height:
                                              44, // 44px tall for accessibility
                                          child: ElevatedButton(
                                            onPressed:
                                                _isFormValid && !_isLoading
                                                    ? (_isSignUpMode
                                                        ? _handleSignUp
                                                        : _handleSignIn)
                                                    : null,
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: const Color(
                                                0xFF6B8B7F,
                                              ), // Brand navy
                                              foregroundColor: Colors.white,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                      10,
                                                    ), // 10px radius
                                              ),
                                              elevation: 0,
                                              disabledBackgroundColor:
                                                  WDDLDesignSystem.textSecondary
                                                      .withValues(alpha: 0.3),
                                              disabledForegroundColor: Colors
                                                  .white
                                                  .withValues(alpha: 0.7),
                                            ),
                                            child:
                                                _isLoading
                                                    ? const SizedBox(
                                                      height: 20,
                                                      width: 20,
                                                      child: CircularProgressIndicator(
                                                        strokeWidth: 2,
                                                        valueColor:
                                                            AlwaysStoppedAnimation<
                                                              Color
                                                            >(Colors.white),
                                                      ),
                                                    )
                                                    : Text(
                                                      _isSignUpMode
                                                          ? 'Create Account'
                                                          : 'Welcome back',
                                                      style: TextStyle(
                                                        fontFamily: 'Inter',
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight
                                                                .w600, // 14px Semibold
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),

                          const SizedBox(
                            height: 24,
                          ), // ~24px margin-top from sign-in card
                          // Links under card
                          if (!_isSignUpMode) ...[
                            // "Forgot password?" link (new)
                            GestureDetector(
                              onTap: _showForgotPasswordModal,
                              child: Text(
                                'Forgot password?',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(
                                    0xFF6B8B7F,
                                  ).withValues(alpha: 0.8),
                                  decoration: TextDecoration.underline,
                                  decorationColor: const Color(
                                    0xFF6B8B7F,
                                  ).withValues(alpha: 0.8),
                                ),
                              ),
                            ),

                            const SizedBox(height: 16),

                            // "New here? Create an account" link
                            GestureDetector(
                              onTap: _toggleAuthMode,
                              child: RichText(
                                text: TextSpan(
                                  text: 'New to Win Daily? ',
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500, // Inter Medium
                                    color: const Color(
                                      0xFF6B8B7F,
                                    ).withValues(alpha: 0.8),
                                  ),
                                  children: [
                                    TextSpan(
                                      text: 'Create an account',
                                      style: TextStyle(
                                        fontFamily: 'Inter',
                                        fontSize: 14,
                                        fontWeight:
                                            FontWeight.w500, // Inter Medium
                                        color: const Color(
                                          0xFF6B8B7F,
                                        ).withValues(alpha: 0.8),
                                        decoration:
                                            TextDecoration
                                                .underline, // underline on "Create an account" portion
                                        decorationColor: const Color(
                                          0xFF6B8B7F,
                                        ).withValues(alpha: 0.8),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ] else ...[
                            // Back to sign in for sign up mode
                            GestureDetector(
                              onTap: _toggleAuthMode,
                              child: Text(
                                'Already have an account? Welcome back',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(
                                    0xFF6B8B7F,
                                  ).withValues(alpha: 0.8),
                                  decoration: TextDecoration.underline,
                                  decorationColor: const Color(
                                    0xFF6B8B7F,
                                  ).withValues(alpha: 0.8),
                                ),
                              ),
                            ),
                          ],

                          const SizedBox(height: 24),

                          // Error message display
                          if (_errorMessage != null) ...[
                            const SizedBox(height: 16),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: WDDLDesignSystem.error.withValues(
                                  alpha: 0.1,
                                ),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: WDDLDesignSystem.error.withValues(
                                    alpha: 0.3,
                                  ),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                    Icons.error_outline,
                                    color: WDDLDesignSystem.error,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      _errorMessage!,
                                      style: WDDLDesignSystem.body.copyWith(
                                        color: WDDLDesignSystem.error,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],

                          const SizedBox(height: 32),

                          // Demo credentials info (only show in dev mode)
                          if (kDebugMode)
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.8),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: WDDLDesignSystem.textSecondary
                                      .withValues(alpha: 0.2),
                                  width: 1,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.info_outline,
                                        color: WDDLDesignSystem.secondary,
                                        size: 18,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Demo Accounts',
                                        style: WDDLDesignSystem.body.copyWith(
                                          color: WDDLDesignSystem.secondary,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'admin@windaily.com / admin123\nuser@windaily.com / user123\ndemo@windaily.com / demo123',
                                    style: WDDLDesignSystem.hint.copyWith(
                                      fontFamily: 'monospace',
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Or create a new account with sign up!',
                                    style: WDDLDesignSystem.hint.copyWith(
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                          const SizedBox(height: 48), // Bottom padding
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
