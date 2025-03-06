import 'dart:math';
import 'package:flutter/material.dart';

class ShakeAnimation {
  final AnimationController controller;

  ShakeAnimation({required this.controller});

  void shake() {
    controller.forward().then((_) => controller.reset());
  }

  Widget buildShakeAnimatedWidget({required Widget child}) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final shakeValue = sin(controller.value * pi * 8);
        return Transform.rotate(
          angle: shakeValue * 0.1,
          child: child,
        );
      },
      child: child,
    );
  }
}
