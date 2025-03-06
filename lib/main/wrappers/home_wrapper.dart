import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lookapp/config/look_custom_icons_icons.dart';
import 'package:lookapp/discover/discover_page.dart';
import 'package:lookapp/main/pages/settings/settings_page.dart';
import 'package:lookapp/main/pages/wishlist/wishlist_page.dart';
import 'package:lookapp/providers/connection_provider.dart';
import 'package:lookapp/discover/providers/discover_provider.dart';
import 'package:lookapp/discover/providers/interactions_provider.dart';
import 'package:lookapp/discover/providers/item_provider.dart';
import 'package:lookapp/discover/providers/overlay_provider.dart';
import 'package:lookapp/test_page.dart';
import 'package:lookapp/widgets/layout/navbar_icon_button.dart';
import 'package:lookapp/widgets/layout/look_app_bar.dart';
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

    if (discoverState.previousIndices.isEmpty || items == null) {
      _shakeController.forward().then((_) => _shakeController.reset());
      return;
    }

    try {
      // Get the previous item that we're rewinding to
      final previousIndex = discoverState.previousIndices.last;
      final previousItem = items[previousIndex];

      // Rewind the card immediately for better UX
      discoverNotifier.rewindCard();

      // Show the action bar if it was hidden
      ref.read(overlayProvider).show();

      // Delete the interaction to reset the card's state
      final success =
          await ref.read(interactionsProvider.notifier).updateInteraction(
                previousItem.id,
                null, // Pass null to delete the interaction
              );

      if (!success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to reset interaction'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
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
    final isConnected = ref.watch(connectionProvider);

    return Scaffold(
      appBar: _selectedIndex == 0 && isConnected
          ? null
          : LookAppBar(
              selectedIndex: _selectedIndex,
              isConnected: isConnected,
              onRewind: _selectedIndex == 0 ? _handleRewind : null,
              shakeAnimation: _selectedIndex == 0 ? _shakeController : null,
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
              icon: Look_custom_icons.cards_outline,
              selectedIcon: Look_custom_icons.cards,
              size: 30,
              isSelected: _selectedIndex == 0,
              selectedColor: theme.primaryColor,
              onPressed: () => _handlePageChange(0),
            ),
            NavbarIconButton(
              icon: Ionicons.sparkles_outline,
              selectedIcon: Ionicons.sparkles,
              size: 32,
              isSelected: _selectedIndex == 1,
              selectedColor: theme.primaryColor,
              onPressed: () => _handlePageChange(1),
            ),
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
