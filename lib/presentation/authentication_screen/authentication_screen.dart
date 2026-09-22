import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/app_export.dart';
import '../../routes/app_routes.dart';
import '../../services/auth_service.dart';
import 'package:win_daily/theme/wddl_design_system.dart';
import '../../widgets/responsive_app_logo.dart';
import './widgets/forgot_password_modal.dart';

class AuthenticationScreen extends StatefulWidget {
  const AuthenticationScreen({super.key});

  @override
  State<AuthenticationScreen> createState() => _AuthenticationScreenState();
}

class _AuthenticationScreenState extends State<AuthenticationScreen>
    with TickerProviderStateMixin {
  bool _isLoading = false;
  bool _isSignUpMode = false;

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late AnimationController _formController;
  late Animation<Offset> _formSlideAnimation;

  final _emailController    = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey            = GlobalKey<FormState>();
  final _emailFocusNode     = FocusNode();
  final _passwordFocusNode  = FocusNode();
  final _confirmPasswordFocusNode = FocusNode();

  bool _obscurePassword        = true;
  bool _obscureConfirmPassword = true;
  bool _isFormValid            = false;

  @override
  void initState() {
    super.initState();
    _checkAuthState();

    _emailController.addListener(_validateForm);
    _passwordController.addListener(_validateForm);
    _confirmPasswordController.addListener(_validateForm);

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );

    _formController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _formSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _formController, curve: Curves.easeOut));

    _startAnimations();
  }

  void _startAnimations() async {
    await _fadeController.forward();
    await Future.delayed(const Duration(milliseconds: 80));
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
    final email    = _emailController.text.trim();
    final password = _passwordController.text;
    bool isValid   = email.isNotEmpty && password.isNotEmpty && _isValidEmail(email);
    if (_isSignUpMode) {
      isValid = isValid &&
          password.length >= 6 &&
          password == _confirmPasswordController.text;
    }
    setState(() => _isFormValid = isValid);
  }

  bool _isValidEmail(String email) =>
      RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email);

  void _checkAuthState() {
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
        Navigator.pushReplacementNamed(context, AppRoutes.onboardingIntro);
      }
    } catch (error) {
      if (mounted) {
        _showError(error.toString().replaceAll('Exception: ', ''));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
        Navigator.pushReplacementNamed(context, AppRoutes.today);
      }
    } catch (error) {
      if (mounted) {
        _showError(error.toString().replaceAll('Exception: ', ''));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: WDDLDesignSystem.body.copyWith(color: Colors.white)),
        backgroundColor: WDDLDesignSystem.ink,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _toggleAuthMode() {
    setState(() => _isSignUpMode = !_isSignUpMode);
  }

  void _showForgotPasswordModal() {
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.transparent,
      builder: (_) => const ForgotPasswordModal(),
    );
  }

  InputDecoration _fieldDecoration(String hint, {Widget? suffixIcon}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: WDDLDesignSystem.hint,
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: WDDLDesignSystem.cream,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: WDDLDesignSystem.beigeDark, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: WDDLDesignSystem.beigeDark, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: WDDLDesignSystem.sage, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WDDLDesignSystem.cream,
      resizeToAvoidBottomInset: true,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height,
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),

                    // Logo + headline — fade in
                    AnimatedBuilder(
                      animation: _fadeAnimation,
                      builder: (_, __) => Opacity(
                        opacity: _fadeAnimation.value,
                        child: Column(
                          children: [
                            const ResponsiveAppLogo(),
                            const SizedBox(height: 16),

                            // Headline outside card — Cormorant italic
                            Text(
                              _isSignUpMode
                                  ? 'Remember your life.'
                                  : 'Remember your life.',
                              style: GoogleFonts.cormorantGaramond(
                                fontSize: 26,
                                fontWeight: FontWeight.w500,
                                fontStyle: FontStyle.italic,
                                color: WDDLDesignSystem.ink,
                                height: 1.25,
                              ),
                              textAlign: TextAlign.center,
                            ),

                            const SizedBox(height: 6),

                            Text(
                              _isSignUpMode
                                  ? 'One win a day, so your weeks stop disappearing.'
                                  : 'Welcome back. Your archive missed you.',
                              style: WDDLDesignSystem.body.copyWith(
                                color: WDDLDesignSystem.inkMuted,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 28),

                    // Form card — slides up
                    AnimatedBuilder(
                      animation: _formSlideAnimation,
                      builder: (_, __) => Transform.translate(
                        offset: Offset(0, _formSlideAnimation.value.dy * 20),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: WDDLDesignSystem.beigeDark),
                            boxShadow: [
                              BoxShadow(
                                color: WDDLDesignSystem.ink.withValues(alpha: 0.05),
                                blurRadius: 20,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(20),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                // Email
                                TextFormField(
                                  controller: _emailController,
                                  focusNode: _emailFocusNode,
                                  keyboardType: TextInputType.emailAddress,
                                  textInputAction: TextInputAction.next,
                                  enabled: !_isLoading,
                                  onFieldSubmitted: (_) =>
                                      _passwordFocusNode.requestFocus(),
                                  style: WDDLDesignSystem.body,
                                  decoration: _fieldDecoration('Email address'),
                                  autocorrect: false,
                                  textCapitalization: TextCapitalization.none,
                                ),

                                const SizedBox(height: 12),

                                // Password
                                TextFormField(
                                  controller: _passwordController,
                                  focusNode: _passwordFocusNode,
                                  obscureText: _obscurePassword,
                                  textInputAction: _isSignUpMode
                                      ? TextInputAction.next
                                      : TextInputAction.done,
                                  enabled: !_isLoading,
                                  onFieldSubmitted: (_) {
                                    if (_isSignUpMode) {
                                      _confirmPasswordFocusNode.requestFocus();
                                    } else {
                                      _handleSignIn();
                                    }
                                  },
                                  style: WDDLDesignSystem.body,
                                  decoration: _fieldDecoration(
                                    'Password',
                                    suffixIcon: IconButton(
                                      onPressed: _isLoading
                                          ? null
                                          : () => setState(() =>
                                              _obscurePassword = !_obscurePassword),
                                      icon: Icon(
                                        _obscurePassword
                                            ? Icons.visibility_off_outlined
                                            : Icons.visibility_outlined,
                                        color: WDDLDesignSystem.inkMuted,
                                        size: 18,
                                      ),
                                    ),
                                  ),
                                ),

                                // Confirm password (sign-up only)
                                if (_isSignUpMode) ...[
                                  const SizedBox(height: 12),
                                  TextFormField(
                                    controller: _confirmPasswordController,
                                    focusNode: _confirmPasswordFocusNode,
                                    obscureText: _obscureConfirmPassword,
                                    textInputAction: TextInputAction.done,
                                    enabled: !_isLoading,
                                    onFieldSubmitted: (_) => _handleSignUp(),
                                    style: WDDLDesignSystem.body,
                                    decoration: _fieldDecoration(
                                      'Confirm password',
                                      suffixIcon: IconButton(
                                        onPressed: _isLoading
                                            ? null
                                            : () => setState(() =>
                                                _obscureConfirmPassword =
                                                    !_obscureConfirmPassword),
                                        icon: Icon(
                                          _obscureConfirmPassword
                                              ? Icons.visibility_off_outlined
                                              : Icons.visibility_outlined,
                                          color: WDDLDesignSystem.inkMuted,
                                          size: 18,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],

                                const SizedBox(height: 16),

                                // Primary CTA
                                SizedBox(
                                  width: double.infinity,
                                  height: 48,
                                  child: ElevatedButton(
                                    onPressed: _isFormValid && !_isLoading
                                        ? (_isSignUpMode
                                            ? _handleSignUp
                                            : _handleSignIn)
                                        : null,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: WDDLDesignSystem.sage,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      elevation: 0,
                                      disabledBackgroundColor:
                                          WDDLDesignSystem.sagePale,
                                      disabledForegroundColor:
                                          WDDLDesignSystem.sage.withValues(alpha: 0.5),
                                    ),
                                    child: _isLoading
                                        ? const SizedBox(
                                            width: 18,
                                            height: 18,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.white,
                                            ),
                                          )
                                        : Text(
                                            _isSignUpMode
                                                ? 'Start remembering →'
                                                : 'Welcome back →',
                                            style: GoogleFonts.dmSans(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.white,
                                            ),
                                          ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Links under card
                    if (!_isSignUpMode) ...[
                      GestureDetector(
                        onTap: _showForgotPasswordModal,
                        child: Text(
                          'Forgot password?',
                          style: WDDLDesignSystem.body.copyWith(
                            color: WDDLDesignSystem.inkMuted,
                            decoration: TextDecoration.underline,
                            decorationColor:
                                WDDLDesignSystem.inkMuted.withValues(alpha: 0.4),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      GestureDetector(
                        onTap: _toggleAuthMode,
                        child: RichText(
                          text: TextSpan(
                            text: 'New to Win Daily? ',
                            style: WDDLDesignSystem.body.copyWith(
                              color: WDDLDesignSystem.inkMuted,
                            ),
                            children: [
                              TextSpan(
                                text: 'Create an account',
                                style: WDDLDesignSystem.body.copyWith(
                                  color: WDDLDesignSystem.sage,
                                  decoration: TextDecoration.underline,
                                  decorationColor: WDDLDesignSystem.sage
                                      .withValues(alpha: 0.4),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ] else ...[
                      GestureDetector(
                        onTap: _toggleAuthMode,
                        child: Text(
                          'Already have an account? Sign in',
                          style: WDDLDesignSystem.body.copyWith(
                            color: WDDLDesignSystem.sage,
                            decoration: TextDecoration.underline,
                            decorationColor:
                                WDDLDesignSystem.sage.withValues(alpha: 0.4),
                          ),
                        ),
                      ),
                    ],

                    // Debug demo accounts
                    if (kDebugMode) ...[
                      const SizedBox(height: 32),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: WDDLDesignSystem.beige,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: WDDLDesignSystem.beigeDark),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Demo accounts',
                              style: WDDLDesignSystem.body.copyWith(
                                fontWeight: FontWeight.w600,
                                color: WDDLDesignSystem.inkMuted,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'admin@windaily.com / admin123\nuser@windaily.com / user123\ndemo@windaily.com / demo123',
                              style: GoogleFonts.dmMono(
                                fontSize: 12,
                                color: WDDLDesignSystem.inkMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 48),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}