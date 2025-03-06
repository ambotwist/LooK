import 'package:flutter/material.dart';

class CardAnimation {
  Widget buildBackgroundCard({
    required Widget child,
    required bool isDragging,
    required bool isAnimating,
    required Animation<double> animation,
  }) {
    // Only show next card when current card is moving
    final showNextCard = isDragging || isAnimating;
    final scale = showNextCard ? 0.95 + (0.05 * animation.value) : 0.95;

    // Calculate opacity - ensure it's visible when dragging
    final opacity = (isAnimating
            ? animation.value
            : isDragging
                ? 0.8 // Fixed value when dragging to ensure visibility
                : 0.0)
        .clamp(0.0, 1.0);

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 150),
      opacity: opacity,
      child: Transform(
        transform: Matrix4.identity()
          ..translate(0.0, 0.0, 0.0)
          ..scale(scale),
        alignment: Alignment.center,
        child: child,
      ),
    );
  }

  Matrix4 buildCardTransform(Offset offset, Size size) {
    return Matrix4.identity()
      ..setEntry(3, 2, 0.001) // perspective
      ..translate(
          offset.dx, offset.dy, 1.0) // Ensure it's above background card
      ..rotateZ(offset.dx / size.width * 0.4 + offset.dy / size.height * 0.2);
  }
}
