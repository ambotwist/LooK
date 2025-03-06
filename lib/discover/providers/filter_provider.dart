import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:lookapp/enums/item_enums.dart';

/// Represents the state of all filters in the app
class FilterState {
  final List<Season> seasons;
  final List<String> topSizes;
  final List<String> shoeSizes;
  final List<String> bottomSizes;
  final List<String> highCategories;
  final List<String> specificCategories;
  final List<String> colors;
  final RangeValues priceRange;
  final List<String> styles;

  const FilterState({
    this.seasons = const [],
    this.topSizes = const [],
    this.shoeSizes = const [],
    this.bottomSizes = const [],
    this.highCategories = const [],
    this.specificCategories = const [],
    this.colors = const [],
    this.priceRange = const RangeValues(0, 1000),
    this.styles = const [],
  });

  /// Creates a copy of this FilterState with the given fields replaced with new values
  FilterState copyWith({
    List<Season>? seasons,
    List<String>? topSizes,
    List<String>? shoeSizes,
    List<String>? bottomSizes,
    List<String>? highCategories,
    List<String>? specificCategories,
    List<String>? colors,
    RangeValues? priceRange,
    List<String>? styles,
  }) {
    return FilterState(
      seasons: seasons ?? this.seasons,
      topSizes: topSizes ?? this.topSizes,
      shoeSizes: shoeSizes ?? this.shoeSizes,
      bottomSizes: bottomSizes ?? this.bottomSizes,
      highCategories: highCategories ?? this.highCategories,
      specificCategories: specificCategories ?? this.specificCategories,
      colors: colors ?? this.colors,
      priceRange: priceRange ?? this.priceRange,
      styles: styles ?? this.styles,
    );
  }

  @override
  String toString() {
    return 'FilterState('
        'seasons: $seasons, '
        'topSizes: $topSizes, '
        'shoeSizes: $shoeSizes, '
        'bottomSizes: $bottomSizes, '
        'highCategories: $highCategories, '
        'specificCategories: $specificCategories, '
        'colors: $colors, '
        'priceRange: $priceRange, '
        'styles: $styles)';
  }
}

/// Manages the filter state and provides methods to update it
class FilterNotifier extends StateNotifier<FilterState> {
  FilterNotifier() : super(const FilterState());

  // Backup state for cancellation
  FilterState? _backupState;

  /// Toggles a high-level category and manages related state
  void toggleHighCategory(String category) {
    final currentCategories = List<String>.from(state.highCategories);

    if (currentCategories.contains(category)) {
      // Remove the category
      currentCategories.remove(category);

      // Clear sizes associated with this category
      state = state.copyWith(
        highCategories: currentCategories,
        topSizes: category == 'tops' ? [] : state.topSizes,
        shoeSizes: category == 'shoes' ? [] : state.shoeSizes,
        bottomSizes: category == 'bottoms' ? [] : state.bottomSizes,
        // Clear specific categories that belong to this high category
        specificCategories: state.specificCategories
            .where((spec) => !specificBelongsToHigh(spec, category))
            .toList(),
      );
    } else {
      // Add the category
      currentCategories.add(category);
      state = state.copyWith(highCategories: currentCategories);
    }
  }

  /// Toggles a specific category
  void toggleSpecificCategory(String category) {
    final currentCategories = List<String>.from(state.specificCategories);

    if (currentCategories.contains(category)) {
      currentCategories.remove(category);
    } else {
      currentCategories.add(category);
    }

    state = state.copyWith(specificCategories: currentCategories);
  }

  /// Helper to check if a specific category belongs to a high category
  bool specificBelongsToHigh(String specific, String high) {
    switch (high) {
      case 'tops':
        return [
          't-shirts',
          'shirts',
          'tank_tops',
          'sweaters',
          'hoodies',
          'blouses',
          'polo_shirts'
        ].contains(specific);
      case 'bottoms':
        return ['pants', 'jeans', 'shorts', 'skirts', 'leggings']
            .contains(specific);
      case 'shoes':
        return ['sneakers', 'boots', 'sandals', 'flats', 'heels', 'loafers']
            .contains(specific);
      case 'outerwear':
        return ['jackets', 'coats', 'blazers', 'vests'].contains(specific);
      case 'sportswear':
        return ['gym_tops', 'gym_bottoms', 'athletic_shoes'].contains(specific);
      case 'bags':
        return false; // No specific categories for bags
      case 'accessories':
        return [
          'scarves',
          'belts',
          'gloves',
          'sunglasses',
          'watches',
          'jewelry'
        ].contains(specific);
      case 'formal_wear':
        return ['suits', 'dresses', 'tuxedos'].contains(specific);
      default:
        return false;
    }
  }

  /// Updates multiple filter fields at once
  void updateFilters({
    List<Season>? seasons,
    List<String>? topSizes,
    List<String>? shoeSizes,
    List<String>? bottomSizes,
    List<String>? highCategories,
    List<String>? specificCategories,
    List<String>? colors,
    RangeValues? priceRange,
    List<String>? styles,
  }) {
    state = state.copyWith(
      seasons: seasons,
      topSizes: topSizes,
      shoeSizes: shoeSizes,
      bottomSizes: bottomSizes,
      highCategories: highCategories,
      specificCategories: specificCategories,
      colors: colors,
      priceRange: priceRange,
      styles: styles,
    );
  }

  /// Creates a backup of the current state
  void backupState() {
    _backupState = FilterState(
      seasons: List<Season>.from(state.seasons),
      topSizes: List<String>.from(state.topSizes),
      shoeSizes: List<String>.from(state.shoeSizes),
      bottomSizes: List<String>.from(state.bottomSizes),
      highCategories: List<String>.from(state.highCategories),
      specificCategories: List<String>.from(state.specificCategories),
      colors: List<String>.from(state.colors),
      priceRange: RangeValues(state.priceRange.start, state.priceRange.end),
      styles: List<String>.from(state.styles),
    );
  }

  /// Restores the state from backup
  void restoreState() {
    if (_backupState != null) {
      state = _backupState!;
      _backupState = null;
    }
  }

  /// Resets all filters to their default values
  void resetFilters() {
    state = const FilterState();
  }

  /// Toggles a top size with validation
  void toggleTopSize(String size) {
    if (!isValidTopSize(size)) return;

    final currentSizes = List<String>.from(state.topSizes);
    if (currentSizes.contains(size)) {
      currentSizes.remove(size);
    } else {
      currentSizes.add(size);
    }

    state = state.copyWith(topSizes: currentSizes);
  }

  /// Toggles a shoe size with validation
  void toggleShoeSize(String size) {
    if (!isValidShoeSize(size)) return;

    final currentSizes = List<String>.from(state.shoeSizes);
    if (currentSizes.contains(size)) {
      currentSizes.remove(size);
    } else {
      currentSizes.add(size);
    }

    state = state.copyWith(shoeSizes: currentSizes);
  }

  /// Toggles a bottom size with validation
  void toggleBottomSize(String size) {
    if (!isValidBottomSize(size)) return;

    final currentSizes = List<String>.from(state.bottomSizes);
    if (currentSizes.contains(size)) {
      currentSizes.remove(size);
    } else {
      currentSizes.add(size);
    }

    state = state.copyWith(bottomSizes: currentSizes);
  }

  /// Adds all possible length combinations for a given waist size
  void addWaistSizeCombinations(String waist) {
    final currentSizes = List<String>.from(state.bottomSizes);
    // Generate all possible length combinations for this waist (28-39)
    for (int length = 28; length <= 39; length++) {
      final size = 'W${waist}L$length';
      if (isValidBottomSize(size) && !currentSizes.contains(size)) {
        currentSizes.add(size);
      }
    }
    state = state.copyWith(bottomSizes: currentSizes);
  }

  /// Adds all possible waist combinations for a given length size
  void addLengthSizeCombinations(String length) {
    final currentSizes = List<String>.from(state.bottomSizes);
    // Generate all possible waist combinations for this length (28-40)
    for (int waist = 28; waist <= 40; waist++) {
      final size = 'W${waist}L$length';
      if (isValidBottomSize(size) && !currentSizes.contains(size)) {
        currentSizes.add(size);
      }
    }
    state = state.copyWith(bottomSizes: currentSizes);
  }

  /// Toggles a season
  void toggleSeason(Season season) {
    final currentSeasons = List<Season>.from(state.seasons);
    if (currentSeasons.contains(season)) {
      currentSeasons.remove(season);
    } else {
      currentSeasons.add(season);
    }
    state = state.copyWith(seasons: currentSeasons);
  }

  /// Toggles a color
  void toggleColor(String color) {
    if (!Categories.colors.contains(color)) return;

    final currentColors = List<String>.from(state.colors);
    if (currentColors.contains(color)) {
      currentColors.remove(color);
    } else {
      currentColors.add(color);
    }
    state = state.copyWith(colors: currentColors);
  }

  /// Toggles a style
  void toggleStyle(String style) {
    if (!Categories.styles.contains(style)) return;

    final currentStyles = List<String>.from(state.styles);
    if (currentStyles.contains(style)) {
      currentStyles.remove(style);
    } else {
      currentStyles.add(style);
    }
    state = state.copyWith(styles: currentStyles);
  }

  /// Updates the price range
  void updatePriceRange(RangeValues range) {
    state = state.copyWith(priceRange: range);
  }

  /// Checks if a specific size filter should be shown based on selected categories
  bool shouldShowSizeFilter(String type) {
    return switch (type) {
      'tops' => state.highCategories.contains('tops'),
      'shoes' => state.highCategories.contains('shoes'),
      'bottoms' => state.highCategories.contains('bottoms'),
      _ => false
    };
  }
}

/// The provider that exposes the FilterState to the rest of the app
final filterProvider =
    StateNotifierProvider<FilterNotifier, FilterState>((ref) {
  return FilterNotifier();
});
