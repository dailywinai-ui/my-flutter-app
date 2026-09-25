import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sizer/sizer.dart';

import '../../services/wins_service.dart';
import 'package:win_daily/theme/wddl_design_system.dart';

class AddWinModal extends StatefulWidget {
  const AddWinModal({super.key});

  @override
  State<AddWinModal> createState() => _AddWinModalState();
}

class _AddWinModalState extends State<AddWinModal>
    with TickerProviderStateMixin {
  final TextEditingController _titleController = TextEditingController();
  final FocusNode _titleFocusNode = FocusNode();

  String? _titleError;
  bool _isSaving = false;
  bool _hasUnsavedChanges = false;
  bool _showMicroAnimation = false;
  String? _defaultGoalId;

  bool _isEditMode = false;
  bool _isBackfillMode = false;
  DateTime? _backfillDate;
  Map<String, dynamic>? _existingWin;
  String? _originalTitle;

  late AnimationController _fadeAnimationController;
  late Animation<double> _fadeAnimation;
  late AnimationController _microAnimationController;
  late Animation<double> _microAnimation;
  late AnimationController _tapAnimationController;
  late Animation<double> _tapAnimation;

  @override
  void initState() {
    super.initState();
    _titleController.addListener(_onTitleChanged);

    _fadeAnimationController = AnimationController(
      duration: WDDLDesignSystem.fadeInDuration,
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fadeAnimationController,
        curve: WDDLDesignSystem.fadeInCurve,
      ),
    );

    _microAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _microAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _microAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    _tapAnimationController = AnimationController(
      duration: WDDLDesignSystem.tapFeedbackDuration,
      vsync: this,
    );
    _tapAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(
        parent: _tapAnimationController,
        curve: WDDLDesignSystem.tapFeedbackCurve,
      ),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkEditMode();
      _fadeAnimationController.forward();
      Future.microtask(() {
        if (mounted) _titleFocusNode.requestFocus();
      });
    });

    _loadDefaultGoal();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _titleFocusNode.dispose();
    _fadeAnimationController.dispose();
    _microAnimationController.dispose();
    _tapAnimationController.dispose();
    super.dispose();
  }

  void _checkEditMode() {
    final arguments = ModalRoute.of(context)?.settings.arguments;
    if (arguments is Map<String, dynamic>) {
      if (arguments['backfill'] == true) {
        final argDate = arguments['date'];
        final now = DateTime.now();
        setState(() {
          _isBackfillMode = true;
          _backfillDate = argDate is DateTime
              ? DateTime(argDate.year, argDate.month, argDate.day)
              : DateTime(now.year, now.month, now.day)
                  .subtract(const Duration(days: 1));
        });
        return;
      }
      setState(() {
        _isEditMode = true;
        _existingWin = arguments;
        _originalTitle = arguments['title'] ?? '';
        _titleController.text = _originalTitle ?? '';

        if (_titleController.text.isNotEmpty) {
          _showMicroAnimation = true;
          _microAnimationController.forward();
        }
      });
    }
  }

  Future<void> _loadDefaultGoal() async {
    try {
      final goals = await WinsService.instance.getMajorGoals(activeOnly: true);
      if (goals.isNotEmpty) {
        setState(() => _defaultGoalId = goals.first.id);
      }
    } catch (e) {
      print('No major goals found: $e');
    }
  }

  void _onTitleChanged() {
    setState(() {
      final currentText = _titleController.text.trim();
      if (_isEditMode) {
        _hasUnsavedChanges = currentText != (_originalTitle ?? '');
      } else {
        _hasUnsavedChanges = currentText.isNotEmpty;
      }

      if (_titleError != null && _titleController.text.isNotEmpty) {
        _titleError = null;
      }

      if (_titleController.text.isNotEmpty && !_showMicroAnimation) {
        _showMicroAnimation = true;
        _microAnimationController.forward();
      } else if (_titleController.text.isEmpty && _showMicroAnimation) {
        _showMicroAnimation = false;
        _microAnimationController.reverse();
      }
    });
  }

  String _formatBackfillDate(DateTime d) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[d.month - 1]} ${d.day}, ${d.year}';
  }

  Future<void> _pickBackfillDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _backfillDate ??
          DateTime(now.year, now.month, now.day)
              .subtract(const Duration(days: 1)),
      firstDate: DateTime(now.year - 5, now.month, now.day),
      lastDate: DateTime(now.year, now.month, now.day),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: WDDLDesignSystem.sage,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && mounted) {
      setState(() =>
          _backfillDate = DateTime(picked.year, picked.month, picked.day));
      HapticFeedback.selectionClick();
    }
  }

  bool _validateForm() {
    setState(() => _titleError = null);

    if (_titleController.text.trim().isEmpty) {
      setState(() => _titleError = 'Please enter what you accomplished today');
      _titleFocusNode.requestFocus();
      return false;
    }

    if (_titleController.text.trim().length < 3) {
      setState(() => _titleError = 'Please enter at least 3 characters');
      _titleFocusNode.requestFocus();
      return false;
    }

    return true;
  }

  Future<String> _ensureDefaultGoal() async {
    if (_defaultGoalId != null) return _defaultGoalId!;

    try {
      final defaultGoal = await WinsService.instance.createMajorGoal(
        title: 'General Progress',
        description: 'Default goal for tracking daily wins',
      );
      setState(() => _defaultGoalId = defaultGoal.id);
      return defaultGoal.id;
    } catch (e) {
      throw Exception('Failed to create default goal: $e');
    }
  }

  Future<void> _saveWin() async {
    if (!_validateForm() || _isSaving) return;

    _tapAnimationController.forward().then((_) => _tapAnimationController.reverse());
    setState(() => _isSaving = true);
    FocusScope.of(context).unfocus();

    try {
      if (_isEditMode && _existingWin != null) {
        // FIX: Edit mode — just update the win and pop back, no reflection screen
        await _updateExistingWin();
        HapticFeedback.mediumImpact();
        _showSuccessModal();
        await Future.delayed(const Duration(milliseconds: 800));
        if (mounted) {
          Navigator.of(context).pop(); // close success dialog
          Navigator.of(context).pop(true); // close add win modal
        }
      } else {
        // New win — save then navigate to reflection screen
        final dailyWin = await _createNewWin();
        HapticFeedback.mediumImpact();
        _showSuccessModal();
        await Future.delayed(const Duration(seconds: 1));
        if (mounted) {
          Navigator.of(context).pushReplacementNamed(
            '/reflection-screen',
            arguments: {'winId': dailyWin.id},
          );
        }
      }
    } catch (e) {
      print('Failed to save win: $e');
      Fluttertoast.showToast(
        msg: "Failed to save win. Please try again.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: WDDLDesignSystem.error,
        textColor: Colors.white,
        fontSize: 14.sp,
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<dynamic> _createNewWin() async {
    final goalId = await _ensureDefaultGoal();
    return await WinsService.instance.createDailyWin(
      description: _titleController.text.trim(),
      goalId: goalId,
      winDate: _isBackfillMode
          ? (_backfillDate ?? DateTime.now())
          : DateTime.now(),
      reflection: null,
    );
  }

  Future<void> _updateExistingWin() async {
    final winId = _existingWin!['id'] as String;
    final winType = _existingWin!['type'] as String;

    if (winType == 'daily_win') {
      await WinsService.instance.updateDailyWin(
        winId: winId,
        description: _titleController.text.trim(),
      );
    } else if (winType == 'win') {
      await WinsService.instance.updateWin(
        winId: winId,
        text: _titleController.text.trim(),
      );
    } else {
      throw Exception('Unknown win type: $winType');
    }
  }

  void _showSuccessModal() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: AnimatedContainer(
          duration: WDDLDesignSystem.successModalDuration,
          padding: const EdgeInsets.all(24),
          decoration: WDDLDesignSystem.cardDecoration.copyWith(
            color: WDDLDesignSystem.surface,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: WDDLDesignSystem.componentGap),
              Text(
                _isEditMode
                    ? 'Win updated.'
                    : WDDLDesignSystem.winLoggedMessage,
                style: WDDLDesignSystem.bodyLarge.copyWith(
                  fontWeight: FontWeight.w600,
                  color: WDDLDesignSystem.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> _onWillPop() async {
    if (!_hasUnsavedChanges) return true;

    final shouldPop = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Discard changes?'),
        content: const Text('You have unsaved changes. Are you sure you want to leave?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: WDDLDesignSystem.error),
            child: const Text('Discard'),
          ),
        ],
      ),
    );

    return shouldPop ?? false;
  }

  void _handleCancel() async {
    HapticFeedback.lightImpact();
    if (_hasUnsavedChanges) {
      final shouldClose = await _onWillPop();
      if (shouldClose && mounted) Navigator.of(context).pop();
    } else {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_hasUnsavedChanges,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop) {
          final shouldPop = await _onWillPop();
          if (shouldPop && context.mounted) Navigator.of(context).pop();
        }
      },
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Scaffold(
          backgroundColor: WDDLDesignSystem.background,
          resizeToAvoidBottomInset: true,
          body: SafeArea(
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.only(
                    top: WDDLDesignSystem.headerTopPadding,
                    bottom: 24,
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          TextButton(
                            onPressed: _isSaving ? null : _handleCancel,
                            child: Text(
                              'Cancel',
                              style: WDDLDesignSystem.bodyLarge.copyWith(
                                color: _isSaving
                                    ? WDDLDesignSystem.textSecondary
                                    : WDDLDesignSystem.secondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const Spacer(),
                        ],
                      ),
                      SizedBox(height: WDDLDesignSystem.sectionGap),
                      Text(
                        _isEditMode
                            ? 'Edit your win'
                            : _isBackfillMode
                                ? 'Add a past win'
                                : 'What do you want to remember about today?',
                        style: WDDLDesignSystem.h1,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _isEditMode
                            ? 'Update your accomplishment'
                            : _isBackfillMode
                                ? 'Fill in a day from memory.'
                                : 'Small steps, big identity.',
                        style: WDDLDesignSystem.body.copyWith(
                          color: WDDLDesignSystem.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      if (_isBackfillMode) ...[
                        const SizedBox(height: 12),
                        GestureDetector(
                          onTap: _isSaving ? null : _pickBackfillDate,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: WDDLDesignSystem.sagePale
                                  .withValues(alpha: 0.6),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.calendar_today_outlined,
                                    size: 14,
                                    color: WDDLDesignSystem.sage),
                                const SizedBox(width: 6),
                                Text(
                                  _backfillDate != null
                                      ? _formatBackfillDate(_backfillDate!)
                                      : 'Pick a date',
                                  style: WDDLDesignSystem.body.copyWith(
                                    color: WDDLDesignSystem.sage,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: WDDLDesignSystem.screenPadding,
                    child: Column(
                      children: [
                        const SizedBox(height: 12),
                        GestureDetector(
                          onTap: () => _titleFocusNode.requestFocus(),
                          child: Container(
                            height: 180,
                            decoration: BoxDecoration(
                              color: WDDLDesignSystem.inputBackground,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: WDDLDesignSystem.inputBorder,
                                width: 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withAlpha(13),
                                  blurRadius: 4,
                                  offset: const Offset(0, 1),
                                ),
                              ],
                            ),
                            child: TextField(
                              controller: _titleController,
                              focusNode: _titleFocusNode,
                              onChanged: (value) {
                                HapticFeedback.selectionClick();
                                _onTitleChanged();
                              },
                              onTap: () => _titleFocusNode.requestFocus(),
                              maxLines: null,
                              expands: true,
                              textAlignVertical: TextAlignVertical.top,
                              style: WDDLDesignSystem.bodyLarge.copyWith(
                                fontWeight: FontWeight.w500,
                                height: 1.4,
                              ),
                              decoration: InputDecoration(
                                hintText: _isEditMode
                                    ? 'Update your accomplishment...'
                                    : 'Exercised for 30 minutes, finished a task, or had a great conversation. What\'s your win?',
                                hintStyle: WDDLDesignSystem.bodyLarge.copyWith(
                                  color: const Color(0xFF9AA0A6),
                                  height: 1.4,
                                ),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.all(16),
                              ),
                              textCapitalization: TextCapitalization.sentences,
                              keyboardType: TextInputType.multiline,
                              textInputAction: TextInputAction.newline,
                              autofocus: true,
                              enableInteractiveSelection: true,
                            ),
                          ),
                        ),
                        if (_titleError != null) ...[
                          const SizedBox(height: 8),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              _titleError!,
                              style: WDDLDesignSystem.body
                                  .copyWith(color: WDDLDesignSystem.error),
                            ),
                          ),
                        ],
                        const SizedBox(height: 16),
                        ScaleTransition(
                          scale: _tapAnimation,
                          child: SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton(
                              onPressed: (_titleController.text.trim().isNotEmpty &&
                                      !_isSaving &&
                                      (_isEditMode ? _hasUnsavedChanges : true))
                                  ? _saveWin
                                  : null,
                              style: WDDLDesignSystem.primaryButton.copyWith(
                                backgroundColor: WidgetStateProperty.all(
                                    WDDLDesignSystem.primary),
                                shadowColor: WidgetStateProperty.all(
                                    Colors.black.withAlpha(26)),
                                elevation: WidgetStateProperty.all(2.0),
                              ),
                              child: _isSaving
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2),
                                    )
                                  : const Text('Save'),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
                // FIX: Only show "Next: reflect" hint for new wins, not edits
                if (!_isEditMode)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 16),
                    decoration: BoxDecoration(
                      color: WDDLDesignSystem.background,
                      border: Border(
                        top: BorderSide(
                          color: WDDLDesignSystem.inputBorder
                              .withValues(alpha: 0.5),
                          width: 1,
                        ),
                      ),
                    ),
                    child: Text(
                      "Reflect. Don't perform.",
                      style: WDDLDesignSystem.hint.copyWith(fontSize: 13),
                      textAlign: TextAlign.center,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}