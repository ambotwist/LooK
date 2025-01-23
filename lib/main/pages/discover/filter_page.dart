import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lookapp/enums/item_enums.dart';
import 'package:lookapp/providers/filter_provider.dart';
import 'package:lookapp/providers/discover_provider.dart';
import 'package:lookapp/providers/item_provider.dart';

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}

class FilterPage extends ConsumerWidget {
  const FilterPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final filterNotifier = ref.read(filterProvider.notifier);
    final filterState = ref.watch(filterProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Filters'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: () {
              filterNotifier.resetFilters();
            },
            style: TextButton.styleFrom(
              foregroundColor: theme.primaryColor,
            ),
            child: const Text('Reset'),
          ),
        ],
      ),
      body: ListView(
        children: [
          // Gender Section
          _buildSection(
            title: 'Gender',
            child: Wrap(
              spacing: 8,
              children: Gender.values.map((gender) {
                return FilterChip(
                  label: Text(gender.displayName),
                  selected: filterState.gender == gender,
                  onSelected: (selected) {
                    filterNotifier.updateFilters(
                      gender: selected ? gender : Gender.unisex,
                    );
                  },
                );
              }).toList(),
            ),
          ),

          // Season Section
          _buildSection(
            title: 'Season',
            child: Wrap(
              spacing: 8,
              children: Season.values.map((season) {
                return FilterChip(
                  label: Text(season.name.capitalize()),
                  selected: filterState.season == season,
                  onSelected: (selected) {
                    filterNotifier.updateFilters(
                      season: selected ? season : Season.any,
                    );
                  },
                );
              }).toList(),
            ),
          ),

          // Size Section
          _buildSection(
            title: 'Size',
            child: Wrap(
              spacing: 8,
              children: Size.values.map((size) {
                return FilterChip(
                  label: Text(size.displayName),
                  selected: filterState.size == size,
                  onSelected: (selected) {
                    filterNotifier.updateFilters(
                      size: selected ? size : null,
                    );
                  },
                );
              }).toList(),
            ),
          ),

          // Category Section
          _buildSection(
            title: 'Category',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'High Level Categories',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 8),
                // High Category
                Wrap(
                  spacing: 8,
                  children: HighLevelCategory.values.map((category) {
                    return FilterChip(
                      label: Text(category.displayName),
                      selected: filterState.highCategories.contains(category),
                      onSelected: (selected) {
                        final updatedCategories = List<HighLevelCategory>.from(
                            filterState.highCategories);
                        if (selected) {
                          updatedCategories.add(category);
                        } else {
                          updatedCategories.remove(category);
                          // Remove associated specific categories
                          final updatedSpecific = filterState.specificCategories
                              .where((specific) =>
                                  _getCategoryMapping(specific) != category)
                              .toList();
                          filterNotifier.updateFilters(
                            specificCategories: updatedSpecific,
                          );
                        }
                        filterNotifier.updateFilters(
                          highCategories: updatedCategories,
                        );
                      },
                    );
                  }).toList(),
                ),
                if (filterState.highCategories.isNotEmpty) ...[
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Divider(),
                  ),
                  const Text(
                    'Specific Categories',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Specific Category
                  Wrap(
                    spacing: 8,
                    children: SpecificCategory.values
                        .where((category) => filterState.highCategories
                            .contains(_getCategoryMapping(category)))
                        .map((category) {
                      return FilterChip(
                        label: Text(category.displayName),
                        selected:
                            filterState.specificCategories.contains(category),
                        onSelected: (selected) {
                          final updatedCategories = List<SpecificCategory>.from(
                              filterState.specificCategories);
                          if (selected) {
                            updatedCategories.add(category);
                          } else {
                            updatedCategories.remove(category);
                          }
                          filterNotifier.updateFilters(
                            specificCategories: updatedCategories,
                          );
                        },
                      );
                    }).toList(),
                  ),
                ],
              ],
            ),
          ),

          // Colors Section
          _buildSection(
            title: 'Colors',
            child: Wrap(
              spacing: 8,
              children: [
                'Black',
                'White',
                'Red',
                'Blue',
                'Green',
                'Yellow',
                'Purple',
                'Pink',
                'Orange',
                'Brown',
                'Grey',
                'Multi'
              ].map((color) {
                return FilterChip(
                  label: Text(color),
                  selected: filterState.colors.contains(color),
                  onSelected: (selected) {
                    final updatedColors = List<String>.from(filterState.colors);
                    if (selected) {
                      updatedColors.add(color);
                    } else {
                      updatedColors.remove(color);
                    }
                    filterNotifier.updateFilters(colors: updatedColors);
                  },
                );
              }).toList(),
            ),
          ),

          // Price Range Section
          _buildSection(
            title:
                'Price Range (\$${filterState.priceRange.start.round()} - \$${filterState.priceRange.end.round()})',
            child: RangeSlider(
              values: filterState.priceRange,
              min: 0,
              max: 1000,
              divisions: 20,
              activeColor: theme.primaryColor,
              inactiveColor: theme.primaryColor.withOpacity(0.2),
              labels: RangeLabels(
                '\$${filterState.priceRange.start.round()}',
                '\$${filterState.priceRange.end.round()}',
              ),
              onChanged: (values) {
                filterNotifier.updateFilters(priceRange: values);
              },
            ),
          ),

          // Styles Section
          _buildSection(
            title: 'Styles',
            child: Wrap(
              spacing: 8,
              children: [
                'Casual',
                'Formal',
                'Sporty',
                'Vintage',
                'Streetwear',
                'Bohemian',
                'Minimalist',
                'Preppy',
                'Punk',
                'Business',
                'Party',
                'Beach'
              ].map((style) {
                return FilterChip(
                  label: Text(style),
                  selected: filterState.styles.contains(style),
                  onSelected: (selected) {
                    final updatedStyles = List<String>.from(filterState.styles);
                    if (selected) {
                      updatedStyles.add(style);
                    } else {
                      updatedStyles.remove(style);
                    }
                    filterNotifier.updateFilters(styles: updatedStyles);
                  },
                );
              }).toList(),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            onPressed: () {
              // Refresh items and reset discover state
              ref.invalidate(itemsProvider);
              ref.read(discoverProvider.notifier).resetState();
              Navigator.pop(context);
            },
            child: const Text(
              'Apply Filters',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required Widget child}) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  HighLevelCategory _getCategoryMapping(SpecificCategory category) {
    switch (category) {
      case SpecificCategory.tShirts:
      case SpecificCategory.shirts:
      case SpecificCategory.tankTops:
      case SpecificCategory.sweaters:
      case SpecificCategory.hoodies:
      case SpecificCategory.blouses:
      case SpecificCategory.poloShirts:
        return HighLevelCategory.tops;
      case SpecificCategory.pants:
      case SpecificCategory.jeans:
      case SpecificCategory.shorts:
      case SpecificCategory.skirts:
      case SpecificCategory.leggings:
        return HighLevelCategory.bottoms;
      case SpecificCategory.sneakers:
      case SpecificCategory.boots:
      case SpecificCategory.sandals:
      case SpecificCategory.flats:
      case SpecificCategory.heels:
      case SpecificCategory.loafers:
        return HighLevelCategory.shoes;
      case SpecificCategory.jackets:
      case SpecificCategory.coats:
      case SpecificCategory.blazers:
      case SpecificCategory.vests:
        return HighLevelCategory.outerwear;
      case SpecificCategory.scarves:
      case SpecificCategory.belts:
      case SpecificCategory.gloves:
      case SpecificCategory.ties:
      case SpecificCategory.sunglasses:
      case SpecificCategory.watches:
      case SpecificCategory.jewelry:
        return HighLevelCategory.accessories;
      case SpecificCategory.gymTops:
      case SpecificCategory.gymBottoms:
      case SpecificCategory.sportsBras:
      case SpecificCategory.athleticShoes:
        return HighLevelCategory.activewear;
      case SpecificCategory.underwear:
      case SpecificCategory.bras:
      case SpecificCategory.pajamas:
      case SpecificCategory.lingerie:
      case SpecificCategory.socks:
        return HighLevelCategory.underwearAndSleepwear;
      case SpecificCategory.swimTrunks:
      case SpecificCategory.bikinis:
      case SpecificCategory.onePieceSwimsuits:
      case SpecificCategory.rashGuards:
        return HighLevelCategory.swimwear;
      case SpecificCategory.suits:
      case SpecificCategory.dresses:
      case SpecificCategory.tuxedos:
        return HighLevelCategory.formalWear;
    }
  }
}
