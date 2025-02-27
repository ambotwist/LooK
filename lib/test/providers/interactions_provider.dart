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

  Future<bool> updateInteraction(String itemId, InteractionStatus? status,
      {String tableName = 'items'}) async {
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
          'tableName': tableName,
        },
      );

      if (userId == null) {
        developer.log(
          'No user ID found',
          name: 'InteractionsNotifier',
        );
        return false;
      }

      // First, check if the item exists in the specified table
      final itemExists = await supabase
          .from(tableName)
          .select('id')
          .eq('id', itemId)
          .maybeSingle();

      if (itemExists == null) {
        developer.log(
          'Item not found in table',
          name: 'InteractionsNotifier',
          error: {'itemId': itemId, 'tableName': tableName},
        );
        return false;
      }

      // Determine which interactions table to use
      final interactionsTable =
          tableName == 'hm_items' ? 'hm_interactions' : 'interactions';

      if (status == null) {
        // Delete the interaction
        final response = await supabase.from(interactionsTable).delete().match({
          'user_id': userId,
          'item_id': itemId,
        });

        developer.log(
          'Deleted interaction',
          name: 'InteractionsNotifier',
          error: response,
        );
      } else {
        // Insert or update the interaction in the appropriate table
        final response = await supabase.from(interactionsTable).upsert({
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
