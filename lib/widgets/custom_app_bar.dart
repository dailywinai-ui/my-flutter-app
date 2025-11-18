import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/wddl_design_system.dart';
import '../utils/brand_assets.dart';

/// Custom app bar implementing disciplined minimalism design
/// with contextual actions and clean typography
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBackButton;
  final bool showLogo;
  final List<Widget>? actions;
  final VoidCallback? onBackPressed;

  const CustomAppBar({
    super.key,
    required this.title,
    this.showBackButton = true,
    this.showLogo = false,
    this.actions,
    this.onBackPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AppBar(
      backgroundColor: isDark
          ? const Color(0xFF1A1F2A) // Dark background
          : WDDLDesignSystem.background,
      foregroundColor: isDark ? Colors.white : WDDLDesignSystem.primary,
      elevation: 0,
      surfaceTintColor: Colors.transparent,

      // Theme-aware leading icon
      leading: showBackButton
          ? IconButton(
              icon: Icon(
                Icons.arrow_back_ios,
                color: isDark ? Colors.white : WDDLDesignSystem.primary,
                size: 20,
              ),
              onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
            )
          : showLogo
              ? Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Image.asset(
                    BrandAssets.appBarIcon(context),
                    width: 24,
                    height: 24,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(
                        Icons.emoji_events,
                        size: 24,
                        color: isDark ? Colors.white : WDDLDesignSystem.primary,
                      );
                    },
                  ),
                )
              : null,

      // Theme-aware title
      title: Text(
        title,
        style: WDDLDesignSystem.h2.copyWith(
          color: isDark ? Colors.white : WDDLDesignSystem.primary,
        ),
      ),

      // Theme-aware actions
      actions: actions?.map((action) {
        if (action is IconButton) {
          return IconButton(
            icon: action.icon,
            onPressed: action.onPressed,
            color: isDark ? Colors.white : WDDLDesignSystem.primary,
          );
        }
        return action;
      }).toList(),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

/// Specialized app bar for today screen with contextual FAB integration
class CustomTodayAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String? subtitle;
  final VoidCallback? onProfileTap;

  const CustomTodayAppBar({
    super.key,
    required this.title,
    this.subtitle,
    this.onProfileTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppBar(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.appBarTheme.titleTextStyle,
          ),
          if (subtitle != null)
            Text(
              subtitle!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.secondary,
              ),
            ),
        ],
      ),
      centerTitle: false,
      backgroundColor: theme.appBarTheme.backgroundColor,
      foregroundColor: theme.appBarTheme.foregroundColor,
      elevation: theme.appBarTheme.elevation,
      surfaceTintColor: theme.appBarTheme.surfaceTintColor,
      actions: [
        IconButton(
          onPressed: () {
            HapticFeedback.lightImpact();
            if (onProfileTap != null) {
              onProfileTap!();
            } else {
              Navigator.pushNamed(context, '/settings-screen');
            }
          },
          icon: CircleAvatar(
            radius: 16,
            backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
            child: Icon(
              Icons.person_outline,
              size: 20,
              color: theme.colorScheme.primary,
            ),
          ),
          tooltip: 'Profile',
        ),
        const SizedBox(width: 8),
      ],
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: theme.brightness == Brightness.light
            ? Brightness.dark
            : Brightness.light,
        statusBarBrightness: theme.brightness,
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
