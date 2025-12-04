import 'package:flutter/material.dart';
import 'package:win_daily/theme/wddl_design_system.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../services/auth_service.dart';
import '../../services/wins_service.dart';
import '../../widgets/custom_app_bar.dart';
import './widgets/action_buttons_widget.dart';
import './widgets/win_card_generator.dart';
import './widgets/win_card_widget.dart';

class WinDetailScreen extends StatefulWidget {
  const WinDetailScreen({super.key});

  @override
  State<WinDetailScreen> createState() => _WinDetailScreenState();
}

class _WinDetailScreenState extends State<WinDetailScreen> {
  late Map<String, dynamic> currentWin;
  late List<Map<String, dynamic>> allWins;
  int currentIndex = 0;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadUserWins();
  }

  Future<void> _loadUserWins() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final currentUser = AuthService.instance.currentUser;
      if (currentUser == null) {
        throw Exception('No authenticated user');
      }

      // Fetch both types of wins
      final wins = await WinsService.instance.getWins(limit: 50);
      final dailyWins = await WinsService.instance.getDailyWins(limit: 50);

      // Convert wins to a common format for display
      final List<Map<String, dynamic>> formattedWins = [];

      // Add general wins
      for (final win in wins) {
        formattedWins.add({
          "id": win.id,
          "date": _formatDate(win.winDate),
          "title": win.text,
          "reflection": win.reflection ?? "",
          "mood": win.mood ?? 3,
          "timestamp": win.winDate,
          "type": "win",
        });
      }

      // Add daily wins
      for (final dailyWin in dailyWins) {
        formattedWins.add({
          "id": dailyWin.id,
          "date": _formatDate(dailyWin.winDate),
          "title": dailyWin.description,
          "reflection": dailyWin.reflection ?? "",
          "mood": dailyWin.moodRating ?? 3,
          "timestamp": dailyWin.winDate,
          "type": "daily_win",
        });
      }

      // Sort by date (newest first)
      formattedWins.sort(
        (a, b) =>
            (b["timestamp"] as DateTime).compareTo(a["timestamp"] as DateTime),
      );

      setState(() {
        allWins = formattedWins;
        if (allWins.isNotEmpty) {
          currentWin = allWins.first;
          currentIndex = 0;
        } else {
          currentWin = {};
        }
        isLoading = false;
      });
    } catch (error) {
      setState(() {
        errorMessage = error.toString();
        isLoading = false;
        allWins = [];
        currentWin = {};
      });
    }
  }

  String _formatDate(DateTime date) {
    final months = [
      "January",
      "February",
      "March",
      "April",
      "May",
      "June",
      "July",
      "August",
      "September",
      "October",
      "November",
      "December",
    ];
    return "${months[date.month - 1]} ${date.day}, ${date.year}";
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: CustomAppBar(
        title: 'Win Details',
        showBackButton: true,
        actions: [
          IconButton(
            onPressed: isLoading || currentWin.isEmpty ? null : _handleEdit,
            icon: CustomIconWidget(
              iconName: 'edit',
              color:
                  isLoading || currentWin.isEmpty
                      ? theme.colorScheme.secondary.withValues(alpha: 0.5)
                      : theme.colorScheme.primary,
              size: 24,
            ),
            tooltip: 'Edit Win',
          ),
        ],
      ),
      body: SafeArea(child: _buildBody()),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return _buildLoadingState();
    }

    if (errorMessage != null) {
      return _buildErrorState();
    }

    if (allWins.isEmpty || currentWin.isEmpty) {
      return _buildEmptyState();
    }

    return _buildWinContent();
  }

  Widget _buildLoadingState() {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: theme.colorScheme.primary),
          SizedBox(height: 2.h),
          Text(
            'Loading your wins...',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.secondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    final theme = Theme.of(context);

    return Center(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 8.w),
        padding: EdgeInsets.all(8.w),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: theme.colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomIconWidget(
              iconName: 'error_outline',
              color: theme.colorScheme.error,
              size: 48,
            ),
            SizedBox(height: 3.h),
            Text(
              'Unable to load wins',
              style: theme.textTheme.titleLarge?.copyWith(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              'There was an issue loading your wins. Please try again.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.secondary,
              ),
            ),
            SizedBox(height: 3.h),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Go Back'),
                  ),
                ),
                SizedBox(width: 4.w),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _loadUserWins,
                    child: const Text('Retry'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWinContent() {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                SizedBox(height: 2.h),

                // Win Card
                GestureDetector(
                  onLongPress: _enableTextSelection,
                  child: WinCardWidget(winData: currentWin),
                ),

                SizedBox(height: 2.h),

                // Navigation hints
                if (allWins.length > 1) _buildNavigationHints(),

                SizedBox(height: 2.h),
              ],
            ),
          ),
        ),

        // Action buttons
        ActionButtonsWidget(
          onCreateWinCard: _handleCreateWinCard,
          onEdit: _handleEdit,
          onDelete: _handleDelete,
        ),

        SizedBox(height: 2.h),
      ],
    );
  }

  Widget _buildNavigationHints() {
    final theme = Theme.of(context);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: currentIndex > 0 ? _navigateToPrevious : null,
            child: Row(
              children: [
                CustomIconWidget(
                  iconName: 'chevron_left',
                  color:
                      currentIndex > 0
                          ? theme.colorScheme.primary
                          : theme.colorScheme.secondary.withValues(alpha: 0.5),
                  size: 20,
                ),
                SizedBox(width: 1.w),
                Text(
                  'Previous',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color:
                        currentIndex > 0
                            ? theme.colorScheme.primary
                            : theme.colorScheme.secondary.withValues(
                              alpha: 0.5,
                            ),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${currentIndex + 1} of ${allWins.length}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.secondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          GestureDetector(
            onTap: currentIndex < allWins.length - 1 ? _navigateToNext : null,
            child: Row(
              children: [
                Text(
                  'Next',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color:
                        currentIndex < allWins.length - 1
                            ? theme.colorScheme.primary
                            : theme.colorScheme.secondary.withValues(
                              alpha: 0.5,
                            ),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(width: 1.w),
                CustomIconWidget(
                  iconName: 'chevron_right',
                  color:
                      currentIndex < allWins.length - 1
                          ? theme.colorScheme.primary
                          : theme.colorScheme.secondary.withValues(alpha: 0.5),
                  size: 20,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    final theme = Theme.of(context);

    return Center(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 8.w),
        padding: EdgeInsets.all(8.w),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: theme.colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomIconWidget(
              iconName: 'emoji_events',
              color: theme.colorScheme.secondary,
              size: 48,
            ),
            SizedBox(height: 3.h),
            Text(
              'No wins yet',
              style: theme.textTheme.titleLarge?.copyWith(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              'Start logging your daily wins to see them here.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.secondary,
              ),
            ),
            SizedBox(height: 3.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Go Back'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToPrevious() {
    if (currentIndex > 0) {
      HapticFeedback.lightImpact();
      setState(() {
        currentIndex--;
        currentWin = allWins[currentIndex];
      });
    }
  }

  void _navigateToNext() {
    if (currentIndex < allWins.length - 1) {
      HapticFeedback.lightImpact();
      setState(() {
        currentIndex++;
        currentWin = allWins[currentIndex];
      });
    }
  }

  void _enableTextSelection() {
    HapticFeedback.lightImpact();
    // Show a toast to indicate text selection is available
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Long press on text to select and copy'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _handleCreateWinCard() async {
    await WinCardGenerator.generateAndShareWinCard(context, currentWin);
  }

  void _handleEdit() {
    HapticFeedback.lightImpact();
    Navigator.pushNamed(context, '/add-win-modal', arguments: currentWin).then((
      result,
    ) {
      if (result != null && result is Map<String, dynamic>) {
        // Reload wins after edit to get updated data
        _loadUserWins();

        // Show success feedback
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Win updated successfully!'),
            backgroundColor: WDDLDesignSystem.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    });
  }

  void _handleDelete() async {
    HapticFeedback.mediumImpact();

    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Win'),
            content: const Text(
              'Are you sure you want to delete this win? This action cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.error,
                ),
                child: const Text('Delete'),
              ),
            ],
          ),
    );

    if (confirmed != true) return;

    try {
      final winId = currentWin['id'] as String;
      final winType = currentWin['type'] as String;

      // Delete from appropriate service based on type
      if (winType == 'win') {
        await WinsService.instance.deleteWin(winId);
      } else if (winType == 'daily_win') {
        await WinsService.instance.deleteDailyWin(winId);
      }

      // Reload wins after deletion
      await _loadUserWins();

      // Show deletion confirmation
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Win deleted successfully'),
            backgroundColor: WDDLDesignSystem.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );

        // Navigate back if no wins left
        if (allWins.isEmpty) {
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted) {
              Navigator.of(context).pop();
            }
          });
        }
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete win: ${error.toString()}'),
            backgroundColor: WDDLDesignSystem.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }
}
