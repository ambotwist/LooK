import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

enum InteractionStatus { like, dislike, tooExpensive, badCondition }

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
      print('Updating interaction - Item: $itemId, Status: ${status?.name}');
      final supabase = Supabase.instance.client;

      if (status == null) {
        // Delete the interaction instead of setting it to 'undecided'
        await supabase.from('interactions').delete().match({
          'user_id': supabase.auth.currentUser!.id,
          'item_id': itemId,
        });
      } else {
        await supabase.from('interactions').upsert({
          'user_id': supabase.auth.currentUser!.id,
          'item_id': itemId,
          'interaction_type': status.name,
          'updated_at': DateTime.now().toIso8601String(),
        }, onConflict: 'user_id,item_id');
      }
      print('Database update completed successfully');

      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      print('Error updating interaction: $e');
      print('Stack trace: $st');
      state = AsyncValue.error(e, st);
      return false;
    }
  }
}
