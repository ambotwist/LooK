import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lookapp/main/pages/settings/settings_page.dart';
import 'package:lookapp/main/pages/discover/discover_page.dart';
import 'package:lookapp/main/pages/wishlist/wishlist_page.dart';
import 'package:lookapp/providers/discover_provider.dart';
import 'package:lookapp/providers/interactions_provider.dart';
import 'package:lookapp/providers/item_provider.dart';
import 'package:lookapp/providers/overlay_provider.dart';
import 'package:lookapp/providers/user_profile_provider.dart';
import 'package:lookapp/test_page.dart';
import 'package:lookapp/widgets/layout/navbar_icon_button.dart';
import 'package:lookapp/widgets/layout/search_bar.dart';
import 'dart:math';
import 'package:ionicons/ionicons.dart';

class HomeWrapper extends ConsumerStatefulWidget {
  const HomeWrapper({super.key});

  @override
  ConsumerState<HomeWrapper> createState() => _HomeWrapperState();
}

class _HomeWrapperState extends ConsumerState<HomeWrapper>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  final double navbarHeight = 90.0;
  late final List<Widget> _pages;
  late final AnimationController _shakeController;

  @override
  void initState() {
    super.initState();
    _pages = [
      DiscoverPage(navbarHeight: navbarHeight),
      const TestPage(),
      const TestPage(),
      const WishlistPage(),
      const SettingsPage(),
    ];

    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  void _handlePageChange(int index) {
    setState(() => _selectedIndex = index);
  }

  void _handleRewind() async {
    final discoverNotifier = ref.read(discoverProvider.notifier);
    final discoverState = ref.read(discoverProvider);
    final items = ref.read(itemsProvider).asData?.value;

    print(
        'Rewind triggered - Previous indices: ${discoverState.previousIndices}');

    if (discoverState.previousIndices.isEmpty || items == null) {
      print('No previous cards to rewind to');
      _shakeController.forward().then((_) => _shakeController.reset());
      return;
    }

    try {
      // Get the previous item that we're rewinding to
      final previousIndex = discoverState.previousIndices.last;
      final previousItem = items[previousIndex];
      print('Rewinding to item: ${previousItem.id} at index: $previousIndex');

      // Rewind the card immediately for better UX
      discoverNotifier.rewindCard();
      print('Card rewound in UI');

      // Show the action bar if it was hidden
      ref.read(overlayProvider).show();

      // Delete the interaction to reset the card's state
      print('Attempting to delete interaction');
      final success =
          await ref.read(interactionsProvider.notifier).updateInteraction(
                previousItem.id,
                null, // Pass null to delete the interaction
              );
      print('Database update result: $success');

      if (!success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to reset interaction'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e, stackTrace) {
      print('Error during rewind: $e');
      print('Stack trace: $stackTrace');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 42,
        leadingWidth: 100,
        leading: _selectedIndex == 0
            ? null
            : Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'LooK',
                    style: TextStyle(
                      color: theme.primaryColor,
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
        title: Text(
          switch (_selectedIndex) {
            1 => 'Search',
            2 => 'Store',
            3 => 'Wishlist',
            4 => 'Settings',
            _ => '',
          },
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        actions: [
          if (_selectedIndex == 0) ...[
            AnimatedBuilder(
              animation: _shakeController,
              builder: (context, child) {
                final shakeValue = sin(_shakeController.value * pi * 8);
                return Transform.rotate(
                  angle: shakeValue * 0.1,
                  child: child,
                );
              },
              child: IconButton(
                icon: const Icon(Ionicons.arrow_undo, size: 28),
                onPressed: _handleRewind,
              ),
            ),
            Expanded(
                child: Container(
                    constraints: const BoxConstraints(maxWidth: 400),
                    child: const CustomSearchBar(
                      hintText: 'What are you looking for?',
                    ))),
            const SizedBox(width: 8),
            //   IconButton(
            //     icon: const Icon(
            //       Icons.filter_list_rounded,
            //       size: 30,
            //     ),
            //     onPressed: () {
            //       Navigator.push(
            //         context,
            //         MaterialPageRoute(
            //           builder: (context) => FilterPage(
            //             onApplyFilters: (newFilters) {
            //               ref.read(filterProvider.notifier).updateFilters(
            //                     seasons: newFilters.seasons,
            //                     topSizes: newFilters.topSizes,
            //                     shoeSizes: newFilters.shoeSizes,
            //                     bottomSizes: newFilters.bottomSizes,
            //                     highCategories: newFilters.highCategories,
            //                     specificCategories: newFilters.specificCategories,
            //                     colors: newFilters.colors,
            //                     priceRange: newFilters.priceRange,
            //                     styles: newFilters.styles,
            //                   );
            //               ref.invalidate(itemsProvider);
            //               ref.read(discoverProvider.notifier).updateState(
            //                 currentIndex: 0,
            //                 currentImageIndex: 0,
            //                 previousIndices: [],
            //               );
            //               ref.read(overlayProvider).show();
            //             },
            //           ),
            //         ),
            //       );
            //     },
            //   ),
          ],
          // if (_selectedIndex == 3) ...[
          //   IconButton(
          //     icon: const Icon(
          //       Icons.filter_list_rounded,
          //       size: 30,
          //     ),
          //     onPressed: () {
          //       Navigator.push(
          //         context,
          //         MaterialPageRoute(
          //           builder: (context) => FilterPage(
          //             onApplyFilters: (newFilters) {
          //               ref.read(filterProvider.notifier).updateFilters(
          //                     season: newFilters.season,
          //                     sizes: newFilters.sizes,
          //                     highCategories: newFilters.highCategories,
          //                     specificCategories: newFilters.specificCategories,
          //                     colors: newFilters.colors,
          //                     priceRange: newFilters.priceRange,
          //                     styles: newFilters.styles,
          //                   );
          //               ref.invalidate(itemsProvider);
          //               ref.read(wishlistProvider.notifier).updateState(
          //                 currentIndex: 0,
          //                 currentImageIndex: 0,
          //                 previousIndices: [],
          //               );
          //               ref.read(overlayProvider).show();
          //             },
          //           ),
          //         ),
          //       );
          //     },
          //   ),
          // ],
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: IconButton(
              icon: const Icon(
                Ionicons.bag,
                size: 26,
              ),
              onPressed: () {},
            ),
          ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        color: Theme.of(context).bottomNavigationBarTheme.backgroundColor,
        height: navbarHeight,
        padding: const EdgeInsets.only(
          bottom: 20,
          left: 16,
          right: 16,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            NavbarIconButton(
              icon: Ionicons.sparkles_outline,
              selectedIcon: Ionicons.sparkles,
              size: 30,
              isSelected: _selectedIndex == 0,
              selectedColor: theme.primaryColor,
              onPressed: () => _handlePageChange(0),
            ),
            // NavbarIconButton(
            //   icon: Ionicons.search_outline,
            //   selectedIcon: Ionicons.search,
            //   size: 32,
            //   isSelected: _selectedIndex == 1,
            //   selectedColor: theme.primaryColor,
            //   onPressed: () => _handlePageChange(1),
            // ),
            NavbarIconButton(
              icon: Ionicons.compass_outline,
              selectedIcon: Ionicons.compass,
              size: 36,
              isSelected: _selectedIndex == 2,
              selectedColor: theme.primaryColor,
              onPressed: () => _handlePageChange(2),
            ),
            NavbarIconButton(
              icon: Ionicons.bookmark_outline,
              selectedIcon: Ionicons.bookmark,
              size: 32,
              isSelected: _selectedIndex == 3,
              selectedColor: theme.primaryColor,
              onPressed: () => _handlePageChange(3),
            ),
            NavbarIconButton(
              icon: Ionicons.person_outline,
              selectedIcon: Ionicons.person,
              size: 30,
              isSelected: _selectedIndex == 4,
              selectedColor: theme.primaryColor,
              onPressed: () => _handlePageChange(4),
            ),
          ],
        ),
      ),
    );
  }
}
