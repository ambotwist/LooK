import 'dart:math';
import 'package:flutter/material.dart';

/// Contains all animation definitions for the discover section
class DiscoverAnimations {
  /// Private constructor to prevent instantiation
  DiscoverAnimations._();

  /// Duration for card swipe animations
  static const Duration swipeDuration = Duration(milliseconds: 300);

  /// Duration for shake animations
  static const Duration shakeDuration = Duration(milliseconds: 500);

  /// Velocity multiplier for swipe animations
  static const double velocityMultiplier = 0.3;

  /// Position threshold for triggering a swipe (as percentage of screen width/height)
  static const double positionThreshold = 0.4;

  /// Velocity threshold for triggering a swipe (pixels per second)
  static const double velocityThreshold = 1000.0;

  /// Superlike threshold (as percentage of screen height)
  static const double superlikeThreshold = 0.3;

  /// Card rotation factor during drag
  static const double rotationFactor = 0.4;

  /// Perspective value for 3D-like rotation
  static const double perspectiveValue = 0.001;

  /// Base scale for the next card
  static const double nextCardBaseScale = 0.95;

  /// Scale increment for the next card during animation
  static const double nextCardScaleIncrement = 0.05;
}

/// Animation curves for different card interactions
class DiscoverCurves {
  /// Private constructor to prevent instantiation
  DiscoverCurves._();

  /// Curve for returning a card to center
  static const Curve returnToCenterCurve = Curves.easeOutBack;

  /// Curve for swiping a card out
  static const Curve swipeOutCurve = Curves.easeOutQuart;

  /// Get the appropriate curve based on whether the card is returning to center
  static Curve getSwipeCurve(bool isReturningToCenter) {
    return isReturningToCenter ? returnToCenterCurve : swipeOutCurve;
  }
}

/// Animations for the rewind button shake effect
class ShakeAnimation {
  /// Private constructor to prevent instantiation
  ShakeAnimation._();

  /// Number of oscillations in the shake animation
  static const double oscillations = 8.0;

  /// Maximum rotation angle in radians
  static const double maxRotationAngle = 0.1;

  /// Calculate the rotation angle for the shake animation
  static double calculateRotationAngle(double animationValue) {
    return sin(animationValue * pi * oscillations) * maxRotationAngle;
  }

  /// Create a shake animation controller
  static AnimationController createController(TickerProvider vsync) {
    return AnimationController(
      duration: DiscoverAnimations.shakeDuration,
      vsync: vsync,
    );
  }

  /// Trigger the shake animation and reset when complete
  static void triggerShake(AnimationController controller) {
    controller.forward().then((_) => controller.reset());
  }
}

/// Animations for card swiping
class SwipeAnimation {
  /// Private constructor to prevent instantiation
  SwipeAnimation._();

  /// Create a swipe animation controller
  static AnimationController createController(TickerProvider vsync) {
    return AnimationController(
      duration: DiscoverAnimations.swipeDuration,
      vsync: vsync,
    );
  }

  /// Calculate the target offset for a swipe in a specific direction
  static Offset calculateTargetOffset(SwipeDirection direction, Size size) {
    switch (direction) {
      case SwipeDirection.left:
        return Offset(-size.width * 1.5, 0);
      case SwipeDirection.right:
        return Offset(size.width * 1.5, 0);
      case SwipeDirection.up:
        return Offset(0, -size.height * 1.5);
      case SwipeDirection.none:
        return Offset.zero;
    }
  }

  /// Calculate the transform matrix for a card based on its offset
  static Matrix4 calculateCardTransform(Offset offset, Size size) {
    return Matrix4.identity()
      ..setEntry(3, 2, DiscoverAnimations.perspectiveValue) // perspective
      ..translate(
          offset.dx, offset.dy, 1.0) // Ensure it's above background card
      ..rotateZ(offset.dx / size.width * DiscoverAnimations.rotationFactor);
  }
}

/// Animations for the next card reveal effect
class NextCardAnimation {
  /// Private constructor to prevent instantiation
  NextCardAnimation._();

  /// Calculate the opacity of the next card based on the current card's position
  static double calculateOpacity(
      bool isAnimating, double animationValue, Offset dragOffset, Size size) {
    if (!isAnimating && dragOffset == Offset.zero) return 0.0;

    // Calculate based on distance or animation value
    final opacity = (isAnimating
            ? animationValue
            : (dragOffset.distance / (size.width / 2)))
        .clamp(0.0, 1.0);

    return opacity;
  }

  /// Calculate the scale of the next card
  static double calculateScale(
      bool isAnimating, double animationValue, bool isDragging) {
    final showNextCard = isDragging || isAnimating;
    return showNextCard
        ? DiscoverAnimations.nextCardBaseScale +
            (DiscoverAnimations.nextCardScaleIncrement *
                (isAnimating ? animationValue : 0))
        : DiscoverAnimations.nextCardBaseScale;
  }
}

/// Enum for different types of swipe interactions
enum SwipeDirection { left, right, up, none }
