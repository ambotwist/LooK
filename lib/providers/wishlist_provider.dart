import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:lookapp/discover/models/items.dart';

// Keep track of when to refresh the wishlist
final _wishlistRefreshProvider = StateProvider<int>((ref) => 0);

final wishlistProvider =
    StateNotifierProvider<WishlistNotifier, AsyncValue<Set<String>>>((ref) {
  return WishlistNotifier();
});

// Provider for fetching and caching wishlist items
final wishlistItemsProvider = FutureProvider<List<Item>>((ref) async {
  try {
    // Watch both the wishlist IDs and the refresh trigger
    final wishlistState = ref.watch(wishlistProvider);
    ref.watch(_wishlistRefreshProvider);

    final supabase = Supabase.instance.client;

    // Get the current wishlist IDs
    final wishlistIds = wishlistState.value ?? {};
    if (wishlistIds.isEmpty) return [];

    // Fetch all items that are in the wishlist
    final itemsResponse = await supabase
        .from('items')
        .select()
        .inFilter('id', wishlistIds.toList());

    return (itemsResponse as List)
        .map((item) => Item.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  } catch (e) {
    throw 'Failed to fetch wishlist items: $e';
  }
});

// Method to force refresh the wishlist items
void refreshWishlistItems(WidgetRef ref) {
  ref.read(_wishlistRefreshProvider.notifier).state++;
}

class WishlistNotifier extends StateNotifier<AsyncValue<Set<String>>> {
  WishlistNotifier() : super(const AsyncValue.data({})) {
    // Load wishlist when initialized
    loadWishlist();
  }

  final supabase = Supabase.instance.client;

  Future<void> loadWishlist() async {
    try {
      state = const AsyncValue.loading();
      final userId = supabase.auth.currentUser!.id;

      final response = await supabase
          .from('wishlist')
          .select('item_id')
          .eq('user_id', userId);

      final itemIds =
          (response as List).map((item) => item['item_id'] as String).toSet();

      state = AsyncValue.data(itemIds);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<bool> toggleWishlist(String itemId) async {
    try {
      final userId = supabase.auth.currentUser!.id;
      final currentState = state.value ?? {};
      final isInWishlist = currentState.contains(itemId);

      if (isInWishlist) {
        // Remove from wishlist
        await supabase
            .from('wishlist')
            .delete()
            .eq('user_id', userId)
            .eq('item_id', itemId);

        state = AsyncValue.data(currentState..remove(itemId));
        return true; // Operation was successful
      } else {
        // Add to wishlist
        await supabase.from('wishlist').insert({
          'user_id': userId,
          'item_id': itemId,
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        });

        state = AsyncValue.data(currentState..add(itemId));
        return true; // Operation was successful
      }
    } catch (e) {
      return false; // Operation failed
    }
  }
}
