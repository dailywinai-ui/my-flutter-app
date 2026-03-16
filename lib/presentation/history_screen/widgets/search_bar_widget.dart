import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:win_daily/theme/wddl_design_system.dart';

class SearchBarWidget extends StatefulWidget {
  final Function(String) onSearchChanged;
  final VoidCallback? onFilterTap;
  final bool showFilter;

  const SearchBarWidget({
    super.key,
    required this.onSearchChanged,
    this.onFilterTap,
    this.showFilter = true,
  });

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isSearchActive = false;

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _isSearchActive ? WDDLDesignSystem.sage : WDDLDesignSystem.beigeDark,
                  width: _isSearchActive ? 1.5 : 1,
                ),
              ),
              child: TextField(
                controller: _searchController,
                focusNode: _focusNode,
                onChanged: (value) {
                  setState(() {});
                  widget.onSearchChanged(value);
                },
                onTap: () {
                  HapticFeedback.lightImpact();
                  setState(() => _isSearchActive = true);
                },
                onSubmitted: (_) {
                  _focusNode.unfocus();
                  setState(() => _isSearchActive = false);
                },
                decoration: InputDecoration(
                  hintText: 'Search wins…',
                  hintStyle: WDDLDesignSystem.body.copyWith(
                    color: WDDLDesignSystem.inkMuted.withValues(alpha: 0.5),
                  ),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: _isSearchActive ? WDDLDesignSystem.sage : WDDLDesignSystem.inkMuted,
                    size: 20,
                  ),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          onPressed: () {
                            _searchController.clear();
                            widget.onSearchChanged('');
                            _focusNode.unfocus();
                            setState(() => _isSearchActive = false);
                          },
                          icon: const Icon(Icons.clear_rounded, color: WDDLDesignSystem.inkMuted, size: 18),
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                style: WDDLDesignSystem.body,
                textInputAction: TextInputAction.search,
              ),
            ),
          ),
          if (widget.showFilter) ...[
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                widget.onFilterTap?.call();
              },
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: WDDLDesignSystem.beigeDark),
                ),
                child: const Icon(Icons.tune_rounded, color: WDDLDesignSystem.sage, size: 22),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
