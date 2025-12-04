import 'package:flutter/material.dart';
import 'package:win_daily/theme/wddl_design_system.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import './win_card_widget.dart';

class ListViewWidget extends StatefulWidget {
  final List<Map<String, dynamic>> wins;
  final Function(Map<String, dynamic>) onWinTap;
  final Function(Map<String, dynamic>) onWinEdit;
  final Function(Map<String, dynamic>) onWinDelete;
  final Function(Map<String, dynamic>) onWinShare;
  final VoidCallback onRefresh;

  const ListViewWidget({
    super.key,
    required this.wins,
    required this.onWinTap,
    required this.onWinEdit,
    required this.onWinDelete,
    required this.onWinShare,
    required this.onRefresh,
  });

  @override
  State<ListViewWidget> createState() => _ListViewWidgetState();
}

class _ListViewWidgetState extends State<ListViewWidget> {
  final ScrollController _scrollController = ScrollController();
  bool _isRefreshing = false;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _handleRefresh() async {
    if (_isRefreshing) return;

    setState(() {
      _isRefreshing = true;
    });

    HapticFeedback.lightImpact();

    // Simulate refresh delay
    await Future.delayed(const Duration(milliseconds: 500));

    widget.onRefresh();

    setState(() {
      _isRefreshing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (widget.wins.isEmpty) {
      return _buildEmptyState(theme);
    }

    return RefreshIndicator(
      onRefresh: _handleRefresh,
      color: WDDLDesignSystem.sageMedium,
      backgroundColor: theme.cardColor,
      child: ListView.builder(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(vertical: 1.h),
        itemCount: widget.wins.length,
        itemBuilder: (context, index) {
          final win = widget.wins[index];
          return WinCardWidget(
            win: win,
            onTap: () => widget.onWinTap(win),
            onEdit: () => widget.onWinEdit(win),
            onDelete: () => widget.onWinDelete(win),
            onShare: () => widget.onWinShare(win),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    final suggestions = [
      "Your wins are waiting to be logged",
      "Every small step counts",
      "Start your winning streak today",
      "Progress over perfection",
      "One win at a time",
    ];

    final randomSuggestion =
        suggestions[DateTime.now().millisecond % suggestions.length];

    return RefreshIndicator(
      onRefresh: _handleRefresh,
      color: WDDLDesignSystem.sageMedium,
      backgroundColor: theme.cardColor,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Container(
          height: 60.h,
          padding: EdgeInsets.symmetric(horizontal: 8.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 20.w,
                height: 20.w,
                decoration: BoxDecoration(
                  color: WDDLDesignSystem.sageMedium.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: CustomIconWidget(
                    iconName: 'emoji_events',
                    color: WDDLDesignSystem.sageMedium,
                    size: 8.w,
                  ),
                ),
              ),
              SizedBox(height: 3.h),
              Text(
                'No wins yet',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.primary,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 1.h),
              Text(
                randomSuggestion,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.secondary,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 4.h),
              ElevatedButton(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  Navigator.pushNamed(context, '/today-screen');
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomIconWidget(
                      iconName: 'add',
                      color: Colors.white,
                      size: 20,
                    ),
                    SizedBox(width: 2.w),
                    Text(
                      'Log Your First Win',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
