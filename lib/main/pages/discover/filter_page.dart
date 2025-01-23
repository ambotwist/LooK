import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lookapp/enums/item_enums.dart';
import 'package:lookapp/providers/filter_provider.dart';
import 'package:lookapp/providers/discover_provider.dart';
import 'package:lookapp/providers/item_provider.dart';
import 'package:lookapp/providers/overlay_provider.dart';
import 'package:lookapp/main/wrappers/home_wrapper.dart';

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}

class FilterPage extends ConsumerStatefulWidget {
  const FilterPage({super.key});

  @override
  ConsumerState<FilterPage> createState() => _FilterPageState();
}

class _FilterPageState extends ConsumerState<FilterPage> {
  late FilterState localFilterState;

  @override
  void initState() {
    super.initState();
    // Initialize local state from provider
    localFilterState = ref.read(filterProvider);
    // Backup the provider state
    ref.read(filterProvider.notifier).backupState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final filterNotifier = ref.read(filterProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Filters'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            filterNotifier.restoreState();
            Navigator.pop(context);
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                localFilterState = FilterState();
              });
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
          // Size Section
          _buildSection(
            title: 'Size',
            child: Wrap(
              spacing: 8,
              children: Size.values.map((size) {
                return FilterChip(
                  label: Text(size.displayName),
                  selected: localFilterState.sizes.contains(size),
                  onSelected: (selected) {
                    setState(() {
                      final updatedSizes =
                          List<Size>.from(localFilterState.sizes);
                      if (selected) {
                        updatedSizes.add(size);
                      } else {
                        updatedSizes.remove(size);
                      }
                      localFilterState =
                          localFilterState.copyWith(sizes: updatedSizes);
                    });
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
                      selected:
                          localFilterState.highCategories.contains(category),
                      onSelected: (selected) {
                        setState(() {
                          final updatedCategories =
                              List<HighLevelCategory>.from(
                                  localFilterState.highCategories);
                          if (selected) {
                            updatedCategories.add(category);
                          } else {
                            updatedCategories.remove(category);
                            // Remove associated specific categories
                            final updatedSpecific = localFilterState
                                .specificCategories
                                .where((specific) =>
                                    _getCategoryMapping(specific) != category)
                                .toList();
                            localFilterState = localFilterState.copyWith(
                              specificCategories: updatedSpecific,
                            );
                          }
                          localFilterState = localFilterState.copyWith(
                            highCategories: updatedCategories,
                          );
                        });
                      },
                    );
                  }).toList(),
                ),
                if (localFilterState.highCategories.isNotEmpty) ...[
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
                        .where((category) => localFilterState.highCategories
                            .contains(_getCategoryMapping(category)))
                        .map((category) {
                      return FilterChip(
                        label: Text(category.displayName),
                        selected: localFilterState.specificCategories
                            .contains(category),
                        onSelected: (selected) {
                          setState(() {
                            final updatedCategories =
                                List<SpecificCategory>.from(
                                    localFilterState.specificCategories);
                            if (selected) {
                              updatedCategories.add(category);
                            } else {
                              updatedCategories.remove(category);
                            }
                            localFilterState = localFilterState.copyWith(
                              specificCategories: updatedCategories,
                            );
                          });
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
                  selected: localFilterState.colors.contains(color),
                  onSelected: (selected) {
                    setState(() {
                      final updatedColors =
                          List<String>.from(localFilterState.colors);
                      if (selected) {
                        updatedColors.add(color);
                      } else {
                        updatedColors.remove(color);
                      }
                      localFilterState =
                          localFilterState.copyWith(colors: updatedColors);
                    });
                  },
                );
              }).toList(),
            ),
          ),

          // Price Range Section
          _buildSection(
            title:
                'Price Range (\$${localFilterState.priceRange.start.round()} - \$${localFilterState.priceRange.end.round()})',
            child: RangeSlider(
              values: localFilterState.priceRange,
              min: 0,
              max: 1000,
              divisions: 20,
              activeColor: theme.primaryColor,
              inactiveColor: theme.primaryColor.withOpacity(0.2),
              labels: RangeLabels(
                '\$${localFilterState.priceRange.start.round()}',
                '\$${localFilterState.priceRange.end.round()}',
              ),
              onChanged: (values) {
                setState(() {
                  localFilterState =
                      localFilterState.copyWith(priceRange: values);
                });
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
                  selected: localFilterState.styles.contains(style),
                  onSelected: (selected) {
                    setState(() {
                      final updatedStyles =
                          List<String>.from(localFilterState.styles);
                      if (selected) {
                        updatedStyles.add(style);
                      } else {
                        updatedStyles.remove(style);
                      }
                      localFilterState =
                          localFilterState.copyWith(styles: updatedStyles);
                    });
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
                  selected: localFilterState.season == season,
                  onSelected: (selected) {
                    setState(() {
                      localFilterState = localFilterState.copyWith(
                        season: selected ? season : Season.any,
                      );
                    });
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
              // Apply local state to provider
              filterNotifier.updateFilters(
                season: localFilterState.season,
                sizes: localFilterState.sizes,
                highCategories: localFilterState.highCategories,
                specificCategories: localFilterState.specificCategories,
                colors: localFilterState.colors,
                priceRange: localFilterState.priceRange,
                styles: localFilterState.styles,
              );
              // Refresh items and reset discover index
              ref.invalidate(itemsProvider);
              ref.read(discoverProvider.notifier).updateState(
                currentIndex: 0,
                currentImageIndex: 0,
                previousIndices: [],
              );
              // Show the action bar overlay
              ref.read(overlayProvider).show();
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
