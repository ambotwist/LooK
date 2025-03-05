import 'package:flutter/material.dart';

/// Enum for different types of swipe interactions
enum SwipeDirection { left, right, up, none }

/// Controller that manages card swipe animations
class SwipeAnimationController {
  final AnimationController animationController;
  final VoidCallback onSwipeComplete;

  bool isProcessingInteraction = false;
  bool isDragging = false;
  Offset dragOffset = Offset.zero;
  Offset? slideOutTween;

  SwipeAnimationController({
    required this.animationController,
    required this.onSwipeComplete,
  }) {
    animationController.addStatusListener(_handleAnimationStatus);
  }

  /// Handle when the user updates their drag/swipe
  void onPanUpdate(DragUpdateDetails details) {
    if (animationController.isAnimating || isProcessingInteraction) return;

    if (!isDragging) {
      isDragging = true;
      dragOffset = details.delta;
    } else {
      dragOffset += details.delta;
    }
  }

  /// Handle when the user ends their drag/swipe
  SwipeDirection onPanEnd(DragEndDetails details, Size size) {
    if (isProcessingInteraction) return SwipeDirection.none;

    final dx = dragOffset.dx;
    final dy = dragOffset.dy;
    final velocity = details.velocity;

    // Check if either actual position or velocity-adjusted position exceeds threshold
    const positionThreshold = 0.4;
    const velocityThreshold = 1000.0; // pixels per second

    // Check for horizontal swipe (like/dislike)
    final isHorizontalSwipe = dx.abs() > size.width * positionThreshold ||
        velocity.pixelsPerSecond.dx.abs() > velocityThreshold;

    // Check for upward swipe (superlike)
    final isUpwardSwipe = dy < -size.height * 0.3 ||
        velocity.pixelsPerSecond.dy < -velocityThreshold;

    SwipeDirection direction = SwipeDirection.none;

    if (isHorizontalSwipe || isUpwardSwipe) {
      isProcessingInteraction = true;

      // Calculate the exit velocity and add it to the tween
      const velocityMultiplier =
          0.3; // Adjust this to control velocity influence

      if (isUpwardSwipe) {
        // For superlike, slide up and out
        slideOutTween = Offset(
          0,
          -size.height * 1.5,
        );
        direction = SwipeDirection.up;
      } else {
        // For like/dislike, slide horizontally
        final isRight = dx > 0;
        slideOutTween = Offset(
          isRight ? size.width * 1.5 : -size.width * 1.5,
          velocity.pixelsPerSecond.dy * velocityMultiplier,
        );
        direction = isRight ? SwipeDirection.right : SwipeDirection.left;
      }
    } else {
      slideOutTween = Offset.zero;
    }

    animationController.forward();
    return direction;
  }

  /// Manually trigger a swipe animation in a specific direction
  void triggerSwipe(SwipeDirection direction, Size size) {
    if (isProcessingInteraction || animationController.isAnimating) return;

    isProcessingInteraction = true;

    switch (direction) {
      case SwipeDirection.left:
        slideOutTween = Offset(-size.width * 1.5, 0);
        break;
      case SwipeDirection.right:
        slideOutTween = Offset(size.width * 1.5, 0);
        break;
      case SwipeDirection.up:
        slideOutTween = Offset(0, -size.height * 1.5);
        break;
      case SwipeDirection.none:
        slideOutTween = Offset.zero;
        isProcessingInteraction = false;
        break;
    }

    if (direction != SwipeDirection.none) {
      animationController.forward();
    }
  }

  /// Reset all animation states
  void reset() {
    dragOffset = Offset.zero;
    slideOutTween = null;
    isProcessingInteraction = false;
    isDragging = false;
  }

  /// Internal handler for animation status changes
  void _handleAnimationStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      if (slideOutTween != null && slideOutTween != Offset.zero) {
        onSwipeComplete();
      }

      reset();
      animationController.reset();
    }
  }

  /// Calculate the card transform based on current animation value
  Matrix4 calculateCardTransform(double animationValue, Size size) {
    final offset = slideOutTween != null
        ? Offset.lerp(dragOffset, slideOutTween, animationValue)!
        : dragOffset;

    return Matrix4.identity()
      ..setEntry(3, 2, 0.001) // perspective
      ..translate(
          offset.dx, offset.dy, 1.0) // Ensure it's above background card
      ..rotateZ(offset.dx / size.width * 0.4);
  }

  /// Calculate the opacity of the next card based on the current card's position
  double calculateNextCardOpacity(bool isAnimating, Size size) {
    if (!isDragging && !isAnimating) return 0.0;

    // Calculate based on distance or animation value
    final opacity = (isAnimating
            ? animationController.value
            : (dragOffset.distance / (size.width / 2)))
        .clamp(0.0, 1.0);

    return opacity;
  }

  /// Calculate the scale of the next card
  double calculateNextCardScale(bool isAnimating) {
    final showNextCard = isDragging || isAnimating;
    return showNextCard
        ? 0.95 + (0.05 * (isAnimating ? animationController.value : 0))
        : 0.95;
  }

  void dispose() {
    animationController.removeStatusListener(_handleAnimationStatus);
  }
}
