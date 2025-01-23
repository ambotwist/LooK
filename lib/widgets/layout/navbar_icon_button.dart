import 'package:flutter/material.dart';

class NavbarIconButton extends StatelessWidget {
  final IconData icon;
  final bool isSelected;
  final VoidCallback onPressed;
  final Color selectedColor;
  final double size;
  final OverlayPortalController? overlayController;

  const NavbarIconButton({
    super.key,
    required this.icon,
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
        icon,
        color: isSelected ? selectedColor : Colors.grey.shade800,
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
