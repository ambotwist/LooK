import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ionicons/ionicons.dart';
import 'package:lookapp/enums/item_enums.dart';
import 'package:lookapp/main/pages/fliter/filter_page.dart';
import 'package:lookapp/discover/shared/providers/discover_provider.dart';
import 'package:lookapp/discover/shared/providers/filter_provider.dart';
import 'package:lookapp/discover/shared/providers/item_provider.dart';
import 'package:lookapp/discover/shared/providers/overlay_provider.dart';
import 'package:lookapp/widgets/layout/filter_dropdown.dart';

class FilterRow extends ConsumerWidget {
  const FilterRow({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      height: 48,
      color: Theme.of(context).appBarTheme.backgroundColor,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Ionicons.filter_outline),
            color: Theme.of(context).colorScheme.onPrimary,
            onPressed: () => _openFilterPage(context, ref),
          ),
          // Brand Filter Dropdown
          _buildBrandFilter(ref),
          const SizedBox(width: 8),
          // Category Filter Dropdown
          _buildCategoryFilter(ref),
          const SizedBox(width: 8),
          // Style Filter Dropdown
          _buildStyleFilter(ref),
          const Spacer(),
          const SizedBox(width: 8),
        ],
      ),
    );
  }

  void _openFilterPage(BuildContext context, WidgetRef ref) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FilterPage(
          onApplyFilters: (newFilters) {
            ref.read(filterProvider.notifier).updateFilters(
                  seasons: newFilters.seasons,
                  topSizes: newFilters.topSizes,
                  shoeSizes: newFilters.shoeSizes,
                  bottomSizes: newFilters.bottomSizes,
                  highCategories: newFilters.highCategories,
                  specificCategories: newFilters.specificCategories,
                  colors: newFilters.colors,
                  priceRange: newFilters.priceRange,
                  styles: newFilters.styles,
                );
            _resetDiscoverState(ref);
          },
        ),
      ),
    );
  }

  void _resetDiscoverState(WidgetRef ref) {
    ref.invalidate(itemsProvider);
    ref.read(discoverProvider.notifier).updateState(
      currentIndex: 0,
      currentImageIndex: 0,
      previousIndices: [],
    );
    ref.read(overlayProvider).show();
  }

  Widget _buildBrandFilter(WidgetRef ref) {
    return FilterDropdown(
      label: 'Brand',
      selectedValues: ref
          .watch(filterProvider)
          .highCategories
          .where((cat) => ['nike', 'adidas'].contains(cat))
          .toSet(),
      items: const [
        PopupMenuItem(
          value: 'nike',
          child: Text('Nike'),
        ),
        PopupMenuItem(
          value: 'adidas',
          child: Text('Adidas'),
        ),
      ],
      onSelected: (value) {
        if (value.isEmpty) {
          // Reset brand filters
          ref.read(filterProvider.notifier).updateFilters(
                highCategories: ref
                    .read(filterProvider)
                    .highCategories
                    .where((cat) => !['nike', 'adidas'].contains(cat))
                    .toList(),
              );
        } else {
          ref.read(filterProvider.notifier).toggleHighCategory(value);
        }
        _resetDiscoverState(ref);
      },
    );
  }

  Widget _buildCategoryFilter(WidgetRef ref) {
    return FilterDropdown(
      label: 'Category',
      selectedValues: ref
          .watch(filterProvider)
          .highCategories
          .where((cat) => !['nike', 'adidas'].contains(cat))
          .toSet(),
      items: Categories.highLevel
          .where((cat) => !['nike', 'adidas'].contains(cat))
          .map((category) => PopupMenuItem(
                value: category,
                child: Text(categoryToDisplayName(category)),
              ))
          .toList(),
      onSelected: (value) {
        if (value.isEmpty) {
          // Reset category filters
          ref.read(filterProvider.notifier).updateFilters(
                highCategories: ref
                    .read(filterProvider)
                    .highCategories
                    .where((cat) => ['nike', 'adidas'].contains(cat))
                    .toList(),
              );
        } else {
          ref.read(filterProvider.notifier).toggleHighCategory(value);
        }
        _resetDiscoverState(ref);
      },
    );
  }

  Widget _buildStyleFilter(WidgetRef ref) {
    return FilterDropdown(
      label: 'Style',
      selectedValues: ref.watch(filterProvider).styles.toSet(),
      items: Categories.styles
          .map((style) => PopupMenuItem(
                value: style,
                child: Text(categoryToDisplayName(style)),
              ))
          .toList(),
      onSelected: (value) {
        if (value.isEmpty) {
          // Reset style filters
          ref.read(filterProvider.notifier).updateFilters(
            styles: [],
          );
        } else {
          ref.read(filterProvider.notifier).toggleStyle(value);
        }
        _resetDiscoverState(ref);
      },
    );
  }
}
