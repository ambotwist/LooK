import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:developer' as developer;

enum HMInteractionStatus { like, dislike, superlike }

final hmInteractionsProvider =
    StateNotifierProvider<HMInteractionsNotifier, AsyncValue<void>>((ref) {
  return HMInteractionsNotifier();
});

class HMInteractionsNotifier extends StateNotifier<AsyncValue<void>> {
  HMInteractionsNotifier() : super(const AsyncValue.data(null));

  Future<bool> updateInteraction(
      String itemId, HMInteractionStatus? status) async {
    state = const AsyncValue.loading();
    try {
      final supabase = Supabase.instance.client;
      final userId = supabase.auth.currentUser?.id;

      developer.log(
        'Updating HM interaction',
        name: 'HMInteractionsNotifier',
        error: {
          'userId': userId,
          'itemId': itemId,
          'status': status?.name,
        },
      );

      if (userId == null) {
        developer.log(
          'No user ID found',
          name: 'HMInteractionsNotifier',
        );
        return false;
      }

      // Check if the HM item exists
      final itemExists = await supabase
          .from('hm_items')
          .select('id')
          .eq('id', itemId)
          .maybeSingle();

      if (itemExists == null) {
        developer.log(
          'HM Item not found',
          name: 'HMInteractionsNotifier',
          error: {'itemId': itemId},
        );
        return false;
      }

      if (status == null) {
        // Delete the interaction
        final response = await supabase.from('hm_interactions').delete().match({
          'user_id': userId,
          'item_id': itemId,
        });

        developer.log(
          'Deleted HM interaction',
          name: 'HMInteractionsNotifier',
          error: response,
        );
      } else {
        // Insert or update the interaction
        final response = await supabase.from('hm_interactions').upsert({
          'user_id': userId,
          'item_id': itemId,
          'interaction_type': status.name,
          'updated_at': DateTime.now().toIso8601String(),
        });

        developer.log(
          'Upserted HM interaction',
          name: 'HMInteractionsNotifier',
          error: response,
        );
      }

      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      developer.log(
        'Error updating HM interaction',
        error: e,
        stackTrace: st,
        name: 'HMInteractionsNotifier',
      );
      state = AsyncValue.error(e, st);
      return false;
    }
  }
}
