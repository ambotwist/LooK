import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lookapp/models/items.dart';
import 'package:lookapp/main.dart';
import 'package:lookapp/providers/filter_provider.dart';
import 'package:lookapp/enums/item_enums.dart';

final itemsProvider = FutureProvider<List<Item>>((ref) async {
  try {
    final filterState = ref.watch(filterProvider);
    final response = await supabase.from('items').select();
    if (response.isEmpty) return [];

    final items = (response as List).map((item) {
      return Item.fromJson(Map<String, dynamic>.from(item));
    }).toList();

    // Apply filters
    return items.where((item) {
      // Gender filter
      if (filterState.gender != Gender.unisex &&
          item.gender != filterState.gender) {
        return false;
      }

      // Season filter
      if (filterState.season != Season.any &&
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
