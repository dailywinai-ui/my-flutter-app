import 'package:flutter/material.dart';
import '../../../theme/wddl_design_system.dart';
import '../../../services/auth_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileSettingsWidget extends StatefulWidget {
  const ProfileSettingsWidget({super.key});

  @override
  State<ProfileSettingsWidget> createState() => _ProfileSettingsWidgetState();
}

class _ProfileSettingsWidgetState extends State<ProfileSettingsWidget> {
  final TextEditingController _nameController = TextEditingController();
  bool _isEditing = false;
  bool _isSaving = false;
  String? _currentName;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final profile = await AuthService.instance.getUserProfile();
    if (mounted && profile?.firstName != null) {
      setState(() {
        _currentName = profile!.firstName;
        _nameController.text = _currentName!;
      });
    }
  }

  Future<void> _saveName() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    setState(() => _isSaving = true);

    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId != null) {
        await Supabase.instance.client.from('user_profiles').update({
          'first_name': name,
          'updated_at': DateTime.now().toIso8601String(),
        }).eq('id', userId);

        if (mounted) {
          setState(() {
            _currentName = name;
            _isEditing = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Name updated successfully')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating name: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: WDDLDesignSystem.screenPadding,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Your Name',
                style: WDDLDesignSystem.bodyLarge.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (!_isEditing && _currentName != null)
                TextButton(
                  onPressed: () => setState(() => _isEditing = true),
                  child: Text(
                    'Edit',
                    style: TextStyle(color: WDDLDesignSystem.primary),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          if (_isEditing)
            Column(
              children: [
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    hintText: 'Enter your name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: WDDLDesignSystem.inputBorder),
                    ),
                    contentPadding: const EdgeInsets.all(16),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          setState(() {
                            _isEditing = false;
                            _nameController.text = _currentName ?? '';
                          });
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _saveName,
                        style: WDDLDesignSystem.primaryButton,
                        child: _isSaving
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('Save'),
                      ),
                    ),
                  ],
                ),
              ],
            )
          else
            Text(
              _currentName ?? 'Not set - tap Edit to add your name',
              style: WDDLDesignSystem.body.copyWith(
                color: _currentName != null
                    ? WDDLDesignSystem.textPrimary
                    : WDDLDesignSystem.textSecondary,
              ),
            ),
        ],
      ),
    );
  }
}
