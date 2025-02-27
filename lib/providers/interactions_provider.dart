import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:developer' as developer;

enum InteractionStatus { like, dislike, superlike }

final interactionsProvider =
    StateNotifierProvider<InteractionsNotifier, AsyncValue<void>>((ref) {
  return InteractionsNotifier();
});

class InteractionsNotifier extends StateNotifier<AsyncValue<void>> {
  InteractionsNotifier() : super(const AsyncValue.data(null));

  Future<bool> updateInteraction(
      String itemId, InteractionStatus? status) async {
    state = const AsyncValue.loading();
    try {
      final supabase = Supabase.instance.client;
      final userId = supabase.auth.currentUser?.id;

      developer.log(
        'Updating interaction',
        name: 'InteractionsNotifier',
        error: {
          'userId': userId,
          'itemId': itemId,
          'status': status?.name,
        },
      );

      if (userId == null) {
        developer.log(
          'No user ID found',
          name: 'InteractionsNotifier',
        );
        return false;
      }

      // Check if the item exists
      final itemExists = await supabase
          .from('items')
          .select('id')
          .eq('id', itemId)
          .maybeSingle();

      if (itemExists == null) {
        developer.log(
          'Item not found in table',
          name: 'InteractionsNotifier',
          error: {'itemId': itemId},
        );
        return false;
      }

      if (status == null) {
        // Delete the interaction
        final response = await supabase.from('interactions').delete().match({
          'user_id': userId,
          'item_id': itemId,
        });

        developer.log(
          'Deleted interaction',
          name: 'InteractionsNotifier',
          error: response,
        );
      } else {
        // Insert or update the interaction
        final response = await supabase.from('interactions').upsert({
          'user_id': userId,
          'item_id': itemId,
          'interaction_type': status.name,
          'updated_at': DateTime.now().toIso8601String(),
        });

        developer.log(
          'Upserted interaction',
          name: 'InteractionsNotifier',
          error: response,
        );
      }

      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      developer.log(
        'Error updating interaction',
        error: e,
        stackTrace: st,
        name: 'InteractionsNotifier',
      );
      state = AsyncValue.error(e, st);
      return false;
    }
  }
}
