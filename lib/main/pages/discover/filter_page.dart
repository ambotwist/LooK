import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lookapp/enums/item_enums.dart';

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
  // Filter state
  Gender selectedGender = Gender.unisex; // Default to '-'
  Season selectedSeason = Season.any; // Default to 'Any'
  Size? selectedSize;
  List<HighLevelCategory> selectedHighCategories = [];
  List<SpecificCategory> selectedSpecificCategories = [];
  List<String> selectedColors = [];
  RangeValues priceRange = const RangeValues(0, 1000);
  List<String> selectedStyles = [];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
              setState(() {
                selectedGender = Gender.unisex; // Reset to default '-'
                selectedSeason = Season.any; // Reset to default 'Any'
                selectedSize = null;
                selectedHighCategories = [];
                selectedSpecificCategories = [];
                selectedColors = [];
                priceRange = const RangeValues(0, 1000);
                selectedStyles = [];
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
          // Gender Section
          _buildSection(
            title: 'Gender',
            child: Wrap(
              spacing: 8,
              children: Gender.values.map((gender) {
                return FilterChip(
                  label: Text(gender.displayName),
                  selected: selectedGender == gender,
                  onSelected: (selected) {
                    setState(() {
                      selectedGender = selected ? gender : Gender.unisex;
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
                  selected: selectedSeason == season,
                  onSelected: (selected) {
                    setState(() {
                      selectedSeason = selected ? season : Season.any;
                    });
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
                  selected: selectedSize == size,
                  onSelected: (selected) {
                    setState(() {
                      selectedSize = selected ? size : null;
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
                      selected: selectedHighCategories.contains(category),
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            selectedHighCategories.add(category);
                          } else {
                            selectedHighCategories.remove(category);
                            // Remove associated specific categories
                            selectedSpecificCategories.removeWhere((specific) =>
                                _getCategoryMapping(specific) == category);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
                if (selectedHighCategories.isNotEmpty) ...[
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
                        .where((category) => selectedHighCategories
                            .contains(_getCategoryMapping(category)))
                        .map((category) {
                      return FilterChip(
                        label: Text(category.displayName),
                        selected: selectedSpecificCategories.contains(category),
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              selectedSpecificCategories.add(category);
                            } else {
                              selectedSpecificCategories.remove(category);
                            }
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
                  selected: selectedColors.contains(color),
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        selectedColors.add(color);
                      } else {
                        selectedColors.remove(color);
                      }
                    });
                  },
                );
              }).toList(),
            ),
          ),

          // Price Range Section
          _buildSection(
            title:
                'Price Range (\$${priceRange.start.round()} - \$${priceRange.end.round()})',
            child: RangeSlider(
              values: priceRange,
              min: 0,
              max: 1000,
              divisions: 20,
              activeColor: theme.primaryColor,
              inactiveColor: theme.primaryColor.withOpacity(0.2),
              labels: RangeLabels(
                '\$${priceRange.start.round()}',
                '\$${priceRange.end.round()}',
              ),
              onChanged: (values) {
                setState(() {
                  priceRange = values;
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
                  selected: selectedStyles.contains(style),
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        selectedStyles.add(style);
                      } else {
                        selectedStyles.remove(style);
                      }
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
              // TODO: Apply filters
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
}
