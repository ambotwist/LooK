import 'package:flutter/material.dart';

class NavbarIconButton extends StatelessWidget {
  final IconData icon;
  final IconData selectedIcon;
  final bool isSelected;
  final VoidCallback onPressed;
  final Color selectedColor;
  final double size;
  final OverlayPortalController? overlayController;

  const NavbarIconButton({
    super.key,
    required this.icon,
    required this.selectedIcon,
    required this.isSelected,
    required this.onPressed,
    required this.selectedColor,
    this.size = 36,
    this.overlayController,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        isSelected ? selectedIcon : icon,
        color: isSelected
            ? selectedColor
            : Theme.of(context).bottomNavigationBarTheme.unselectedItemColor,
        size: size,
      ),
      style: IconButton.styleFrom(
        highlightColor: Colors.transparent,
      ),
      onPressed: () {
        onPressed();
        if (overlayController != null) {
          overlayController!.hide();
        }
      },
    );
  }
}
