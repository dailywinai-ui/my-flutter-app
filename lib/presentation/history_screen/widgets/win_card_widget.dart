import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:win_daily/theme/wddl_design_system.dart';

class WinCardWidget extends StatelessWidget {
  final Map<String, dynamic> win;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onShare;

  const WinCardWidget({
    super.key,
    required this.win,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    final date = DateTime.parse(win['date'] as String);
    final title = win['title'] as String? ?? 'Untitled Win';
    final reflection = win['reflection'] as String? ?? '';

    return Dismissible(
      key: Key('win_${win['id']}'),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) => _showDeleteConfirmation(context),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: WDDLDesignSystem.error,
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Icon(Icons.delete_outline_rounded,
            color: Colors.white, size: 22),
      ),
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap?.call();
        },
        onLongPress: () {
          HapticFeedback.mediumImpact();
          _showContextMenu(context);
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: WDDLDesignSystem.cardDecoration,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date label
              Text(
                _formatDate(date),
                style: WDDLDesignSystem.eyebrow,
              ),

              const SizedBox(height: 8),

              // Win title — Cormorant
              Text(
                title,
                style: GoogleFonts.cormorantGaramond(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: WDDLDesignSystem.ink,
                  height: 1.3,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              // Reflection preview
              if (reflection.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  reflection,
                  style: GoogleFonts.cormorantGaramond(
                    fontSize: 15,
                    fontStyle: FontStyle.italic,
                    color: WDDLDesignSystem.inkMuted,
                    height: 1.5,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final winDate = DateTime(date.year, date.month, date.day);

    if (winDate == today) return 'Today';
    if (winDate == yesterday) return 'Yesterday';

    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  Future<bool?> _showDeleteConfirmation(BuildContext context) async {
    return showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: WDDLDesignSystem.cream,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Delete win?',
          style: GoogleFonts.cormorantGaramond(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: WDDLDesignSystem.ink,
          ),
        ),
        content: Text(
          'This action cannot be undone.',
          style: WDDLDesignSystem.body.copyWith(color: WDDLDesignSystem.inkMuted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Cancel',
                style: WDDLDesignSystem.body.copyWith(
                    color: WDDLDesignSystem.inkMuted)),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(true);
              onDelete?.call();
            },
            child: Text('Delete',
                style: WDDLDesignSystem.body.copyWith(
                    color: WDDLDesignSystem.error)),
          ),
        ],
      ),
    );
  }

  void _showContextMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: WDDLDesignSystem.cream,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: WDDLDesignSystem.beigeDark,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              _sheetTile(
                context,
                icon: Icons.edit_outlined,
                label: 'Edit win',
                onTap: () {
                  Navigator.pop(context);
                  onEdit?.call();
                },
              ),
              _sheetTile(
                context,
                icon: Icons.share_outlined,
                label: 'Share win card',
                onTap: () {
                  Navigator.pop(context);
                  onShare?.call();
                },
              ),
              _sheetTile(
                context,
                icon: Icons.delete_outline_rounded,
                label: 'Delete win',
                color: WDDLDesignSystem.error,
                onTap: () {
                  Navigator.pop(context);
                  _showDeleteConfirmation(context).then((confirmed) {
                    if (confirmed == true) onDelete?.call();
                  });
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sheetTile(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? color,
  }) {
    final c = color ?? WDDLDesignSystem.ink;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: c, size: 22),
      title: Text(label,
          style: WDDLDesignSystem.bodyLarge.copyWith(color: c)),
      onTap: onTap,
    );
  }
}