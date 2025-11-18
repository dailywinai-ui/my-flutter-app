import 'package:flutter/material.dart';

import '../../core/app_export.dart';
import '../../routes/app_routes.dart';
import '../../services/auth_service.dart';
import '../../theme/wddl_design_system.dart';
import '../../utils/brand_assets.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen>
    with TickerProviderStateMixin {
  bool _isLoading = false;
  String? _errorMessage;

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late AnimationController _formController;
  late Animation<Offset> _formSlideAnimation;

  // Form controllers and validation
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _passwordFocusNode = FocusNode();
  final _confirmPasswordFocusNode = FocusNode();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isFormValid = false;

  @override
  void initState() {
    super.initState();

    // Add listeners for form validation
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
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    super.dispose();
  }

  void _validateForm() {
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    bool isValid = password.isNotEmpty &&
        password.length >= 6 &&
        password == confirmPassword;

    setState(() {
      _isFormValid = isValid;
    });
  }

  Future<void> _handleResetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
  await AuthService.instance.updatePassword(_passwordController.text);

      if (mounted) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Password updated successfully!'),
            backgroundColor: WDDLDesignSystem.success,
          ),
        );

        // Navigate to main app
        Navigator.pushReplacementNamed(context, AppRoutes.today);
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _errorMessage = error.toString().replaceAll('Exception: ', '');
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_errorMessage!),
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

  void _dismissKeyboard() {
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Container(
        // Uniform calm background
        color: isDark ? const Color(0xFF1A1F2A) : const Color(0xFFA8DADC),
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
                    colors: isDark
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
                      minHeight: MediaQuery.of(context).size.height -
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
                                    // Horizontal wordmark logo (140px wide)
                                    SizedBox(
                                      width: 140,
                                      child: Image.asset(
                                        BrandAssets.otherHorizontalLogo(),
                                        width: 140,
                                        fit: BoxFit.contain,
                                        filterQuality: FilterQuality.high,
                                        errorBuilder: (
                                          context,
                                          error,
                                          stackTrace,
                                        ) {
                                          return Text(
                                            'Win Daily',
                                            style: TextStyle(
                                              fontSize: 28,
                                              fontWeight: FontWeight.bold,
                                              color: isDark
                                                  ? Colors.white
                                                  : const Color(0xFF1D3557),
                                            ),
                                            textAlign: TextAlign.center,
                                          );
                                        },
                                      ),
                                    ),

                                    const SizedBox(
                                      height: 12,
                                    ), // 12px between logo and tagline
                                    // "Reset your password" subtext
                                    Text(
                                      'Reset your password',
                                      style: TextStyle(
                                        fontFamily: 'Inter',
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: isDark
                                            ? const Color(
                                                0xFFFFFFFF,
                                              ).withValues(alpha: 0.8)
                                            : const Color(
                                                0xFF1D3557,
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
                          ), // 24px between tagline and reset form card
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // Header text
                                        Text(
                                          'Create a new password',
                                          style: TextStyle(
                                            fontFamily: 'Inter',
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600,
                                            color: const Color(0xFF1D3557),
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Enter a new password for your account. Make sure it\'s at least 6 characters long.',
                                          style: TextStyle(
                                            fontFamily: 'Inter',
                                            fontSize: 14,
                                            fontWeight: FontWeight.w400,
                                            color:
                                                WDDLDesignSystem.textSecondary,
                                          ),
                                        ),
                                        const SizedBox(height: 24),

                                        // New Password field
                                        GestureDetector(
                                          onTap: () {
                                            Future.delayed(
                                                const Duration(
                                                    milliseconds: 50), () {
                                              if (mounted &&
                                                  _passwordFocusNode
                                                      .canRequestFocus) {
                                                _passwordFocusNode
                                                    .requestFocus();
                                              }
                                            });
                                          },
                                          child: TextFormField(
                                            controller: _passwordController,
                                            focusNode: _passwordFocusNode,
                                            textInputAction:
                                                TextInputAction.next,
                                            obscureText: _obscurePassword,
                                            enabled: !_isLoading,
                                            onFieldSubmitted: (_) {
                                              _confirmPasswordFocusNode
                                                  .requestFocus();
                                            },
                                            validator: (value) {
                                              if (value == null ||
                                                  value.isEmpty) {
                                                return 'Password is required';
                                              }
                                              if (value.length < 6) {
                                                return 'Password must be at least 6 characters';
                                              }
                                              return null;
                                            },
                                            decoration: InputDecoration(
                                              labelText: 'New Password',
                                              hintText:
                                                  'Enter your new password',
                                              hintStyle: TextStyle(
                                                fontFamily: 'Inter',
                                                fontSize: 14,
                                                fontWeight: FontWeight.w400,
                                                color: WDDLDesignSystem
                                                    .textSecondary,
                                              ),
                                              suffixIcon: IconButton(
                                                onPressed: _isLoading
                                                    ? null
                                                    : () => setState(
                                                          () => _obscurePassword =
                                                              !_obscurePassword,
                                                        ),
                                                icon: Icon(
                                                  _obscurePassword
                                                      ? Icons.visibility_off
                                                      : Icons.visibility,
                                                  color: WDDLDesignSystem
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
                                                  color: WDDLDesignSystem
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

                                        const SizedBox(height: 16),

                                        // Confirm Password field
                                        GestureDetector(
                                          onTap: () {
                                            Future.delayed(
                                                const Duration(
                                                    milliseconds: 50), () {
                                              if (mounted &&
                                                  _confirmPasswordFocusNode
                                                      .canRequestFocus) {
                                                _confirmPasswordFocusNode
                                                    .requestFocus();
                                              }
                                            });
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
                                            onFieldSubmitted: (_) =>
                                                _handleResetPassword(),
                                            validator: (value) {
                                              if (value == null ||
                                                  value.isEmpty) {
                                                return 'Please confirm your password';
                                              }
                                              if (value !=
                                                  _passwordController.text) {
                                                return 'Passwords do not match';
                                              }
                                              return null;
                                            },
                                            decoration: InputDecoration(
                                              labelText: 'Confirm Password',
                                              hintText:
                                                  'Confirm your new password',
                                              hintStyle: TextStyle(
                                                fontFamily: 'Inter',
                                                fontSize: 14,
                                                fontWeight: FontWeight.w400,
                                                color: WDDLDesignSystem
                                                    .textSecondary,
                                              ),
                                              suffixIcon: IconButton(
                                                onPressed: _isLoading
                                                    ? null
                                                    : () => setState(
                                                          () => _obscureConfirmPassword =
                                                              !_obscureConfirmPassword,
                                                        ),
                                                icon: Icon(
                                                  _obscureConfirmPassword
                                                      ? Icons.visibility_off
                                                      : Icons.visibility,
                                                  color: WDDLDesignSystem
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
                                                  color: WDDLDesignSystem
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

                                        const SizedBox(height: 24),

                                        // Reset Password button
                                        SizedBox(
                                          width: double.infinity,
                                          height:
                                              44, // 44px tall for accessibility
                                          child: ElevatedButton(
                                            onPressed:
                                                _isFormValid && !_isLoading
                                                    ? _handleResetPassword
                                                    : null,
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: const Color(
                                                0xFF1D3557,
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
                                            child: _isLoading
                                                ? const SizedBox(
                                                    height: 20,
                                                    width: 20,
                                                    child:
                                                        CircularProgressIndicator(
                                                      strokeWidth: 2,
                                                      valueColor:
                                                          AlwaysStoppedAnimation<
                                                                  Color>(
                                                              Colors.white),
                                                    ),
                                                  )
                                                : Text(
                                                    'Update Password',
                                                    style: TextStyle(
                                                      fontFamily: 'Inter',
                                                      fontSize: 14,
                                                      fontWeight: FontWeight
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

                          const SizedBox(height: 24),

                          // Back to sign in link
                          GestureDetector(
                            onTap: () {
                              Navigator.pushReplacementNamed(
                                  context, AppRoutes.authentication);
                            },
                            child: Text(
                              'Back to Sign In',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF1D3557)
                                    .withValues(alpha: 0.8),
                                decoration: TextDecoration.underline,
                                decorationColor: const Color(0xFF1D3557)
                                    .withValues(alpha: 0.8),
                              ),
                            ),
                          ),

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
