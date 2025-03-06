import 'package:flutter/material.dart';

class SlideAnimation {
  final AnimationController controller;
  final Function(VoidCallback) setState;
  final VoidCallback onCardCompleted;

  Offset dragOffset = Offset.zero;
  Offset? slideOutTween;
  bool isProcessingInteraction = false;
  bool isDragging = false;

  SlideAnimation({
    required this.controller,
    required this.setState,
    required this.onCardCompleted,
  }) {
    controller.addStatusListener(_handleAnimationStatus);
  }

  void _handleAnimationStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      if (slideOutTween != null && slideOutTween != Offset.zero) {
        onCardCompleted();
      }

      setState(() {
        reset();
      });

      controller.reset();
    }
  }

  void reset() {
    dragOffset = Offset.zero;
    slideOutTween = null;
    isProcessingInteraction = false;
    isDragging = false;
  }

  void updateDragOffset(DragUpdateDetails details) {
    if (controller.isAnimating || isProcessingInteraction) return;

    // Set isDragging to true as soon as we detect any movement
    isDragging = true;

    if (dragOffset == Offset.zero) {
      dragOffset = details.delta;
    } else {
      dragOffset += details.delta;
    }
  }

  bool shouldSlideOut(DragEndDetails details, Size size) {
    final dx = dragOffset.dx;
    final velocity = details.velocity;

    // Check if either actual position or velocity-adjusted position exceeds threshold
    const positionThreshold = 0.4;
    const velocityThreshold = 1000.0; // pixels per second

    return dx.abs() > size.width * positionThreshold ||
        velocity.pixelsPerSecond.dx.abs() > velocityThreshold;
  }

  void prepareSlideOut(Size size, bool isLike) {
    slideOutTween = Offset(
      isLike ? size.width * 1.5 : -size.width * 1.5,
      0, // We're not using vertical velocity in this simplified version
    );
    isProcessingInteraction = true;
  }

  void cancelSlideOut() {
    slideOutTween = Offset.zero;
    isProcessingInteraction = false;
    // Don't reset isDragging here to allow the card to animate back smoothly
  }

  void startAnimation() {
    controller.forward();
  }

  Offset getAnimatedOffset(double animationValue) {
    return slideOutTween != null
        ? Offset.lerp(dragOffset, slideOutTween, animationValue)!
        : dragOffset;
  }
}
