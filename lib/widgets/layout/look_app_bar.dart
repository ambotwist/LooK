import 'dart:math';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:lookapp/widgets/layout/search_bar.dart';

class LookAppBar extends StatelessWidget implements PreferredSizeWidget {
  final int selectedIndex;
  final bool isConnected;
  final VoidCallback? onRewind;
  final Animation<double>? shakeAnimation;

  const LookAppBar({
    super.key,
    required this.selectedIndex,
    required this.isConnected,
    this.onRewind,
    this.shakeAnimation,
  });

  @override
  Size get preferredSize => const Size.fromHeight(42);

  String _getTitleForIndex(int index) {
    return switch (index) {
      0 => 'Discover',
      1 => 'Outfitter',
      2 => 'Occasions',
      3 => 'Wishlist',
      4 => 'Settings',
      _ => '',
    };
  }

  Widget? _buildLeading(BuildContext context) {
    if (selectedIndex == 0 && isConnected) return null;

    return Padding(
      padding: const EdgeInsets.only(left: 8.0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          'LooK',
          style: TextStyle(
            color: Theme.of(context).primaryColor,
            fontSize: 26,
            fontWeight: FontWeight.w700,
            letterSpacing: -1,
          ),
        ),
      ),
    );
  }

  List<Widget> _buildActions(BuildContext context) {
    if (selectedIndex == 0 && isConnected) {
      return [
        if (shakeAnimation != null && onRewind != null)
          AnimatedBuilder(
            animation: shakeAnimation!,
            builder: (context, child) {
              final shakeValue = sin(shakeAnimation!.value * 3.14159 * 8);
              return Transform.rotate(
                angle: shakeValue * 0.1,
                child: child,
              );
            },
            child: IconButton(
              icon: const Icon(Ionicons.arrow_undo, size: 28),
              onPressed: onRewind,
            ),
          ),
        Expanded(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            child: const CustomSearchBar(
              hintText: 'What are you looking for?',
            ),
          ),
        ),
        const SizedBox(width: 8),
        _buildShoppingBagButton(),
      ];
    }
    return [_buildShoppingBagButton()];
  }

  Widget _buildShoppingBagButton() {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: IconButton(
        icon: const Icon(
          Ionicons.bag,
          size: 26,
        ),
        onPressed: () {},
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      toolbarHeight: 42,
      leadingWidth: 100,
      leading: _buildLeading(context),
      title: Text(
        _getTitleForIndex(selectedIndex),
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 18,
        ),
      ),
      actions: _buildActions(context),
    );
  }
}
