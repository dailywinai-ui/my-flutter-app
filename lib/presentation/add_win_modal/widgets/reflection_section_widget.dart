import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class ReflectionSectionWidget extends StatefulWidget {
  final TextEditingController controller;
  final Function(String) onChanged;

  const ReflectionSectionWidget({
    super.key,
    required this.controller,
    required this.onChanged,
  });

  @override
  State<ReflectionSectionWidget> createState() =>
      _ReflectionSectionWidgetState();
}

class _ReflectionSectionWidgetState extends State<ReflectionSectionWidget> {
  bool _isExpanded = false;
  bool _showPrompts = false;

  final List<String> _reflectionPrompts = [
    'What made this possible?',
    'How do you feel?',
    'What did you learn?',
    'What would you do differently?',
    'Who helped you achieve this?',
    'What\'s your next step?',
    'Why was this important?',
    'What surprised you?',
  ];

  void _insertPrompt(String prompt) {
    final currentText = widget.controller.text;
    final newText = currentText.isEmpty ? prompt : '$currentText\n\n$prompt';
    widget.controller.text = newText;
    widget.onChanged(newText);
    setState(() {
      _showPrompts = false;
      _isExpanded = true;
    });
    HapticFeedback.lightImpact();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Reflection (Optional)',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
            TextButton.icon(
              onPressed: () {
                HapticFeedback.selectionClick();
                setState(() {
                  _showPrompts = !_showPrompts;
                });
              },
              icon: CustomIconWidget(
                iconName:
                    _showPrompts ? 'keyboard_arrow_up' : 'lightbulb_outline',
                size: 20,
                color: theme.colorScheme.tertiary,
              ),
              label: Text(
                _showPrompts ? 'Hide' : 'Prompts',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.tertiary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ],
        ),
        if (_showPrompts) ...[
          SizedBox(height: 1.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.colorScheme.outline.withValues(alpha: 0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tap a prompt to get started:',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 1.h),
                Wrap(
                  spacing: 2.w,
                  runSpacing: 1.h,
                  children:
                      _reflectionPrompts.map((prompt) {
                        return GestureDetector(
                          onTap: () => _insertPrompt(prompt),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 3.w,
                              vertical: 1.h,
                            ),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.tertiary.withValues(
                                alpha: 0.1,
                              ),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: theme.colorScheme.tertiary.withValues(
                                  alpha: 0.3,
                                ),
                              ),
                            ),
                            child: Text(
                              prompt,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.tertiary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                ),
              ],
            ),
          ),
        ],
        SizedBox(height: 2.h),
        GestureDetector(
          onTap: () {
            setState(() {
              _isExpanded = true;
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: _isExpanded ? 20.h : 8.h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Color(0xFFE0E0E0), width: 1),
            ),
            child: TextField(
              controller: widget.controller,
              onChanged: (value) {
                widget.onChanged(value);
                if (value.isNotEmpty && !_isExpanded) {
                  setState(() {
                    _isExpanded = true;
                  });
                }
              },
              onTap: () {
                setState(() {
                  _isExpanded = true;
                });
              },
              maxLines: null,
              expands: true,
              style: theme.textTheme.bodyMedium?.copyWith(fontSize: 14.sp),
              decoration: InputDecoration(
                hintText:
                    _isExpanded
                        ? 'Share your thoughts, feelings, or insights...'
                        : 'Tap to add reflection...',
                hintStyle: theme.textTheme.bodyMedium?.copyWith(
                  color: Color(0xFF9AA0A6),
                  fontSize: 14.sp,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(16),
              ),
              textCapitalization: TextCapitalization.sentences,
              keyboardType: TextInputType.multiline,
              textInputAction: TextInputAction.newline,
            ),
          ),
        ),
      ],
    );
  }
}
