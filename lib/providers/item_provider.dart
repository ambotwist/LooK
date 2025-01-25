import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lookapp/models/items.dart';
import 'package:lookapp/main.dart';
import 'package:lookapp/providers/filter_provider.dart';
import 'package:lookapp/providers/user_preferences_provider.dart';
import 'package:lookapp/enums/item_enums.dart';

final itemsProvider = FutureProvider<List<Item>>((ref) async {
  try {
    final filterState = ref.watch(filterProvider);
    final userPrefs = ref.watch(userPreferencesProvider);

    // First, get all interactions for the current user
    final userId = supabase.auth.currentUser!.id;
    final interactions = await supabase
        .from('interactions')
        .select('item_id')
        .eq('user_id', userId);

    final interactedItemIds = (interactions as List)
        .map((interaction) => interaction['item_id'] as String)
        .toSet();

    // Build the query
    var query = supabase.from('items').select();

    // Apply filters using Supabase query builder
    if (userPrefs.gender != Gender.unisex) {
      query =
          query.inFilter('gender', [userPrefs.gender.name, Gender.unisex.name]);
    }

    if (filterState.season != Season.any) {
      query = query.eq('season', filterState.season.name);
    }

    if (filterState.sizes.isNotEmpty) {
      query =
          query.inFilter('size', filterState.sizes.map((s) => s.name).toList());
    }

    if (filterState.highCategories.isNotEmpty) {
      query = query.inFilter('high_category',
          filterState.highCategories.map((c) => c.name).toList());
    }

    if (filterState.specificCategories.isNotEmpty) {
      query = query.inFilter('specific_category',
          filterState.specificCategories.map((c) => c.name).toList());
    }

    if (filterState.colors.isNotEmpty) {
      query = query.inFilter('color', filterState.colors);
    }

    // Price range filter
    query = query
        .gte('price', filterState.priceRange.start)
        .lte('price', filterState.priceRange.end);

    // Style filter using containedBy for array comparison
    if (filterState.styles.isNotEmpty) {
      query = query.overlaps('styles', filterState.styles);
    }

    final response = await query;
    if (response.isEmpty) return [];

    // Filter out interacted items client-side since it's user-specific
    return (response as List)
        .map((item) => Item.fromJson(Map<String, dynamic>.from(item)))
        .where((item) => !interactedItemIds.contains(item.id))
        .toList();
  } catch (e) {
    throw 'Failed to fetch items: $e';
  }
});
