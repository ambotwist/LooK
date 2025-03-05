import 'package:flutter/material.dart';
import 'package:lookapp/features/discover/presentation/animations/discover_animations.dart';

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
    final positionThreshold = DiscoverAnimations.positionThreshold;
    final velocityThreshold = DiscoverAnimations.velocityThreshold;

    // Check for horizontal swipe (like/dislike)
    final isHorizontalSwipe = dx.abs() > size.width * positionThreshold ||
        velocity.pixelsPerSecond.dx.abs() > velocityThreshold;

    // Check for upward swipe (superlike)
    final isUpwardSwipe =
        dy < -size.height * DiscoverAnimations.superlikeThreshold ||
            velocity.pixelsPerSecond.dy < -velocityThreshold;

    SwipeDirection direction = SwipeDirection.none;

    if (isHorizontalSwipe || isUpwardSwipe) {
      isProcessingInteraction = true;

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
          velocity.pixelsPerSecond.dy * DiscoverAnimations.velocityMultiplier,
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
    slideOutTween = SwipeAnimation.calculateTargetOffset(direction, size);

    if (direction != SwipeDirection.none) {
      animationController.forward();
    } else {
      isProcessingInteraction = false;
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

    return SwipeAnimation.calculateCardTransform(offset, size);
  }

  /// Calculate the opacity of the next card based on the current card's position
  double calculateNextCardOpacity(bool isAnimating, Size size) {
    return NextCardAnimation.calculateOpacity(
      isAnimating,
      animationController.value,
      dragOffset,
      size,
    );
  }

  /// Calculate the scale of the next card
  double calculateNextCardScale(bool isAnimating) {
    return NextCardAnimation.calculateScale(
      isAnimating,
      animationController.value,
      isDragging,
    );
  }

  void dispose() {
    animationController.removeStatusListener(_handleAnimationStatus);
  }
}
