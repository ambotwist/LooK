import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lookapp/enums/item_enums.dart';
import 'package:lookapp/providers/filter_provider.dart';

/// Configuration class to control which filter sections are visible
class FilterConfiguration {
  final bool showSizes;
  final bool showCategories;
  final bool showColors;
  final bool showPriceRange;
  final bool showStyles;
  final bool showSeason;

  const FilterConfiguration({
    this.showSizes = true,
    this.showCategories = true,
    this.showColors = true,
    this.showPriceRange = true,
    this.showStyles = true,
    this.showSeason = true,
  });
}

class FilterPage extends ConsumerStatefulWidget {
  final void Function(FilterState)? onApplyFilters;
  final VoidCallback? onCancel;

  const FilterPage({
    super.key,
    this.onApplyFilters,
    this.onCancel,
  });

  @override
  ConsumerState<FilterPage> createState() => _FilterPageState();
}

class _FilterPageState extends ConsumerState<FilterPage> {
  @override
  void initState() {
    super.initState();
    // Backup the current state when opening the filter page
    ref.read(filterProvider.notifier).backupState();
  }

  @override
  Widget build(BuildContext context) {
    final filterState = ref.watch(filterProvider);
    final notifier = ref.read(filterProvider.notifier);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        title: const Text('Filters'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            notifier.restoreState();
            widget.onCancel?.call();
            Navigator.pop(context);
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              notifier.resetFilters();
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
          // Styles
          _buildSection(
            title: 'Styles',
            child: Wrap(
              spacing: 8,
              runSpacing: 0,
              children: Categories.styles.map((style) {
                return FilterChip(
                  label: Text(categoryToDisplayName(style)),
                  selected: filterState.styles.contains(style),
                  onSelected: (selected) {
                    notifier.toggleStyle(style);
                  },
                );
              }).toList(),
            ),
          ),
          // High Level Categories
          _buildSection(
            title: 'Categories',
            child: Wrap(
              spacing: 8,
              runSpacing: 0,
              children: Categories.highLevel.map((category) {
                return FilterChip(
                  label: Text(categoryToDisplayName(category)),
                  selected: filterState.highCategories.contains(category),
                  onSelected: (selected) {
                    notifier.toggleHighCategory(category);
                  },
                );
              }).toList(),
            ),
          ),

          // Specific Categories (only show if high category is selected)
          if (filterState.highCategories.isNotEmpty)
            _buildSection(
              title: 'Specific Categories',
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: Categories.specific
                    .where((specific) => filterState.highCategories.any(
                        (high) =>
                            notifier.specificBelongsToHigh(specific, high)))
                    .map((category) {
                  return FilterChip(
                    label: Text(categoryToDisplayName(category)),
                    selected: filterState.specificCategories.contains(category),
                    onSelected: (selected) {
                      notifier.toggleSpecificCategory(category);
                    },
                  );
                }).toList(),
              ),
            ),

          // Top Sizes
          if (notifier.shouldShowSizeFilter('tops'))
            _buildSection(
              title: 'Top Sizes',
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: ['xs', 's', 'm', 'l', 'xl', 'xxl'].map((size) {
                  return FilterChip(
                    label: Text(size.toUpperCase()),
                    selected: filterState.topSizes.contains(size),
                    onSelected: (selected) {
                      notifier.toggleTopSize(size);
                    },
                  );
                }).toList(),
              ),
            ), 

          // Shoe Sizes
          if (notifier.shouldShowSizeFilter('shoes'))
            _buildSection(
              title: 'Shoe Sizes',
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children:
                    List.generate(20, (i) => (30 + i).toString()).map((size) {
                  return FilterChip(
                    label: Text(size),
                    selected: filterState.shoeSizes.contains(size),
                    onSelected: (selected) {
                      notifier.toggleShoeSize(size);
                    },
                  );
                }).toList(),
              ),
            ),

          // Bottom Sizes
          if (notifier.shouldShowSizeFilter('bottoms'))
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSection(
                  title: 'Waist Size',
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: List.generate(13, (i) => (28 + i).toString())
                        .map((waist) {
                      final hasWaist = filterState.bottomSizes
                          .any((size) => size.startsWith('W$waist'));
                      return FilterChip(
                        label: Text('W$waist'),
                        selected: hasWaist,
                        onSelected: (selected) {
                          if (selected) {
                            notifier.addWaistSizeCombinations(waist);
                          } else {
                            // Remove all sizes with this waist
                            filterState.bottomSizes
                                .where((size) => size.startsWith('W$waist'))
                                .forEach(
                                    (size) => notifier.toggleBottomSize(size));
                          }
                        },
                      );
                    }).toList(),
                  ),
                ),
                _buildSection(
                  title: 'Length',
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: List.generate(12, (i) => (28 + i).toString())
                        .map((length) {
                      final hasLength = filterState.bottomSizes
                          .any((size) => size.endsWith('L$length'));
                      return FilterChip(
                        label: Text('L$length'),
                        selected: hasLength,
                        onSelected: (selected) {
                          if (selected) {
                            notifier.addLengthSizeCombinations(length);
                          } else {
                            // Remove all sizes with this length
                            filterState.bottomSizes
                                .where((size) => size.endsWith('L$length'))
                                .forEach(
                                    (size) => notifier.toggleBottomSize(size));
                          }
                        },
                      );
                    }).toList(),
                  ),
                ),
              ],
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
              widget.onApplyFilters?.call(filterState);
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
}
