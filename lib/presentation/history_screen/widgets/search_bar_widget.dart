import 'package:flutter/material.dart';
import 'package:win_daily/theme/wddl_design_system.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

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
    final theme = Theme.of(context);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _isSearchActive
                      ? WDDLDesignSystem.sageMedium
                      : theme.colorScheme.outline.withValues(alpha: 0.2),
                  width: _isSearchActive ? 2 : 1,
                ),
              ),
              child: TextField(
                controller: _searchController,
                focusNode: _focusNode,
                onChanged: (value) {
                  widget.onSearchChanged(value);
                },
                onTap: () {
                  HapticFeedback.lightImpact();
                  setState(() {
                    _isSearchActive = true;
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Search wins...',
                  hintStyle: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  prefixIcon: Padding(
                    padding: EdgeInsets.all(3.w),
                    child: CustomIconWidget(
                      iconName: 'search',
                      color: _isSearchActive
                          ? WDDLDesignSystem.sageMedium
                          : theme.colorScheme.onSurfaceVariant,
                      size: 20,
                    ),
                  ),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          onPressed: () {
                            HapticFeedback.lightImpact();
                            _searchController.clear();
                            widget.onSearchChanged('');
                            _focusNode.unfocus();
                            setState(() {
                              _isSearchActive = false;
                            });
                          },
                          icon: CustomIconWidget(
                            iconName: 'clear',
                            color: theme.colorScheme.onSurfaceVariant,
                            size: 20,
                          ),
                        )
                      : null,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 4.w,
                    vertical: 2.h,
                  ),
                ),
                style: theme.textTheme.bodyMedium,
                textInputAction: TextInputAction.search,
                onSubmitted: (value) {
                  _focusNode.unfocus();
                  setState(() {
                    _isSearchActive = false;
                  });
                },
              ),
            ),
          ),
          if (widget.showFilter) ...[
            SizedBox(width: 3.w),
            GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                widget.onFilterTap?.call();
              },
              child: Container(
                padding: EdgeInsets.all(3.w),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: theme.colorScheme.outline.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                child: CustomIconWidget(
                  iconName: 'tune',
                  color: theme.colorScheme.primary,
                  size: 24,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
