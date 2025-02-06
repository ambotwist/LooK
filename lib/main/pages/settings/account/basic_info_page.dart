import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lookapp/providers/user_preferences_provider.dart';
import 'package:lookapp/providers/user_profile_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:developer' as developer;

class BasicInfoPage extends ConsumerStatefulWidget {
  const BasicInfoPage({super.key});

  @override
  ConsumerState<BasicInfoPage> createState() => _BasicInfoPageState();
}

class _BasicInfoPageState extends ConsumerState<BasicInfoPage> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final userPrefs = ref.read(userPreferencesProvider);
    _firstNameController.text = userPrefs.firstName ?? '';
    _lastNameController.text = userPrefs.lastName ?? '';
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _saveBasicInfo() async {
    try {
      final supabase = Supabase.instance.client;

      final response = await supabase
          .from('user_profiles')
          .update({
            'first_name': _firstNameController.text.trim(),
            'last_name': _lastNameController.text.trim(),
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('user_id', supabase.auth.currentUser!.id)
          .select();

      // Update the local state
      ref.read(userPreferencesProvider.notifier)
        ..updateFirstName(_firstNameController.text)
        ..updateLastName(_lastNameController.text);

      // Refresh the user profile to ensure all states are in sync
      ref.read(userProfileProvider.notifier).loadUserProfile();

      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (error, stackTrace) {
      developer.log(
        'Error saving basic info',
        error: error,
        stackTrace: stackTrace,
        name: 'BasicInfoPage',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Failed to save changes: ${error.toString()}')),
        );
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 42,
        leading: const Text(''),
        title: const Text(
          'Basic Info',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _saveBasicInfo,
            child: const Text(
              'Save',
              style: TextStyle(
                color: Colors.blue,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField(
                controller: _firstNameController,
                label: 'First Name',
                hint: 'Enter your first name',
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _lastNameController,
                label: 'Last Name',
                hint: 'Enter your last name',
                textCapitalization: TextCapitalization.words,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    TextCapitalization textCapitalization = TextCapitalization.none,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          textCapitalization: textCapitalization,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onPrimary,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(
                color: Colors.transparent,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(
                color: Colors.transparent,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
          ),
        ),
      ],
    );
  }
}
