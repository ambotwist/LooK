import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lookapp/main.dart';

class UserProfileNotifier extends StateNotifier<AsyncValue<void>> {
  UserProfileNotifier() : super(const AsyncValue.data(null));

  Future<bool> updateUserProfile({
    String? firstName,
    String? lastName,
    String? phoneNumber,
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

      if (updates.isEmpty) return true;

      await supabase
          .from('user_profiles')
          .update(updates)
          .eq('user_id', userId);

      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }
}

final userProfileProvider =
    StateNotifierProvider<UserProfileNotifier, AsyncValue<void>>((ref) {
  return UserProfileNotifier();
});
