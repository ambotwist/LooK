import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lookapp/main.dart';
import 'dart:developer' as developer;

class NotificationPreferencesNotifier
    extends StateNotifier<AsyncValue<Map<String, bool>>> {
  NotificationPreferencesNotifier() : super(const AsyncValue.data({})) {
    loadNotificationPreferences();
  }

  Future<void> loadNotificationPreferences() async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) return;

      final response = await supabase
          .from('user_profiles')
          .select('notification_preferences')
          .eq('user_id', userId)
          .single();

      final preferences = (response['notification_preferences'] as Map?)
              ?.cast<String, bool>() ??
          {
            'personalized_finds': false,
            'new_arrivals': false,
            'orders_status': false,
            'wishlist_price_drop': false,
            'wishlist_low_stock': false,
            'wishlist_back_in_stock': false,
            'fav_sales': false,
          };

      state = AsyncValue.data(preferences);
    } catch (e, st) {
      developer.log(
        'Error loading notification preferences',
        error: e,
        stackTrace: st,
        name: 'NotificationPreferencesNotifier',
      );
      state = AsyncValue.error(e, st);
    }
  }

  Future<bool> saveNotificationPreferences(
      Map<String, bool> preferences) async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) return false;

      await supabase.from('user_profiles').update({
        'notification_preferences': preferences,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('user_id', userId);

      state = AsyncValue.data(preferences);
      return true;
    } catch (e, st) {
      developer.log(
        'Error saving notification preferences',
        error: e,
        stackTrace: st,
        name: 'NotificationPreferencesNotifier',
      );
      state = AsyncValue.error(e, st);
      return false;
    }
  }
}

final notificationPreferencesProvider = StateNotifierProvider<
    NotificationPreferencesNotifier,
    AsyncValue<Map<String, bool>>>((ref) => NotificationPreferencesNotifier());
