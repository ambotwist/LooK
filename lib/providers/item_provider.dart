import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lookapp/models/items.dart';
import 'package:lookapp/main.dart';
import 'package:lookapp/providers/filter_provider.dart';
import 'package:lookapp/enums/item_enums.dart';

final itemsProvider = FutureProvider<List<Item>>((ref) async {
  try {
    final filterState = ref.watch(filterProvider);

    // First, get all interactions for the current user
    final userId = supabase.auth.currentUser!.id;
    final interactions = await supabase
        .from('interactions')
        .select('item_id')
        .eq('user_id', userId);

    final interactedItemIds = (interactions as List)
        .map((interaction) => interaction['item_id'] as String)
        .toSet();

    // Then get all items that haven't been interacted with
    final response = await supabase.from('items').select();
    if (response.isEmpty) return [];

    final items = (response as List)
        .map((item) => Item.fromJson(Map<String, dynamic>.from(item)))
        .where((item) =>
            !interactedItemIds.contains(item.id)) // Exclude interacted items
        .toList();

    // Apply filters
    return items.where((item) {
      // Gender filter
      if (filterState.gender != Gender.unisex &&
          item.gender != filterState.gender) {
        return false;
      }

      // Season filter
      if (filterState.season != Season.any &&
          item.season != Season.any &&
          item.season != filterState.season) {
        return false;
      }

      // Size filter
      if (filterState.size != null && item.size != filterState.size) {
        return false;
      }

      // High category filter
      if (filterState.highCategories.isNotEmpty &&
          !filterState.highCategories.contains(item.highCategory)) {
        return false;
      }

      // Specific category filter
      if (filterState.specificCategories.isNotEmpty &&
          !filterState.specificCategories.contains(item.specificCategory)) {
        return false;
      }

      // Color filter
      if (filterState.colors.isNotEmpty &&
          !filterState.colors.contains(item.color)) {
        return false;
      }

      // Price range filter
      if (item.price < filterState.priceRange.start ||
          item.price > filterState.priceRange.end) {
        return false;
      }

      // Styles filter
      if (filterState.styles.isNotEmpty &&
          !item.styles.any((style) => filterState.styles.contains(style))) {
        return false;
      }

      return true;
    }).toList();
  } catch (e) {
    throw 'Failed to fetch items: $e';
  }
});
