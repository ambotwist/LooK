import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lookapp/main.dart';
import 'package:lookapp/providers/user_preferences_provider.dart';
import 'dart:developer' as developer;

class UserProfileNotifier extends StateNotifier<AsyncValue<void>> {
  UserProfileNotifier(this.ref) : super(const AsyncValue.data(null)) {
    // Load user profile when initialized
    developer.log('Initializing UserProfileNotifier',
        name: 'UserProfileNotifier');

    // Listen to auth state changes
    supabase.auth.onAuthStateChange.listen((data) {
      developer.log('Auth state changed: ${data.event}',
          name: 'UserProfileNotifier');
      if (data.session != null) {
        loadUserProfile();
      }
    });
  }

  final Ref ref;

  Future<void> loadUserProfile() async {
    developer.log('Loading user profile...', name: 'UserProfileNotifier');
    try {
      final userId = supabase.auth.currentUser?.id;
      developer.log('Current user ID: $userId', name: 'UserProfileNotifier');
      if (userId == null) {
        developer.log('No user ID found', name: 'UserProfileNotifier');
        return;
      }

      final response = await supabase
          .from('user_profiles')
          .select()
          .eq('user_id', userId)
          .single();

      developer.log('Profile loaded: $response', name: 'UserProfileNotifier');

      // Update the UserPreferencesProvider with the loaded data
      final notifier = ref.read(userPreferencesProvider.notifier);
      notifier
        ..updateFirstName(response['first_name'])
        ..updateLastName(response['last_name'])
        ..updatePhoneNumber(response['phone_number'])
        ..updateDialCode(response['dial_code'] ?? '')
        ..updateIsoCode(response['iso_code'] ?? '');

      developer.log(
          'UserPreferences updated - First Name: ${response['first_name']}, Last Name: ${response['last_name']}',
          name: 'UserProfileNotifier');
    } catch (e, st) {
      developer.log('Error loading profile',
          error: e, stackTrace: st, name: 'UserProfileNotifier');
      state = AsyncValue.error(e, st);
    }
  }

  Future<bool> updateUserProfile({
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String? dialCode,
    String? isoCode,
  }) async {
    state = const AsyncValue.loading();
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) return false;

      // Only include non-null values in the update
      final updates = <String, dynamic>{};
      if (firstName != null) updates['first_name'] = firstName;
      if (lastName != null) updates['last_name'] = lastName;
      if (phoneNumber != null) updates['phone_number'] = phoneNumber;
      if (dialCode != null) updates['dial_code'] = dialCode;
      if (isoCode != null) updates['iso_code'] = isoCode;

      developer.log(
        'Updating user profile',
        name: 'UserProfileNotifier',
        error: {
          'updates': updates,
          'userId': userId,
        },
      );

      if (updates.isEmpty) return true;

      final response = await supabase
          .from('user_profiles')
          .update(updates)
          .eq('user_id', userId)
          .select();

      developer.log(
        'Profile updated',
        name: 'UserProfileNotifier',
        error: response,
      );

      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      developer.log(
        'Error updating profile',
        error: e,
        stackTrace: st,
        name: 'UserProfileNotifier',
      );
      state = AsyncValue.error(e, st);
      return false;
    }
  }
}

final userProfileProvider =
    StateNotifierProvider<UserProfileNotifier, AsyncValue<void>>((ref) {
  return UserProfileNotifier(ref);
});
