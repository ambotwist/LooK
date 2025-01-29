import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lookapp/models/items.dart';
import 'package:lookapp/main.dart';
import 'package:lookapp/providers/filter_provider.dart';
import 'package:lookapp/providers/user_preferences_provider.dart';
import 'package:lookapp/enums/item_enums.dart';
import 'package:lookapp/providers/provider_refresh.dart';

final itemsProvider = FutureProvider<List<Item>>((ref) async {
  // Watch the refresh provider to trigger updates
  ref.watch(refreshProvider);

  try {
    // Watch the filter and user preferences providers
    final filterState = ref.watch(filterProvider);
    final userPrefs = ref.watch(userPreferencesProvider);

    // Get the current user id with null check
    final userId =
        supabase.auth.currentUser?.id ?? (throw Exception('Not authenticated'));

    // Get all interactions for the current user
    final interactions = await supabase
        .from('interactions')
        .select('item_id')
        .eq('user_id', userId);
    final interactedItemIds = (interactions as List)
        .map((interaction) => interaction['item_id'] as String)
        .toSet();

    // Build the query
    var query = supabase.from('items').select();

    // Exclude interacted items
    if (interactedItemIds.isNotEmpty) {
      query = query.filter('id', 'not.in', interactedItemIds);
    }

    // Apply sex filter
    if (userPrefs.sex != Sex.unisex) {
      query = query.inFilter(
          'sex', [userPrefs.sex.databaseValue, Sex.unisex.databaseValue]);
    }

    // Apply season filter
    if (filterState.seasons.isNotEmpty) {
      query = query.inFilter('seasons',
          filterState.seasons.map((season) => season.databaseValue).toList());
    }

    // First apply high-level category filter
    if (filterState.highCategories.isNotEmpty) {
      query = query.inFilter('high_category', filterState.highCategories);
    }

    // Build OR logic for sizing
    final List<String> orClauses = [];

    if (filterState.highCategories.contains('tops') &&
        filterState.topSizes.isNotEmpty) {
      final sizesForTops = filterState.topSizes.join(",");
      orClauses.add("and(high_category.eq.tops,top_size.in.($sizesForTops))");
    }

    if (filterState.highCategories.contains('bottoms') &&
        filterState.bottomSizes.isNotEmpty) {
      final sizesForBottoms = filterState.bottomSizes.join(",");
      orClauses.add(
          "and(high_category.eq.bottoms,bottom_size.in.($sizesForBottoms))");
    }

    if (filterState.highCategories.contains('shoes') &&
        filterState.shoeSizes.isNotEmpty) {
      final sizesForShoes = filterState.shoeSizes.join(",");
      orClauses
          .add("and(high_category.eq.shoes,shoe_size.in.($sizesForShoes))");
    }

    // Use OR logic if we have any sizing filters
    if (orClauses.isNotEmpty) {
      // Join the groups with commas so Supabase sees them as OR conditions
      final orFilterString = orClauses.join(",");
      query = query.or(orFilterString);
    }

    // Apply specific category filter
    if (filterState.specificCategories.isNotEmpty) {
      query =
          query.inFilter('specific_category', filterState.specificCategories);
    }

    // Apply color filter
    if (filterState.colors.isNotEmpty) {
      query = query.inFilter('color', filterState.colors);
    }

    // Price range filter
    query = query
        .gte('price', filterState.priceRange.start)
        .lte('price', filterState.priceRange.end);

    // Style filter using 'overlaps' for array comparison
    if (filterState.styles.isNotEmpty) {
      query = query.overlaps('styles', filterState.styles);
    }

    print('Debug - about to execute items query with filters:');
    print('High Categories: ${filterState.highCategories}');
    print('Top Sizes: ${filterState.topSizes}');
    print('Bottom Sizes: ${filterState.bottomSizes}');
    print('Shoe Sizes: ${filterState.shoeSizes}');
    print('OR filter string: $orClauses');

    final response = await query;

    // Debug prints
    print('Raw Supabase response: $response');

    if (response.isEmpty) return [];

    final filteredItems = (response as List)
        .map((item) => Item.fromJson(Map<String, dynamic>.from(item)))
        .toList();

    print('Filtered items: $filteredItems');

    return filteredItems;
  } catch (e) {
    print('Error fetching items: $e');
    throw 'Failed to fetch items: $e';
  }
});
