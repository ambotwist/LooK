import 'package:flutter/material.dart';

class ActionBar extends StatelessWidget {
  final bool isDragging;
  final Offset dragOffset;
  final double screenWidth;
  final double bigButtonHeight;
  final double smallButtonHeight;
  final VoidCallback? onDislike;
  final VoidCallback? onLike;
  final VoidCallback? onAddToCart;

  const ActionBar({
    super.key,
    required this.isDragging,
    required this.dragOffset,
    required this.bigButtonHeight,
    required this.smallButtonHeight,
    required this.screenWidth,
    this.onDislike,
    this.onLike,
    this.onAddToCart,
  });

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback? onTap,
    bool showWhenDragging = true,
    bool isMainAction = false,
    bool scaleOnDragLeft = false,
    bool scaleOnDragRight = false,
  }) {
    final bool isVerticalDominant = dragOffset.dy.abs() > dragOffset.dx.abs();

    return AnimatedScale(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      scale: (!showWhenDragging && isDragging) ||
              (isMainAction && isVerticalDominant)
          ? 0.0
          : (scaleOnDragLeft && dragOffset.dx < 0) ||
                  (scaleOnDragRight && dragOffset.dx > 0)
              ? 1.3
              : 1.0,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(100),
        ),
        child: Container(
          decoration: BoxDecoration(
            color: isMainAction
                ? _getBackgroundColor(
                    scaleOnDragLeft: scaleOnDragLeft,
                    scaleOnDragRight: scaleOnDragRight,
                    color: color,
                  )
                : Colors.white,
            borderRadius: BorderRadius.circular(100),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 4)
            ],
          ),
          child: IconButton(
            onPressed: onTap,
            icon: Icon(
              icon,
              size: isMainAction ? bigButtonHeight : smallButtonHeight,
              color: isMainAction
                  ? _getIconColor(
                      scaleOnDragLeft: scaleOnDragLeft,
                      scaleOnDragRight: scaleOnDragRight,
                      color: color,
                    )
                  : color,
            ),
          ),
        ),
      ),
    );
  }

  Color _getBackgroundColor({
    required bool scaleOnDragLeft,
    required bool scaleOnDragRight,
    required Color color,
  }) {
    if ((scaleOnDragLeft && dragOffset.dx < 0) ||
        (scaleOnDragRight && dragOffset.dx > 0)) {
      return color.withOpacity(
        (dragOffset.dx.abs() / (screenWidth / 2)).clamp(0.0, 1.0),
      );
    }
    return Colors.white;
  }

  Color _getIconColor({
    required bool scaleOnDragLeft,
    required bool scaleOnDragRight,
    required Color color,
  }) {
    if ((scaleOnDragLeft && dragOffset.dx < 0) ||
        (scaleOnDragRight && dragOffset.dx > 0)) {
      return Colors.white;
    }
    return color;
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> buttons = [];

    // Helper to add spacing between buttons
    void addButtonWithSpacing(Widget button) {
      if (buttons.isNotEmpty) {
        buttons.add(const SizedBox(width: 24)); // Fixed spacing of 24 pixels
      }
      buttons.add(button);
    }

    addButtonWithSpacing(_buildActionButton(
        icon: Icons.close_sharp,
        color: Colors.redAccent,
        onTap: onDislike,
        isMainAction: true,
        scaleOnDragLeft: true));

    addButtonWithSpacing(_buildActionButton(
        icon: Icons.add_shopping_cart_rounded,
        color: const Color(0xFFCF00F4),
        onTap: onAddToCart,
        showWhenDragging: false));

    addButtonWithSpacing(_buildActionButton(
      icon: Icons.favorite_sharp,
      color: const Color.fromARGB(255, 0, 200, 120),
      onTap: onLike,
      isMainAction: true,
      scaleOnDragRight: true,
    ));

    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: buttons,
      ),
    );
  }
}
