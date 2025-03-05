import 'package:flutter/foundation.dart';
import 'package:lookapp/features/discover/data/providers/hm_interactions_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Repository for handling all interactions with items (like, dislike, superlike)
class ItemInteractionRepository {
  final SupabaseClient _supabase;

  ItemInteractionRepository({
    SupabaseClient? supabase,
  }) : _supabase = supabase ?? Supabase.instance.client;

  /// Update an interaction for a specific item with a specific status
  /// Returns true if successful, false otherwise
  Future<bool> updateInteraction(
      String itemId, HMInteractionStatus? status) async {
    try {
      final userId = _supabase.auth.currentUser?.id;

      debugPrint(
        'Updating HM interaction - userId: $userId, itemId: $itemId, status: ${status?.name}',
      );

      if (userId == null) {
        debugPrint('No user ID found');
        return false;
      }

      // Check if the HM item exists
      final itemExists = await _supabase
          .from('hm_items')
          .select('id')
          .eq('id', itemId)
          .maybeSingle();

      if (itemExists == null) {
        debugPrint('HM Item not found - itemId: $itemId');
        return false;
      }

      if (status == null) {
        // Delete the interaction
        await _supabase.from('hm_interactions').delete().match({
          'user_id': userId,
          'item_id': itemId,
        });

        debugPrint('Deleted HM interaction for item: $itemId');
      } else {
        // Insert or update the interaction
        await _supabase.from('hm_interactions').upsert({
          'user_id': userId,
          'item_id': itemId,
          'interaction_type': status.name,
          'updated_at': DateTime.now().toIso8601String(),
        });

        debugPrint(
            'Updated HM interaction for item: $itemId with status: ${status.name}');
      }

      return true;
    } catch (e, st) {
      debugPrint('Error updating HM interaction: $e');
      debugPrint('Stack trace: $st');
      return false;
    }
  }

  /// Get all interactions for the current user
  Future<List<String>> getUserInteractedItemIds() async {
    try {
      final userId = _supabase.auth.currentUser?.id;

      if (userId == null) {
        debugPrint('No user ID found when fetching interactions');
        return [];
      }

      final interactions = await _supabase
          .from('hm_interactions')
          .select('item_id')
          .eq('user_id', userId)
          .not('interaction_type', 'is', null);

      return (interactions as List)
          .map((interaction) => interaction['item_id'] as String)
          .toList();
    } catch (e) {
      debugPrint('Error fetching user interactions: $e');
      return [];
    }
  }

  /// Get all items liked by the current user
  Future<List<String>> getLikedItemIds() async {
    try {
      final userId = _supabase.auth.currentUser?.id;

      if (userId == null) {
        debugPrint('No user ID found when fetching liked items');
        return [];
      }

      final interactions = await _supabase
          .from('hm_interactions')
          .select('item_id')
          .eq('user_id', userId)
          .eq('interaction_type', HMInteractionStatus.like.name);

      return (interactions as List)
          .map((interaction) => interaction['item_id'] as String)
          .toList();
    } catch (e) {
      debugPrint('Error fetching liked items: $e');
      return [];
    }
  }
}
