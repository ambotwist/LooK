import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';

class ActionBar extends StatefulWidget {
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
    required this.screenWidth,
    required this.bigButtonHeight,
    required this.smallButtonHeight,
    this.onDislike,
    this.onLike,
    this.onAddToCart,
  });

  @override
  State<ActionBar> createState() => _ActionBarState();
}

class _ActionBarState extends State<ActionBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback? onTap,
    bool showWhenDragging = true,
    bool isMainAction = false,
    bool scaleOnDragLeft = false,
    bool scaleOnDragRight = false,
  }) {
    final bool isVerticalDominant =
        widget.dragOffset.dy.abs() > widget.dragOffset.dx.abs();

    return ScaleTransition(
      scale: _scaleAnimation,
      child: AnimatedScale(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        scale: (!showWhenDragging && widget.isDragging) ||
                (isMainAction && isVerticalDominant)
            ? 0.0
            : (scaleOnDragLeft && widget.dragOffset.dx < 0) ||
                    (scaleOnDragRight && widget.dragOffset.dx > 0)
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
                size: isMainAction
                    ? widget.bigButtonHeight
                    : widget.smallButtonHeight,
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
      ),
    );
  }

  Color _getBackgroundColor({
    required bool scaleOnDragLeft,
    required bool scaleOnDragRight,
    required Color color,
  }) {
    if ((scaleOnDragLeft && widget.dragOffset.dx < 0) ||
        (scaleOnDragRight && widget.dragOffset.dx > 0)) {
      return color.withOpacity(
        (widget.dragOffset.dx.abs() / (widget.screenWidth / 2)).clamp(0.0, 1.0),
      );
    }
    return Colors.white;
  }

  Color _getIconColor({
    required bool scaleOnDragLeft,
    required bool scaleOnDragRight,
    required Color color,
  }) {
    if ((scaleOnDragLeft && widget.dragOffset.dx < 0) ||
        (scaleOnDragRight && widget.dragOffset.dx > 0)) {
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
        icon: Ionicons.close,
        color: Colors.redAccent,
        onTap: widget.onDislike,
        isMainAction: true,
        scaleOnDragLeft: true));

    addButtonWithSpacing(_buildActionButton(
        icon: Ionicons.bag_add,
        color: const Color(0xFFCF00F4),
        onTap: widget.onAddToCart,
        showWhenDragging: false));

    addButtonWithSpacing(_buildActionButton(
      icon: Ionicons.heart,
      color: const Color.fromARGB(255, 0, 200, 120),
      onTap: widget.onLike,
      isMainAction: true,
      scaleOnDragRight: true,
    ));

    return ScaleTransition(
      scale: _scaleAnimation,
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: buttons,
        ),
      ),
    );
  }
}
