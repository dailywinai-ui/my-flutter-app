import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TitleInputWidget extends StatefulWidget {
  final TextEditingController controller;
  final Function(String) onChanged;
  final String? errorText;

  const TitleInputWidget({
    super.key,
    required this.controller,
    required this.onChanged,
    this.errorText,
  });

  @override
  State<TitleInputWidget> createState() => _TitleInputWidgetState();
}

class _TitleInputWidgetState extends State<TitleInputWidget> {
  bool _showMicroAnimation = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() {
    final hasText = widget.controller.text.isNotEmpty;
    if (hasText != _showMicroAnimation) {
      setState(() {
        _showMicroAnimation = hasText;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'What did you accomplish today?',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF6B8B7F),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Small steps, big identity.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: const Color(0xFF6E767D),
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 24),
        Stack(
          children: [
            Container(
              height: 180,
              decoration: BoxDecoration(
                color: const Color(0xFFF8F9FA),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: TextField(
                controller: widget.controller,
                onChanged: (value) {
                  HapticFeedback.selectionClick();
                  widget.onChanged(value);
                },
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  height: 1.4,
                ),
                decoration: InputDecoration(
                  hintText:
                      'Exercised for 30 minutes, finished a task, or had a great conversation — what\'s your win?',
                  hintStyle: theme.textTheme.bodyLarge?.copyWith(
                    color: const Color(0xFF9AA0A6),
                    fontSize: 16,
                    height: 1.4,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(16),
                ),
                textCapitalization: TextCapitalization.sentences,
                keyboardType: TextInputType.multiline,
                textInputAction: TextInputAction.newline,
              ),
            ),
            // Micro animation
            if (_showMicroAnimation)
              Positioned(
                top: 16,
                right: 16,
                child: AnimatedOpacity(
                  opacity: _showMicroAnimation ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 300),
                  child: const Icon(Icons.edit, color: Color(0xFF7A9D8E), size: 20),
                ),
              ),
          ],
        ),
        if (widget.errorText != null) ...[
          const SizedBox(height: 8),
          Text(
            widget.errorText!,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.error,
            ),
          ),
        ],
      ],
    );
  }
}
