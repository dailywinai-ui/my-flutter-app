import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:win_daily/theme/wddl_design_system.dart';

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
    setState(() => _isRefreshing = true);
    HapticFeedback.lightImpact();
    await Future.delayed(const Duration(milliseconds: 500));
    widget.onRefresh();
    setState(() => _isRefreshing = false);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.wins.isEmpty) return _buildEmptyState();
    return RefreshIndicator(
      onRefresh: _handleRefresh,
      color: WDDLDesignSystem.sage,
      backgroundColor: WDDLDesignSystem.cream,
      child: ListView.builder(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(vertical: 8),
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

  Widget _buildEmptyState() {
    return RefreshIndicator(
      onRefresh: _handleRefresh,
      color: WDDLDesignSystem.sage,
      backgroundColor: WDDLDesignSystem.cream,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: SizedBox(
          height: 400,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: const BoxDecoration(
                  color: WDDLDesignSystem.sagePale,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.auto_awesome_outlined, color: WDDLDesignSystem.sage, size: 32),
              ),
              const SizedBox(height: 20),
              Text(
                'No wins yet',
                style: GoogleFonts.cormorantGaramond(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: WDDLDesignSystem.ink,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Your wins will appear here.',
                style: WDDLDesignSystem.body.copyWith(color: WDDLDesignSystem.inkMuted),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
