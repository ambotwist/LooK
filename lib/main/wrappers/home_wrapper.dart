import 'package:flutter/material.dart';
import 'package:lookapp/main/pages/account/account_page.dart';
import 'package:lookapp/main/pages/discover/discover_page.dart';
import 'package:lookapp/test_page.dart';
import 'package:lookapp/widgets/layout/navbar_icon_button.dart';

class HomeWrapper extends StatefulWidget {
  const HomeWrapper({super.key});

  @override
  State<HomeWrapper> createState() => _HomeWrapperState();
}

class _HomeWrapperState extends State<HomeWrapper> {
  int _selectedIndex = 0;
  final double navbarHeight = 90.0;
  late final List<Widget> _pages;
  final OverlayPortalController overlayPortalController =
      OverlayPortalController();

  @override
  void initState() {
    super.initState();
    _pages = [
      DiscoverPage(
          overlayPortalController: overlayPortalController,
          navbarHeight: navbarHeight),
      const TestPage(),
      const TestPage(),
      const TestPage(),
      const AccountPage(),
    ];
    overlayPortalController.show();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        toolbarHeight: 42,
        leadingWidth: 100,
        leading: Padding(
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
            0 => 'Discover',
            1 => 'Search',
            2 => 'Store',
            3 => 'Wishlist',
            4 => 'Account',
            _ => '',
          },
          style: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          if (_selectedIndex == 0) ...[
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: IconButton(
                icon: const Icon(
                  Icons.fast_rewind_rounded,
                  size: 32,
                ),
                onPressed: () {},
              ),
            )
          ],
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: IconButton(
              icon: const Icon(
                Icons.shopping_basket_rounded,
                size: 30,
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
        color: Colors.white,
        height: navbarHeight,
        padding: const EdgeInsets.only(bottom: 16, left: 16, right: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            NavbarIconButton(
              icon: Icons.home_rounded,
              isSelected: _selectedIndex == 0,
              selectedColor: theme.primaryColor,
              onPressed: () {
                setState(() => _selectedIndex = 0);
                overlayPortalController.show();
              },
            ),
            NavbarIconButton(
              icon: Icons.search_rounded,
              isSelected: _selectedIndex == 1,
              selectedColor: theme.primaryColor,
              onPressed: () => setState(() => _selectedIndex = 1),
              overlayController: overlayPortalController,
            ),
            NavbarIconButton(
              icon: Icons.store_rounded,
              isSelected: _selectedIndex == 2,
              selectedColor: theme.primaryColor,
              onPressed: () => setState(() => _selectedIndex = 2),
              overlayController: overlayPortalController,
            ),
            NavbarIconButton(
              icon: Icons.favorite_rounded,
              isSelected: _selectedIndex == 3,
              selectedColor: theme.primaryColor,
              onPressed: () => setState(() => _selectedIndex = 3),
              overlayController: overlayPortalController,
            ),
            NavbarIconButton(
              icon: Icons.account_circle_rounded,
              isSelected: _selectedIndex == 4,
              selectedColor: theme.primaryColor,
              onPressed: () => setState(() => _selectedIndex = 4),
              overlayController: overlayPortalController,
            ),
          ],
        ),
      ),
    );
  }
}
