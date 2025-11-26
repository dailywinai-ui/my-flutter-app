import 'package:flutter/material.dart';

import '../../../core/app_export.dart';
import '../../../theme/wddl_design_system.dart';
import '../../../widgets/custom_icon_widget.dart';

class AuthFormWidget extends StatefulWidget {
  final Function(String email, String password) onSignIn;
  final bool isLoading;
  final bool isSignUpMode;

  const AuthFormWidget({
    super.key,
    required this.onSignIn,
    this.isLoading = false,
    this.isSignUpMode = false,
  });

  @override
  State<AuthFormWidget> createState() => _AuthFormWidgetState();
}

class _AuthFormWidgetState extends State<AuthFormWidget>
    with TickerProviderStateMixin {
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

  late AnimationController _buttonController;
  late Animation<double> _buttonScaleAnimation;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_validateForm);
    _passwordController.addListener(_validateForm);
    _confirmPasswordController.addListener(_validateForm);

    // Initialize button scale animation
    _buttonController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _buttonScaleAnimation = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _buttonController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    _buttonController.dispose();
    super.dispose();
  }

  void _validateForm() {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    bool isValid =
        email.isNotEmpty && password.isNotEmpty && _isValidEmail(email);

    if (widget.isSignUpMode) {
      isValid = isValid && password.length >= 6 && password == confirmPassword;
    }

    setState(() {
      _isFormValid = isValid;
    });
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email);
  }

  void _handleSubmit() {
    if (!_isFormValid || widget.isLoading) return;

    // Dismiss keyboard
    FocusScope.of(context).unfocus();

    _buttonController.forward().then((_) {
      _buttonController.reverse();
    });

    widget.onSignIn(
      _emailController.text.trim().toLowerCase(),
      _passwordController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          // Email field with WDDL filled input style
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.9), // 90% opacity white
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 3,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: TextFormField(
              controller: _emailController,
              focusNode: _emailFocusNode,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              enabled: !widget.isLoading,
              onFieldSubmitted: (_) {
                _passwordFocusNode.requestFocus();
              },
              decoration: InputDecoration(
                hintText: 'Email address',
                prefixIcon: Padding(
                  padding: const EdgeInsets.all(16),
                  child: CustomIconWidget(
                    iconName: 'email',
                    color: WDDLDesignSystem.textSecondary,
                    size: 20,
                  ),
                ),
                border: InputBorder.none,
                // Gentle focus outline
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(
                    color: WDDLDesignSystem.secondary, // #457B9D
                    width: 1,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                hintStyle: WDDLDesignSystem.body.copyWith(
                  color: WDDLDesignSystem.textSecondary,
                ),
              ),
              style: WDDLDesignSystem.body,
              autocorrect: false,
              textCapitalization: TextCapitalization.none,
            ),
          ),

          const SizedBox(height: 16),

          // Password field
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.9), // 90% opacity white
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 3,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: TextFormField(
              controller: _passwordController,
              focusNode: _passwordFocusNode,
              textInputAction:
                  widget.isSignUpMode
                      ? TextInputAction.next
                      : TextInputAction.done,
              obscureText: _obscurePassword,
              enabled: !widget.isLoading,
              onFieldSubmitted: (_) {
                if (widget.isSignUpMode) {
                  _confirmPasswordFocusNode.requestFocus();
                } else {
                  _handleSubmit();
                }
              },
              decoration: InputDecoration(
                hintText: 'Password',
                prefixIcon: Padding(
                  padding: const EdgeInsets.all(16),
                  child: CustomIconWidget(
                    iconName: 'lock',
                    color: WDDLDesignSystem.textSecondary,
                    size: 20,
                  ),
                ),
                suffixIcon: IconButton(
                  onPressed:
                      widget.isLoading
                          ? null
                          : () => setState(
                            () => _obscurePassword = !_obscurePassword,
                          ),
                  icon: CustomIconWidget(
                    iconName:
                        _obscurePassword ? 'visibility_off' : 'visibility',
                    color: WDDLDesignSystem.textSecondary,
                    size: 20,
                  ),
                ),
                border: InputBorder.none,
                // Gentle focus outline
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(
                    color: WDDLDesignSystem.secondary, // #457B9D
                    width: 1,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                hintStyle: WDDLDesignSystem.body.copyWith(
                  color: WDDLDesignSystem.textSecondary,
                ),
              ),
              style: WDDLDesignSystem.body,
            ),
          ),

          // Confirm password field for sign up
          if (widget.isSignUpMode) ...[
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.9), // 90% opacity white
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 3,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: TextFormField(
                controller: _confirmPasswordController,
                focusNode: _confirmPasswordFocusNode,
                textInputAction: TextInputAction.done,
                obscureText: _obscureConfirmPassword,
                enabled: !widget.isLoading,
                onFieldSubmitted: (_) => _handleSubmit(),
                decoration: InputDecoration(
                  hintText: 'Confirm password',
                  prefixIcon: Padding(
                    padding: const EdgeInsets.all(16),
                    child: CustomIconWidget(
                      iconName: 'lock',
                      color: WDDLDesignSystem.textSecondary,
                      size: 20,
                    ),
                  ),
                  suffixIcon: IconButton(
                    onPressed:
                        widget.isLoading
                            ? null
                            : () => setState(
                              () =>
                                  _obscureConfirmPassword =
                                      !_obscureConfirmPassword,
                            ),
                    icon: CustomIconWidget(
                      iconName:
                          _obscureConfirmPassword
                              ? 'visibility_off'
                              : 'visibility',
                      color: WDDLDesignSystem.textSecondary,
                      size: 20,
                    ),
                  ),
                  border: InputBorder.none,
                  // Gentle focus outline
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                      color: WDDLDesignSystem.secondary, // #457B9D
                      width: 1,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  hintStyle: WDDLDesignSystem.body.copyWith(
                    color: WDDLDesignSystem.textSecondary,
                  ),
                ),
                style: WDDLDesignSystem.body,
              ),
            ),
          ],

          const SizedBox(height: 32),

          // Primary button with WDDL styling and scale microanimation
          SizedBox(
            width: double.infinity,
            child: AnimatedBuilder(
              animation: _buttonScaleAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _buttonScaleAnimation.value,
                  child: ElevatedButton(
                    onPressed:
                        _isFormValid && !widget.isLoading
                            ? _handleSubmit
                            : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: WDDLDesignSystem.secondary, // #457B9D
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                      disabledBackgroundColor: WDDLDesignSystem.textSecondary
                          .withValues(alpha: 0.3),
                      disabledForegroundColor: Colors.white.withValues(
                        alpha: 0.7,
                      ),
                    ),
                    child:
                        widget.isLoading
                            ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                            : Text(
                              widget.isSignUpMode
                                  ? 'Create Account'
                                  : 'Sign In',
                              style: WDDLDesignSystem.bodyLarge.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                  ),
                );
              },
            ),
          ),

          // Password requirements for sign up
          if (widget.isSignUpMode) ...[
            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: WDDLDesignSystem.surface.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: WDDLDesignSystem.textSecondary.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Password requirements:',
                    style: WDDLDesignSystem.body.copyWith(
                      fontWeight: FontWeight.w600,
                      color: WDDLDesignSystem.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '• At least 6 characters long\n• Passwords must match',
                    style: WDDLDesignSystem.hint,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
